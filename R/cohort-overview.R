# Cohort overview: the first table of an analysis ----------------------------------

#' Overview table of a cohort
#'
#' A preliminary table describing the data set at the start of an analysis:
#' one block of rows per variable with its type, number observed, missing
#' values, summary (overall and by group), a group comparison and a small text
#' histogram of the observed values.
#'
#' * Continuous and discrete variables: median \[Q1; Q3\] and range; text
#'   histogram of the observed values (8 bins).
#' * Categorical and binary variables: a header row, then one row per level
#'   with n (%) of the observed values and a bar proportional to the share.
#' * Dates: range.
#' * Group comparison (`by`, `test = TRUE`): Wilcoxon / Kruskal-Wallis for
#'   numeric variables, chi-squared or Fisher (expected counts < 5) for
#'   categorical ones; unadjusted p-values, for description only.
#' * Variables with more than `missing_warn` percent missing values are
#'   highlighted.
#'
#' @param data A data frame, one row per subject.
#' @param vars Variables to describe (names or tidyselect; default: all but
#'   `id_col` and `by`).
#' @param by Optional grouping column (e.g. treatment arm).
#' @param id_col Optional identifier column: the subtitle reports the number
#'   of unique identifiers and warns about duplicates.
#' @param blocks Optional named list `block -> variables`, shown as row
#'   groups (variables not listed go to "Other variables").
#' @param labels Optional named vector of labels.
#' @param test Compare the groups of `by`.
#' @param digits Decimals of the summaries.
#' @param spark Add the text-histogram column.
#' @param discrete_max Numeric variables with integer values and at most this
#'   number of distinct values are typed "Discrete".
#' @param missing_warn Share of missing values (%) above which the cell is
#'   highlighted.
#' @param title,subtitle Title and subtitle (`subtitle = NULL`: automatic
#'   summary of the data set).
#' @param output `"gt"` (formatted table, needs the gt package) or `"data"`
#'   (the underlying tibble).
#' @return A `gt_tbl` or a tibble (`output = "data"`).
#' @export
#' @examples
#' describe_cohort(cohort_sim, vars = c(AGE, SEX, BMI, NFL_V0, MOCA_V0, FALL_V0),
#'                 by = GROUP, id_col = ID, output = "data")
#' @examplesIf rlang::is_installed("gt")
#' describe_cohort(cohort_sim, vars = c(AGE, SEX, BMI, NFL_V0, IL6_V0, MOCA_V0, FALL_V0),
#'                 by = GROUP, id_col = ID,
#'                 blocks = list(Demography = c("AGE", "SEX", "BMI"),
#'                               Biomarkers = c("NFL_V0", "IL6_V0"),
#'                               Clinical = c("MOCA_V0", "FALL_V0")))
describe_cohort <- function(data, vars = NULL, by = NULL, id_col = NULL, blocks = NULL,
                            labels = NULL, test = TRUE, digits = 1, spark = TRUE,
                            discrete_max = 15, missing_warn = 20,
                            title = "Cohort overview", subtitle = NULL,
                            output = c("gt", "data")) {
  output <- match.arg(output)
  data <- as.data.frame(.as_df(data))
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  by <- .select(rlang::enquo(by), data, "by", single = TRUE)
  vars <- .select(rlang::enquo(vars), data, "vars") %||% names(data)
  vars <- setdiff(vars, c(id_col, by))
  if (!length(vars)) cli::cli_abort("No variable to describe.")
  .check_flag(test, "test")
  .check_flag(spark, "spark")

  grp <- if (!is.null(by)) droplevels(as.factor(data[[by]])) else NULL
  if (!is.null(grp) && anyNA(grp)) {
    cli::cli_inform(c("i" = "{sum(is.na(grp))} subject(s) without {.field {by}}: counted in Overall only."))
  }
  block_of <- stats::setNames(rep(NA_character_, length(vars)), vars)
  if (!is.null(blocks)) {
    if (!is.list(blocks) || is.null(names(blocks))) cli::cli_abort("{.arg blocks} must be a named list.")
    for (b in names(blocks)) block_of[intersect(blocks[[b]], vars)] <- b
    block_of[is.na(block_of)] <- "Other variables"
    vars <- vars[order(match(block_of[vars], c(names(blocks), "Other variables")))]
  }

  rows <- lapply(vars, function(v) {
    r <- .cohort_rows(data[[v]], label_get(v, labels), grp, test, digits, discrete_max)
    r$.var <- v
    r$.block <- block_of[[v]]
    r
  })
  tab <- dplyr::bind_rows(rows)
  if (!spark) tab$Distribution <- NULL

  n <- nrow(data)
  cc <- sum(stats::complete.cases(data[, vars, drop = FALSE]))
  id_txt <- if (!is.null(id_col)) {
    nu <- dplyr::n_distinct(data[[id_col]], na.rm = TRUE)
    if (nu < n) cli::cli_warn("{n - nu} duplicated or missing value(s) in {.field {id_col}}.")
    sprintf(" (%d unique identifiers)", nu)
  } else ""
  sub <- subtitle %||% sprintf("%d subjects%s | %d variables | %d complete subjects (%.0f%%)%s",
                               n, id_txt, length(vars), cc, 100 * cc / max(n, 1),
                               if (!is.null(grp)) paste0(" | by ", label_get(by, labels)) else "")
  attr(tab, "subtitle") <- sub
  if (output == "data") return(tibble::as_tibble(tab))

  .need("gt", "to format the cohort overview table.")
  grp_cols <- if (!is.null(grp)) levels(grp) else character(0)
  tests <- unique(stats::na.omit(tab$.test))
  shown <- c("Variable", "Type", "N", "Missing", "Overall", "Range", grp_cols,
             if (length(grp_cols) && test) "p", if (spark) "Distribution")
  disp <- tab[, c(shown, ".block", ".is_level", ".pct_missing"), drop = FALSE]
  tb <- gt::gt(disp, groupname_col = if (!is.null(blocks)) ".block" else NULL)
  tb <- gt::cols_hide(tb, columns = dplyr::any_of(c(".block", ".is_level", ".pct_missing")))
  tb <- gt::tab_header(tb, title = gt::md(paste0("**", title, "**")), subtitle = sub)
  if (length(grp_cols)) {
    n_by <- table(grp)
    lab_by <- lapply(stats::setNames(grp_cols, grp_cols),
                     function(g) gt::html(sprintf("%s<br>(n = %d)", g, as.integer(n_by[[g]]))))
    tb <- gt::cols_label(tb, .list = lab_by)
    tb <- gt::tab_spanner(tb, label = label_get(by, labels), columns = dplyr::all_of(grp_cols))
  }
  tb <- gt::cols_label(tb, Overall = gt::html(sprintf("Overall<br>(n = %d)", n)))
  # summaries kept on one line ("13.0 [8.4; 17.3]"), the table scrolls instead of wrapping
  tb <- gt::tab_style(tb, gt::cell_text(whitespace = "nowrap"),
                      gt::cells_body(columns = dplyr::any_of(c("Overall", "Range", grp_cols))))
  tb <- gt::sub_missing(tb, columns = "N", missing_text = "")
  if ("p" %in% shown) {
    tb <- gt::fmt(tb, columns = "p", fns = function(x) ifelse(is.na(x), "", fmt_p(x)))
    sig <- which(!is.na(disp$p) & disp$p < 0.05)
    if (length(sig)) tb <- gt::tab_style(tb, gt::cell_text(weight = "bold"),
                                         gt::cells_body(columns = "p", rows = sig))
  }
  head_rows <- which(!disp$.is_level)
  level_rows <- which(disp$.is_level)
  if (length(head_rows)) {
    tb <- gt::tab_style(tb, gt::cell_text(weight = "bold"), gt::cells_body(columns = "Variable", rows = head_rows))
  }
  if (length(level_rows)) {
    tb <- gt::tab_style(tb, gt::cell_text(indent = gt::px(18), color = "#444444"),
                        gt::cells_body(columns = "Variable", rows = level_rows))
  }
  warn_rows <- which(!is.na(disp$.pct_missing) & disp$.pct_missing > missing_warn)
  if (length(warn_rows)) {
    tb <- gt::tab_style(tb, list(gt::cell_fill(color = "#FDE0C5"), gt::cell_text(color = "#A63603", weight = "bold")),
                        gt::cells_body(columns = "Missing", rows = warn_rows))
  }
  if (spark) {
    tb <- gt::tab_style(tb, gt::cell_text(font = c("Consolas", "Menlo", "DejaVu Sans Mono", "monospace"),
                                          color = "#3B8EA5", whitespace = "pre"),
                        gt::cells_body(columns = "Distribution"))
  }
  tb <- gt::cols_align(tb, align = "center", columns = dplyr::any_of(c("Type", "N", "Missing", "p")))
  note <- paste0(
    "Continuous / discrete: median [Q1; Q3] and range; categorical: n (%) of the observed values. ",
    "Missing: n (% of subjects)", if (length(warn_rows)) sprintf(", highlighted above %g%%", missing_warn), ". ",
    if (spark) "Distribution: histogram of the observed values (8 bins) or share of each level. " else "",
    if (length(tests) && "p" %in% shown) sprintf("p: %s, unadjusted (description only).", paste(tests, collapse = " / ")) else "")
  tb <- gt::tab_source_note(tb, note)
  gt::tab_options(tb, table.font.size = gt::px(12), heading.align = "left",
                  heading.title.font.size = gt::px(18), heading.subtitle.font.size = gt::px(12),
                  column_labels.font.weight = "bold", row_group.font.weight = "bold",
                  row_group.background.color = "#ECF0F1", data_row.padding = gt::px(3),
                  table.border.top.color = "#2C3E50", column_labels.border.bottom.color = "#2C3E50",
                  source_notes.font.size = gt::px(10))
}

#' Rows of one variable in the cohort overview
#' @noRd
.cohort_rows <- function(x, label, grp, test, digits, discrete_max) {
  n_all <- length(x)
  n_obs <- sum(!is.na(x))
  pct_miss <- 100 * (n_all - n_obs) / max(n_all, 1)
  miss_txt <- sprintf("%d (%.0f%%)", n_all - n_obs, pct_miss)
  grp_lev <- if (!is.null(grp)) levels(grp) else character(0)
  num <- function(v) fmt_num(v, digits)
  base <- function(type, overall, range = "", p = NA_real_, test_name = NA_character_, spark = "") {
    out <- tibble::tibble(Variable = label, Type = type, N = n_obs, Missing = miss_txt,
                          Overall = overall, Range = range)
    for (g in grp_lev) out[[g]] <- ""
    out$p <- p
    out$Distribution <- spark
    out$.test <- test_name
    out$.is_level <- FALSE
    out$.pct_missing <- pct_miss
    out
  }
  xo <- x[!is.na(x)]

  if (inherits(x, c("Date", "POSIXt"))) {
    rng <- if (length(xo)) paste(format(min(xo)), "to", format(max(xo))) else ""
    return(base("Date", rng))
  }
  is_cat <- is.factor(x) || is.character(x) || is.logical(x) ||
    (is.numeric(x) && length(unique(xo)) <= 2)
  if (!is_cat) {
    ux <- unique(xo)
    integer_valued <- length(ux) && all(abs(ux - round(ux)) < 1e-8)
    type <- if (integer_valued && length(ux) <= discrete_max) "Discrete" else "Continuous"
    summ <- function(z) {
      if (!length(z)) return("")
      q <- stats::quantile(z, c(0.25, 0.5, 0.75), names = FALSE)
      sprintf("%s [%s; %s]", num(q[2]), num(q[1]), num(q[3]))
    }
    tst <- if (test && !is.null(grp)) .group_test(x, grp, "continuous", "nonparametric") else NULL
    out <- base(type, summ(xo), if (length(xo)) paste(num(min(xo)), "to", num(max(xo))) else "",
                p = if (!is.null(tst)) tst$p else NA_real_,
                test_name = if (!is.null(tst)) tst$name else NA_character_,
                spark = .spark_hist(xo))
    for (g in grp_lev) out[[g]] <- summ(x[!is.na(x) & !is.na(grp) & grp == g])
    return(out)
  }
  f <- if (is.factor(x)) droplevels(x) else factor(x)
  lev <- levels(f)
  tst <- if (test && !is.null(grp)) .group_test(f, grp, "categorical") else NULL
  head <- base(if (length(lev) <= 2) "Binary" else "Categorical", "",
               p = if (!is.null(tst)) tst$p else NA_real_,
               test_name = if (!is.null(tst)) tst$name else NA_character_)
  nt <- function(z, l) {
    z <- z[!is.na(z)]
    if (!length(z)) return("")
    sprintf("%d (%.0f%%)", sum(z == l), 100 * mean(z == l))
  }
  lv <- dplyr::bind_rows(lapply(lev, function(l) {
    pct <- if (n_obs) 100 * mean(f[!is.na(f)] == l) else 0
    r <- tibble::tibble(Variable = l, Type = "", N = NA_integer_, Missing = "", Overall = nt(f, l), Range = "")
    for (g in grp_lev) r[[g]] <- nt(f[!is.na(grp) & grp == g], l)
    r$p <- NA_real_
    r$Distribution <- strrep("\u2588", round(pct / 10))
    r$.test <- NA_character_
    r$.is_level <- TRUE
    r$.pct_missing <- NA_real_
    r
  }))
  dplyr::bind_rows(head, lv)
}

#' Text histogram of a numeric vector (Unicode block characters)
#' @noRd
.spark_hist <- function(x, bins = 8) {
  x <- x[is.finite(x)]
  if (length(x) < 2 || length(unique(x)) < 2) return("")
  counts <- .hist_counts(x, bins)
  blocks <- c("\u2581", "\u2582", "\u2583", "\u2584", "\u2585", "\u2586", "\u2587", "\u2588")
  idx <- ifelse(counts == 0, 0L, pmax(1L, as.integer(ceiling(8 * counts / max(counts)))))
  paste(ifelse(idx == 0, " ", blocks[pmax(idx, 1L)]), collapse = "")
}

#' Counts of equal-width bins
#' @noRd
.hist_counts <- function(x, bins) {
  br <- seq(min(x), max(x), length.out = bins + 1)
  as.integer(table(cut(x, br, include.lowest = TRUE)))
}
