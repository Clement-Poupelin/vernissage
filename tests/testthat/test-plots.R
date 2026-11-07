test_that("plot_distribution: panels, groups, attributes", {
  p <- plot_distribution(cohort_sim, c(NFL_V0, MOCA_V0, SEX), group = GROUP, outlier_mad = TRUE)
  expect_true(is_pw(p))
  expect_renders(p)
  tests <- attr(p, "tests")
  expect_equal(tests$Variable, c("NFL_V0", "MOCA_V0", "SEX"))
  expect_true("p_adj_BH" %in% names(tests))
  expect_true(all(c("id", "Variable", "Value", "MAD", "IQR") %in% names(attr(p, "outliers"))))
  p2 <- plot_distribution(cohort_sim, CRP_V0, transform = "log", show_box = FALSE, ref_lines = list(CRP_V0 = 1))
  expect_renders(p2)
  expect_message(expect_null(plot_distribution(cohort_sim, vars = c("NOPE"))), "not found")
  expect_error(plot_distribution(cohort_sim, NFL_V0, transform = "cube"), "Unknown")
})

test_that("plot_distribution takes the group from metadata", {
  meta <- cohort_sim[, c("ID", "GROUP")]
  dat <- cohort_sim[, c("ID", "NFL_V0")]
  p <- plot_distribution(dat, NFL_V0, group = GROUP, metadata = meta, id_col = ID)
  expect_equal(nrow(attr(p, "tests")), 1)
  expect_error(plot_distribution(dat, NFL_V0, group = GROUP, metadata = meta), "id_col")
  m <- as.matrix(cohort_sim[, c("AGE", "BMI")])
  expect_true(is_pw(plot_distribution(m)))
})

test_that("plot_distribution_overview", {
  p <- plot_distribution_overview(cohort_sim, c(AGE, NFL_V0, CRP_V0), group = GROUP)
  expect_true(is_gg(p))
  expect_builds(p)
  expect_error(plot_distribution_overview(cohort_sim, c(SEX, GROUP)), "No numeric")
})

test_that("plot_na_map in both orientations", {
  p <- plot_na_map(cohort_sim, c(NFL_V0:CRP_V3), id_col = ID)
  expect_true(is_pw(p))
  expect_renders(p)
  p2 <- plot_na_map(cohort_sim, c(NFL_V3, MOCA_V3), orientation = "rows", group = GROUP, margins = FALSE)
  expect_true(is_gg(p2))
  expect_builds(p2)
  expect_error(plot_na_map(cohort_sim, palette = "nope"), "palette")
})

test_that("plot_paired_visits with and without transitions", {
  p <- plot_paired_visits(cohort_sim, c(NFL_V0, MOCA_V0), id_col = ID)
  expect_true(is_gg(p))
  expect_builds(p)
  s <- attr(p, "summary")
  expect_equal(s$var, c("NFL_V0", "MOCA_V0"))
  expect_true(all(s$rho > 0))
  p2 <- plot_paired_visits(cohort_sim, NFL_V0, id_col = ID, transitions = TRUE, transition_mode = "crossing")
  expect_builds(p2)
  tr <- attr(p2, "transitions")
  expect_true(all(c("high0", "high1", "detailed", "crossing") %in% names(tr)))
  expect_true(attr(p2, "summary")$kappa <= 1)
  p3 <- plot_paired_visits(cohort_sim, NFL_V0, id_col = ID, transitions = TRUE, split_cut = 12)
  expect_equal(attr(p3, "summary")$t0, 12)
  expect_error(plot_paired_visits(cohort_sim, NFL_V0, id_col = ID, transitions = TRUE, split = "manual"), "split_cut")
  expect_error(plot_paired_visits(cohort_sim, AGE, id_col = ID), "counterpart")
})

test_that("trajectories and change vs baseline", {
  p <- plot_trajectories(cohort_sim, c(MOCA_V0, MOCA_V3), id_col = ID, group = GROUP, ref_line = 26)
  expect_true(is_gg(p))
  expect_builds(p)
  expect_null(plot_trajectories(cohort_sim[1:2, ], c(MOCA_V0, MOCA_V3), id_col = ID))
  expect_error(plot_trajectories(cohort_sim, MOCA_V0, id_col = ID), "at least 2")
  g <- plot_trajectory_grid(cohort_sim, c("NFL", "MOCA", "NOPE"), id_col = "ID")
  expect_true(is_pw(g))
  expect_null(plot_trajectory_grid(cohort_sim, "NOPE", id_col = ID))
  d <- plot_delta_vs_baseline(cohort_sim, c("NFL", "UPDRS"), group = GROUP)
  expect_true(is_pw(d))
  expect_renders(d)
  expect_null(plot_delta_vs_baseline(cohort_sim, "NOPE"))
})

test_that("correlation heatmaps", {
  cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0))
  p <- plot_cor_heatmap(cm, labels = c(NFL_V0 = "NfL"))
  expect_true(is_gg(p))
  expect_builds(p)
  expect_builds(plot_cor_heatmap(cm, order = "original", use_adj = FALSE, show_values = FALSE))
  expect_error(plot_cor_heatmap(list(a = 1)), "cor_matrix_test")
  cc <- plot_cor_cross(cohort_sim, c(NFL_V0, IL6_V0), c(MOCA_V0, UPDRS_V0), covariates = c(AGE, SEX))
  expect_equal(nrow(cc$table), 4)
  expect_builds(cc$plot)
})

test_that("PCA figures", {
  pc <- pca_compute(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, AGE), id_col = ID)
  expect_builds(plot_pca_scree(pc))
  expect_builds(plot_pca_ind(pc, cohort_sim, id_col = ID, color_var = GROUP))
  expect_builds(plot_pca_ind(pc, cohort_sim, id_col = ID, color_var = AGE))
  expect_builds(plot_pca_ind(pc))
  expect_builds(plot_pca_var(pc, groups = list(Bio = c("NFL_V0", "IL6_V0"))))
  expect_builds(plot_pca_contrib(pc, axes = 1:3, top_n = 3))
  l <- plot_pca_distribution(pc, cohort_sim, c(GROUP, SEX), id_col = ID)
  expect_named(l, c("GROUP", "SEX"))
  expect_true(is_pw(l$GROUP))
  expect_error(plot_pca_scree(list()), "pca_compute")
})

test_that("plot_radar", {
  p <- plot_radar(cohort_sim, c(AGE, BMI, NFL_V0, MOCA_V0, SEX), group = GROUP, seed = 1)
  expect_true(is_gg(p))
  expect_builds(p)
  rd <- attr(p, "radar_data")
  expect_equal(nrow(rd$tests), 5)
  expect_true(all(rd$summary$z >= 0 & rd$summary$z <= 1, na.rm = TRUE))
  p2 <- plot_radar(cohort_sim, c(AGE, NFL_V0, MOCA_V0), normalize = "zscore", stat = "median",
                   ci_method = "boot", n_boot = 50, seed = 2, grid_shape = "polygon", inner_radius = 0.2,
                   show_values = TRUE, return_data = TRUE)
  expect_named(p2, c("plot", "summary", "tests"))
  expect_builds(p2$plot)
  expect_error(plot_radar(cohort_sim, c(AGE, BMI, SEX), quali_levels = list(SEX = "X")), "not found")
  expect_error(plot_radar(cohort_sim, c(AGE, BMI, MOCA_V0), inner_radius = 1), "inner_radius")
  expect_warning(plot_radar(cohort_sim, c(AGE, BMI)), "Fewer than 3")
})

test_that("plot_forest", {
  res <- data.frame(label = c("NfL", "IL-6", "CRP"), estimate = c(0.4, -0.1, 0.2),
                    conf.low = c(0.1, -0.4, -0.1), conf.high = c(0.7, 0.2, 0.5),
                    p.value = c(0.01, 0.5, 0.2), p_adj = c(0.03, 0.5, 0.3))
  p <- plot_forest(res, p_adj = p_adj, title = "Effects")
  expect_true(is_pw(p))
  expect_renders(p)
  res2 <- rbind(transform(res, model = "A"), transform(res, model = "B", estimate = estimate + 0.1))
  expect_renders(plot_forest(res2, group = model, log_x = FALSE))
  expect_null(plot_forest(transform(res, estimate = NA)))
})

test_that("visual snapshots", {
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("vdiffr")
  withr::local_options(vernissage.unicode = TRUE)
  vdiffr::expect_doppelganger("distribution-nfl", plot_distribution(cohort_sim, NFL_V0, group = GROUP))
  vdiffr::expect_doppelganger("cor-heatmap",
                              plot_cor_heatmap(cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, MOCA_V0))))
  vdiffr::expect_doppelganger("radar", plot_radar(cohort_sim, c(AGE, NFL_V0, MOCA_V0, SEX), group = GROUP, seed = 1))
})

test_that("figures fall back to ASCII on devices without Unicode (pdf, R CMD check)", {
  withr::local_options(vernissage.unicode = FALSE)
  expect_equal(vernissage:::.u("\u03c1 = 0.5 | \u0394 (V3 \u2212 V0) | p \u2265 0.05"),
               "rho = 0.5 | Delta (V3 - V0) | p >= 0.05")
  expect_equal(vernissage:::.u(fmt_p(0.00012)), "1.2x10^-4")
  expect_null(vernissage:::.u(NULL))
  withr::local_options(vernissage.unicode = TRUE)
  expect_equal(vernissage:::.u("\u03c1"), "\u03c1")
})

test_that("figures built while a classic pdf() device is open can be drawn on it", {
  withr::local_options(vernissage.unicode = "auto")
  f <- tempfile(fileext = ".pdf")
  grDevices::pdf(f, width = 14, height = 10)
  on.exit({
    grDevices::dev.off()
    unlink(f)
  }, add = TRUE)
  res <- data.frame(label = c("A", "B"), estimate = c(0.4, -0.1), conf.low = c(0.1, -0.4),
                    conf.high = c(0.7, 0.2), p.value = c(0.0001, 0.5))
  expect_no_error(print(plot_forest(res)))
  expect_no_error(print(plot_cor_heatmap(cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, MOCA_V0)))))
  expect_no_error(print(plot_delta_vs_baseline(cohort_sim, "NFL")))
})
