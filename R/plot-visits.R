# Paired visits and trajectories ---------------------------------------------------

#' Paired visits: one line per subject between two visits
#'
#' Two overlaid distributions (V0 and V3) can be identical while every subject
#' moves. This plot shows the subject-level changes: one line per subject,
#' a boxplot per visit and the median line. The panel title gives the number
#' of paired subjects, the Spearman correlation between visits (stability of
#' the ranking) and the paired Wilcoxon test (shift of the distribution).
#'
#' With `transitions = TRUE`, each subject is "High" or "Low" at each visit
#' with respect to a threshold (median by default) and its line is coloured by
#' its transition; the threshold of each visit is drawn as a dashed segment,
#' and the panel title adds the share of subjects changing side and Cohen's
#' kappa of the High / Low status (kappa < 0: inverted ranking).
#'
#' @param data One row per subject (wide format).
#' @param vars First-visit numeric variables (names or tidyselect), e.g.
#'   `NFL_V0`; the second-visit column is found with [visit_swap()].
#' @param id_col Subject identifier.
#' @param visits The two visit suffixes.
#' @param labels Optional named vector of labels.
#' @param ncol Number of columns of panels.
#' @param palette Colours of the two visits.
#' @param title,subtitle Titles.
#' @param base_size Base font size.
#' @param transitions Colour the lines by High / Low transition.
#' @param split Threshold rule: `"median"`, `"mean"`, `"quantile"`
#'   (`split_prob`) or `"manual"` (`split_cut`, then required for every
#'   variable).
#' @param split_prob Probability of the `"quantile"` rule.
#' @param split_cut Manual threshold(s), named by first-visit variable
#'   (override `split` for these variables), or one unnamed value for all, on
#'   the plotted scale.
#' @param split_ref `"visit"`: threshold computed at each visit (insensitive
#'   to a global shift); `"first"`: threshold of the first visit applied at
#'   both. Manual thresholds are the same at both visits.
#' @param transition_mode `"detailed"` (High -> High, Low -> Low, High -> Low,
#'   Low -> High) or `"crossing"` (Same side, High -> Low, Low -> High).
#' @param transition_palette Named colours of the transitions (`NULL`:
#'   default).
#' @return A ggplot with the attributes `"transitions"` (one row per subject x
#'   variable, when `transitions = TRUE`) and `"summary"` (one row per
#'   variable: n, rho, Wilcoxon p, thresholds, % changing side, kappa).
#' @export
#' @examples
#' plot_paired_visits(cohort_sim, c(NFL_V0, MOCA_V0), id_col = ID)
#' p <- plot_paired_visits(cohort_sim, NFL_V0, id_col = ID, transitions = TRUE)
#' attr(p, "summary")
plot_paired_visits <- function(data, vars, id_col, visits = c("V0", "V3"), labels = NULL, ncol = 4,
                               palette = c("#0072B2", "#D55E00"), title = NULL, subtitle = NULL,
                               base_size = 10, transitions = FALSE,
                               split = c("median", "mean", "quantile", "manual"), split_prob = 0.5,
                               split_cut = NULL, split_ref = c("visit", "first"),
                               transition_mode = c("detailed", "crossing"), transition_palette = NULL) {
  split <- match.arg(split)
  split_ref <- match.arg(split_ref)
  transition_mode <- match.arg(transition_mode)
  data <- as.data.frame(.as_df(data))
  vars <- .select(rlang::enquo(vars), data, "vars")
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  second <- function(v) visit_swap(v, visits[1], visits[2])
  vars <- vars[endsWith(vars, paste0("_", visits[1])) & second(vars) %in% names(data)]
  if (!length(vars)) cli::cli_abort("No variable of {.arg vars} has a {.val {visits[2]}} counterpart.")
  arr <- .u("\u2192")

  pairs <- dplyr::bind_rows(lapply(vars, function(v) {
    x0 <- as.numeric(data[[v]])
    x1 <- as.numeric(data[[second(v)]])
    ok <- !is.na(x0) & !is.na(x1)
    tibble::tibble(id = data[[id_col]][ok], var = v, x0 = x0[ok], x1 = x1[ok])
  }))
  threshold <- function(x, v) {
    if (!is.null(split_cut)) {
      if (!is.null(names(split_cut)) && v %in% names(split_cut)) return(unname(split_cut[[v]]))
      if (is.null(names(split_cut))) return(split_cut[[1]])
    }
    switch(split,
           median = stats::median(x),
           mean = mean(x),
           quantile = unname(stats::quantile(x, split_prob)),
           manual = cli::cli_abort("{.code split = \"manual\"}: no threshold in {.arg split_cut} for {.val {v}}."))
  }
  is_manual <- function(v) !is.null(split_cut) && (is.null(names(split_cut)) || v %in% names(split_cut))
  lev_detail <- c(paste("High", arr, "High"), paste("Low", arr, "Low"), paste("High", arr, "Low"), paste("Low", arr, "High"))
  lev_cross <- c("Same side", paste("High", arr, "Low"), paste("Low", arr, "High"))
  if (transitions) {
    thr <- dplyr::bind_rows(lapply(base::split(pairs, pairs$var), function(d) {
      v <- d$var[1]
      tibble::tibble(var = v, t0 = threshold(d$x0, v),
                     t1 = if (split_ref == "first" || is_manual(v)) threshold(d$x0, v) else threshold(d$x1, v))
    }))
    pairs <- dplyr::left_join(pairs, thr, by = "var")
    pairs$high0 <- pairs$x0 >= pairs$t0                     # a value equal to the threshold goes up
    pairs$high1 <- pairs$x1 >= pairs$t1
    pairs$detailed <- factor(paste(ifelse(pairs$high0, "High", "Low"), arr, ifelse(pairs$high1, "High", "Low")),
                             levels = lev_detail)
    pairs$crossing <- factor(ifelse(pairs$high0 == pairs$high1, "Same side", as.character(pairs$detailed)),
                             levels = lev_cross)
    pairs$Transition <- if (transition_mode == "detailed") pairs$detailed else pairs$crossing
  }
  st <- dplyr::bind_rows(lapply(vars, function(v) {
    d <- pairs[pairs$var == v, , drop = FALSE]
    tibble::tibble(
      var = v, n = nrow(d),
      rho = suppressWarnings(stats::cor(d$x0, d$x1, method = "spearman")),
      p = tryCatch(stats::wilcox.test(d$x1, d$x0, paired = TRUE, exact = FALSE)$p.value, error = function(e) NA_real_),
      t0 = if (transitions) d$t0[1] else NA_real_,
      t1 = if (transitions) d$t1[1] else NA_real_,
      pct_change = if (transitions) 100 * mean(d$high0 != d$high1) else NA_real_,
      kappa = if (transitions) .cohen_kappa(d$high0, d$high1, c(FALSE, TRUE)) else NA_real_)
  }))
  st$Facet <- .u(sprintf("%s\nn = %d | rho(%s, %s) = %.2f \npaired Wilcoxon p = %s%s",
                      label_get(st$var, labels), st$n, visits[1], visits[2], st$rho, fmt_p(st$p),
                      if (transitions) sprintf("\n%.0f%% change side | kappa = %.2f", st$pct_change, st$kappa) else ""))
  long <- dplyr::left_join(pairs, st[, c("var", "Facet")], by = "var")
  long <- tidyr::pivot_longer(long, c("x0", "x1"), names_to = "Visit", values_to = "value")
  long$Visit <- factor(ifelse(long$Visit == "x0", visits[1], visits[2]), levels = visits)
  long$Facet <- factor(long$Facet, levels = st$Facet)

  p <- ggplot2::ggplot(long, ggplot2::aes(Visit, value))
  if (transitions) {
    tpal <- transition_palette %||% stats::setNames(c("#F5D49B", "#A8DCC6", "#B2182B", "#2166AC", "grey60"),
                                                    c(lev_detail, "Same side"))
    split_txt <- switch(split, median = "median", mean = "mean", quantile = sprintf("quantile %g", split_prob),
                        manual = "manual cut-off")
    if (!is.null(split_cut) && split != "manual") split_txt <- paste(split_txt, "(manual cut-off where given)")
    seg <- tidyr::pivot_longer(tibble::tibble(Facet = factor(st$Facet, levels = levels(long$Facet)), t0 = st$t0, t1 = st$t1),
                               c("t0", "t1"), names_to = "k", values_to = "thr")
    seg$xpos <- ifelse(seg$k == "t0", 1, 2)
    # subjects changing side drawn last and thicker, so that they are not hidden by the others
    moved <- long$high0 != long$high1
    p <- p + ggplot2::geom_line(data = long[!moved, , drop = FALSE], ggplot2::aes(group = id, colour = Transition),
                                alpha = 0.6, linewidth = 0.35) +
      ggplot2::geom_line(data = long[moved, , drop = FALSE], ggplot2::aes(group = id, colour = Transition),
                         alpha = 0.95, linewidth = 0.8) +
      ggplot2::geom_point(ggplot2::aes(colour = Transition), size = 0.9, alpha = 0.6) +
      ggplot2::geom_boxplot(ggplot2::aes(fill = Visit), width = 0.3, alpha = 0.35, outlier.shape = NA) +
      ggplot2::geom_segment(data = seg, ggplot2::aes(x = xpos - 0.3, xend = xpos + 0.3, y = thr, yend = thr),
                            inherit.aes = FALSE, linetype = "dashed", colour = "black", linewidth = 0.8) +
      ggplot2::scale_colour_manual(values = tpal, name = NULL, drop = FALSE)
    cap <- paste(sprintf("Coloured lines: transition of each subject with respect to the %s (%s); dashed segments: threshold of each visit.",
                         split_txt, if (split_ref == "first") sprintf("threshold of %s applied at both visits", visits[1])
                         else "computed at each visit"),
                 "A value equal to the threshold counts as High. kappa = Cohen's kappa of the High / Low status between visits.",
                 sep = "\n")
  } else {
    p <- p + ggplot2::geom_line(ggplot2::aes(group = id), colour = "grey55", alpha = 0.25, linewidth = 0.3) +
      ggplot2::geom_point(ggplot2::aes(colour = Visit), size = 0.9, alpha = 0.45) +
      ggplot2::geom_boxplot(ggplot2::aes(fill = Visit), width = 0.3, alpha = 0.55, outlier.shape = NA) +
      ggplot2::scale_colour_manual(values = stats::setNames(palette, visits), guide = "none")
    cap <- "Grey lines: one subject."
  }
  p <- p +
    ggplot2::stat_summary(ggplot2::aes(group = 1), fun = stats::median, geom = "line", colour = "black", linewidth = 0.9) +
    ggplot2::facet_wrap(~ Facet, scales = "free_y", ncol = ncol) +
    ggplot2::scale_fill_manual(values = stats::setNames(palette, visits), guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = "Value (analysed scale)",
                  caption = paste(cap, "Black line: median.",
                                  "rho = Spearman correlation between visits (1 = same ranking of the subjects at both visits).",
                                  "Paired Wilcoxon: shift of the distribution between visits.", sep = "\n")) +
    theme_pub(base_size) + ggplot2::theme(strip.text = ggplot2::element_text(size = base_size - 1),
                                          legend.position = "bottom")
  attr(p, "transitions") <- if (transitions) {
    pairs[, c("id", "var", "x0", "x1", "t0", "t1", "high0", "high1", "detailed", "crossing")]
  } else NULL
  attr(p, "summary") <- st[, setdiff(names(st), "Facet")]
  p
}

#' Individual trajectories across visits (spaghetti plot)
#'
#' `plot_trajectories()` draws one thin line per subject, a thick summary
#' line (median or mean) per group and, optionally, boxplots per visit.
#' `plot_trajectory_grid()` draws one panel per root.
#'
#' @param data Wide format (one column per visit).
#' @param vars Columns in chronological order, e.g. `c(NFL_V0, NFL_V3)`
#'   (names or tidyselect).
#' @param id_col Subject identifier.
#' @param group Optional colour variable.
#' @param labels Optional named vector of labels.
#' @param time_labels Visit labels (default: the suffixes of `vars`).
#' @param title,y_lab Title (default: label of the root) and y-axis title.
#' @param palette Colours of the groups.
#' @param show_box Boxplots per visit (and group) in the background.
#' @param summary_fun `"median"` or `"mean"`.
#' @param line_alpha Transparency of the subject lines.
#' @param base_size Base font size.
#' @param ref_line Optional horizontal reference line.
#' @param roots Root names (one panel each).
#' @param visits Visit suffixes.
#' @param ncol Number of columns of panels.
#' @param ... Passed to `plot_trajectories()`.
#' @return A ggplot (`NULL` when fewer than 3 complete subjects), or a
#'   patchwork for `plot_trajectory_grid()`.
#' @export
#' @examples
#' plot_trajectories(cohort_sim, c(MOCA_V0, MOCA_V3), id_col = ID, group = GROUP)
#' plot_trajectory_grid(cohort_sim, c("NFL", "MOCA", "UPDRS"), id_col = "ID", group = "GROUP")
plot_trajectories <- function(data, vars, id_col, group = NULL, labels = NULL, time_labels = NULL,
                              title = NULL, y_lab = NULL, palette = NULL, show_box = TRUE,
                              summary_fun = c("median", "mean"), line_alpha = 0.25, base_size = 11,
                              ref_line = NULL) {
  summary_fun <- match.arg(summary_fun)
  data <- as.data.frame(.as_df(data))
  vars <- .select(rlang::enquo(vars), data, "vars")
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  group <- .select(rlang::enquo(group), data, "group", single = TRUE)
  if (length(vars) < 2) cli::cli_abort("{.arg vars} must select at least 2 visits.")
  time_labels <- time_labels %||% sub("^.*_", "", vars)
  d <- data[, unique(c(id_col, group, vars)), drop = FALSE]
  d <- d[stats::complete.cases(d[, vars, drop = FALSE]), , drop = FALSE]
  if (nrow(d) < 3) return(NULL)
  d$.id <- d[[id_col]]
  d$.grp <- if (!is.null(group)) as.factor(d[[group]]) else factor("All")
  long <- tidyr::pivot_longer(d[, c(".id", ".grp", vars)], dplyr::all_of(vars), names_to = ".var", values_to = "val")
  long$Visit <- factor(time_labels[match(long$.var, vars)], levels = time_labels)
  pal <- pal_levels(levels(long$.grp), palette)
  fun <- if (summary_fun == "median") stats::median else mean
  summ <- dplyr::summarise(long, s = fun(val), .by = c(".grp", "Visit"))
  n_by <- if (!is.null(group)) {
    tb <- table(d[[group]])
    paste(sprintf("%s: %d", names(tb), as.integer(tb)), collapse = ", ")
  } else NULL

  p <- ggplot2::ggplot(long, ggplot2::aes(x = Visit, y = val, colour = .grp))
  if (show_box) {
    p <- p + ggplot2::geom_boxplot(ggplot2::aes(fill = .grp, group = interaction(Visit, .grp)),
                                   alpha = 0.15, width = 0.4, outlier.shape = NA,
                                   position = ggplot2::position_dodge(width = 0.5), colour = "grey55")
  }
  p <- p +
    ggplot2::geom_line(ggplot2::aes(group = .id), alpha = line_alpha, linewidth = 0.35) +
    ggplot2::geom_point(size = 0.9, alpha = 0.4) +
    ggplot2::geom_line(data = summ, ggplot2::aes(y = s, group = .grp), linewidth = 1.6) +
    ggplot2::geom_point(data = summ, ggplot2::aes(y = s), size = 3, shape = 21, fill = "white", stroke = 1.3) +
    ggplot2::scale_colour_manual(values = pal, name = label_get(group, labels),
                                 guide = if (is.null(group)) "none" else "legend") +
    ggplot2::scale_fill_manual(values = pal, guide = "none")
  if (!is.null(ref_line)) p <- p + ggplot2::geom_hline(yintercept = ref_line, linetype = "dotdash", colour = "#D55E00")
  p + ggplot2::labs(title = title %||% label_get(sub("_[^_]+$", "", vars[1]), labels),
                    subtitle = sprintf("N = %d paired individuals%s", nrow(d), if (!is.null(n_by)) paste0(" (", n_by, ")") else ""),
                    caption = sprintf("Thin lines: individuals; thick line: %s%s; boxes: Q1-Q3 per visit",
                                      summary_fun, if (!is.null(group)) " per group" else ""),
                    x = NULL, y = y_lab %||% "Value") +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom")
}

#' @rdname plot_trajectories
#' @export
plot_trajectory_grid <- function(data, roots, id_col, visits = c("V0", "V3"), group = NULL,
                                 labels = NULL, ncol = 3, base_size = 10, ...) {
  data <- as.data.frame(.as_df(data))
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  group <- .select(rlang::enquo(group), data, "group", single = TRUE)
  plots <- list()
  for (r in roots) {
    v <- paste0(r, "_", visits)
    if (!all(v %in% names(data))) next
    pl <- plot_trajectories(data, vars = v, id_col = id_col, group = group, labels = labels,
                            title = label_get(r, labels), base_size = base_size, ...)
    if (!is.null(pl)) plots[[r]] <- pl + ggplot2::labs(caption = NULL)
  }
  if (!length(plots)) return(NULL)
  patchwork::wrap_plots(plots, ncol = ncol, guides = "collect") +
    patchwork::plot_annotation(caption = "Thin lines: individuals; thick line: median; boxes: Q1-Q3 per visit",
                               theme = theme_pub(base_size)) &
    ggplot2::theme(legend.position = "bottom")
}

#' Change versus baseline value
#'
#' Shows regression to the mean and floor / ceiling effects: change between
#' two visits against the first-visit value, LOESS smooth with its 95% band
#' and the Spearman correlation between baseline and change.
#'
#' @param data Wide format.
#' @param roots Root names (one panel each).
#' @param from,to Visit suffixes.
#' @param labels Optional named vector of labels.
#' @param group Optional colour variable.
#' @param palette Colours of the groups.
#' @param ncol Number of columns of panels.
#' @param base_size Base font size.
#' @return A patchwork, or `NULL` when no root has at least 10 complete pairs.
#' @export
#' @examples
#' plot_delta_vs_baseline(cohort_sim, c("NFL", "MOCA"), group = GROUP)
plot_delta_vs_baseline <- function(data, roots, from = "V0", to = "V3", labels = NULL,
                                   group = NULL, palette = NULL, ncol = 3, base_size = 10) {
  data <- as.data.frame(.as_df(data))
  group <- .select(rlang::enquo(group), data, "group", single = TRUE)
  plots <- list()
  for (r in roots) {
    a <- paste0(r, "_", from)
    b <- paste0(r, "_", to)
    if (!all(c(a, b) %in% names(data)) || !is.numeric(data[[a]])) next
    d <- tibble::tibble(x0 = data[[a]], dl = data[[b]] - data[[a]],
                        .grp = if (!is.null(group)) as.factor(data[[group]]) else factor("All"))
    d <- d[stats::complete.cases(d), , drop = FALSE]
    if (nrow(d) < 10) next
    ct <- suppressWarnings(stats::cor.test(d$x0, d$dl, method = "spearman", exact = FALSE))
    plots[[r]] <- ggplot2::ggplot(d, ggplot2::aes(x = x0, y = dl)) +
      ggplot2::geom_hline(yintercept = 0, colour = "grey50", linetype = "dashed") +
      ggplot2::geom_point(ggplot2::aes(colour = .grp), alpha = 0.6, size = 1.4) +
      ggplot2::geom_smooth(method = "loess", formula = y ~ x, colour = "#D55E00", fill = "#D55E00", alpha = 0.15) +
      ggplot2::scale_colour_manual(values = pal_levels(levels(d$.grp), palette),
                                   guide = if (is.null(group)) "none" else "legend", name = NULL) +
      ggplot2::labs(title = label_get(r, labels),
                    subtitle = .u(sprintf("\u03c1 = %.2f | p = %s %s | N = %d", unname(ct$estimate),
                                          fmt_p(ct$p.value), fmt_stars(ct$p.value), nrow(d))),
                    x = paste("Value at", from), y = .u(sprintf("\u0394 (%s \u2212 %s)", to, from))) +
      theme_pub(base_size)
  }
  if (!length(plots)) return(NULL)
  patchwork::wrap_plots(plots, ncol = ncol, guides = "collect") +
    patchwork::plot_annotation(caption = .u("Orange: LOESS smooth with 95% band; \u03c1: Spearman correlation between baseline and change"),
                               theme = theme_pub(base_size)) &
    ggplot2::theme(legend.position = "bottom")
}
