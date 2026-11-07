# Helpers shared by the tests ----------------------------------------------------

is_gg <- function(x) inherits(x, c("ggplot", "ggplot2::ggplot"))
is_theme <- function(x) inherits(x, c("theme", "ggplot2::theme"))
is_pw <- function(x) inherits(x, "patchwork")

# a ggplot builds without error
expect_builds <- function(p) {
  testthat::expect_no_error(ggplot2::ggplot_build(p))
}

# a plot renders without error, on a device large enough for multi-panel figures
expect_renders <- function(p) {
  if (!capabilities("cairo")) testthat::skip("cairo graphics not available")
  testthat::expect_no_error({
    f <- tempfile(fileext = ".png")
    grDevices::png(f, width = 14, height = 10, units = "in", res = 50, type = "cairo")
    on.exit({
      grDevices::dev.off()
      unlink(f)
    }, add = TRUE)
    print(p)
  })
}

small <- function() {
  data.frame(id = sprintf("S%02d", 1:20), g = rep(c("A", "B"), 10),
             x = c(1:19, 100), y = (1:20) / 2, f = factor(rep(c("lo", "hi"), each = 10)),
             stringsAsFactors = FALSE)
}
