test_that("outlier flags follow the documented rules", {
  x <- c(1:19, 100, NA)
  expect_equal(which(outlier_flag_mad(x)), 20)
  expect_equal(which(outlier_flag_iqr(x)), 20)
  expect_false(outlier_flag_mad(x)[21])
  expect_true(all(is.na(outlier_flag_mad(c(1, 2, NA)))))
  # MAD = 0: nothing flagged by the MAD rule
  expect_false(any(outlier_flag_mad(c(rep(1, 10), 50))))
  # hinges and type-7 quartiles give the same flag here
  expect_equal(outlier_flag_iqr(x, method = "hinges"), outlier_flag_iqr(x))
  expect_error(outlier_flag_mad("a"), "numeric")
})

test_that("outlier_detect and outlier_mask", {
  d <- small()
  out <- outlier_detect(d, x, id_col = id, rule = "any")
  expect_equal(out$id, "S20")
  expect_equal(out$Value, 100)
  expect_true(out$MAD && out$IQR)
  expect_gt(out$modified_z, 3.5)
  empty <- outlier_detect(d, y)
  expect_equal(nrow(empty), 0)
  expect_named(empty, c("id", "Variable", "Value", "modified_z", "MAD", "IQR"))
  m <- outlier_mask(d, out, id_col = id)
  expect_true(is.na(m$x[20]))
  expect_equal(sum(is.na(m$x)), 1)
  expect_equal(outlier_mask(d, empty, id_col = id), d)
  expect_error(outlier_mask(d, data.frame(a = 1), id_col = id), "outlier_detect")
  # row numbers as identifiers when id_col is not given
  expect_equal(outlier_detect(d, x)$id, "20")
  # "both" is the intersection, "any" the union
  both <- outlier_detect(cohort_sim, CRP_V0, rule = "both")
  any_ <- outlier_detect(cohort_sim, CRP_V0, rule = "any")
  expect_true(all(both$id %in% any_$id))
})

test_that("transform_compare / choose / propagate / apply", {
  cmp <- transform_compare(cohort_sim, c(NFL_V0, AGE), methods = c("none", "log", "sqrt"))
  expect_setequal(unique(cmp$Method), c("none", "log", "sqrt"))
  expect_true(all(c("skewness", "kurtosis", "W", "p_shapiro") %in% names(cmp)))
  ch <- transform_choose(cmp)
  expect_equal(nrow(ch), 2)
  expect_equal(ch$Method[ch$Variable == "AGE"], "none")
  expect_true("Reason" %in% names(ch))
  pr <- transform_propagate(ch)
  expect_true("NFL_V3" %in% pr$Variable)
  expect_false(anyDuplicated(pr$Variable) > 0)
  res <- transform_apply(cohort_sim, pr)
  new <- res$map$New[res$map$Variable == "NFL_V0"]
  if (new != "NFL_V0") expect_true(new %in% names(res$data))
  expect_error(transform_choose(data.frame(a = 1)), "transform_compare")
  expect_error(transform_apply(cohort_sim, data.frame(a = 1)), "Variable")
})

test_that("transform_choose keeps working when the preferred method is absent", {
  cmp <- transform_compare(data.frame(x = c(-1, stats::rexp(50))), x, methods = c("none", "sqrt"))
  expect_equal(nrow(transform_choose(cmp)), 1)
})

test_that("Box-Cox decisions with car", {
  skip_if_not_installed("car")
  bc <- transform_boxcox(cohort_sim, c(NFL_V0, CRP_V0, AGE))
  expect_equal(bc$Variable, c("NFL_V0", "CRP_V0", "AGE"))
  expect_true(all(c("lambda_ml", "rounded", "p_log", "p_none", "Method", "Reason") %in% names(bc)))
  expect_equal(bc$Method[bc$Variable == "NFL_V0"], "log")
  expect_equal(transform_boxcox(data.frame(x = c(0, 1:20)), x)$Method, "none")
  cmp <- transform_compare(cohort_sim, CRP_V0)
  expect_true("boxcox" %in% cmp$Method)
  dec <- transform_boxcox_resid(cohort_sim, c("UPDRS", "MOCA"), covariates = c("AGE", "SEX"))
  expect_equal(dec$Root, c("UPDRS", "MOCA"))
  expect_equal(dec$family[dec$Root == "UPDRS"], if (all(stats::na.omit(cohort_sim$UPDRS_V0) > 0)) "bcPower" else "yjPower")
  app <- transform_apply_resid(cohort_sim, dec)
  expect_equal(nrow(app$map), 2)
  expect_error(transform_apply_resid(cohort_sim, data.frame(a = 1)), "transform_boxcox_resid")
  expect_error(transform_boxcox_resid(cohort_sim, "UPDRS", covariates = "NOPE"), "not found")
})

test_that("internal moments match the moment estimators", {
  x <- c(1, 2, 3, 10)
  m <- mean(x)
  expect_equal(vernissage:::.skewness(x), mean((x - m)^3) / mean((x - m)^2)^1.5)
  expect_equal(vernissage:::.kurtosis_excess(x), mean((x - m)^4) / mean((x - m)^2)^2 - 3)
  expect_true(is.na(vernissage:::.skewness(c(1, 1, 1))))
})
