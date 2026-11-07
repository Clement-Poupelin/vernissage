test_that("fmt_sci writes mantissa and superscript exponent", {
  expect_equal(fmt_sci(0.000021), "2.1\u00d710\u207b\u2075")
  expect_equal(fmt_sci(0), "0")
  expect_equal(fmt_sci(NA), "NA")
  expect_equal(fmt_sci(9.96e-3, digits = 2), "1.0\u00d710\u207b\u00b2")
  expect_error(fmt_sci("a"), "must be numeric")
})

test_that("fmt_num switches to scientific notation for tiny or huge values", {
  expect_equal(fmt_num(1.23456, 2), "1.23")
  expect_equal(fmt_num(0.0001, 2), fmt_sci(0.0001, 2))
  expect_equal(fmt_num(2e6, 1), fmt_sci(2e6, 2))
  expect_equal(fmt_num(c(NA, Inf)), c("NA", "Inf"))
})

test_that("fmt_p formats p-values element by element", {
  expect_equal(fmt_p(0.0312), "0.031")
  expect_equal(fmt_p(c(0.2, 0.031)), c("0.2", "0.031"))
  expect_match(fmt_p(1e-20), "^<2.2")
  expect_equal(fmt_p(0.00012), fmt_sci(0.00012, 2))
  expect_equal(fmt_p(NA_real_), "NA")
})

test_that("fmt_stars follows the usual cut-points", {
  expect_equal(fmt_stars(c(0.2, 0.07, 0.03, 0.004, 0.0001, NA)),
               c("ns", ".", "*", "**", "***", ""))
  expect_equal(fmt_stars(0.07, trend = FALSE), "ns")
  expect_equal(fmt_stars(0.2, ns = ""), "")
})
