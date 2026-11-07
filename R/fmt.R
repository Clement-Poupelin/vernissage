# Number and p-value formatting -----------------------------------------------

#' Format numbers and p-values for figures and tables
#'
#' @description
#' * `fmt_sci()` writes numbers in scientific notation with a multiplication
#'   sign and Unicode superscript exponents (2.1 x 10 to the power -6 is
#'   printed with a raised `-6`), readable in gt tables, DT tables, ggplot2
#'   texts and inline text without LaTeX.
#' * `fmt_num()` uses fixed decimals, and switches to scientific notation when
#'   the value would print as 0 (`|x| < 0.5 x 10^-digits`) or is very large
#'   (`|x| >= 1e6`).
#' * `fmt_p()` formats p-values: `"0.023"`, `"0.0024"`, and scientific
#'   notation below `sci_below`; values under the machine precision are
#'   written as "< 2.2 x 10 to the power -16".
#' * `fmt_stars()` converts p-values into significance stars.
#'
#' @param x,p Numeric vector (`NA` allowed).
#' @param digits Significant digits of the mantissa (`fmt_sci()`, `fmt_p()`)
#'   or number of decimals (`fmt_num()`).
#' @param sci_digits Significant digits used when `fmt_num()` switches to
#'   scientific notation.
#' @param sci_below p-values below this threshold are written in scientific
#'   notation.
#' @param ns Symbol of a non-significant p-value.
#' @param trend If `TRUE`, `"."` marks `0.05 <= p < 0.10`.
#'
#' @return A character vector of the same length as the input
#'   (`"NA"` for missing values, `""` in `fmt_stars()`).
#' @export
#' @examples
#' fmt_sci(c(0.000021, 123456789))
#' fmt_num(c(1.23456, 0.0001, NA), digits = 2)
#' fmt_p(c(0.2, 0.0312, 0.00012, 1e-20))
#' fmt_stars(c(0.2, 0.07, 0.03, 0.004, 0.0001))
fmt_sci <- function(x, digits = 2) {
  .check_numeric_input(x, "x")
  sup <- function(e) {
    chartr("0123456789-",
           "\u2070\u00b9\u00b2\u00b3\u2074\u2075\u2076\u2077\u2078\u2079\u207b",
           as.character(e))
  }
  vapply(x, function(v) {
    if (is.na(v)) return("NA")
    if (!is.finite(v)) return(as.character(v))
    if (v == 0) return("0")
    e <- floor(log10(abs(v)))
    m <- signif(v / 10^e, digits)
    if (abs(m) >= 10) {                       # rounding 9.96 -> 10.0
      m <- m / 10
      e <- e + 1
    }
    paste0(formatC(m, format = "f", digits = max(digits - 1, 0)), "\u00d710", sup(e))
  }, character(1), USE.NAMES = FALSE)
}

#' @rdname fmt_sci
#' @export
fmt_num <- function(x, digits = 2, sci_digits = 2) {
  .check_numeric_input(x, "x")
  vapply(x, function(v) {
    if (is.na(v)) return("NA")
    if (!is.finite(v)) return(as.character(v))
    if (v != 0 && (abs(v) < 0.5 * 10^-digits || abs(v) >= 1e6)) return(fmt_sci(v, sci_digits))
    formatC(v, format = "f", digits = digits)
  }, character(1), USE.NAMES = FALSE)
}

#' @rdname fmt_sci
#' @export
fmt_p <- function(p, digits = 2, sci_below = 0.001) {
  .check_numeric_input(p, "p")
  # element by element: format.pval() on a vector pads every value to the same width
  vapply(p, function(v) {
    if (is.na(v)) return("NA")
    if (v < .Machine$double.eps) return(paste0("<", fmt_sci(.Machine$double.eps, 2)))
    if (v < sci_below) return(fmt_sci(v, digits))
    format.pval(v, digits = digits)
  }, character(1), USE.NAMES = FALSE)
}

#' @rdname fmt_sci
#' @export
fmt_stars <- function(p, ns = "ns", trend = TRUE) {
  .check_numeric_input(p, "p")
  dplyr::case_when(
    is.na(p)         ~ "",
    p < 0.001        ~ "***",
    p < 0.01         ~ "**",
    p < 0.05         ~ "*",
    trend & p < 0.10 ~ ".",
    TRUE             ~ ns
  )
}

#' @noRd
.check_numeric_input <- function(x, arg, call = rlang::caller_env()) {
  if (!is.numeric(x) && !all(is.na(x))) {
    cli::cli_abort("{.arg {arg}} must be numeric, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}
