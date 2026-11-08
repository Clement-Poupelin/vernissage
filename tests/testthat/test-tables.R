test_that("describe_cohort data output", {
  tab <- describe_cohort(cohort_sim, vars = c(AGE, SEX, MOCA_V0, FALL_V0, NFL_V3), by = GROUP,
                         id_col = ID, output = "data")
  expect_s3_class(tab, "tbl_df")
  heads <- tab[!tab$.is_level, ]
  expect_equal(heads$Variable, c("AGE", "SEX", "MOCA_V0", "FALL_V0", "NFL_V3"))
  expect_equal(heads$Type, c("Continuous", "Binary", "Discrete", "Binary", "Continuous"))
  expect_true(all(c("Placebo", "Active", "p", "Distribution") %in% names(tab)))
  expect_equal(heads$N[heads$Variable == "NFL_V3"], sum(!is.na(cohort_sim$NFL_V3)))
  expect_equal(sum(tab$.is_level), 4)                         # 2 levels x 2 categorical variables
  expect_true(all(!is.na(heads$p)))
  expect_match(heads$Overall[1], "^[0-9.]+ \\[")
  expect_true(nchar(heads$Distribution[1]) == 8)
})

test_that("describe_cohort without groups, with blocks and labels", {
  tab <- describe_cohort(cohort_sim, vars = c(AGE, NFL_V0, SEX), blocks = list(Bio = "NFL_V0"),
                         labels = c(AGE = "Age (years)"), spark = FALSE, output = "data")
  expect_equal(unique(tab$.block), c("Bio", "Other variables"))
  expect_true("Age (years)" %in% tab$Variable)
  expect_false("Distribution" %in% names(tab))
  expect_false("p" %in% names(tab) && any(!is.na(tab$p)))
  expect_error(describe_cohort(cohort_sim, vars = c(ID), id_col = ID, output = "data"), "No variable")
  expect_error(describe_cohort(cohort_sim, blocks = "x", output = "data"), "named list")
  d <- rbind(cohort_sim[1:3, ], cohort_sim[1, ])
  expect_warning(describe_cohort(d, vars = AGE, id_col = ID, output = "data"), "duplicated")
})

test_that("describe_cohort gt output", {
  skip_if_not_installed("gt")
  g <- describe_cohort(cohort_sim, vars = c(AGE, SEX, NFL_V0, MOCA_V0), by = GROUP,
                       blocks = list(Demography = c("AGE", "SEX")))
  expect_s3_class(g, "gt_tbl")
  html <- gt::as_raw_html(g)
  expect_match(html, "Cohort overview")
  expect_match(html, "Placebo<br>\\(n = ")
})

test_that("gt_pub formats numbers and p-values", {
  skip_if_not_installed("gt")
  df <- data.frame(name = c("a", "b"), N = c(10, 20), est = c(1.2345, 0.00001), p.value = c(0.03, 0.4))
  g <- gt_pub(df, title = "T", note = "note")
  expect_s3_class(g, "gt_tbl")
  html <- gt::as_raw_html(g)
  expect_match(html, "1.23")
  expect_match(html, "0.03")
  expect_error(gt_pub(1:3), "data frame")
})

test_that("gt_signif, gt_highlight_rows and legend", {
  skip_if_not_installed("gt")
  df <- data.frame(a = c("x", "y"), b = c("u", "v"), p = c(0.01, 0.2), p_adj = c(0.02, 0.4),
                   txt = c("+1.2; p = 0.0024 *", "-0.1; p = 0.6"))
  g <- gt_pub(df) |> gt_signif(p_cols = "p", fdr_cols = "p_adj", text_cols = "txt")
  g <- gt_highlight_rows(g, c(TRUE, FALSE))
  expect_s3_class(g, "gt_tbl")
  expect_match(gt::as_raw_html(g), "significant after FDR")
  expect_error(gt_signif(df), "gt table")
  expect_equal(vernissage:::.p_from_text(c("OR 0.57; p = 3.2\u00d710\u207b\u2075", "none")), c(3.2e-5, NA))
  expect_named(gt_sig_colors(), c("nominal", "fdr", "robust"))
})

test_that("dt_export", {
  skip_if_not_installed("DT")
  w <- dt_export(data.frame(a = c(1.23456, 2)), digits = 2)
  expect_s3_class(w, "datatables")
})

test_that("qmd helpers print Quarto markdown", {
  out <- utils::capture.output(qmd_tabset(list(A = "text a", B = list("b1", "b2"), C = NULL)))
  expect_true(any(grepl("::: panel-tabset", out, fixed = TRUE)))
  expect_true(any(grepl("### A", out, fixed = TRUE)))
  expect_true(any(grepl("Not available", out)))
  expect_error(qmd_tabset(list("x")), "named list")
  expect_invisible(qmd_tabset(list()))
  out2 <- utils::capture.output(qmd_callout_raw(model = summary(stats::lm(dist ~ speed, data = cars)),
                                                title = "Raw"))
  expect_true(any(grepl("callout-note", out2)))
  expect_true(any(grepl("**model**", out2, fixed = TRUE)))
})
