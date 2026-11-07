# Transformations (log, log1p, sqrt, Box-Cox, Yeo-Johnson) --------------------------
#
# Box-Cox lambda : car::powerTransform(), maximum likelihood (Box & Cox 1964;
#                  Fox & Weisberg 2019); car's "rounded power" = the first of
#                  1, 0, -1, 0.5, 0.33, -0.5, -0.33, 2, -2 inside the Wald 95% CI.
# Box-Cox values : car::bcPower(), (y^lambda - 1) / lambda, log(y) if lambda = 0.
# Rule for longitudinal data: decided at V0, applied unchanged at the other visits.

#' Box-Cox lambda by maximum likelihood, with a shift for values <= 0
#' @noRd
.boxcox_lambda <- function(x) {
  .need("car", "for the Box-Cox transformation.")
  x <- x[!is.na(x)]
  shift <- if (min(x) <= 0) abs(min(x)) + 1 else 0
  pt <- tryCatch(car::powerTransform(x + shift, family = "bcPower"), error = function(e) NULL)
  list(lambda = if (is.null(pt)) NA_real_ else unname(pt$lambda), shift = shift)
}

#' Apply one transformation to a vector
#' @noRd
.apply_one_transform <- function(x, method, lambda = NULL, shift = 0) {
  switch(method,
    none  = x,
    log   = {
      if (any(x <= 0, na.rm = TRUE)) { cli::cli_warn("log: values <= 0 set to NA."); x[x <= 0] <- NA }
      log(x)
    },
    log10 = {
      if (any(x <= 0, na.rm = TRUE)) { cli::cli_warn("log10: values <= 0 set to NA."); x[x <= 0] <- NA }
      log10(x)
    },
    log1p = log1p(x),
    sqrt  = sqrt(pmax(x, 0)),
    boxcox = {
      .need("car", "for the Box-Cox transformation.")
      y <- x + shift
      # a later-visit value can fall below the reference shift: power undefined -> NA
      if (any(y <= 0, na.rm = TRUE)) { cli::cli_warn("Box-Cox: values <= 0 after shift set to NA."); y[y <= 0] <- NA }
      out <- rep(NA_real_, length(y))
      ok <- !is.na(y)
      out[ok] <- car::bcPower(y[ok], lambda)
      out
    },
    cli::cli_abort("Unknown transformation {.val {method}}."))
}

#' Map car's rounded power to the transformation applied
#' @noRd
.power_to_method <- function(p) {
  if (is.na(p)) return("none")
  if (isTRUE(all.equal(p, 1))) return("none")
  if (isTRUE(all.equal(p, 0))) return("log")
  if (isTRUE(all.equal(p, 0.5))) return("sqrt")
  "boxcox"
}

#' Apply one power transformation of a car family
#' @noRd
.apply_car_power <- function(x, family, lambda) {
  if (is.na(lambda) || isTRUE(all.equal(lambda, 1))) return(x)
  out <- rep(NA_real_, length(x))
  if (family == "bcPower") {
    ok <- !is.na(x) & x > 0
    out[ok] <- if (isTRUE(all.equal(lambda, 0))) log(x[ok]) else
      if (isTRUE(all.equal(lambda, 0.5))) sqrt(x[ok]) else car::bcPower(x[ok], lambda)
    return(out)
  }
  ok <- !is.na(x)
  out[ok] <- if (isTRUE(all.equal(lambda, 0)) && all(x[ok] >= 0)) log1p(x[ok]) else car::yjPower(x[ok], lambda)
  out
}

#' Name of the transformation (column prefix and label)
#' @noRd
.outcome_method <- function(family, lambda) {
  if (is.na(lambda) || isTRUE(all.equal(lambda, 1))) return("none")
  if (family == "bcPower") {
    if (isTRUE(all.equal(lambda, 0))) return("log")
    if (isTRUE(all.equal(lambda, 0.5))) return("sqrt")
    return("boxcox")
  }
  if (isTRUE(all.equal(lambda, 0))) return("log1p")
  "yj"
}

#' Compare, choose and apply transformations
#'
#' @description
#' Workflow based on the shape of the marginal distribution:
#' * `transform_compare()`: skewness, excess kurtosis, Shapiro-Wilk W and p
#'   of every variable under every transformation (a decision tool, to be
#'   read with the plots);
#' * `transform_choose()`: one transformation per variable: the highest W,
#'   but the preferred method (log, interpretable as a multiplicative effect)
#'   is kept when its W is within `tol` of the best, and `"none"` is kept when
#'   the variable is already about symmetric (`|skewness| < skew_ok`);
#' * `transform_propagate()`: copies the reference-visit choice (same method
#'   and same lambda) to the other visits;
#' * `transform_apply()`: adds the transformed variables as new prefixed
#'   columns (`LOG_`, `BC_`, ...).
#'
#' @param df A data frame.
#' @param vars Numeric variables (names or tidyselect).
#' @param methods Transformations compared, among `"none"`, `"log"`,
#'   `"log10"`, `"log1p"`, `"sqrt"`, `"boxcox"` (the latter needs the car
#'   package).
#' @param cmp Output of `transform_compare()`.
#' @param prefer Preferred methods, in order.
#' @param tol Tolerance on W for the preferred method.
#' @param skew_ok Absolute skewness below which no transformation is applied.
#' @param choice Output of `transform_choose()` (columns `Variable`, `Method`,
#'   and `lambda`, `shift` for Box-Cox).
#' @param from Regular expression of the reference-visit suffix.
#' @param to Replacement suffix(es) of the other visits.
#' @param prefixes Named vector `method -> prefix of the new column`.
#' @return `transform_compare()`: one row per variable x method.
#'   `transform_choose()`: one row per variable with a `Reason` column.
#'   `transform_propagate()`: the choice with extra rows for the other visits.
#'   `transform_apply()`: `list(data, map)` with `map` = original variable,
#'   new column, method and lambda.
#' @export
#' @examples
#' cmp <- transform_compare(cohort_sim, c(NFL_V0, CRP_V0), methods = c("none", "log", "sqrt"))
#' choice <- transform_choose(cmp)
#' choice <- transform_propagate(choice)
#' res <- transform_apply(cohort_sim, choice)
#' res$map
transform_compare <- function(df, vars, methods = c("none", "log", "log1p", "sqrt", "boxcox")) {
  df <- .as_df(df, "df")
  vars <- .select(rlang::enquo(vars), df, "vars")
  methods <- match.arg(methods, c("none", "log", "log10", "log1p", "sqrt", "boxcox"), several.ok = TRUE)
  if ("boxcox" %in% methods && !requireNamespace("car", quietly = TRUE)) {
    cli::cli_inform(c("!" = "Package {.pkg car} not installed: {.val boxcox} skipped."))
    methods <- setdiff(methods, "boxcox")
  }
  dplyr::bind_rows(lapply(vars, function(v) {
    x <- df[[v]]
    if (!is.numeric(x)) return(NULL)
    bc <- if ("boxcox" %in% methods) .boxcox_lambda(x) else list(lambda = NA_real_, shift = 0)
    dplyr::bind_rows(lapply(methods, function(m) {
      if (m %in% c("log", "log10") && any(x <= 0, na.rm = TRUE)) return(NULL)
      if (m == "boxcox" && is.na(bc$lambda)) return(NULL)
      y <- suppressWarnings(.apply_one_transform(x, m, bc$lambda, bc$shift))
      y <- y[is.finite(y)]
      sw <- if (length(y) >= 3 && length(y) <= 5000 && stats::sd(y) > 0)
        tryCatch(stats::shapiro.test(y), error = function(e) NULL) else NULL
      tibble::tibble(
        Variable = v, Method = m, N = length(y),
        skewness = .skewness(y), kurtosis = .kurtosis_excess(y),
        W = if (!is.null(sw)) unname(sw$statistic) else NA_real_,
        p_shapiro = if (!is.null(sw)) sw$p.value else NA_real_,
        lambda = if (m == "boxcox") bc$lambda else NA_real_,
        shift = if (m == "boxcox") bc$shift else 0)
    }))
  }))
}

#' @rdname transform_compare
#' @export
transform_choose <- function(cmp, prefer = c("log", "log1p"), tol = 0.01, skew_ok = 0.5) {
  if (!is.data.frame(cmp) || !all(c("Variable", "Method", "W", "skewness") %in% names(cmp))) {
    cli::cli_abort("{.arg cmp} must be the output of {.fn transform_compare}.")
  }
  out <- lapply(split(cmp, factor(cmp$Variable, levels = unique(cmp$Variable))), function(d) {
    none <- d[d$Method == "none", , drop = FALSE]
    if (nrow(none) && !is.na(none$skewness[1]) && abs(none$skewness[1]) < skew_ok) {
      return(dplyr::mutate(none[1, , drop = FALSE], Reason = "Already ~symmetric"))
    }
    if (!any(is.finite(d$W))) {
      keep <- if (nrow(none)) none[1, , drop = FALSE] else d[1, , drop = FALSE]
      return(dplyr::mutate(keep, Reason = "No Shapiro W available: first method kept"))
    }
    best <- d[which.max(d$W), , drop = FALSE]
    pref <- d[d$Method %in% prefer, , drop = FALSE]
    if (nrow(pref)) pref <- pref[order(match(pref$Method, prefer))[1], , drop = FALSE]
    if (nrow(pref) && !is.na(pref$W) && pref$W >= best$W - tol) {
      dplyr::mutate(pref, Reason = sprintf("Preferred (W within %.2f of max)", tol))
    } else {
      dplyr::mutate(best, Reason = "Highest Shapiro W")
    }
  })
  dplyr::bind_rows(out)
}

#' @rdname transform_compare
#' @export
transform_propagate <- function(choice, from = "_V0$", to = "_V3") {
  if (!"Variable" %in% names(choice)) cli::cli_abort("{.arg choice} needs a {.field Variable} column.")
  extra <- dplyr::bind_rows(lapply(to, function(t) {
    e <- choice
    e$Variable <- sub(from, t, e$Variable)
    e
  }))
  out <- dplyr::bind_rows(choice, extra)
  out[!duplicated(out$Variable), , drop = FALSE]
}

#' @rdname transform_compare
#' @export
transform_apply <- function(df, choice, prefixes = c(log = "LOG", log10 = "LOG10", log1p = "LOG1P",
                                                     sqrt = "SQRT", boxcox = "BC")) {
  df <- .as_df(df, "df")
  if (!all(c("Variable", "Method") %in% names(choice))) {
    cli::cli_abort("{.arg choice} needs {.field Variable} and {.field Method} columns.")
  }
  choice <- choice[choice$Variable %in% names(df), , drop = FALSE]
  if (!"lambda" %in% names(choice)) choice$lambda <- NA_real_
  if (!"shift" %in% names(choice)) choice$shift <- 0
  map_rows <- vector("list", nrow(choice))
  for (k in seq_len(nrow(choice))) {
    v <- choice$Variable[k]
    m <- choice$Method[k]
    if (m == "none") {
      map_rows[[k]] <- tibble::tibble(Variable = v, New = v, Method = "none", lambda = NA_real_)
      next
    }
    sh <- choice$shift[k]
    if (is.na(sh)) sh <- 0
    new <- paste0(prefixes[[m]], "_", v)
    df[[new]] <- .apply_one_transform(df[[v]], m, choice$lambda[k], sh)
    map_rows[[k]] <- tibble::tibble(Variable = v, New = new, Method = m, lambda = choice$lambda[k])
  }
  list(data = df, map = dplyr::bind_rows(map_rows))
}

#' Box-Cox decision with car's documented rule
#'
#' @description
#' Every decision is made by an existing function with its documented
#' default: lambda by maximum likelihood with its Wald 95% CI
#' ([car::powerTransform()]), car's rounded power (the first of 1, 0, -1, 0.5,
#' 0.33, -0.5, -0.33, 2, -2 inside the CI) and likelihood-ratio tests of
#' lambda = 0 (log) and lambda = 1 (no transformation)
#' ([car::testTransform()]).
#'
#' * `transform_boxcox()`: marginal distribution of strictly positive
#'   variables (values <= 0 or fewer than 10 values: kept raw);
#' * `transform_boxcox_resid()`: for a response, the normality assumption
#'   concerns the residuals: lambda is estimated for `<root><visit>` in the
#'   linear model `score ~ covariates`. Scores with zeros use the Yeo-Johnson
#'   family ([car::yjPower()], Yeo & Johnson 2000), equal to `log(1 + y)` for
#'   lambda = 0;
#' * `transform_apply_resid()`: adds the transformed scores at every visit
#'   (prefixes `LOG_`, `SQRT_`, `BC_`, `LOG1P_`, `YJ_`) with the reference
#'   decision.
#'
#' @param df A data frame.
#' @param vars Strictly positive variables (names or tidyselect).
#' @param roots Root names of the scores.
#' @param covariates Covariates of the linear model.
#' @param visit Suffix of the reference visit (with the underscore).
#' @param decision Output of `transform_boxcox_resid()`.
#' @param visits Visit suffixes where the transformation is applied.
#' @param prefixes Named vector `method -> prefix`.
#' @return `transform_boxcox()`: one row per variable with lambda, CI, rounded
#'   power, LR p-values, `Method` / `lambda` / `shift` (input of
#'   [transform_apply()]), skewness and W before / after.
#'   `transform_boxcox_resid()`: one row per root with the skewness of the
#'   residuals before / after. `transform_apply_resid()`: `list(data, map)`.
#' @references Box GEP, Cox DR (1964). An analysis of transformations. *J R
#'   Stat Soc B* 26:211-252. Fox J, Weisberg S (2019). *An R Companion to
#'   Applied Regression*, 3rd ed. Yeo IK, Johnson RA (2000). A new family of
#'   power transformations to improve normality or symmetry. *Biometrika*
#'   87:954-959.
#' @export
#' @examplesIf rlang::is_installed("car")
#' transform_boxcox(cohort_sim, c(NFL_V0, CRP_V0))
#' dec <- transform_boxcox_resid(cohort_sim, "UPDRS", covariates = c("AGE", "SEX"))
#' transform_apply_resid(cohort_sim, dec)$map
transform_boxcox <- function(df, vars) {
  .need("car", "for the Box-Cox transformation.")
  df <- .as_df(df, "df")
  vars <- .select(rlang::enquo(vars), df, "vars")
  dplyr::bind_rows(lapply(vars, function(v) {
    x <- df[[v]]
    if (!is.numeric(x)) return(NULL)
    x <- x[!is.na(x)]
    out <- tibble::tibble(Variable = v, N = length(x), lambda_ml = NA_real_, ci_low = NA_real_,
                          ci_high = NA_real_, rounded = NA_real_, p_log = NA_real_, p_none = NA_real_,
                          Method = "none", lambda = NA_real_, shift = 0,
                          skew_before = .skewness(x), W_before = .sw_W(x))
    raw <- function(reason) {
      out$Reason <- reason
      out$skew_after <- out$skew_before
      out$W_after <- out$W_before
      out
    }
    if (length(x) < 10 || any(x <= 0)) return(raw("Box-Cox undefined (values <= 0 or < 10 values): kept raw"))
    pt <- tryCatch(car::powerTransform(x, family = "bcPower"), error = function(e) NULL)
    if (is.null(pt)) return(raw("powerTransform() failed: kept raw"))
    res <- summary(pt)$result
    out$lambda_ml <- unname(res[1, 1])
    out$rounded <- unname(pt$roundlam)
    out$ci_low <- unname(res[1, 3])
    out$ci_high <- unname(res[1, 4])
    # testTransform() returns its p-value as text: recomputed from LRT and df
    lr_p <- function(l) {
      tt <- car::testTransform(pt, l)
      stats::pchisq(tt$LRT, tt$df, lower.tail = FALSE)
    }
    out$p_log <- lr_p(0)
    out$p_none <- lr_p(1)
    out$Method <- .power_to_method(out$rounded)
    out$lambda <- if (out$Method == "boxcox") out$rounded else NA_real_
    in_ci <- out$ci_low <= out$rounded & out$rounded <= out$ci_high
    out$Reason <- if (out$Method == "none") "lambda = 1 inside the 95% CI: no transformation"
      else if (out$Method == "log") "lambda = 0 inside the 95% CI: log"
      else if (out$Method == "sqrt") "lambda = 0.5 inside the 95% CI: square root"
      else if (in_ci && abs(out$rounded - out$lambda_ml) > 1e-8)
        sprintf("Rounded power %s inside the 95%% CI: Box-Cox", format(out$rounded))
      else "No rounded power inside the 95% CI: Box-Cox at the ML lambda"
    y <- .apply_one_transform(x, out$Method, out$lambda, 0)
    out$skew_after <- .skewness(y)
    out$W_after <- .sw_W(y)
    out
  }))
}

#' @rdname transform_boxcox
#' @export
transform_boxcox_resid <- function(df, roots, covariates, visit = "_V0") {
  .need("car", "for the Box-Cox / Yeo-Johnson transformation.")
  df <- .as_df(df, "df")
  covariates <- .keep_existing(covariates, names(df), "covariates", strict = TRUE)
  dplyr::bind_rows(lapply(roots, function(r) {
    v <- paste0(r, visit)
    if (!v %in% names(df) || !is.numeric(df[[v]])) return(NULL)
    d <- .complete_subset(df, c(v, covariates))
    y <- d[[v]]
    fam <- if (all(y > 0)) "bcPower" else "yjPower"
    fit <- stats::lm(stats::reformulate(covariates, response = v), data = d)
    out <- tibble::tibble(Root = r, N = nrow(d), family = fam, lambda_ml = NA_real_, ci_low = NA_real_,
                          ci_high = NA_real_, rounded = NA_real_, p_log = NA_real_, p_none = NA_real_,
                          skew_resid_before = .skewness(stats::residuals(fit)))
    pt <- tryCatch(car::powerTransform(fit, family = fam), error = function(e) NULL)
    if (!is.null(pt)) {
      res <- summary(pt)$result
      out$lambda_ml <- unname(res[1, 1])
      out$rounded <- unname(pt$roundlam)
      out$ci_low <- unname(res[1, 3])
      out$ci_high <- unname(res[1, 4])
      lr_p <- function(l) {
        tt <- car::testTransform(pt, l)
        stats::pchisq(tt$LRT, tt$df, lower.tail = FALSE)
      }
      out$p_log <- lr_p(0)
      out$p_none <- lr_p(1)
    }
    out$Method <- .outcome_method(fam, out$rounded)
    out$lambda <- if (out$Method == "none") NA_real_ else out$rounded
    d$.y <- .apply_car_power(y, fam, out$lambda)
    fit2 <- stats::lm(stats::reformulate(covariates, response = ".y"), data = d)
    out$skew_resid_after <- .skewness(stats::residuals(fit2))
    out
  }))
}

#' @rdname transform_boxcox
#' @export
transform_apply_resid <- function(df, decision, visits = c("V0", "V3"),
                                  prefixes = c(log = "LOG", sqrt = "SQRT", boxcox = "BC",
                                               log1p = "LOG1P", yj = "YJ")) {
  df <- .as_df(df, "df")
  if (!all(c("Root", "family", "Method", "lambda") %in% names(decision))) {
    cli::cli_abort("{.arg decision} must be the output of {.fn transform_boxcox_resid}.")
  }
  if (any(decision$Method %in% c("boxcox", "yj"))) .need("car", "for the Box-Cox / Yeo-Johnson transformation.")
  rows <- vector("list", nrow(decision))
  for (k in seq_len(nrow(decision))) {
    d <- decision[k, ]
    if (d$Method == "none") {
      rows[[k]] <- tibble::tibble(Root = d$Root, New = d$Root, Method = "none", lambda = NA_real_)
      next
    }
    new <- paste0(prefixes[[d$Method]], "_", d$Root)
    for (vs in visits) {
      v <- paste0(d$Root, "_", vs)
      if (v %in% names(df)) df[[paste0(new, "_", vs)]] <- .apply_car_power(df[[v]], d$family, d$lambda)
    }
    rows[[k]] <- tibble::tibble(Root = d$Root, New = new, Method = d$Method, lambda = d$lambda)
  }
  list(data = df, map = dplyr::bind_rows(rows))
}
