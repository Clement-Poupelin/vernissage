# Normality, correlations, PCA -----------------------------------------------------

#' Normality of each variable
#'
#' Shapiro-Wilk test (on a random sample of 5000 values above that size),
#' Anderson-Darling test (if the nortest package is installed), skewness and
#' excess kurtosis, with a verdict combining p and shape: with N above about
#' 100, Shapiro-Wilk rejects minor departures that do not matter for a linear
#' model.
#'
#' @param data A data frame.
#' @param vars Numeric variables (names or tidyselect).
#' @param labels Optional named vector of labels.
#' @param alpha Significance level of the verdict.
#' @param seed Seed of the subsample used above 5000 values.
#' @return A tibble, one row per variable with at least 8 values and some
#'   variance.
#' @export
#' @examples
#' describe_normality(cohort_sim, c(AGE, NFL_V0, CRP_V0, MOCA_V0))
describe_normality <- function(data, vars, labels = NULL, alpha = 0.05, seed = 1) {
  data <- .as_df(data)
  vars <- .select(rlang::enquo(vars), data, "vars")
  dplyr::bind_rows(lapply(vars, function(v) {
    x <- data[[v]]
    x <- x[!is.na(x)]
    if (!is.numeric(x) || length(x) < 8 || stats::sd(x) == 0) return(NULL)
    xs <- if (length(x) > 5000) withr::with_seed(seed, sample(x, 5000)) else x
    sw <- tryCatch(stats::shapiro.test(xs), error = function(e) NULL)
    ad <- if (requireNamespace("nortest", quietly = TRUE)) tryCatch(nortest::ad.test(x), error = function(e) NULL) else NULL
    sk <- .skewness(x)
    ku <- .kurtosis_excess(x)
    p_sw <- if (!is.null(sw)) sw$p.value else NA_real_
    verdict <- if (!is.na(p_sw) && p_sw >= alpha) "Compatible with normality"
      else if (abs(sk) < 0.5 && abs(ku) < 1) "Slight departure (near-normal shape)"
      else if (abs(sk) < 1) "Moderate skewness"
      else "Strong skewness: transform / non-parametric"
    tibble::tibble(Variable = v, Label = label_get(v, labels), N = length(x),
                   W = if (!is.null(sw)) unname(sw$statistic) else NA_real_, p_Shapiro = p_sw,
                   p_AD = if (!is.null(ad)) ad$p.value else NA_real_, Skewness = sk, Kurtosis = ku,
                   Verdict = verdict)
  }))
}

#' Correlations
#'
#' @description
#' * `cor_partial_spearman()`: partial rank correlation: Spearman correlation
#'   between `x` and `y` after removing (linear regression) the effect of the
#'   covariates `Z` on the ranks of `x` and `y`; t test with n - 2 - k degrees
#'   of freedom (k = number of covariate columns). Without covariates it is
#'   the ordinary Spearman correlation.
#' * `cor_matrix_test()`: correlation, p-value, adjusted p-value and N
#'   matrices on pairwise complete observations.
#'
#' @param x,y Numeric vectors.
#' @param Z Optional data frame of covariates (same number of rows).
#' @param data A data frame.
#' @param vars Numeric variables (names or tidyselect).
#' @param method Correlation method of [stats::cor.test()].
#' @param p_adjust Multiplicity correction ([stats::p.adjust()] method).
#' @return `cor_partial_spearman()`: `list(estimate, p.value, n)`.
#'   `cor_matrix_test()`: `list(r, p, p_adj, n, long, method, p_adjust)`,
#'   `long` holding one row per pair.
#' @export
#' @examples
#' cor_partial_spearman(cohort_sim$NFL_V0, cohort_sim$MOCA_V0, cohort_sim[, c("AGE", "SEX")])
#' cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0))
#' round(cm$r, 2)
cor_partial_spearman <- function(x, y, Z = NULL) {
  if (length(x) != length(y)) cli::cli_abort("{.arg x} and {.arg y} must have the same length.")
  ok <- stats::complete.cases(x, y, if (!is.null(Z)) Z)
  x <- x[ok]
  y <- y[ok]
  n <- length(x)
  if (n < 5) return(list(estimate = NA_real_, p.value = NA_real_, n = n))
  rx <- rank(x)
  ry <- rank(y)
  if (is.null(Z) || ncol(as.data.frame(Z)) == 0) {
    ct <- suppressWarnings(stats::cor.test(x, y, method = "spearman", exact = FALSE))
    return(list(estimate = unname(ct$estimate), p.value = ct$p.value, n = n))
  }
  Zd <- as.data.frame(Z)[ok, , drop = FALSE]
  Zm <- stats::model.matrix(~ ., data = Zd)
  ex <- stats::lm.fit(Zm, rx)$residuals
  ey <- stats::lm.fit(Zm, ry)$residuals
  r <- stats::cor(ex, ey)
  k <- ncol(Zm) - 1
  df <- n - 2 - k
  t <- r * sqrt(df / max(1e-12, 1 - r^2))
  list(estimate = r, p.value = 2 * stats::pt(-abs(t), df), n = n)
}

#' @rdname cor_partial_spearman
#' @export
cor_matrix_test <- function(data, vars, method = "spearman", p_adjust = "BH") {
  data <- .as_df(data)
  vars <- .select(rlang::enquo(vars), data, "vars")
  vars <- vars[vapply(vars, function(v) is.numeric(data[[v]]), logical(1))]
  k <- length(vars)
  if (k < 2) cli::cli_abort("At least 2 numeric variables are needed.")
  R <- P <- N <- matrix(NA_real_, k, k, dimnames = list(vars, vars))
  for (i in seq_len(k)) for (j in seq_len(k)) {
    if (j < i) next
    if (i == j) {
      R[i, j] <- 1
      P[i, j] <- 0
      N[i, j] <- sum(!is.na(data[[vars[i]]]))
      next
    }
    ok <- stats::complete.cases(data[[vars[i]]], data[[vars[j]]])
    if (sum(ok) < 5) next
    ct <- suppressWarnings(stats::cor.test(data[[vars[i]]][ok], data[[vars[j]]][ok], method = method, exact = FALSE))
    R[i, j] <- R[j, i] <- unname(ct$estimate)
    P[i, j] <- P[j, i] <- ct$p.value
    N[i, j] <- N[j, i] <- sum(ok)
  }
  up <- upper.tri(P)
  long <- tibble::tibble(Var1 = rownames(P)[row(P)[up]], Var2 = colnames(P)[col(P)[up]],
                         r = R[up], p = P[up], n = N[up])
  long$p_adj <- stats::p.adjust(long$p, p_adjust)
  Padj <- P
  Padj[up] <- long$p_adj
  Padj[lower.tri(Padj)] <- t(Padj)[lower.tri(Padj)]
  list(r = R, p = P, p_adj = Padj, n = N, long = long, method = method, p_adjust = p_adjust)
}

#' Principal component analysis
#'
#' `pca_compute()` runs [stats::prcomp()] on a set of variables (factors and
#' logicals coded numerically). `pca_scores_join()` joins the component
#' scores back to the data.
#'
#' @param data A data frame.
#' @param vars Variables (names or tidyselect).
#' @param id_col Identifier column (default: row numbers).
#' @param scale Scale the variables to unit variance.
#' @param impute `"none"` (complete cases only) or `"median"` (simple median
#'   imputation, for visualisation only, never for inference).
#' @param pca_obj Output of `pca_compute()`.
#' @param n_pc Number of components joined.
#' @return `pca_compute()`: list with `pca` (prcomp object), `ve` (variance
#'   explained, %), `scores` (tibble with `.id`), `keep`, `vars`, `n`,
#'   `impute`, `loadings` and `cor_var` (correlations of the variables with the
#'   components). `pca_scores_join()`: the rows of `data` kept in the PCA, with
#'   the columns `PC1`, `PC2`, ...
#' @export
#' @examples
#' pc <- pca_compute(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0, AGE), id_col = ID)
#' round(pc$ve, 1)
#' head(pca_scores_join(pc, cohort_sim, id_col = ID)[, c("ID", "PC1", "PC2")])
pca_compute <- function(data, vars, id_col = NULL, scale = TRUE, impute = c("none", "median")) {
  impute <- match.arg(impute)
  data <- .as_df(data)
  vars <- .select(rlang::enquo(vars), data, "vars")
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  if (length(vars) < 2) cli::cli_abort("At least 2 variables are needed.")
  X <- as.data.frame(data[, vars, drop = FALSE])
  X[] <- lapply(X, function(z) if (is.factor(z) || is.logical(z)) as.numeric(z) - (is.factor(z)) else as.numeric(z))
  ids <- if (!is.null(id_col)) as.character(data[[id_col]]) else as.character(seq_len(nrow(X)))
  if (impute == "median") {
    for (v in vars) X[[v]][is.na(X[[v]])] <- stats::median(X[[v]], na.rm = TRUE)
    keep <- rep(TRUE, nrow(X))
  } else {
    keep <- stats::complete.cases(X)
  }
  if (sum(keep) < 3) cli::cli_abort("Fewer than 3 complete individuals.")
  pc <- stats::prcomp(X[keep, , drop = FALSE], center = TRUE, scale. = scale)
  ve <- 100 * pc$sdev^2 / sum(pc$sdev^2)
  scores <- tibble::as_tibble(pc$x)
  scores <- dplyr::mutate(scores, .id = ids[keep], .before = 1)
  list(pca = pc, ve = ve, scores = scores, keep = keep, vars = vars, n = sum(keep), impute = impute,
       loadings = tibble::as_tibble(pc$rotation, rownames = "Variable"),
       cor_var = tibble::as_tibble(sweep(pc$rotation, 2, pc$sdev, "*"), rownames = "Variable"))
}

#' @rdname pca_compute
#' @export
pca_scores_join <- function(pca_obj, data, id_col = NULL, n_pc = 2) {
  data <- .as_df(data)
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  key <- if (!is.null(id_col)) as.character(data[[id_col]]) else as.character(seq_len(nrow(data)))
  sc <- pca_obj$scores[, c(".id", paste0("PC", seq_len(min(n_pc, length(pca_obj$ve))))), drop = FALSE]
  out <- as.data.frame(data)[match(sc$.id, key), , drop = FALSE]
  dplyr::bind_cols(out, sc[, -1, drop = FALSE])
}
