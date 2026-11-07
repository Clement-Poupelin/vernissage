# Missing data -----------------------------------------------------------------------

#' Missing values per variable and complete cases per variable set
#'
#' `na_summary()` gives the number and share of missing values of each
#' variable, with its block. `na_complete_cases()` gives the number of
#' subjects with every variable of a set observed, for several sets (useful
#' to anticipate the N of a multivariable model).
#'
#' @param data A data frame.
#' @param blocks Named list `block -> variables`.
#' @param labels Optional named vector of labels.
#' @param var_sets Named list of variable vectors.
#' @return A tibble.
#' @export
#' @examples
#' na_summary(cohort_sim, list(Biomarkers = c("NFL_V0", "IL6_V0", "CRP_V0"),
#'                             Scores = c("MOCA_V0", "UPDRS_V0")))
#' na_complete_cases(cohort_sim, list(Baseline = c("NFL_V0", "IL6_V0", "MOCA_V0"),
#'                                    Both_visits = c("NFL_V0", "NFL_V3")))
na_summary <- function(data, blocks, labels = NULL) {
  data <- .as_df(data)
  if (!is.list(blocks) || is.null(names(blocks))) cli::cli_abort("{.arg blocks} must be a named list.")
  out <- dplyr::bind_rows(lapply(names(blocks), function(blk) {
    vars <- intersect(blocks[[blk]], names(data))
    tibble::tibble(Block = rep(blk, length(vars)), Variable = vars, Label = label_get(vars, labels),
                   N_missing = vapply(vars, function(v) sum(is.na(data[[v]])), integer(1), USE.NAMES = FALSE),
                   Pct_missing = round(100 * vapply(vars, function(v) mean(is.na(data[[v]])), numeric(1), USE.NAMES = FALSE), 1))
  }))
  dplyr::arrange(out, dplyr::desc(.data$Pct_missing))
}

#' @rdname na_summary
#' @export
na_complete_cases <- function(data, var_sets) {
  data <- .as_df(data)
  if (!is.list(var_sets) || is.null(names(var_sets))) cli::cli_abort("{.arg var_sets} must be a named list.")
  dplyr::bind_rows(lapply(names(var_sets), function(nm) {
    v <- intersect(var_sets[[nm]], names(data))
    cc <- stats::complete.cases(data[, v, drop = FALSE])
    tibble::tibble(`Variable set` = nm, `N variables` = length(v),
                   `N complete` = sum(cc), `% complete` = round(100 * mean(cc), 1))
  }))
}

#' Missing-data map
#'
#' One tile per subject and variable. Subjects are sorted by number of missing
#' values; variable labels carry the count and share of missing values;
#' optional marginal bars give the share missing per variable (fixed 0-100%
#' scale) and the number missing per subject. Strings such as `"NA"` or `""`
#' count as missing.
#'
#' @param data A data frame.
#' @param vars Variables to show (names or tidyselect; default: all but
#'   `id_col` and `group`).
#' @param id_col Identifier column (default: row numbers).
#' @param labels Optional named vector of labels.
#' @param group Optional grouping column: one panel per group.
#' @param orientation `"cols"`: variables in columns; `"rows"`: variables in
#'   rows.
#' @param sort_rows Sort subjects by number of missing values.
#' @param sort_vars Sort variables by share of missing values.
#' @param na_strings Strings counted as missing in character / factor columns.
#' @param title,subtitle Titles (`subtitle = NULL`: automatic summary).
#' @param palette `"okabe"`, `"viridis"`, `"cividis"` or
#'   `c(Missing = , Observed = )`.
#' @param margins Add the marginal bar charts.
#' @param show_ids Show subject identifiers (`"auto"`: when n <= 60).
#' @param tile_border Colour of the tile borders (`"auto"`: white when
#'   n <= 150).
#' @param show_pct Add the count (%) of missing values to the variable labels.
#' @param x_angle Angle of the x-axis labels.
#' @param x_text_size Size of the axis labels (`NULL`: `base_size - 2`).
#' @param base_size Base font size.
#' @param bar_bg Background colour of the marginal bar charts.
#' @param title_size Title size relative to `base_size`.
#' @return A ggplot (`margins = FALSE`) or a patchwork.
#' @export
#' @examples
#' plot_na_map(cohort_sim, vars = c(NFL_V0:CRP_V3), id_col = ID)
#' plot_na_map(cohort_sim, vars = c(NFL_V0, IL6_V0, MOCA_V0), group = GROUP, margins = FALSE)
plot_na_map <- function(data, vars = NULL, id_col = NULL, labels = NULL, group = NULL,
                        orientation = c("cols", "rows"), sort_rows = TRUE, sort_vars = FALSE,
                        na_strings = c("NA", "", "NaN", "N/A"), title = "Missing data",
                        subtitle = NULL, palette = "okabe", margins = TRUE, show_ids = "auto",
                        tile_border = "auto", show_pct = TRUE, x_angle = 60, x_text_size = NULL,
                        base_size = 10, bar_bg = "grey92", title_size = 1.8) {
  orientation <- match.arg(orientation)
  vert <- orientation == "rows"
  df <- as.data.frame(.as_df(data))
  id_col <- .select(rlang::enquo(id_col), df, "id_col", single = TRUE)
  group <- .select(rlang::enquo(group), df, "group", single = TRUE)
  vars <- .select(rlang::enquo(vars), df, "vars") %||% names(df)
  vars <- setdiff(vars, c(id_col, group))
  if (!length(vars)) cli::cli_abort("No variable to show.")
  n <- nrow(df)
  cols <- if (is.character(palette) && length(palette) == 1) {
    switch(palette,
           okabe   = c(Missing = "#D55E00", Observed = "#E4E9EF"),
           viridis = c(Missing = "#FDE725", Observed = "#440154"),
           cividis = c(Missing = "#FFEA46", Observed = "#00204D"),
           cli::cli_abort("{.arg palette}: {.val okabe}, {.val viridis}, {.val cividis} or {.code c(Missing = , Observed = )}."))
  } else palette
  if (!all(c("Missing", "Observed") %in% names(cols))) {
    cli::cli_abort("{.arg palette} must be named {.code c(Missing = , Observed = )}.")
  }

  na_mat <- vapply(vars, function(v) {
    x <- df[[v]]
    is.na(x) | (if (is.character(x) || is.factor(x)) trimws(as.character(x)) %in% na_strings else FALSE)
  }, logical(n))
  na_mat <- matrix(na_mat, nrow = n, dimnames = list(NULL, vars))

  ids <- if (!is.null(id_col)) as.character(df[[id_col]]) else as.character(seq_len(n))
  ids <- make.unique(ids)
  grp <- if (!is.null(group)) as.character(df[[group]]) else rep("All", n)
  cnt <- colSums(na_mat)
  pct <- 100 * cnt / n
  row_na <- rowSums(na_mat)
  base_lab <- label_get(vars, labels)
  vlab <- if (!show_pct) base_lab else if (vert) sprintf("%s  %d (%.0f%%)", base_lab, cnt, pct) else
    sprintf("%s\n%d (%.0f%%)", base_lab, cnt, pct)
  ord_v <- if (sort_vars) order(-pct) else seq_along(vars)
  ord_r <- if (sort_rows) order(row_na, decreasing = TRUE) else seq_len(n)
  lev_v <- if (vert) rev(vlab[ord_v]) else vlab[ord_v]
  lev_r <- if (vert) ids[ord_r] else rev(ids[ord_r])

  long <- tibble::tibble(.row = factor(rep(ids, times = length(vars)), levels = lev_r),
                         .grp = rep(grp, times = length(vars)),
                         Variable = factor(rep(vlab, each = n), levels = lev_v),
                         Status = factor(ifelse(as.vector(na_mat), "Missing", "Observed"),
                                         levels = c("Missing", "Observed")))
  if (identical(show_ids, "auto")) show_ids <- n <= 60
  border <- if (identical(tile_border, "auto")) (if (n <= 150) "white" else NA) else tile_border
  leg_lab <- c(Missing = sprintf("Missing (%d; %.1f%%)", sum(na_mat), 100 * mean(na_mat)),
               Observed = sprintf("Observed (%d)", sum(!na_mat)))
  xs <- x_text_size %||% max(base_size - 2, 6)
  ind_title <- sprintf("Individuals (n = %d)", n)
  no_ids <- function(axis) {
    if (axis == "x") ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank())
    else ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank())
  }

  # main map
  p_main <- ggplot2::ggplot(long, if (vert) ggplot2::aes(x = .row, y = Variable, fill = Status) else
    ggplot2::aes(x = Variable, y = .row, fill = Status)) +
    ggplot2::geom_tile(colour = border, linewidth = if (is.na(border)) 0 else 0.15) +
    ggplot2::scale_fill_manual(values = cols, labels = leg_lab, name = NULL, drop = FALSE) +
    ggplot2::scale_x_discrete(expand = c(0, 0)) + ggplot2::scale_y_discrete(expand = c(0, 0)) +
    theme_pub(base_size) +
    ggplot2::theme(panel.grid = ggplot2::element_blank(), legend.position = "bottom")
  if (vert) {
    p_main <- p_main + ggplot2::labs(x = if (show_ids) NULL else ind_title, y = NULL) +
      ggplot2::theme(axis.text.y = ggplot2::element_text(size = xs))
    p_main <- p_main + if (show_ids) theme_rotate_x(90, xs - 1) else no_ids("x")
    if (!is.null(group)) p_main <- p_main + ggplot2::facet_grid(. ~ .grp, scales = "free_x", space = "free_x")
  } else {
    p_main <- p_main + ggplot2::labs(x = NULL, y = if (show_ids) NULL else ind_title) +
      theme_rotate_x(x_angle, xs) + ggplot2::theme(axis.text.x = ggplot2::element_text(size = xs, lineheight = 0.85))
    p_main <- p_main + if (show_ids) ggplot2::theme(axis.text.y = ggplot2::element_text(size = xs - 1)) else no_ids("y")
    if (!is.null(group)) p_main <- p_main + ggplot2::facet_grid(.grp ~ ., scales = "free_y", space = "free_y")
  }

  sub <- subtitle %||% sprintf("%d individuals x %d variables | %.1f%% missing | %d complete individuals (%.0f%%)%s",
                               n, length(vars), 100 * mean(na_mat), sum(row_na == 0), 100 * mean(row_na == 0),
                               if (sort_rows) " | individuals sorted by number of missing values" else "")
  cap <- if (show_pct) "Variable labels: number (%) of missing values" else NULL
  title_theme <- ggplot2::theme(plot.title = ggplot2::element_text(size = ggplot2::rel(title_size), face = "bold"),
                                plot.subtitle = ggplot2::element_text(size = ggplot2::rel(1.05)))
  if (!margins) return(p_main + ggplot2::labs(title = title, subtitle = sub, caption = cap) + title_theme)

  # marginal bars
  bar_col <- cols[["Missing"]]
  pct_scale <- function(f) f(limits = c(0, 100), breaks = c(0, 50, 100), expand = c(0, 0),
                             labels = function(x) paste0(x, "%"))
  bar_theme <- theme_pub(base_size) +
    ggplot2::theme(panel.background = ggplot2::element_rect(fill = bar_bg, colour = NA),
                   panel.grid.major = ggplot2::element_line(colour = "white", linewidth = 0.5),
                   panel.grid.minor = ggplot2::element_blank())
  d_var <- tibble::tibble(Variable = factor(vlab, levels = lev_v), pct = pct)
  p_var <- if (vert) {
    ggplot2::ggplot(d_var, ggplot2::aes(pct, Variable)) +
      ggplot2::geom_col(fill = bar_col, width = 0.85, orientation = "y") +
      ggplot2::scale_y_discrete(expand = c(0, 0)) + pct_scale(ggplot2::scale_x_continuous) +
      ggplot2::labs(x = "% missing", y = NULL) + bar_theme + no_ids("y") +
      ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
  } else {
    ggplot2::ggplot(d_var, ggplot2::aes(Variable, pct)) +
      ggplot2::geom_col(fill = bar_col, width = 0.85) +
      ggplot2::scale_x_discrete(expand = c(0, 0)) + pct_scale(ggplot2::scale_y_continuous) +
      ggplot2::labs(x = NULL, y = "% missing") + bar_theme + no_ids("x") +
      ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  }
  # not drawn with groups: the subjects are split across panels
  d_ind <- tibble::tibble(.row = factor(ids, levels = lev_r), k = row_na)
  ind_scale <- function(f) f(limits = c(0, length(vars)), expand = c(0, 0))
  p_ind <- if (!is.null(group)) NULL else if (vert) {
    ggplot2::ggplot(d_ind, ggplot2::aes(.row, k)) +
      ggplot2::geom_col(fill = bar_col, width = 1) +
      ggplot2::scale_x_discrete(expand = c(0, 0)) + ind_scale(ggplot2::scale_y_continuous) +
      ggplot2::labs(x = NULL, y = "n missing") + bar_theme + no_ids("x") +
      ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  } else {
    ggplot2::ggplot(d_ind, ggplot2::aes(k, .row)) +
      ggplot2::geom_col(fill = bar_col, width = 1, orientation = "y") +
      ggplot2::scale_y_discrete(expand = c(0, 0)) + ind_scale(ggplot2::scale_x_continuous) +
      ggplot2::labs(x = "n missing", y = NULL) + bar_theme + no_ids("y") +
      ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
  }
  top <- if (vert) p_ind else p_var
  right <- if (vert) p_var else p_ind
  plots <- Filter(Negate(is.null), list(top, p_main, right))
  design <- if (!is.null(top) && !is.null(right)) "A#\nBC" else if (!is.null(top)) "A\nB" else "AB"
  heights <- if (grepl("\n", design)) c(1, 4) else 1
  widths <- if (grepl("C|AB", design)) c(6, 1) else 1
  patchwork::wrap_plots(plots, design = design, heights = heights, widths = widths, guides = "collect") +
    patchwork::plot_annotation(title = title, subtitle = sub, caption = cap,
                               theme = theme_pub(base_size) + title_theme) &
    ggplot2::theme(legend.position = "bottom")
}
