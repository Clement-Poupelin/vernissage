# Outliers --------------------------------------------------------------------------
#
# Two classical robust rules, computed on the values as they are analysed (after
# transformation when a variable is log / Box-Cox transformed). Both use the median
# and quantiles, not the mean and SD, which are pulled by the very values they should
# detect (masking effect; Leys et al. 2013).
#
# Tukey's IQR rule (Tukey 1977): x < Q1 - k IQR or x > Q3 + k IQR (k = 1.5).
#   Normal data: fences at mu +/- 2.70 sigma (about 0.7% of values flagged).
#   The probability of flagging at least one value grows with n (Hoaglin, Iglewicz
#   & Tukey 1986): a flag is a prompt to look, not a reason to delete.
# Modified z-score (Iglewicz & Hoaglin 1993): M = 0.6745 (x - median) / MAD with the
#   RAW MAD = median(|x - median|); |M| > 3.5. stats::mad() multiplies by 1.4826 by
#   default: combined with 0.6745 the correction would be applied twice (threshold
#   of 5.2 sigma). mad(constant = 1) is used here.

#' Robust outlier rules
#'
#' @description
#' * `outlier_flag_mad()`: modified z-score of Iglewicz & Hoaglin (1993),
#'   `|0.6745 (x - median) / MAD| > threshold` with the raw
#'   `MAD = median(|x - median|)`. When more than half of the values are
#'   identical (MAD = 0, e.g. values piled at a detection floor) no value is
#'   flagged by this rule.
#' * `outlier_flag_iqr()`: Tukey's fences (Tukey 1977),
#'   `x < Q1 - k IQR` or `x > Q3 + k IQR`. `method = "quantile"` uses the
#'   type-7 quartiles of [stats::quantile()]; `method = "hinges"` uses
#'   Tukey's hinges of [grDevices::boxplot.stats()] (the boxplot whiskers).
#'
#' Normal data: the IQR rule (about 2.7 SD) is stricter than the MAD rule
#' (3.5 SD), so nearly every MAD outlier is also an IQR outlier. "MAD only"
#' values appear with skewed or bimodal distributions; values flagged by both
#' rules are the most robust signals.
#'
#' @param x Numeric vector (`NA` allowed).
#' @param threshold Cut-off on the absolute modified z-score (3.5 recommended).
#' @param k Fence multiplier (1.5 = outlier, 3 = far out).
#' @param method `"quantile"` or `"hinges"`, see Description.
#' @return A logical vector of the same length as `x` (`NA` everywhere when
#'   fewer than 5 values are observed; `FALSE` for missing values otherwise).
#' @references
#' Tukey JW (1977). *Exploratory Data Analysis*. Addison-Wesley.
#'
#' Hoaglin DC, Iglewicz B, Tukey JW (1986). Performance of some resistant rules
#' for outlier labeling. *J Am Stat Assoc* 81:991-999.
#'
#' Iglewicz B, Hoaglin DC (1993). *How to Detect and Handle Outliers*. ASQC
#' Quality Press.
#'
#' Leys C, Ley C, Klein O, Bernard P, Licata L (2013). Detecting outliers: do
#' not use standard deviation around the mean, use absolute deviation around
#' the median. *J Exp Soc Psychol* 49:764-766.
#' @export
#' @examples
#' x <- c(rnorm(50), 8)
#' which(outlier_flag_mad(x))
#' which(outlier_flag_iqr(x))
outlier_flag_mad <- function(x, threshold = 3.5) {
  .check_numeric_input(x, "x")
  ok <- !is.na(x)
  if (sum(ok) < 5) return(rep(NA, length(x)))
  med <- stats::median(x[ok])
  md <- stats::mad(x[ok], constant = 1)
  z <- if (md > 0) 0.6745 * (x - med) / md else rep(0, length(x))
  !is.na(z) & abs(z) > threshold
}

#' @rdname outlier_flag_mad
#' @export
outlier_flag_iqr <- function(x, k = 1.5, method = c("quantile", "hinges")) {
  .check_numeric_input(x, "x")
  method <- match.arg(method)
  ok <- !is.na(x)
  if (sum(ok) < 5) return(rep(NA, length(x)))
  if (method == "hinges") {
    return(!is.na(x) & x %in% grDevices::boxplot.stats(x[ok], coef = k)$out)
  }
  q <- stats::quantile(x[ok], c(0.25, 0.75))
  b <- c(q[1] - k * diff(q), q[2] + k * diff(q))
  !is.na(x) & (x < b[1] | x > b[2])
}

#' Table of outliers and masking
#'
#' `outlier_detect()` lists the flagged values (one row per subject x
#' variable). `outlier_mask()` sets the listed values to `NA`.
#'
#' @param df A data frame.
#' @param vars Numeric variables (names or tidyselect).
#' @param id_col Identifier column (default: row numbers).
#' @param rule Which values are listed: `"mad"` (MAD rule), `"iqr"` (Tukey),
#'   `"both"` (flagged by both rules, most conservative) or `"any"` (flagged
#'   by at least one rule).
#' @param mad_z_threshold Cut-off of the modified z-score.
#' @param iqr_k Multiplier of the Tukey fences.
#' @param iqr_method `"quantile"` or `"hinges"`, see [outlier_flag_iqr()].
#' @param outliers Output of `outlier_detect()`.
#' @return `outlier_detect()`: a tibble `id`, `Variable`, `Value`,
#'   `modified_z`, `MAD`, `IQR` (logical: rule that flagged the value).
#'   `outlier_mask()`: `df` with the listed values set to `NA`.
#' @export
#' @examples
#' out <- outlier_detect(cohort_sim, c(CRP_V0, NFL_V0), id_col = ID, rule = "any")
#' out
#' masked <- outlier_mask(cohort_sim, out, id_col = ID)
outlier_detect <- function(df, vars, id_col = NULL, rule = c("mad", "iqr", "both", "any"),
                           mad_z_threshold = 3.5, iqr_k = 1.5, iqr_method = c("quantile", "hinges")) {
  df <- .as_df(df, "df")
  rule <- match.arg(rule)
  iqr_method <- match.arg(iqr_method)
  vars <- .select(rlang::enquo(vars), df, "vars")
  id_col <- .select(rlang::enquo(id_col), df, "id_col", single = TRUE)
  ids <- if (!is.null(id_col)) as.character(df[[id_col]]) else as.character(seq_len(nrow(df)))
  out <- dplyr::bind_rows(lapply(vars, function(v) {
    x <- df[[v]]
    if (!is.numeric(x)) return(NULL)
    m <- outlier_flag_mad(x, mad_z_threshold)
    m[is.na(m)] <- FALSE
    i <- outlier_flag_iqr(x, iqr_k, iqr_method)
    i[is.na(i)] <- FALSE
    keep <- switch(rule, mad = m, iqr = i, both = m & i, any = m | i)
    if (!any(keep)) return(NULL)
    md <- stats::mad(x, constant = 1, na.rm = TRUE)
    z <- if (isTRUE(md > 0)) 0.6745 * (x - stats::median(x, na.rm = TRUE)) / md else rep(NA_real_, length(x))
    tibble::tibble(id = ids[keep], Variable = v, Value = x[keep], modified_z = z[keep],
                   MAD = m[keep], IQR = i[keep])
  }))
  if (!nrow(out)) {
    out <- tibble::tibble(id = character(0), Variable = character(0), Value = numeric(0),
                          modified_z = numeric(0), MAD = logical(0), IQR = logical(0))
  }
  out
}

#' @rdname outlier_detect
#' @export
outlier_mask <- function(df, outliers, id_col) {
  df <- .as_df(df, "df")
  id_col <- .select(rlang::enquo(id_col), df, "id_col", single = TRUE)
  if (is.null(outliers) || !nrow(outliers)) return(df)
  if (!all(c("id", "Variable") %in% names(outliers))) {
    cli::cli_abort("{.arg outliers} must be the output of {.fn outlier_detect}.")
  }
  for (k in seq_len(nrow(outliers))) {
    idx <- which(as.character(df[[id_col]]) == outliers$id[k])
    df[[outliers$Variable[k]]][idx] <- NA
  }
  df
}
