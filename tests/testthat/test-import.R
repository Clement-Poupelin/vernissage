test_that("read_cohort_csv reads a Latin-1 French CSV and converts comma decimals", {
  f <- system.file("extdata", "cohort_messy.csv", package = "vernissage")
  expect_message(d <- read_cohort_csv(f), "latin1")
  expect_equal(nrow(d), 6)
  expect_type(d[["NfL V0"]], "double")
  expect_equal(d[["NfL V0"]][1], 12.4)
  expect_true(is.na(d[["NfL V3"]][2]))          # "NR" is missing
  expect_true(is.na(d[["Score MoCA V0"]][5]))   # "ND" is missing
  expect_type(d$Groupe, "character")
  expect_true(all(validUTF8(names(d))))
  expect_true(any(grepl("\u00c2ge", names(d))))
  expect_message(read_cohort_csv(f, encoding = "latin1"), NA)
})

test_that("path_resolve_nfc returns existing paths and fails clearly", {
  f <- system.file("extdata", "cohort_messy.csv", package = "vernissage")
  expect_equal(path_resolve_nfc(f), f)
  expect_error(path_resolve_nfc(1), "single character")
  skip_if_not_installed("stringi")
  expect_error(path_resolve_nfc(file.path(tempdir(), "no_such_file.csv")), "not found")
})

test_that("clean_colnames and rename_with_map", {
  d <- data.frame(`nfl v0` = 1, `il-6.v0` = 2, `nfl v0` = 3, check.names = FALSE)
  expect_equal(names(clean_colnames(d)), c("NFLV0", "IL_6_V0", "NFLV0_1"))
  expect_equal(names(clean_colnames(d, upper = FALSE))[2], "il_6_v0")
  expect_error(clean_colnames(1:3), "data frame")
  expect_message(r <- rename_with_map(data.frame(a = 1, b = 2), c(a = "AGE", z = "ZZ")), "not found")
  expect_equal(names(r), c("AGE", "b"))
  expect_error(rename_with_map(data.frame(a = 1), c("x")), "named")
})

test_that("catalog_vars detects types and visits", {
  cat <- catalog_vars(cohort_sim, list(Bio = c("NFL", "IL6"), Clin = c("AGE", "MOCA", "FALL", "SEX", "NOPE")))
  expect_equal(cat$Variable, c("NFL", "IL6", "AGE", "MOCA", "FALL", "SEX"))
  expect_equal(cat$Type[cat$Variable == "NFL"], "Continuous")
  expect_equal(cat$Type[cat$Variable == "MOCA"], "Discrete")
  expect_equal(cat$Type[cat$Variable == "FALL"], "Categorical")
  expect_equal(cat$Visits[cat$Variable == "NFL"], "V0, V3")
  expect_error(catalog_vars(cohort_sim, list("NFL")), "named list")
})
