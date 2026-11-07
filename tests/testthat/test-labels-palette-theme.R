test_that("label_get falls back to the raw name", {
  labs <- c(NFL = "NfL")
  expect_equal(label_get(c("NFL", "AGE"), labs), c("NfL", "AGE"))
  expect_equal(label_get("NFL"), "NFL")
  expect_equal(label_get(character(0), labs), character(0))
})

test_that("label_expand handles visits and prefixes recursively", {
  labs <- c(NFL = "NfL", IL6 = "IL-6")
  out <- label_expand(c("NFL_V0", "LOG_NFL_V3", "DELTA_LOG_NFL", "BIN_IL6_V0", "OTHER"), labs)
  expect_equal(unname(out), c("NfL V0", "log(NfL) V3", "\u0394 log(NfL)", "IL-6 (high) V0", "OTHER"))
  expect_named(out, c("NFL_V0", "LOG_NFL_V3", "DELTA_LOG_NFL", "BIN_IL6_V0", "OTHER"))
  out2 <- label_expand("BIN_IL6_V0", labs, bin_format = "%s (tertiles)")
  expect_equal(unname(out2), "IL-6 (tertiles) V0")
  out3 <- label_expand("BIN_IL6_V0", labs, bin_format_root = c(IL6 = "%s (cut)"))
  expect_equal(unname(out3), "IL-6 (cut) V0")
  expect_error(label_expand(1, labs), "character")
})

test_that("pal_levels returns named colours", {
  p <- pal_levels(c("a", "b"))
  expect_named(p, c("a", "b"))
  expect_equal(unname(p), unname(pal_okabe_ito()[c("orange", "skyblue")]))
  expect_length(pal_levels(letters[1:12]), 12)
  expect_equal(pal_levels(c("a", "b"), c(b = "red", a = "blue")), c(a = "blue", b = "red"))
  expect_length(pal_levels(c("a", "b", "c"), "Dark 3"), 3)
  expect_length(pal_levels(1:3, grDevices::rainbow), 3)
  expect_error(pal_levels("a", "not_a_palette"), "Unknown palette")
})

test_that("theme_pub is a complete theme", {
  expect_true(is_theme(theme_pub(12)))
  expect_error(theme_pub("a"), "base_size")
  expect_true(is_theme(theme_rotate_x(45)))
})
