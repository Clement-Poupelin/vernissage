# Radar (spider) plot ---------------------------------------------------------------------

#' Radar plot comparing groups on several variables
#'
#' Each numeric variable gives one axis (mean or median per group); each
#' categorical variable gives one or several axes (proportion of a level per
#' group). Every value is brought to a 0-100% scale (configurable
#' normalisation) with an optional confidence band. A between-group test per
#' axis (Wilcoxon / Kruskal-Wallis / t / ANOVA / chi-squared / Fisher), with a
#' multiplicity correction, adds stars or p-values to the labels.
#'
#' The plot is drawn in Cartesian coordinates (not `coord_polar()`): profiles
#' are straight-sided polygons and the grid is circular or polygonal.
#'
#' @param data Wide data frame, one row per subject.
#' @param vars Variables on the radar (names or tidyselect). Numeric:
#'   quantitative axes; factor / character / logical: proportions.
#' @param group Grouping column (`NULL`: one profile).
#' @param group_levels Order of the groups.
#' @param group_labels Renaming of the groups (named `old = new`, or unnamed
#'   in level order).
#' @param labels Axis labels: named vector (variable name, or
#'   `"variable:level"` for a categorical axis) or unnamed vector of one label
#'   per axis.
#' @param var_order Order of the axes (variable names, axis ids or labels),
#'   starting at `start_angle`; axes not listed follow.
#' @param reverse Variables reversed (1 - x), e.g. when "higher = better" for
#'   some scales and not others.
#' @param force_quali Numeric variables treated as categorical (e.g. 0/1).
#' @param quali_levels Named list: level(s) shown for each categorical
#'   variable, e.g. `list(SEX = "Female")`. Default: `TRUE` for a logical, the
#'   2nd level of a binary variable, every level otherwise.
#' @param quali_expand If `FALSE`, a variable with more than 2 levels and no
#'   `quali_levels` gives a single axis (1st level).
#' @param quali_sep Separator of the `"variable : level"` labels.
#' @param stat `"mean"` or `"median"`.
#' @param ci Draw the confidence band.
#' @param ci_level Level of the confidence band.
#' @param ci_method `"t"` (Student CI), `"boot"` (percentile bootstrap),
#'   `"se"` (+/- 1 SE) or `"sd"` (+/- 1 SD). For the median, `"t"` and `"se"`
#'   switch to `"boot"`. Proportions always use the Wilson CI.
#' @param n_boot Number of bootstrap resamples.
#' @param seed Seed of the bootstrap and simulated Fisher tests (`NULL`: the
#'   current random state is used; with a seed, the random state is restored
#'   afterwards).
#' @param normalize `"minmax"` (individual data), `"quantile"` (same on the
#'   `quantile_probs` quantiles, robust to extremes), `"summary"` (min-max of
#'   the group summaries), `"zscore"` (SD units around the mean of
#'   `reference`, 50% = reference mean, edges = `z_range` SD; recommended when
#'   group differences are small compared with the range), `"rank"`
#'   (percentile ranks of the subjects, all groups pooled, then mean per
#'   group) or `"none"` (data assumed in \[0, 1\]).
#' @param limits Named list of fixed bounds per variable, with priority, e.g.
#'   `list(MOCA_V0 = c(0, 30))` (advised for bounded clinical scales).
#' @param reference Reference group of `normalize = "zscore"` (`NULL`: all
#'   subjects).
#' @param z_range Range shown in SD units for `"zscore"`.
#' @param quantile_probs Bounds of `normalize = "quantile"`.
#' @param normalize_quali Normalise the proportions too (`FALSE`: shown as is,
#'   0-100%).
#' @param clip Clip the normalised values to \[0, 1\].
#' @param test Quantitative axes: `"auto"` (Wilcoxon with 2 groups,
#'   Kruskal-Wallis otherwise), `"wilcox"`, `"kruskal"`, `"t"` (Welch t /
#'   Welch ANOVA), `"anova"` or `"none"`.
#' @param test_quali Categorical axes: `"auto"` (chi-squared, or Fisher with
#'   expected counts < 5), `"chisq"`, `"fisher"` or `"none"`.
#' @param p_adjust Method of [stats::p.adjust()].
#' @param show_signif Add the significance to the labels.
#' @param p_values P-values computed elsewhere (named by variable or axis id),
#'   e.g. paired tests between visits; they replace `test` and `test_quali`
#'   (`p_adjust` is applied to them).
#' @param test_label Name of the test of `p_values`, for the caption.
#' @param signif_format `"stars"`, `"p"` or `"both"`.
#' @param signif_cutpoints,signif_symbols Cut-points and symbols of the stars
#'   (`length(signif_symbols) == length(signif_cutpoints) + 1`, the last
#'   symbol meaning "not significant").
#' @param p_digits Decimals of the p-values shown.
#' @param start_angle Angle of the first axis, in degrees (90 = top).
#' @param clockwise Direction of the axes.
#' @param inner_radius Radius of the central hole (0 to < 1), so that small
#'   values are not squashed at the centre.
#' @param grid_levels Levels of the grid circles, on \[0, 1\].
#' @param grid_shape `"circle"` or `"polygon"` (spider web).
#' @param grid_colour,grid_linewidth,grid_linetype Style of the grid.
#' @param spoke_colour,spoke_linewidth Style of the spokes.
#' @param background_fill Fill of the disc (`NA`: none).
#' @param show_grid_labels Print the grid levels.
#' @param grid_label_fmt Function formatting the grid levels (`NULL`:
#'   automatic, %, SD for `"zscore"`, percentiles for `"rank"`).
#' @param grid_label_angle Angle where the grid levels are printed (default:
#'   `start_angle`).
#' @param grid_label_size,grid_label_colour Style of the grid levels.
#' @param palette Palette of the groups (see [pal_levels()]); default
#'   `"okabe"`.
#' @param colours Explicit colours (named by group or not), with priority.
#' @param line_width Width of the profiles.
#' @param linetypes Line types per group (`NULL`: solid).
#' @param point_size Size of the points.
#' @param point_shape Shape of the points (one value, or one per group).
#' @param show_points Draw the points.
#' @param band_alpha Transparency of the confidence band.
#' @param fill_alpha Fill of the profile areas (0 = none).
#' @param show_values Print the raw (non-normalised) value at each point.
#' @param value_digits,value_size Format of the values printed.
#' @param label_size,label_colour,label_fontface Style of the axis labels.
#' @param label_offset Distance between the labels and the outer circle.
#' @param label_wrap Width (characters) for wrapping the labels (`NULL`: no
#'   wrapping).
#' @param label_lineheight Line height of multi-line labels.
#' @param title,subtitle Titles.
#' @param caption `NULL` = automatic caption (tests and CI), `FALSE` = none,
#'   or a text.
#' @param legend_title Title of the legend (default: name of `group`).
#' @param legend_position `"bottom"`, `"right"`, `"top"`, `"left"` or
#'   `"none"`.
#' @param legend_nrow Number of rows of the legend.
#' @param show_legend `NULL` = automatic (hidden with a single group).
#' @param base_size,base_family Base font size and family.
#' @param title_size,caption_size Sizes of the title and caption.
#' @param plot_margin Margins `c(top, right, bottom, left)` in points.
#' @param expand_x,expand_y Space around the radar for the labels.
#' @param return_data `TRUE`: return `list(plot, summary, tests)`.
#' @return A ggplot (the tables are in `attr(p, "radar_data")`), or a list
#'   when `return_data = TRUE`.
#' @export
#' @examples
#' plot_radar(cohort_sim, c(AGE, BMI, NFL_V0, IL6_V0, MOCA_V0, UPDRS_V0, SEX),
#'            group = GROUP, normalize = "zscore", quali_levels = list(SEX = "Female"))
plot_radar <- function(
    data, vars,
    group = NULL, group_levels = NULL, group_labels = NULL,
    labels = NULL, var_order = NULL, reverse = NULL, force_quali = NULL,
    quali_levels = NULL, quali_expand = TRUE, quali_sep = " : ",
    stat = c("mean", "median"), ci = TRUE, ci_level = 0.95,
    ci_method = c("t", "boot", "se", "sd"), n_boot = 1000, seed = NULL,
    normalize = c("minmax", "quantile", "summary", "zscore", "rank", "none"), limits = NULL,
    reference = NULL, z_range = c(-1, 1),
    quantile_probs = c(0.025, 0.975), normalize_quali = FALSE, clip = TRUE,
    test = c("auto", "wilcox", "kruskal", "t", "anova", "none"),
    test_quali = c("auto", "chisq", "fisher", "none"),
    p_adjust = "BH", show_signif = TRUE, p_values = NULL, test_label = NULL,
    signif_format = c("stars", "p", "both"),
    signif_cutpoints = c(0.001, 0.01, 0.05, 0.10),
    signif_symbols = c("***", "**", "*", ".", "ns"), p_digits = 3,
    start_angle = 90, clockwise = TRUE, inner_radius = 0,
    grid_levels = c(0.25, 0.50, 0.75, 1), grid_shape = c("circle", "polygon"),
    grid_colour = "grey82", grid_linewidth = 0.4, grid_linetype = "solid",
    spoke_colour = "grey70", spoke_linewidth = 0.4, background_fill = NA,
    show_grid_labels = TRUE, grid_label_fmt = NULL,
    grid_label_angle = NULL, grid_label_size = 3.3, grid_label_colour = "grey55",
    palette = "okabe", colours = NULL, line_width = 1.1, linetypes = NULL,
    point_size = 2.8, point_shape = 19, show_points = TRUE,
    band_alpha = 0.20, fill_alpha = 0,
    show_values = FALSE, value_digits = 1, value_size = 3,
    label_size = 4.2, label_colour = "#2C3E50", label_fontface = "bold",
    label_offset = 0.10, label_wrap = NULL, label_lineheight = 0.9,
    title = NULL, subtitle = NULL, caption = NULL, legend_title = NULL,
    legend_position = "bottom", legend_nrow = NULL, show_legend = NULL,
    base_size = 13, base_family = "", title_size = NULL, caption_size = 9,
    plot_margin = c(10, 20, 10, 20), expand_x = 0.65, expand_y = 0.20,
    return_data = FALSE) {

  stat <- match.arg(stat)
  ci_method <- match.arg(ci_method)
  normalize <- match.arg(normalize)
  test <- match.arg(test)
  test_quali <- match.arg(test_quali)
  signif_format <- match.arg(signif_format)
  grid_shape <- match.arg(grid_shape)
  if (is.null(grid_label_fmt)) {
    grid_label_fmt <- switch(normalize,
      zscore = function(x) sprintf("%+.2g SD", z_range[1] + x * diff(z_range)),
      rank = function(x) paste0("P", round(100 * x)),
      function(x) paste0(round(100 * x), "%"))
  }

  # 0. checks
  data <- as.data.frame(.as_df(data), stringsAsFactors = FALSE)
  vars <- .select(rlang::enquo(vars), data, "vars")
  group <- .select(rlang::enquo(group), data, "group", single = TRUE)
  if (length(signif_symbols) != length(signif_cutpoints) + 1) {
    cli::cli_abort("{.arg signif_symbols} must have {.code length(signif_cutpoints) + 1} elements.")
  }
  if (inner_radius < 0 || inner_radius >= 1) cli::cli_abort("{.arg inner_radius} must be in [0, 1).")
  if (!is.null(seed)) {
    withr::local_seed(seed)
  }

  # 1. groups
  if (is.null(group)) {
    g <- factor(rep("All", nrow(data)))
  } else {
    g <- data[[group]]
    g <- if (!is.null(group_levels)) factor(g, levels = group_levels) else as.factor(g)
  }
  keep <- !is.na(g)
  data <- data[keep, , drop = FALSE]
  g <- droplevels(g[keep])
  if (!is.null(group_labels)) {
    if (is.null(names(group_labels))) {
      if (length(group_labels) != nlevels(g)) cli::cli_abort("{.arg group_labels}: one label per group needed.")
      levels(g) <- as.character(group_labels)
    } else {
      lv <- levels(g)
      levels(g) <- ifelse(lv %in% names(group_labels), unname(group_labels[lv]), lv)
    }
  }
  grp_names <- levels(g)
  k <- length(grp_names)
  if (is.null(show_legend)) show_legend <- k > 1
  if (is.null(legend_title)) legend_title <- group %||% ""

  # 2. axes (numeric -> 1 axis; categorical -> 1 axis per level)
  axes <- list()
  for (v in vars) {
    x <- data[[v]]
    if (is.numeric(x) && !(v %in% force_quali)) {
      if (normalize == "rank") x <- rank(x, na.last = "keep") / sum(!is.na(x))
      axes[[length(axes) + 1]] <- list(id = v, var = v, type = "quanti", level = NA_character_,
                                       x = as.numeric(x), lab = v)
    } else {
      f <- if (is.logical(x)) factor(x, levels = c(FALSE, TRUE)) else as.factor(x)
      lv <- if (!is.null(quali_levels[[v]])) as.character(quali_levels[[v]])
        else if (is.logical(x)) "TRUE"
        else if (nlevels(f) == 2) levels(f)[2]
        else if (quali_expand) levels(f)
        else levels(f)[1]
      bad <- setdiff(lv, levels(f))
      if (length(bad)) cli::cli_abort("Level(s) {.val {bad}} not found in {.field {v}}.")
      for (l in lv) {
        axes[[length(axes) + 1]] <- list(
          id = paste0(v, ":", l), var = v, type = "quali", level = l,
          x = ifelse(is.na(f), NA_real_, as.numeric(f == l)),
          lab = if (is.logical(x)) v else paste0(v, quali_sep, l))
      }
    }
  }
  ids <- vapply(axes, `[[`, "", "id")
  ax_vars <- vapply(axes, `[[`, "", "var")
  ax_types <- vapply(axes, `[[`, "", "type")
  lab <- vapply(axes, `[[`, "", "lab")
  n_ax <- length(axes)
  if (n_ax < 3) cli::cli_warn("Fewer than 3 axes: a radar plot is hard to read.")

  if (!is.null(labels)) {
    if (is.null(names(labels))) {
      if (length(labels) != n_ax) cli::cli_abort("Unnamed {.arg labels}: {n_ax} labels needed (one per axis).")
      lab <- as.character(labels)
    } else {
      for (i in seq_len(n_ax)) {
        if (ids[i] %in% names(labels)) {
          lab[i] <- labels[[ids[i]]]
        } else if (ax_vars[i] %in% names(labels) && sum(ax_vars == ax_vars[i]) == 1) {
          lab[i] <- labels[[ax_vars[i]]]
        }
      }
    }
  }
  pos <- seq_len(n_ax)
  if (!is.null(var_order)) {
    o <- unlist(lapply(var_order, function(z) which(ids == z | ax_vars == z | lab == z)))
    o <- unique(c(o, seq_len(n_ax)))
    pos[o] <- seq_len(n_ax)
  }
  rev_flag <- ids %in% reverse | ax_vars %in% reverse

  # 3. internal functions
  wilson <- function(s, n, conf) {
    z <- stats::qnorm(1 - (1 - conf) / 2)
    p <- s / n
    den <- 1 + z^2 / n
    ctr <- (p + z^2 / (2 * n)) / den
    h <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / den
    c(ctr - h, ctr + h)
  }
  summarise_axis <- function(x, type) {
    x <- x[!is.na(x)]
    n <- length(x)
    if (n == 0) return(c(est = NA, ci_lo = NA, ci_hi = NA, n = 0))
    if (type == "quali") {
      civ <- if (ci) wilson(sum(x), n, ci_level) else c(NA, NA)
      return(c(est = mean(x), ci_lo = civ[1], ci_hi = civ[2], n = n))
    }
    f <- if (stat == "mean") mean else stats::median
    est <- f(x)
    if (!ci || n < 2) return(c(est = est, ci_lo = NA, ci_hi = NA, n = n))
    a <- 1 - ci_level
    cm <- if (stat == "median" && ci_method %in% c("t", "se")) "boot" else ci_method
    civ <- switch(cm,
      t = est + c(-1, 1) * stats::qt(1 - a / 2, n - 1) * stats::sd(x) / sqrt(n),
      se = est + c(-1, 1) * stats::sd(x) / sqrt(n),
      sd = est + c(-1, 1) * stats::sd(x),
      boot = {
        b <- replicate(n_boot, f(sample(x, n, replace = TRUE)))
        unname(stats::quantile(b, c(a / 2, 1 - a / 2)))
      })
    c(est = est, ci_lo = civ[1], ci_hi = civ[2], n = n)
  }
  test_axis <- function(x, gg, type) {
    ok <- !is.na(x) & !is.na(gg)
    x <- x[ok]
    gg <- droplevels(gg[ok])
    kk <- nlevels(gg)
    out <- list(p = NA_real_, method = NA_character_)
    if (kk < 2 || length(unique(x)) < 2) return(out)
    tryCatch({
      if (type == "quanti") {
        if (test == "none") return(out)
        tt <- test
        if (tt == "auto") tt <- if (kk == 2) "wilcox" else "kruskal"
        if (tt == "wilcox" && kk > 2) tt <- "kruskal"
        if (tt == "t") {
          if (kk == 2) {
            out$p <- stats::t.test(x ~ gg)$p.value
            out$method <- "Welch t test"
          } else {
            out$p <- stats::oneway.test(x ~ gg)$p.value
            out$method <- "Welch ANOVA"
          }
        } else if (tt == "wilcox") {
          out$p <- stats::wilcox.test(x ~ gg, exact = FALSE)$p.value
          out$method <- "Wilcoxon test"
        } else if (tt == "kruskal") {
          out$p <- stats::kruskal.test(x ~ gg)$p.value
          out$method <- "Kruskal-Wallis test"
        } else if (tt == "anova") {
          out$p <- stats::anova(stats::lm(x ~ gg))[["Pr(>F)"]][1]
          out$method <- "ANOVA"
        }
      } else {
        if (test_quali == "none") return(out)
        tab <- table(x, gg)
        tq <- test_quali
        if (tq == "auto") {
          ex <- suppressWarnings(stats::chisq.test(tab)$expected)
          tq <- if (any(ex < 5)) "fisher" else "chisq"
        }
        if (tq == "chisq") {
          out$p <- suppressWarnings(stats::chisq.test(tab)$p.value)
          out$method <- "chi-square test"
        } else {
          out$p <- tryCatch(stats::fisher.test(tab)$p.value,
                            error = function(e) stats::fisher.test(tab, simulate.p.value = TRUE, B = 1e4)$p.value)
          out$method <- "Fisher exact test"
        }
      }
      out
    }, error = function(e) list(p = NA_real_, method = NA_character_))
  }
  stars <- function(p) {
    s <- rep(signif_symbols[length(signif_symbols)], length(p))
    for (i in rev(seq_along(signif_cutpoints))) s[!is.na(p) & p < signif_cutpoints[i]] <- signif_symbols[i]
    s[is.na(p)] <- NA
    s
  }
  p_label <- function(p) {
    lim <- 10^(-p_digits)
    ifelse(is.na(p), NA,
           ifelse(p < lim, paste0("p<", format(lim, scientific = FALSE)),
                  paste0("p=", formatC(p, format = "f", digits = p_digits))))
  }

  # 4. summaries per group
  summ <- do.call(rbind, lapply(seq_len(n_ax), function(i) {
    do.call(rbind, lapply(grp_names, function(gl) {
      s <- summarise_axis(axes[[i]]$x[g == gl], axes[[i]]$type)
      data.frame(id = ids[i], variable = ax_vars[i], type = ax_types[i], label = lab[i], group = gl,
                 n = s[["n"]], est = s[["est"]], ci_lo = s[["ci_lo"]], ci_hi = s[["ci_hi"]],
                 stringsAsFactors = FALSE)
    }))
  }))
  summ$group <- factor(summ$group, levels = grp_names)

  # 5. normalisation to [0, 1]
  get_lims <- function(i) {
    ax <- axes[[i]]
    if (!is.null(limits)) {
      if (!is.null(limits[[ax$id]])) return(limits[[ax$id]])
      if (!is.null(limits[[ax$var]])) return(limits[[ax$var]])
    }
    if (ax$type == "quali" && !normalize_quali) return(c(0, 1))
    if (all(is.na(ax$x))) return(c(0, 1))
    rng <- switch(normalize,
      minmax = range(ax$x, na.rm = TRUE),
      quantile = unname(stats::quantile(ax$x, quantile_probs, na.rm = TRUE)),
      summary = {
        e <- summ$est[summ$id == ax$id]
        if (sum(!is.na(e)) >= 2) range(e, na.rm = TRUE) else range(ax$x, na.rm = TRUE)
      },
      zscore = {
        if (!is.null(reference) && !(reference %in% levels(g))) {
          cli::cli_abort("{.arg reference} must be one of the groups: {.val {levels(g)}}.")
        }
        xr <- if (is.null(reference)) ax$x else ax$x[g == reference]
        m <- mean(xr, na.rm = TRUE)
        s <- stats::sd(xr, na.rm = TRUE)
        if (!is.finite(s) || s == 0) s <- 1
        m + z_range * s
      },
      rank = c(0, 1),
      none = c(0, 1))
    if (diff(rng) == 0) rng <- rng + c(-0.5, 0.5)
    rng
  }
  lims <- stats::setNames(lapply(seq_len(n_ax), get_lims), ids)
  summ$lim_min <- vapply(summ$id, function(z) lims[[z]][1], 0)
  summ$lim_max <- vapply(summ$id, function(z) lims[[z]][2], 0)
  summ$reversed <- rev_flag[match(summ$id, ids)]
  sc <- function(v) (v - summ$lim_min) / (summ$lim_max - summ$lim_min)
  z <- sc(summ$est)
  zlo <- sc(summ$ci_lo)
  zhi <- sc(summ$ci_hi)
  r <- summ$reversed
  z[r] <- 1 - z[r]
  tmp <- zlo[r]
  zlo[r] <- 1 - zhi[r]
  zhi[r] <- 1 - tmp
  if (clip) {
    cl <- function(v) pmin(pmax(v, 0), 1)
    z <- cl(z)
    zlo <- cl(zlo)
    zhi <- cl(zhi)
  }
  summ$z <- z
  summ$z_lo <- zlo
  summ$z_hi <- zhi

  # 6. tests and final labels
  tests <- data.frame(id = ids, variable = ax_vars, type = ax_types, label = lab,
                      p = NA_real_, method = NA_character_, stringsAsFactors = FALSE)
  if (!is.null(p_values)) {
    key <- ifelse(ids %in% names(p_values), ids, ax_vars)
    tests$p <- unname(p_values[key])
    tests$method <- test_label %||% "user-supplied test"
    tests$p_adj <- stats::p.adjust(tests$p, method = p_adjust)
  } else if (k >= 2) {
    for (i in seq_len(n_ax)) {
      tt <- test_axis(axes[[i]]$x, g, axes[[i]]$type)
      tests$p[i] <- tt$p
      tests$method[i] <- tt$method
    }
    tests$p_adj <- stats::p.adjust(tests$p, method = p_adjust)
  } else {
    tests$p_adj <- NA_real_
  }
  tests$signif <- stars(tests$p_adj)
  sig_on <- show_signif && (k >= 2 || !is.null(p_values)) && any(!is.na(tests$p_adj))
  lab_final <- lab
  if (sig_on) {
    suff <- switch(signif_format, stars = tests$signif, p = p_label(tests$p_adj),
                   both = paste0(tests$signif, ", ", p_label(tests$p_adj)))
    lab_final <- ifelse(is.na(tests$p_adj), lab, paste0(lab, " (", suff, ")"))
  }
  if (!is.null(label_wrap)) {
    lab_final <- vapply(lab_final, function(s) paste(strwrap(s, label_wrap), collapse = "\n"), "")
  }

  # 7. geometry (Cartesian coordinates)
  dir <- if (clockwise) -1 else 1
  theta <- (start_angle + dir * 360 * (pos - 1) / n_ax) * pi / 180
  rad <- function(v) inner_radius + (1 - inner_radius) * v
  R_out <- rad(max(c(1, grid_levels)))
  R_lab <- R_out + label_offset
  summ$pos <- pos[match(summ$id, ids)]
  summ$theta <- theta[match(summ$id, ids)]
  summ <- summ[order(summ$group, summ$pos), ]
  prof <- summ[!is.na(summ$z), ]
  prof$x <- rad(prof$z) * cos(prof$theta)
  prof$y <- rad(prof$z) * sin(prof$theta)
  band_on <- ci && any(!is.na(summ$z_lo) & !is.na(summ$z_hi))
  if (band_on) {
    bb <- summ[!is.na(summ$z_lo) & !is.na(summ$z_hi), ]
    band <- rbind(
      data.frame(group = bb$group, ring = "hi", x = rad(bb$z_hi) * cos(bb$theta), y = rad(bb$z_hi) * sin(bb$theta)),
      data.frame(group = bb$group, ring = "lo", x = rad(bb$z_lo) * cos(bb$theta), y = rad(bb$z_lo) * sin(bb$theta)))
  }
  th_sorted <- theta[order(pos)]
  ring_xy <- function(rr) {
    tt <- if (grid_shape == "circle") seq(0, 2 * pi, length.out = 361) else c(th_sorted, th_sorted[1])
    data.frame(x = rr * cos(tt), y = rr * sin(tt))
  }
  grid_lv <- sort(unique(grid_levels))
  if (inner_radius > 0) grid_lv <- unique(c(0, grid_lv))
  grid_df <- do.call(rbind, lapply(grid_lv, function(L) cbind(ring_xy(rad(L)), lev = L)))
  spokes <- data.frame(x0 = rad(0) * cos(theta), y0 = rad(0) * sin(theta),
                       x1 = R_out * cos(theta), y1 = R_out * sin(theta))
  cx <- cos(theta)
  sy <- sin(theta)
  ax_lab <- data.frame(x = R_lab * cx, y = R_lab * sy, label = lab_final,
                       hj = ifelse(abs(cx) < 0.15, 0.5, ifelse(cx > 0, 0, 1)),
                       vj = ifelse(abs(sy) < 0.15, 0.5, ifelse(sy > 0, 0, 1)))
  if (show_grid_labels) {
    ga <- (grid_label_angle %||% start_angle) * pi / 180
    gl_lv <- grid_levels[grid_levels > 0]
    grid_lab <- data.frame(x = rad(gl_lv) * cos(ga) + 0.015, y = rad(gl_lv) * sin(ga), label = grid_label_fmt(gl_lv))
  }

  # colours
  if (!is.null(colours)) {
    if (!is.null(names(colours))) {
      m <- setdiff(grp_names, names(colours))
      if (length(m)) cli::cli_abort("Missing colour(s) for {.val {m}}.")
      cols <- unname(colours[grp_names])
    } else {
      cols <- rep_len(colours, k)
    }
    names(cols) <- grp_names
  } else {
    cols <- pal_levels(grp_names, palette)
  }

  # 8. automatic caption
  if (is.null(caption)) {
    parts <- character(0)
    if (sig_on) {
      meth <- paste(unique(stats::na.omit(tests$method)), collapse = " / ")
      corr <- if (p_adjust != "none") paste0(", ", p_adjust, " correction") else ""
      if (signif_format == "p") {
        parts <- c(parts, sprintf("Adjusted p-values (%s%s).", meth, corr))
      } else {
        cuts <- paste(paste0(signif_symbols[seq_along(signif_cutpoints)], " p<", signif_cutpoints), collapse = "  |  ")
        parts <- c(parts, sprintf("Significance (%s%s): %s  |  %s = not significant.",
                                  meth, corr, cuts, signif_symbols[length(signif_symbols)]))
      }
    }
    if (band_on) {
      what <- if (stat == "mean") "of the mean" else "of the median"
      cm <- if (stat == "median" && ci_method %in% c("t", "se")) "boot" else ci_method
      desc <- switch(cm,
        t = sprintf("%g%% CI %s", 100 * ci_level, what),
        boot = sprintf("%g%% bootstrap CI %s", 100 * ci_level, what),
        se = "\u00b1 1 standard error",
        sd = "\u00b1 1 standard deviation")
      if (any(ax_types == "quali")) desc <- paste0(desc, "; Wilson CI for the proportions")
      parts <- c(parts, sprintf("Band = %s (normalised scale).", desc))
    }
    if (normalize == "zscore") {
      parts <- c(parts, sprintf("Scale: SD units around the mean of %s (middle circle), from %+g to %+g SD.",
                                if (is.null(reference)) "all individuals" else reference, z_range[1], z_range[2]))
    }
    if (normalize == "rank") {
      parts <- c(parts, "Scale: mean percentile rank of the individuals (all groups pooled); 50% = median.")
    }
    caption <- if (length(parts)) paste(parts, collapse = "\n") else NULL
  } else if (isFALSE(caption)) {
    caption <- NULL
  }

  # 9. ggplot
  p <- ggplot2::ggplot()
  if (!is.na(background_fill)) {
    p <- p + ggplot2::geom_polygon(data = ring_xy(R_out), ggplot2::aes(x = x, y = y), fill = background_fill, colour = NA)
  }
  p <- p +
    ggplot2::geom_path(data = grid_df, ggplot2::aes(x = x, y = y, group = lev),
                       colour = grid_colour, linewidth = grid_linewidth, linetype = grid_linetype) +
    ggplot2::geom_segment(data = spokes, ggplot2::aes(x = x0, y = y0, xend = x1, yend = y1),
                          colour = spoke_colour, linewidth = spoke_linewidth)
  if (band_on) {
    p <- p + ggplot2::geom_polygon(data = band, ggplot2::aes(x = x, y = y, group = group, subgroup = ring, fill = group),
                                   alpha = band_alpha, colour = NA, show.legend = show_legend)
  }
  prof_aes <- if (!is.null(linetypes)) {
    ggplot2::aes(x = x, y = y, group = group, colour = group, fill = group, linetype = group)
  } else {
    ggplot2::aes(x = x, y = y, group = group, colour = group, fill = group)
  }
  p <- p + ggplot2::geom_polygon(data = prof, mapping = prof_aes, alpha = fill_alpha, linewidth = line_width,
                                 key_glyph = "path", show.legend = show_legend)
  if (show_points) {
    if (length(point_shape) > 1) {
      p <- p +
        ggplot2::geom_point(data = prof, ggplot2::aes(x = x, y = y, colour = group, shape = group),
                            size = point_size, show.legend = show_legend) +
        ggplot2::scale_shape_manual(values = stats::setNames(rep_len(point_shape, k), grp_names), name = legend_title)
    } else {
      p <- p + ggplot2::geom_point(data = prof, ggplot2::aes(x = x, y = y, colour = group),
                                   size = point_size, shape = point_shape, show.legend = show_legend)
    }
  }
  if (show_values) {
    vfmt <- ifelse(prof$type == "quali", paste0(formatC(100 * prof$est, format = "f", digits = value_digits), "%"),
                   formatC(prof$est, format = "f", digits = value_digits))
    vr <- rad(prof$z) + 0.05
    p <- p + ggplot2::geom_text(
      data = data.frame(x = vr * cos(prof$theta), y = vr * sin(prof$theta), label = vfmt, group = prof$group),
      ggplot2::aes(x = x, y = y, label = label, colour = group),
      size = value_size, family = base_family, show.legend = FALSE)
  }
  if (show_grid_labels) {
    p <- p + ggplot2::geom_text(data = grid_lab, ggplot2::aes(x = x, y = y, label = label), hjust = 0, vjust = 0.5,
                                size = grid_label_size, colour = grid_label_colour, family = base_family)
  }
  p <- p + ggplot2::geom_text(data = ax_lab, ggplot2::aes(x = x, y = y, label = label, hjust = hj, vjust = vj),
                              size = label_size, colour = label_colour, fontface = label_fontface,
                              lineheight = label_lineheight, family = base_family)
  p <- p + ggplot2::scale_colour_manual(values = cols, breaks = grp_names, name = legend_title,
                                        aesthetics = c("colour", "fill"))
  if (!is.null(linetypes)) {
    p <- p + ggplot2::scale_linetype_manual(values = stats::setNames(rep_len(linetypes, k), grp_names),
                                            name = legend_title)
  }
  if (!is.null(legend_nrow)) {
    p <- p + ggplot2::guides(colour = ggplot2::guide_legend(nrow = legend_nrow),
                             fill = ggplot2::guide_legend(nrow = legend_nrow))
  }
  xl <- R_lab + expand_x
  yl <- R_lab + expand_y
  p <- p +
    ggplot2::coord_fixed(xlim = c(-xl, xl), ylim = c(-yl, yl), expand = FALSE, clip = "off") +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::theme_void(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = title_size %||% ggplot2::rel(1.6),
                                         margin = ggplot2::margin(b = 8)),
      plot.subtitle = ggplot2::element_text(hjust = 0.5, colour = "grey30"),
      plot.caption = ggplot2::element_text(hjust = 0.5, colour = "grey45", size = caption_size, lineheight = 1.1),
      legend.position = if (show_legend) legend_position else "none",
      legend.title = ggplot2::element_text(size = ggplot2::rel(1.1)),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.95)),
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(plot_margin[1], plot_margin[2], plot_margin[3], plot_margin[4], "pt"))

  # 10. output
  out_summary <- summ[, c("id", "variable", "type", "label", "group", "n", "est", "ci_lo", "ci_hi",
                          "lim_min", "lim_max", "reversed", "z", "z_lo", "z_hi")]
  rownames(out_summary) <- NULL
  attr(p, "radar_data") <- list(summary = out_summary, tests = tests)
  if (return_data) return(list(plot = p, summary = out_summary, tests = tests))
  p
}
