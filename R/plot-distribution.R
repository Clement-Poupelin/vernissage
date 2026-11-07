# Distributions ------------------------------------------------------------------------

# Outlier categories (colour-blind safe). The two rules are separate tests, so a
# value is flagged by one, the other or both.
.outlier_colors <- c("None" = "grey25", "MAD" = "#B2182B", "IQR" = "#E69F00", "MAD+IQR" = "#762A83")
.outlier_labels <- c("MAD" = "MAD only", "IQR" = "IQR only", "MAD+IQR" = "MAD and IQR")

#' Same legend keys in every panel, so that patchwork collects one legend per aesthetic
#' @noRd
.fill_guide <- function() {
  ggplot2::guide_legend(override.aes = list(alpha = 0.6, colour = NA, linewidth = 0))
}

#' @noRd
.resolve_type <- function(x, type, discrete_max) {
  if (type != "auto") return(type)
  if (is.factor(x) || is.character(x) || is.logical(x)) return("bar")
  ux <- unique(x[!is.na(x)])
  if (length(ux) <= 2) return("bar")
  integer_valued <- all(abs(ux - round(ux)) < 1e-8)
  if (length(ux) <= discrete_max && integer_valued) return("histogram")
  if (integer_valued && (max(ux) - min(ux)) <= 3 * discrete_max) return("histogram")
  "density"
}

#' @noRd
.apply_display_transform <- function(x, transform) {
  if (is.null(transform)) return(list(x = x, tag = NULL))
  if (is.function(transform)) return(list(x = transform(x), tag = "f"))
  y <- switch(transform,
              log = { x[x <= 0] <- NA; log(x) },
              log10 = { x[x <= 0] <- NA; log10(x) },
              log1p = log1p(x),
              sqrt = sqrt(pmax(x, 0)),
              none = x,
              cli::cli_abort("Unknown {.arg transform} {.val {transform}}."))
  list(x = y, tag = if (transform == "none") NULL else transform)
}

#' Distribution of one or several variables
#'
#' One panel per variable, its type chosen from the data:
#' * continuous: density, jittered points (rug) and an aligned horizontal
#'   boxplot;
#' * discrete (integer scores such as MoCA or UPDRS): histogram with bin width
#'   1 (a smoothed density would invent values);
#' * categorical or binary: bar chart with N and %.
#'
#' Options: groups (from `data` or joined from `metadata`), on-the-fly
#' display transformation, outliers flagged by the MAD and / or IQR rules
#' (see [outlier_flag_mad()], computed on the plotted scale, coloured by the
#' rule that flags them, formulas printed in the caption), a group test in
#' each subtitle (Wilcoxon / Kruskal-Wallis, Welch t / ANOVA, Fisher /
#' chi-squared) and reference lines per variable (LOD, clinical cut-off...).
#'
#' @param data A data frame, tibble or matrix.
#' @param vars Variables to plot (names or tidyselect; default: all but the
#'   identifier and the group).
#' @param group Optional grouping column, in `data` or in `metadata`.
#' @param metadata Optional data frame holding `group`, joined on `id_col`.
#' @param id_col Identifier column (default: row names, or row numbers).
#'   Required with `metadata`.
#' @param labels Optional named vector of labels.
#' @param type `"auto"`, `"density"`, `"histogram"` or `"bar"`, or a named
#'   vector `variable -> type`.
#' @param discrete_max Integer variables with at most this many distinct
#'   values (or a range below three times this value) are drawn as histograms.
#' @param transform `NULL`, `"log"`, `"log10"`, `"log1p"`, `"sqrt"` or a
#'   function, applied for display only.
#' @param outlier_mad,outlier_iqr Flag outliers with the MAD rule and / or
#'   Tukey's rule.
#' @param mad_z_threshold Cut-off of the modified z-score.
#' @param iqr_k Multiplier of the Tukey fences.
#' @param show_points Show the jittered points under the density.
#' @param show_box Add the horizontal boxplot under each panel.
#' @param show_stats Subset of `c("median", "mean")`: vertical lines.
#' @param ref_lines Numeric (every variable) or named list `variable -> values`.
#' @param ref_label Legend text of the reference lines (caption).
#' @param test `"auto"` / `"nonparametric"`, `"parametric"` or `"none"`.
#' @param palette Colours of the groups (see [pal_levels()]).
#' @param fill_color Fill colour without groups.
#' @param value_label X-axis title (default: label of the variable).
#' @param ncol Number of columns of panels.
#' @param base_size Base font size.
#' @param rug_height_pct Height of the jittered points, as a share of the
#'   density peak.
#' @param heights Relative heights of the density and boxplot panels.
#' @param title,subtitle Titles of the whole figure.
#' @param seed Seed of the jitter.
#' @return A patchwork with the attributes `"outliers"` (one row per flagged
#'   value) and `"tests"` (one row per variable with `p_adj_BH`), or `NULL`
#'   when nothing can be plotted.
#' @export
#' @examples
#' p <- plot_distribution(cohort_sim, c(NFL_V0, MOCA_V0, SEX), group = GROUP,
#'                        outlier_mad = TRUE)
#' p
#' attr(p, "tests")
#' plot_distribution(cohort_sim, CRP_V0, transform = "log", ref_lines = list(CRP_V0 = log(5)))
plot_distribution <- function(data, vars = NULL, group = NULL, metadata = NULL, id_col = NULL,
                              labels = NULL, type = "auto", discrete_max = 15, transform = NULL,
                              outlier_mad = FALSE, outlier_iqr = TRUE, mad_z_threshold = 3.5, iqr_k = 1.5,
                              show_points = TRUE, show_box = TRUE, show_stats = c("median"),
                              ref_lines = NULL, ref_label = "reference line",
                              test = c("auto", "nonparametric", "parametric", "none"),
                              palette = NULL, fill_color = "#3B8EA5", value_label = NULL,
                              ncol = 3, base_size = 11, rug_height_pct = 0.08, heights = c(3, 1),
                              title = NULL, subtitle = NULL, seed = 1) {
  test <- match.arg(test)
  if (test == "auto") test <- "nonparametric"
  data <- .as_df(data)
  rn <- rownames(data)
  df <- as.data.frame(data, check.names = FALSE, stringsAsFactors = FALSE)
  id_col <- .select(rlang::enquo(id_col), df, "id_col", single = TRUE)
  pool <- df[0, , drop = FALSE]
  if (!is.null(metadata)) {
    metadata <- as.data.frame(.as_df(metadata, "metadata"))
    for (m in setdiff(names(metadata), names(pool))) pool[[m]] <- metadata[[m]][0]
  }
  group <- .select(rlang::enquo(group), pool, "group", single = TRUE)
  vars <- .select(rlang::enquo(vars), df, "vars") %||% setdiff(names(df), c(id_col, group))
  vars <- setdiff(vars, c(id_col, group))
  if (!length(vars)) {
    cli::cli_inform("No variable to plot.")
    return(invisible(NULL))
  }

  # identifier and group
  has_rn <- !is.null(rn) && !identical(rn, as.character(seq_len(nrow(df))))
  df$.id <- if (!is.null(id_col)) as.character(df[[id_col]]) else if (has_rn) rn else as.character(seq_len(nrow(df)))
  if (!is.null(group)) {
    if (group %in% names(df)) {
      df$.group <- df[[group]]
    } else {
      if (is.null(id_col) || !id_col %in% names(metadata)) {
        cli::cli_abort("{.arg group} is taken from {.arg metadata}: {.arg id_col} must be given and present in both tables.")
      }
      df$.group <- metadata[[group]][match(df$.id, as.character(metadata[[id_col]]))]
    }
    n_na <- sum(is.na(df$.group))
    if (n_na > 0) cli::cli_inform("{n_na} row(s) without group removed.")
    df <- df[!is.na(df$.group), , drop = FALSE]
    df$.group <- droplevels(as.factor(df$.group))
  }
  has_group <- ".group" %in% names(df)

  pal <- if (has_group) pal_levels(levels(df$.group), palette) else NULL
  show_outlier <- outlier_mad || outlier_iqr
  out_levels <- c(if (outlier_mad) "MAD", if (outlier_iqr) "IQR", if (outlier_mad && outlier_iqr) "MAD+IQR")
  out_labels <- if (outlier_mad && outlier_iqr) .outlier_labels[out_levels] else
    c(MAD = "MAD rule", IQR = "IQR rule (Tukey)")[out_levels]
  out_scale <- function() {
    ggplot2::scale_colour_manual(
      values = .outlier_colors[out_levels], limits = out_levels, labels = out_labels, name = "Outlier", drop = FALSE,
      guide = ggplot2::guide_legend(override.aes = list(colour = unname(.outlier_colors[out_levels]), size = 2.5, alpha = 1)))
  }
  all_outliers <- list()
  all_tests <- list()
  th <- function() {
    theme_pub(base_size) +
      ggplot2::theme(legend.position = "bottom",
                     plot.subtitle = ggplot2::element_text(size = base_size - 2, colour = "#5D6D7E", hjust = 0))
  }
  grp_lab <- if (has_group) label_get(group, labels) else NULL
  jitter <- function(h) ggplot2::position_jitter(width = 0, height = h, seed = seed)

  one_var <- function(v) {
    lab <- label_get(v, labels)
    x_raw <- df[[v]]
    tp <- if (!is.null(names(type))) { if (v %in% names(type)) type[[v]] else "auto" } else type[1]
    tp <- .resolve_type(x_raw, tp, discrete_max)
    refs <- if (is.list(ref_lines)) ref_lines[[v]] else ref_lines

    # categorical / binary: bar chart
    if (tp == "bar") {
      d <- tibble::tibble(.id = df$.id, val = x_raw, .group = if (has_group) df$.group else NA)
      n_na <- sum(is.na(d$val))
      d <- d[!is.na(d$val), ]
      d$val <- factor(d$val)
      tst <- if (has_group) .group_test(d$val, d$.group, "categorical", test) else NULL
      if (!is.null(tst)) all_tests[[v]] <<- tibble::tibble(Variable = v, Test = tst$name, p = tst$p)
      cnt <- if (has_group) dplyr::count(d, .group, val) else dplyr::count(d, val)
      cnt <- if (has_group) dplyr::mutate(cnt, pct = 100 * n / sum(n), .by = ".group") else dplyr::mutate(cnt, pct = 100 * n / sum(n))
      cnt$.panel <- lab
      p <- ggplot2::ggplot(cnt, ggplot2::aes(x = val, y = n)) + ggplot2::facet_wrap(~ .panel)
      p <- if (has_group) {
        p + ggplot2::geom_col(ggplot2::aes(fill = .group), position = ggplot2::position_dodge(0.85),
                              width = 0.8, alpha = 0.85, colour = "white", key_glyph = "rect") +
          ggplot2::geom_text(ggplot2::aes(label = sprintf("%d\n(%.0f%%)", n, pct), group = .group),
                             position = ggplot2::position_dodge(0.85), vjust = -0.2,
                             size = base_size / 4, lineheight = 0.85) +
          ggplot2::scale_fill_manual(values = pal, name = grp_lab, guide = .fill_guide())
      } else {
        p + ggplot2::geom_col(fill = fill_color, width = 0.7, alpha = 0.85) +
          ggplot2::geom_text(ggplot2::aes(label = sprintf("%d (%.0f%%)", n, pct)), vjust = -0.4, size = base_size / 4)
      }
      sub <- .u(paste0("N = ", nrow(d), if (n_na) paste0(" (missing = ", n_na, ")") else "",
                    if (!is.null(tst)) sprintf("  |  %s p = %s %s", tst$name, fmt_p(tst$p), fmt_stars(tst$p)) else ""))
      return(p + ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.25))) +
               ggplot2::labs(x = NULL, y = "Count", subtitle = sub) + th())
    }

    # numeric: density or histogram
    tr <- .apply_display_transform(as.numeric(x_raw), transform)
    x <- tr$x
    xlab <- value_label %||% (if (is.null(tr$tag)) lab else paste0(tr$tag, "(", lab, ")"))
    m <- if (outlier_mad) outlier_flag_mad(x, mad_z_threshold) else rep(FALSE, length(x))
    m[is.na(m)] <- FALSE
    i <- if (outlier_iqr) outlier_flag_iqr(x, iqr_k) else rep(FALSE, length(x))
    i[is.na(i)] <- FALSE
    d <- tibble::tibble(.id = df$.id, val = x, is_mad = m, is_iqr = i,
                        .group = if (has_group) df$.group else factor("All"))
    d$outlier_cat <- ifelse(d$is_mad & d$is_iqr, "MAD+IQR", ifelse(d$is_mad, "MAD", ifelse(d$is_iqr, "IQR", "None")))
    n_na <- sum(is.na(d$val))
    d <- d[!is.na(d$val), ]
    if (nrow(d) < 3) return(NULL)
    d$.panel <- lab
    tst <- if (has_group) .group_test(d$val, d$.group, "continuous", test) else NULL
    if (!is.null(tst)) all_tests[[v]] <<- tibble::tibble(Variable = v, Test = tst$name, p = tst$p)

    # height of the rug, as a share of the panel's density peak
    peak <- if (tp == "histogram") {
      max(vapply(split(d$val, d$.group), function(z) if (length(z)) max(table(round(z))) / length(z) else 0, numeric(1)))
    } else {
      max(vapply(split(d$val, d$.group), function(z) if (length(unique(z)) > 1) max(stats::density(z)$y) else 0, numeric(1)))
    }
    if (!is.finite(peak) || peak <= 0) peak <- 1
    jit_h <- peak * rug_height_pct
    d$.y0 <- -(as.integer(d$.group) - 1) * 2.4 * jit_h - (if (has_group) jit_h else 0)
    out_tab <- d[d$outlier_cat != "None", , drop = FALSE]
    if (nrow(out_tab)) {
      all_outliers[[v]] <<- tibble::tibble(id = out_tab$.id, Variable = v, Value = out_tab$val,
                                           MAD = out_tab$is_mad, IQR = out_tab$is_iqr)
    }
    xr <- range(c(d$val, refs), na.rm = TRUE)
    xr <- xr + c(-1, 1) * 0.04 * diff(xr)

    p <- ggplot2::ggplot(d, ggplot2::aes(x = val)) + ggplot2::facet_wrap(~ .panel)
    if (tp == "histogram") {
      p <- if (has_group) {
        p + ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density), fill = .group),
                                    binwidth = 1, center = 0, position = "identity",
                                    alpha = 0.45, colour = "white", linewidth = 0.2, key_glyph = "rect")
      } else {
        p + ggplot2::geom_histogram(ggplot2::aes(y = ggplot2::after_stat(density)), binwidth = 1,
                                    center = 0, fill = fill_color, alpha = 0.7, colour = "white")
      }
      ylab <- "Proportion"
    } else {
      p <- if (has_group) {
        p + ggplot2::geom_density(ggplot2::aes(fill = .group), colour = "grey30", alpha = 0.45,
                                  linewidth = 0.4, key_glyph = "rect")
      } else {
        p + ggplot2::geom_density(fill = fill_color, colour = "grey25", alpha = 0.5, linewidth = 0.5)
      }
      ylab <- "Density"
    }
    if (has_group) p <- p + ggplot2::scale_fill_manual(values = pal, name = grp_lab, guide = .fill_guide())

    if (length(show_stats)) {
      st <- dplyr::summarise(d, median = stats::median(val), mean = mean(val), .by = ".group")
      for (s in intersect(show_stats, c("median", "mean"))) {
        # column copied before aes(): aes(.data[[s]]) would be evaluated lazily with the last s
        st_s <- data.frame(xint = st[[s]], .group = st$.group)
        p <- p + ggplot2::geom_vline(data = st_s, ggplot2::aes(xintercept = xint),
                                     colour = if (has_group) unname(pal[as.character(st_s$.group)]) else "grey20",
                                     linetype = if (s == "median") "dashed" else "solid", linewidth = 0.6)
      }
    }
    if (length(refs)) {
      p <- p + ggplot2::geom_vline(xintercept = refs, colour = "#D55E00", linetype = "dotdash", linewidth = 0.7)
    }
    if (show_points) {
      normal <- d[d$outlier_cat == "None", , drop = FALSE]
      p <- p + ggplot2::geom_point(data = normal, ggplot2::aes(y = .y0), position = jitter(jit_h),
                                   colour = if (has_group) unname(pal[as.character(normal$.group)]) else "grey25",
                                   shape = 16, size = 1, alpha = 0.6)
    }
    if (show_outlier && nrow(out_tab)) {
      # show.legend = TRUE: since ggplot2 3.5 a layer draws no key for a level absent from its data
      p <- p + ggplot2::geom_point(data = out_tab, ggplot2::aes(y = .y0, colour = outlier_cat), show.legend = TRUE,
                                   position = jitter(jit_h), size = 1.8, alpha = 0.9) +
        out_scale()
    }
    parts <- paste0("N = ", nrow(d), if (n_na) paste0(" (missing = ", n_na, ")") else "")
    if (outlier_mad) parts <- c(parts, sprintf("MAD: %d", sum(d$is_mad)))
    if (outlier_iqr) parts <- c(parts, sprintf("IQR: %d", sum(d$is_iqr)))
    if (!is.null(tst)) parts <- c(parts, sprintf("%s p = %s %s", tst$name, fmt_p(tst$p), fmt_stars(tst$p)))
    p <- p + ggplot2::coord_cartesian(xlim = xr) +
      ggplot2::labs(x = if (show_box) NULL else xlab, y = ylab, subtitle = .u(paste(parts, collapse = "  |  "))) + th()
    if (!show_box) return(p)
    p <- p + ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank())

    b <- ggplot2::ggplot(d, ggplot2::aes(x = .group, y = val))
    b <- if (has_group) {
      b + ggplot2::geom_boxplot(ggplot2::aes(fill = .group), alpha = 0.5, colour = "grey30", outlier.shape = NA,
                                width = 0.6, key_glyph = "rect") +
        ggplot2::scale_fill_manual(values = pal, name = grp_lab, guide = .fill_guide())
    } else {
      b + ggplot2::geom_boxplot(fill = fill_color, alpha = 0.5, colour = "grey30", outlier.shape = NA, width = 0.5)
    }
    b <- b + ggplot2::stat_summary(fun = mean, geom = "point", shape = 23, size = 1.8, fill = "white", colour = "grey20")
    if (show_outlier && nrow(out_tab)) {
      b <- b + ggplot2::geom_point(data = out_tab, ggplot2::aes(colour = outlier_cat), size = 1.8, alpha = 0.9,
                                   show.legend = TRUE) +
        out_scale()
    }
    if (length(refs)) {
      b <- b + ggplot2::geom_hline(yintercept = refs, colour = "#D55E00", linetype = "dotdash", linewidth = 0.7)
    }
    b <- b + ggplot2::coord_flip(ylim = xr) + ggplot2::labs(x = NULL, y = xlab) + th() +
      ggplot2::theme(axis.text.y = if (has_group) ggplot2::element_text(size = base_size - 2) else ggplot2::element_blank(),
                     axis.ticks.y = ggplot2::element_blank())
    patchwork::wrap_plots(p, b, ncol = 1, heights = heights)
  }

  plots <- lapply(vars, one_var)
  plots <- plots[!vapply(plots, is.null, logical(1))]
  if (!length(plots)) return(invisible(NULL))

  caption <- paste(c(
    if ("median" %in% show_stats) "dashed line = median",
    if ("mean" %in% show_stats) "solid line = mean",
    if (show_box) "\u25c7 = mean (boxplot)",
    if (show_outlier) "coloured points = outliers, computed on the plotted scale:",
    if (!is.null(ref_lines)) paste0("orange dot-dash = ", ref_label)
  ), collapse = " | ")
  rules <- c(
    if (outlier_iqr) sprintf("IQR rule (Tukey): x < Q1 - %g x IQR  or  x > Q3 + %g x IQR,  with IQR = Q3 - Q1", iqr_k, iqr_k),
    if (outlier_mad) sprintf("MAD rule (Iglewicz & Hoaglin): |modified z| = |0.6745 x (x - median) / MAD| > %g,  with MAD = median(|x - median|)",
                             mad_z_threshold))
  if (show_outlier) caption <- paste(c(caption, rules), collapse = "\n")
  caption <- .u(caption)

  out <- patchwork::wrap_plots(plots, ncol = min(ncol, length(plots))) +
    patchwork::plot_layout(guides = "collect") +
    patchwork::plot_annotation(title = title, subtitle = subtitle,
                               caption = if (nzchar(caption)) caption else NULL, theme = theme_pub(base_size)) &
    ggplot2::theme(legend.position = "bottom")
  tests <- dplyr::bind_rows(all_tests)
  if (nrow(tests)) tests$p_adj_BH <- stats::p.adjust(tests$p, "BH")
  attr(out, "outliers") <- dplyr::bind_rows(all_outliers)
  attr(out, "tests") <- tests
  out
}

#' Overlaid standardised densities of a block of variables
#'
#' One density per variable (z-scores by default), coloured by the absolute
#' skewness, with the pooled density as a dashed black curve: a quick look at
#' the shapes of many variables.
#'
#' @param data A data frame.
#' @param vars Numeric variables (names or tidyselect).
#' @param labels Optional named vector of labels.
#' @param group Optional grouping column: one panel per group.
#' @param scale Standardise each variable (z-scores).
#' @param base_size Base font size.
#' @param title Title.
#' @param highlight_skew Absolute skewness above which a density is
#'   highlighted.
#' @return A ggplot.
#' @export
#' @examples
#' plot_distribution_overview(cohort_sim, c(AGE, BMI, NFL_V0, IL6_V0, CRP_V0, MOCA_V0))
plot_distribution_overview <- function(data, vars, labels = NULL, group = NULL, scale = TRUE,
                                       base_size = 11, title = NULL, highlight_skew = 1) {
  df <- as.data.frame(.as_df(data))
  vars <- .select(rlang::enquo(vars), df, "vars")
  group <- .select(rlang::enquo(group), df, "group", single = TRUE)
  long <- dplyr::bind_rows(lapply(vars, function(v) {
    x <- df[[v]]
    if (!is.numeric(x)) return(NULL)
    z <- if (scale) (x - mean(x, na.rm = TRUE)) / stats::sd(x, na.rm = TRUE) else x
    tibble::tibble(Variable = label_get(v, labels), val = z,
                   .group = if (!is.null(group)) as.character(df[[group]]) else "All",
                   skewed = ifelse(isTRUE(abs(.skewness(x)) > highlight_skew), "asym", "sym"))
  }))
  if (!nrow(long)) cli::cli_abort("No numeric variable in {.arg vars}.")
  long <- long[!is.na(long$val) & !is.na(long$.group), , drop = FALSE]
  p <- ggplot2::ggplot(long, ggplot2::aes(x = val, group = Variable)) +
    ggplot2::geom_density(ggplot2::aes(colour = skewed), linewidth = 0.5) +
    ggplot2::geom_density(ggplot2::aes(group = 1), colour = "black", linewidth = 1.2, linetype = "dashed") +
    ggplot2::scale_colour_manual(values = c(sym = "#56B4E9", asym = "#D55E00"),
                                 labels = c(sym = .u(sprintf("|skewness| \u2264 %s", highlight_skew)),
                                            asym = sprintf("|skewness| > %s", highlight_skew)), name = NULL) +
    ggplot2::labs(title = title %||% "Distribution overview",
                  subtitle = sprintf("%d variables | dashed black curve = pooled density%s",
                                     dplyr::n_distinct(long$Variable), if (scale) " | z-scores" else ""),
                  x = if (scale) "Standardised value (z)" else "Value", y = "Density") +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom")
  if (!is.null(group)) p <- p + ggplot2::facet_wrap(~ .group)
  p
}
