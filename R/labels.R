# Readable labels -------------------------------------------------------------

#' Readable labels of variables
#'
#' `label_get()` looks variable names up in a named vector of labels and falls
#' back to the raw name. `label_expand()` builds labels of derived variables
#' from a dictionary of *root* names: the visit suffix is removed first, then
#' the prefixes one by one, so that `DELTA_LOG_NFL` becomes `"Delta log(NfL)"`
#' and `BIN_IL6_V0` becomes `"IL-6 (high) V0"`.
#'
#' @param var,vars Character vector of variable names.
#' @param labels Named character vector `name -> label`, or `NULL`.
#' @param base_labels Named character vector of labels of the root names.
#' @param visit_map Named vector `suffix -> text appended to the label`.
#' @param prefix_map Named vector `prefix -> sprintf() format`. The `BIN`
#'   entry, when `NA`, is replaced by `bin_format`.
#' @param bin_format Format of the categorised variables (`BIN_` prefix), e.g.
#'   `"%s (high)"` for a median split or `"%s (tertiles)"`.
#' @param bin_format_root Optional named vector `root -> format` overriding
#'   `bin_format` for some roots (e.g. from `lodestar::cut_label_formats()`).
#'
#' @return `label_get()`: an unnamed character vector of labels.
#'   `label_expand()`: a character vector named by `vars`.
#' @export
#' @examples
#' labs <- c(NFL = "NfL", IL6 = "IL-6")
#' label_get(c("NFL", "AGE"), labs)
#' label_expand(c("NFL_V0", "LOG_NFL_V3", "DELTA_LOG_NFL", "BIN_IL6_V0"), labs)
label_get <- function(var, labels = NULL) {
  if (is.null(labels) || !length(var)) return(var)
  var <- as.character(var)
  out <- unname(labels[var])
  out[is.na(out)] <- var[is.na(out)]
  as.character(out)
}

#' @rdname label_get
#' @export
label_expand <- function(vars, base_labels,
                         visit_map = c(V0 = "V0", V3 = "V3"),
                         prefix_map = c(LOG = "log(%s)", LOG10 = "log10(%s)", LOG1P = "log(1+%s)",
                                        BC = "Box-Cox(%s)", SQRT = "\u221a%s", BIN = NA,
                                        DELTA = "\u0394 %s", Z = "%s (z)"),
                         bin_format = "%s (high)", bin_format_root = NULL) {
  if (!is.character(vars)) cli::cli_abort("{.arg vars} must be a character vector.")
  lab_one <- function(v) {
    if (v %in% names(base_labels)) return(unname(base_labels[[v]]))
    for (vs in names(visit_map)) {
      if (endsWith(v, paste0("_", vs))) {
        return(paste(lab_one(sub(paste0("_", vs, "$"), "", v)), visit_map[[vs]]))
      }
    }
    for (pf in names(prefix_map)) {
      if (startsWith(v, paste0(pf, "_"))) {
        rest <- sub(paste0("^", pf, "_"), "", v)
        fmt <- prefix_map[[pf]]
        if (pf == "BIN") {
          if (is.na(fmt)) fmt <- bin_format
          if (!is.null(bin_format_root) && rest %in% names(bin_format_root)) fmt <- bin_format_root[[rest]]
        }
        return(sprintf(fmt, lab_one(rest)))
      }
    }
    v
  }
  stats::setNames(vapply(vars, lab_one, character(1)), vars)
}
