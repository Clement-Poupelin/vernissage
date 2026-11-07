test_that("visit_root and visit_swap", {
  expect_equal(visit_root(c("NFL_V0", "MDS_TOT_V3", "AGE")), c("NFL", "MDS_TOT", "AGE"))
  expect_equal(visit_swap(c("NFL_V0", "V0_X")), c("NFL_V3", "V0_X"))
})

test_that("visit_map_suffix requires a selection and maps the longest suffix first", {
  m <- visit_map_suffix(c("MRI_GPI_L0", "MRI_GPI_L36", "AGE"), select = "^MRI_")
  expect_equal(m, c(MRI_GPI_L0 = "MRI_GPI_L_V0", MRI_GPI_L36 = "MRI_GPI_L_V3"))
  expect_error(visit_map_suffix("MRI_X0"), "required")
})

test_that("combine_bilateral averages the sides", {
  d <- combine_bilateral(cohort_sim, "PUT")
  expect_true(all(c("PUT_V0", "PUT_V3") %in% names(d)))
  i <- which(!is.na(cohort_sim$PUT_R_V0))[1]
  expect_equal(d$PUT_V0[i], mean(c(cohort_sim$PUT_L_V0[i], cohort_sim$PUT_R_V0[i])))
  j <- which(is.na(cohort_sim$PUT_R_V0))[1]
  expect_equal(d$PUT_V0[j], cohort_sim$PUT_L_V0[j])
  d2 <- combine_bilateral(cohort_sim, "PUT", allow_one_side = FALSE)
  expect_true(is.na(d2$PUT_V0[j]))
})

test_that("visit_to_long reshapes and re-types", {
  long <- visit_to_long(cohort_sim, c("NFL", "FALL"), id_col = ID, keep = c(GROUP, AGE),
                        time_values = c(V0 = 0, V3 = 36))
  expect_equal(nrow(long), 2 * nrow(cohort_sim))
  expect_type(long$NFL, "double")
  expect_s3_class(long$FALL, "factor")
  expect_equal(levels(long$FALL), levels(cohort_sim$FALL_V0))
  expect_equal(levels(long$VISIT), c("V0", "V3"))
  expect_equal(sort(unique(long$TIME)), c(0, 36))
  expect_true(all(c("GROUP", "AGE") %in% names(long)))
  long2 <- visit_to_long(cohort_sim, "NFL", id_col = "ID")
  expect_equal(long2$NFL, long$NFL)
  expect_error(visit_to_long(cohort_sim, "NOPE", id_col = ID), "No column")
  expect_error(visit_to_long(cohort_sim, "NFL", id_col = NOPE), "not found")
})

test_that("visit_add_deltas", {
  d <- visit_add_deltas(cohort_sim, c("NFL", "FALL"))
  expect_equal(d$DELTA_NFL, cohort_sim$NFL_V3 - cohort_sim$NFL_V0)
  expect_false("DELTA_FALL" %in% names(d))
})
