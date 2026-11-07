# Quarto output from a `results: asis` chunk --------------------------------------

#' Quarto output from a `results: asis` chunk
#'
#' @description
#' * `qmd_tabset()` prints a named list of objects (ggplot / patchwork, gt
#'   tables, kable tables, character vectors, data frames, nested lists) as a
#'   Quarto `panel-tabset`, one tab per element.
#' * `qmd_callout_raw()` prints the raw console output of one or several
#'   objects (`summary(fit)`, anova tables...) in a collapsed callout.
#'
#' Both write Markdown with [cat()]: use them in a chunk with the option
#' `#| results: asis`.
#'
#' @param items Named list of objects; the names become the tab titles.
#' @param level Heading level of the tab titles.
#' @param ... Named objects: each name becomes a sub-heading in the callout.
#' @param title Title of the callout.
#' @param collapse Collapse the callout.
#' @param width Console width used to print the objects.
#' @return `NULL`, invisibly (called for the printed Markdown).
#' @export
#' @examples
#' qmd_tabset(list(Summary = "Some text", Data = "More text"))
#' qmd_callout_raw(`Linear model` = summary(lm(MOCA_V0 ~ AGE, data = cohort_sim)))
qmd_tabset <- function(items, level = 3) {
  if (!length(items)) return(invisible(NULL))
  if (is.null(names(items)) || any(!nzchar(names(items)))) cli::cli_abort("{.arg items} must be a named list.")
  print_one <- function(obj) {
    if (is.null(obj)) {
      cat("*Not available (insufficient data).*\n\n")
    } else if (inherits(obj, "gt_tbl")) {
      cat(gt::as_raw_html(obj, inline_css = FALSE), "\n\n")
    } else if (inherits(obj, c("gg", "ggplot", "patchwork"))) {
      print(obj)
      cat("\n\n")
    } else if (inherits(obj, "knitr_kable")) {
      cat(obj, "\n\n")
    } else if (is.character(obj)) {
      cat(obj, sep = "\n")
      cat("\n\n")
    } else if (is.data.frame(obj)) {
      if (requireNamespace("gt", quietly = TRUE)) {
        cat(gt::as_raw_html(gt_pub(obj, decimals = 3), inline_css = FALSE), "\n\n")
      } else {
        print(obj)
        cat("\n\n")
      }
    } else if (is.list(obj)) {
      for (el in obj) print_one(el)
    } else {
      print(obj)
      cat("\n\n")
    }
  }
  cat("\n\n::: panel-tabset\n\n")
  for (nm in names(items)) {
    cat(paste0("\n\n", strrep("#", level)), nm, "\n\n")
    print_one(items[[nm]])
  }
  cat("\n:::\n\n")
  invisible(NULL)
}

#' @rdname qmd_tabset
#' @export
qmd_callout_raw <- function(..., title = "Raw model output", collapse = TRUE, width = 120) {
  objs <- list(...)
  cat(sprintf('\n\n::: {.callout-note collapse="%s"}\n## %s\n\n', tolower(collapse), title))
  old <- options(width = width)
  on.exit(options(old), add = TRUE)
  nms <- names(objs) %||% rep("", length(objs))
  for (k in seq_along(objs)) {
    if (nzchar(nms[k])) cat("**", nms[k], "**\n\n", sep = "")
    out <- if (is.character(objs[[k]])) objs[[k]] else utils::capture.output(print(objs[[k]]))
    cat("```\n", paste(out, collapse = "\n"), "\n```\n\n", sep = "")
  }
  cat(":::\n\n")
  invisible(NULL)
}
