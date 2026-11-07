# Internal helpers (not exported) -------------------------------------------

#' Keep the elements of `x` present in `table` (order of `x` kept); report or
#' reject the missing ones
#' @noRd
.keep_existing <- function(x, table, arg = "vars", strict = FALSE, quiet = FALSE,
                           call = rlang::caller_env()) {
  x <- as.character(x)
  missing <- setdiff(x, table)
  if (length(missing)) {
    if (strict) {
      cli::cli_abort(c("Column(s) not found in the data: {.val {missing}}.",
                       "i" = "Check {.arg {arg}}."), call = call)
    }
    if (!quiet) {
      cli::cli_inform(c("!" = "{.arg {arg}}: {length(missing)} column(s) not found, ignored: {.val {missing}}."))
    }
  }
  intersect(x, table)
}

#' Resolve a column selection given as a character vector (directly or through
#' a variable), bare column names or tidyselect helpers
#'
#' * character vectors keep the historical lenient behaviour (missing names are
#'   dropped with a message), unless `strict = TRUE`;
#' * anything else goes through `tidyselect::eval_select()`.
#' @noRd
.select <- function(quo, data, arg, single = FALSE, strict = FALSE,
                    call = rlang::caller_env()) {
  if (rlang::quo_is_missing(quo) || rlang::quo_is_null(quo)) return(NULL)
  nms <- names(data)
  expr <- rlang::quo_get_expr(quo)
  if (rlang::is_symbol(expr) && rlang::as_string(expr) %in% nms) {
    out <- rlang::as_string(expr)
  } else {
    failed <- structure(list(), class = "vernissage_eval_failed")
    val <- if (is.character(expr)) expr else
      tryCatch(rlang::eval_tidy(quo), error = function(e) failed)
    if (is.null(val)) return(NULL)
    if (is.character(val)) {
      out <- .keep_existing(val, nms, arg = arg, strict = strict || single, call = call)
    } else if (inherits(val, "vernissage_eval_failed") && rlang::is_symbol(expr)) {
      # a bare name that is neither a column nor an object
      cli::cli_abort(c("Column {.val {rlang::as_string(expr)}} not found in the data.",
                       "i" = "Check {.arg {arg}}."), call = call)
    } else {
      pos <- tidyselect::eval_select(quo, data, allow_rename = FALSE, error_call = call)
      out <- names(pos)
    }
  }
  if (single && length(out) != 1) {
    cli::cli_abort("{.arg {arg}} must select exactly one column, not {length(out)}.", call = call)
  }
  out
}

#' Data frame (a matrix is converted), with an informative error otherwise
#' @noRd
.as_df <- function(data, arg = "data", call = rlang::caller_env()) {
  if (is.matrix(data)) data <- as.data.frame(data, stringsAsFactors = FALSE)
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg {arg}} must be a data frame or a matrix, not {.obj_type_friendly {data}}.",
                   call = call)
  }
  data
}

#' Single number (optionally within bounds)
#' @noRd
.check_number <- function(x, arg, min = -Inf, max = Inf, call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1 || is.na(x) || x < min || x > max) {
    cli::cli_abort("{.arg {arg}} must be a single number between {min} and {max}.", call = call)
  }
  invisible(x)
}

#' Single logical
#' @noRd
.check_flag <- function(x, arg, call = rlang::caller_env()) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort("{.arg {arg}} must be {.code TRUE} or {.code FALSE}.", call = call)
  }
  invisible(x)
}

#' Rows with every listed column observed
#' @noRd
.complete_subset <- function(data, cols) {
  d <- as.data.frame(data)[, unique(cols), drop = FALSE]
  d[stats::complete.cases(d), , drop = FALSE]
}

#' Skewness g1 = m3 / m2^(3/2) (moment estimator, same as e1071::skewness(type = 1))
#' @noRd
.skewness <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3 || stats::sd(x) == 0) return(NA_real_)
  m <- mean(x)
  s <- sqrt(mean((x - m)^2))
  mean((x - m)^3) / s^3
}

#' Excess kurtosis g2 = m4 / m2^2 - 3 (same as e1071::kurtosis(type = 1))
#' @noRd
.kurtosis_excess <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 4 || stats::sd(x) == 0) return(NA_real_)
  m <- mean(x)
  s2 <- mean((x - m)^2)
  mean((x - m)^4) / s2^2 - 3
}

#' Shapiro-Wilk W of a vector (NA if not computable)
#' @noRd
.sw_W <- function(y) {
  y <- y[is.finite(y)]
  if (length(y) < 3 || length(y) > 5000 || stats::sd(y) == 0) return(NA_real_)
  unname(stats::shapiro.test(y)$statistic)
}

#' Cohen's kappa of two classifications with the same levels
#' @noRd
.cohen_kappa <- function(a, b, levels = NULL) {
  levels <- levels %||% sort(unique(c(as.character(a), as.character(b))))
  tab <- table(factor(a, levels = levels), factor(b, levels = levels))
  n <- sum(tab)
  if (n == 0) return(NA_real_)
  po <- sum(diag(tab)) / n
  pe <- sum(rowSums(tab) * colSums(tab)) / n^2
  if (pe < 1) (po - pe) / (1 - pe) else NA_real_
}

#' Names of the columns holding p-values: a separate token "p" or "FDR"
#' @noRd
.detect_p_cols <- function(nms) nms[grepl("(^|[^[:alnum:]])p([^[:alnum:]]|$)|FDR", nms)]

#' Group comparison adapted to the variable type; list(name, p) or NULL
#' @noRd
.group_test <- function(x, g, kind = c("continuous", "categorical"),
                        test = c("auto", "nonparametric", "parametric", "none")) {
  kind <- match.arg(kind)
  test <- match.arg(test)
  if (test == "none" || is.null(g)) return(NULL)
  ok <- !is.na(x) & !is.na(g)
  x <- x[ok]
  g <- droplevels(as.factor(g[ok]))
  k <- nlevels(g)
  if (k < 2 || any(table(g) < 2)) return(NULL)
  if (kind == "categorical") {
    tab <- table(droplevels(as.factor(x)), g)
    if (nrow(tab) < 2) return(NULL)
    if (suppressWarnings(min(stats::chisq.test(tab)$expected)) < 5) {
      r <- tryCatch(stats::fisher.test(tab, simulate.p.value = any(dim(tab) > 2), B = 1e4),
                    error = function(e) NULL)
      return(if (is.null(r)) NULL else list(name = "Fisher", p = r$p.value))
    }
    return(list(name = "Chi\u00b2", p = suppressWarnings(stats::chisq.test(tab))$p.value))
  }
  if (length(unique(x)) < 2) return(NULL)
  param <- test == "parametric"
  if (k == 2) {
    if (param) list(name = "Welch t-test", p = stats::t.test(x ~ g)$p.value)
    else list(name = "Wilcoxon", p = suppressWarnings(stats::wilcox.test(x ~ g, exact = FALSE))$p.value)
  } else {
    if (param) list(name = "Welch ANOVA", p = stats::oneway.test(x ~ g)$p.value)
    else list(name = "Kruskal-Wallis", p = stats::kruskal.test(x ~ g)$p.value)
  }
}

#' Capitalise the first letter
#' @noRd
.capitalise <- function(x) paste0(toupper(substring(x, 1, 1)), substring(x, 2))

#' Abort when an optional package is missing
#' @noRd
.need <- function(pkg, reason) rlang::check_installed(pkg, reason = reason)

#' Can the graphics device draw non-Latin-1 characters?
#'
#' Option `vernissage.unicode`: `TRUE`, `FALSE` or `"auto"` (default). In
#' `"auto"` mode, Unicode symbols are used unless the open device (or, when none
#' is open, the default device) is one of the classic `pdf()` / `postscript()`
#' devices, which cannot draw characters outside Latin-1 (e.g. R CMD check,
#' `ggsave("plot.pdf")`).
#' @noRd
.unicode_ok <- function() {
  opt <- getOption("vernissage.unicode", "auto")
  if (!identical(opt, "auto")) return(isTRUE(opt))
  if (!isTRUE(l10n_info()[["UTF-8"]])) return(FALSE)
  dev <- names(grDevices::dev.cur())
  if (identical(dev, "null device")) {
    d <- getOption("device")
    dev <- if (is.character(d)) d
      else if (is.function(d) && identical(d, grDevices::pdf)) "pdf"
      else if (is.function(d) && identical(d, grDevices::postscript)) "postscript"
      else if (is.null(d)) "pdf"
      else "other"
  }
  !dev %in% c("pdf", "postscript", "xfig", "pictex")
}

#' Text for a figure: Unicode symbols, or an ASCII equivalent when the device
#' cannot draw them (see .unicode_ok())
#' @noRd
.u <- function(x) {
  if (is.null(x) || !is.character(x) || .unicode_ok()) return(x)
  sup <- "\u2070\u00b9\u00b2\u00b3\u2074\u2075\u2076\u2077\u2078\u2079\u207b"
  x <- gsub(paste0("\u00d710([", sup, "]+)"), "x10^\\1", x)
  x <- chartr(sup, "0123456789-", x)
  map <- c("\u03c1" = "rho", "\u03b2" = "beta", "\u0394" = "Delta", "\u2212" = "-", "\u2013" = "-",
           "\u2014" = "-", "\u2265" = ">=", "\u2264" = "<=", "\u2192" = "->", "\u25c7" = "<>",
           "\u221a" = "sqrt ")
  for (k in names(map)) x <- gsub(k, map[[k]], x, fixed = TRUE)
  x
}
