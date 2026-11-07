# Composite scores -------------------------------------------------------------------

#' Composite score per domain
#'
#' Mean of the z-scored variables of each domain (binary factors coded 0/1
#' before scaling). The z-scores use the mean and SD of `ref` (default: the
#' data itself), so that the same scaling can be applied to another visit or
#' population.
#'
#' @param data A data frame.
#' @param domains Named list `composite name -> variables`.
#' @param direction Optional named vector `variable -> +1 / -1` (sign flip,
#'   e.g. so that higher always means worse).
#' @param ref Data giving the mean and SD of the z-scores.
#' @param min_prop Minimal share of observed variables to compute a score.
#' @param prefix Prefix of the new columns (the domain name is upper-cased,
#'   non-alphanumeric characters replaced by `_`).
#' @return `data` with one column per domain.
#' @export
#' @examples
#' d <- score_composite(cohort_sim, list(inflammation = c("IL6_V0", "CRP_V0"),
#'                                       cognition = c("MOCA_V0", "UPDRS_V0")),
#'                      direction = c(MOCA_V0 = -1))
#' summary(d[, c("COMP_INFLAMMATION", "COMP_COGNITION")])
score_composite <- function(data, domains, direction = NULL, ref = data, min_prop = 0.5,
                            prefix = "COMP_") {
  data <- .as_df(data)
  if (!is.list(domains) || is.null(names(domains))) cli::cli_abort("{.arg domains} must be a named list.")
  .check_number(min_prop, "min_prop", 0, 1)
  as_num <- function(x) if (is.factor(x)) as.numeric(x) - 1 else as.numeric(x)
  for (nm in names(domains)) {
    vars <- intersect(domains[[nm]], names(data))
    if (!length(vars)) next
    Z <- vapply(vars, function(v) {
      r <- as_num(ref[[v]])
      x <- as_num(data[[v]])
      z <- (x - mean(r, na.rm = TRUE)) / stats::sd(r, na.rm = TRUE)
      if (!is.null(direction) && v %in% names(direction)) z <- z * direction[[v]]
      z
    }, numeric(nrow(data)))
    Z <- matrix(Z, nrow = nrow(data))
    ok <- rowMeans(!is.na(Z)) >= min_prop
    sc <- rowMeans(Z, na.rm = TRUE)
    sc[!ok] <- NA_real_
    data[[paste0(prefix, gsub("[^A-Za-z0-9]+", "_", toupper(nm)))]] <- sc
  }
  data
}
