#' vernissage: show your cohort data at their best
#'
#' Preprocessing, description and figures for clinical cohort data stored in
#' wide format: one row per subject, one column per variable and visit, with
#' column names following the `<ROOT>_<VISIT>` convention (e.g. `NFL_V0`,
#' `NFL_V3`).
#'
#' Functions are grouped in families sharing a prefix:
#'
#' * import and cleaning: [read_cohort_csv()], [clean_colnames()],
#'   [rename_with_map()], [path_resolve_nfc()], [catalog_vars()];
#' * visits: `visit_*()` and [combine_bilateral()];
#' * outliers: `outlier_*()`;
#' * transformations: `transform_*()`;
#' * missing data: `na_*()` and [plot_na_map()];
#' * description: `describe_*()`, `cor_*()`, `pca_*()`, [score_composite()];
#' * labels and formatting: `label_*()`, `fmt_*()`;
#' * themes and palettes: `theme_*()`, `pal_*()`;
#' * figures: `plot_*()`;
#' * tables and Quarto output: `gt_*()`, [dt_export()], `qmd_*()`.
#'
#' Limits of detection and cut-offs are handled by the companion package
#' lodestar.
#'
#' @section Symbols in figures and PDF output:
#' Figures use Unicode symbols (Greek letters such as rho and Delta, minus
#' and comparison signs, superscript exponents). The classic [grDevices::pdf()]
#' and [grDevices::postscript()] devices cannot draw characters outside
#' Latin-1; this is the device of `R CMD check` and of `ggplot2::ggsave()` for
#' a `.pdf` file. The option `vernissage.unicode` controls the symbols:
#'
#' * `"auto"` (default): Unicode, except when the open device (or the default
#'   device, when none is open) is a classic `pdf()` or `postscript()`
#'   device; then ASCII equivalents are used (`rho`, `Delta`, `>=`, `x10^-4`).
#' * `TRUE` / `FALSE`: always Unicode / always ASCII.
#'
#' The choice is made when the figure is built. To keep the symbols in a PDF
#' file, save with a Cairo device, e.g.
#' `ggplot2::ggsave("figure.pdf", p, device = grDevices::cairo_pdf)`; to build
#' figures in an interactive session and save them later with `pdf()`, set
#' `options(vernissage.unicode = FALSE)`.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang %||% .data
## usethis namespace: end
NULL
