# Publication tables (gt) and interactive tables (DT) -----------------------------

#' Publication table with gt
#'
#' Numbers rounded (scientific notation when they would print as 0, see
#' [fmt_num()]), whole-number columns without decimals, p-value columns
#' detected from their name (a separate token `p`, e.g. `p`, `p.value`,
#' `p_adj`, `McNemar p`, or `FDR`) and formatted with [fmt_p()], bold when
#' below 0.05, missing p-values shown as a dash; optional source note.
#'
#' @param df A data frame.
#' @param title,subtitle Title and subtitle (Markdown).
#' @param groupname_col Optional column defining row groups.
#' @param p_cols Columns of p-values, in addition to those detected.
#' @param decimals Decimals of the other numeric columns.
#' @param font_size Font size, in pixels.
#' @param note Optional source note (Markdown), e.g. model, adjustment, N.
#' @param auto_p Detect p-value columns from their names.
#' @return A `gt_tbl`.
#' @export
#' @examplesIf rlang::is_installed("gt")
#' tab <- describe_normality(cohort_sim, c(AGE, NFL_V0, CRP_V0))
#' gt_pub(tab, title = "Normality", note = "Shapiro-Wilk test")
gt_pub <- function(df, title = NULL, subtitle = NULL, groupname_col = NULL, p_cols = NULL,
                   decimals = 2, font_size = 12, note = NULL, auto_p = TRUE) {
  .need("gt", "to build gt tables.")
  df <- .as_df(df, "df")
  tb <- gt::gt(df, groupname_col = groupname_col)
  if (!is.null(title)) {
    tb <- gt::tab_header(tb, title = gt::md(title), subtitle = if (!is.null(subtitle)) gt::md(subtitle) else NULL)
  }
  dbl_cols <- names(df)[vapply(df, is.double, logical(1))]
  if (auto_p) p_cols <- union(p_cols, .detect_p_cols(dbl_cols))
  num_cols <- setdiff(dbl_cols, p_cols)
  for (nc in num_cols) {
    x <- df[[nc]]
    whole <- all(is.na(x) | (is.finite(x) & abs(x - round(x)) < 1e-9 & abs(x) < 1e6))
    tb <- gt::fmt(tb, columns = dplyr::all_of(nc),
                  fns = if (whole) function(v) ifelse(is.na(v), "NA", formatC(v, format = "d", big.mark = ""))
                        else function(v) fmt_num(v, decimals))
  }
  for (pc in intersect(p_cols, names(df))) {
    tb <- gt::fmt(tb, columns = dplyr::all_of(pc), fns = function(x) ifelse(is.na(x), "\u2013", fmt_p(x)))
    sig_rows <- which(!is.na(df[[pc]]) & df[[pc]] < 0.05)
    if (length(sig_rows)) {
      tb <- gt::tab_style(tb, style = gt::cell_text(weight = "bold"),
                          locations = gt::cells_body(columns = dplyr::all_of(pc), rows = sig_rows))
    }
  }
  if (!is.null(note)) tb <- gt::tab_source_note(tb, gt::md(note))
  gt::tab_options(tb, table.font.size = gt::px(font_size), row_group.font.weight = "bold",
                  heading.title.font.weight = "bold")
}

#' Colours of significance highlighting
#'
#' Three shades of green (ColorBrewer "Greens", colour-blind safe, readable in
#' print): `nominal` (p < 0.05 unadjusted, light), `fdr` (significant after
#' Benjamini-Hochberg, medium) and `robust` (association found again across
#' analyses, dark).
#'
#' @return Named character vector.
#' @export
#' @examples
#' gt_sig_colors()
gt_sig_colors <- function() c(nominal = "#E5F5E0", fdr = "#A1D99B", robust = "#238B45")

#' Highlight significant results in gt tables
#'
#' @description
#' * `gt_signif()` colours cells: numeric unadjusted p-values below `alpha`
#'   (light green), numeric adjusted p-values below `alpha` (medium green,
#'   bold), and text cells "effect; p = ..." (light green when p < `alpha`,
#'   medium green bold when the cell ends with `*`).
#' * `gt_highlight_rows()` colours whole rows (selected columns), e.g. robust
#'   associations (dark green, white bold text).
#' * `gt_signif_legend()` adds a legend of the colours under the table.
#'
#' Use after any theme function: the cell styles are added on top of it.
#'
#' @param x A `gt_tbl`.
#' @param p_cols Numeric columns of unadjusted p-values.
#' @param fdr_cols Numeric columns of adjusted p-values.
#' @param text_cols Text columns containing `"p = ..."`.
#' @param alpha Significance level.
#' @param colors Named colours `nominal`, `fdr`, `robust` (see [gt_sig_colors()]).
#' @param legend Add the colour legend.
#' @param rows Logical vector or indices of the rows to highlight.
#' @param columns Columns to colour (default: the first two).
#' @param level `"robust"`, `"fdr"` or `"nominal"`.
#' @param robust,fdr Show these entries in the legend.
#' @return A `gt_tbl`.
#' @export
#' @examplesIf rlang::is_installed("gt")
#' cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0))
#' gt_pub(cm$long) |>
#'   gt_signif(p_cols = "p", fdr_cols = "p_adj") |>
#'   gt_highlight_rows(cm$long$p_adj < 0.01, columns = c("Var1", "Var2"))
gt_signif <- function(x, p_cols = NULL, fdr_cols = NULL, text_cols = NULL, alpha = 0.05,
                      colors = gt_sig_colors(), legend = TRUE) {
  .need("gt", "to style gt tables.")
  if (!inherits(x, "gt_tbl")) cli::cli_abort("{.arg x} must be a gt table.")
  dat <- x[["_data"]]
  for (col in intersect(p_cols, names(dat))) {
    x <- .gt_paint(x, col, which(dat[[col]] < alpha), colors[["nominal"]])
  }
  for (col in intersect(fdr_cols, names(dat))) {
    x <- .gt_paint(x, col, which(dat[[col]] < alpha), colors[["fdr"]], bold = TRUE)
  }
  for (col in intersect(text_cols, names(dat))) {
    p <- .p_from_text(dat[[col]])
    fdr <- grepl("\\*\\s*$", as.character(dat[[col]]))
    x <- .gt_paint(x, col, which(p < alpha & !fdr), colors[["nominal"]])
    x <- .gt_paint(x, col, which(fdr), colors[["fdr"]], bold = TRUE)
  }
  if (legend) x <- gt_signif_legend(x, colors, alpha, robust = FALSE, fdr = length(c(fdr_cols, text_cols)) > 0)
  x
}

#' @rdname gt_signif
#' @export
gt_highlight_rows <- function(x, rows, columns = NULL, level = c("robust", "fdr", "nominal"),
                              colors = gt_sig_colors()) {
  .need("gt", "to style gt tables.")
  level <- match.arg(level)
  dat <- x[["_data"]]
  if (is.logical(rows)) rows <- which(rows)
  columns <- columns %||% names(dat)[1:2]
  for (col in intersect(columns, names(dat))) {
    x <- .gt_paint(x, col, rows, colors[[level]], bold = TRUE,
                   text_color = if (level == "robust") "white" else NULL)
  }
  x
}

#' @rdname gt_signif
#' @export
gt_signif_legend <- function(x, colors = gt_sig_colors(), alpha = 0.05, robust = TRUE, fdr = TRUE) {
  .need("gt", "to style gt tables.")
  sq <- function(col) {
    sprintf("<span style='display:inline-block;width:0.9em;height:0.9em;background:%s;border:1px solid #999;vertical-align:middle;margin:0 0.3em 0 0.8em;'></span>", col)
  }
  txt <- paste0(sq(colors[["nominal"]]), sprintf("p &lt; %s", alpha),
                if (fdr) paste0(sq(colors[["fdr"]]), sprintf("significant after FDR (&lt; %s)", alpha)) else "",
                if (robust) paste0(sq(colors[["robust"]]), "robust across analyses") else "")
  gt::tab_source_note(x, gt::html(txt))
}

#' @noRd
.gt_paint <- function(x, col, rows, fill, bold = FALSE, text_color = NULL) {
  rows <- rows[!is.na(rows)]
  if (!length(rows)) return(x)
  st <- list(gt::cell_fill(color = fill))
  if (bold || !is.null(text_color)) {
    st <- c(st, list(gt::cell_text(weight = if (bold) "bold" else NULL, color = text_color)))
  }
  gt::tab_style(x, style = st, locations = gt::cells_body(columns = dplyr::all_of(col), rows = rows))
}

#' p-value written in a text cell ("+4.55; p = 0.0024 *")
#' @noRd
.p_from_text <- function(txt) {
  txt <- as.character(txt)
  txt <- chartr("\u2070\u00b9\u00b2\u00b3\u2074\u2075\u2076\u2077\u2078\u2079\u207b", "0123456789-", txt)
  txt <- gsub("\u00d710", "e", txt)
  p <- suppressWarnings(as.numeric(sub("^.*p = <?\\s*([0-9.]+(e-?[0-9]+)?).*$", "\\1", txt)))
  p[!grepl("p = ", txt)] <- NA_real_
  p
}

#' Interactive table with export buttons
#'
#' A [DT::datatable()] with column filters and CSV / Excel buttons.
#'
#' @param df A data frame.
#' @param caption Optional caption.
#' @param page_length Rows per page.
#' @param digits Optional number of significant digits of the double columns.
#' @return An htmlwidget.
#' @export
#' @examplesIf rlang::is_installed("DT")
#' dt_export(na_summary(cohort_sim, list(All = names(cohort_sim))))
dt_export <- function(df, caption = NULL, page_length = 10, digits = NULL) {
  .need("DT", "to build interactive tables.")
  df <- .as_df(df, "df")
  if (!is.null(digits)) df <- dplyr::mutate(df, dplyr::across(tidyselect::where(is.double), function(x) signif(x, digits)))
  DT::datatable(df, caption = caption, rownames = FALSE, filter = "top", extensions = "Buttons",
                options = list(dom = "Bfrtip", buttons = c("csv", "excel"),
                               pageLength = page_length, scrollX = TRUE))
}
