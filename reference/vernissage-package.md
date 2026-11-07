# vernissage: show your cohort data at their best

Preprocessing, description and figures for clinical cohort data stored
in wide format: one row per subject, one column per variable and visit,
with column names following the `<ROOT>_<VISIT>` convention (e.g.
`NFL_V0`, `NFL_V3`).

## Details

Functions are grouped in families sharing a prefix:

- import and cleaning:
  [`read_cohort_csv()`](https://clement-poupelin.github.io/vernissage/reference/read_cohort_csv.md),
  [`clean_colnames()`](https://clement-poupelin.github.io/vernissage/reference/clean_colnames.md),
  [`rename_with_map()`](https://clement-poupelin.github.io/vernissage/reference/rename_with_map.md),
  [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md),
  [`catalog_vars()`](https://clement-poupelin.github.io/vernissage/reference/catalog_vars.md);

- visits: `visit_*()` and
  [`combine_bilateral()`](https://clement-poupelin.github.io/vernissage/reference/combine_bilateral.md);

- outliers: `outlier_*()`;

- transformations: `transform_*()`;

- missing data: `na_*()` and
  [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md);

- description: `describe_*()`, `cor_*()`, `pca_*()`,
  [`score_composite()`](https://clement-poupelin.github.io/vernissage/reference/score_composite.md);

- labels and formatting: `label_*()`, `fmt_*()`;

- themes and palettes: `theme_*()`, `pal_*()`;

- figures: `plot_*()`;

- tables and Quarto output: `gt_*()`,
  [`dt_export()`](https://clement-poupelin.github.io/vernissage/reference/dt_export.md),
  `qmd_*()`.

Limits of detection and cut-offs are handled by the companion package
lodestar.

## Symbols in figures and PDF output

Figures use Unicode symbols (Greek letters such as rho and Delta, minus
and comparison signs, superscript exponents). The classic
[`grDevices::pdf()`](https://rdrr.io/r/grDevices/pdf.html) and
[`grDevices::postscript()`](https://rdrr.io/r/grDevices/postscript.html)
devices cannot draw characters outside Latin-1; this is the device of
`R CMD check` and of
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
for a `.pdf` file. The option `vernissage.unicode` controls the symbols:

- `"auto"` (default): Unicode, except when the open device (or the
  default device, when none is open) is a classic
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) or
  [`postscript()`](https://rdrr.io/r/grDevices/postscript.html) device;
  then ASCII equivalents are used (`rho`, `Delta`, `>=`, `x10^-4`).

- `TRUE` / `FALSE`: always Unicode / always ASCII.

The choice is made when the figure is built. To keep the symbols in a
PDF file, save with a Cairo device, e.g.
`ggplot2::ggsave("figure.pdf", p, device = grDevices::cairo_pdf)`; to
build figures in an interactive session and save them later with
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html), set
`options(vernissage.unicode = FALSE)`.

## See also

Useful links:

- <https://github.com/Clement-Poupelin/vernissage>

- <https://clement-poupelin.github.io/vernissage/>

- Report bugs at <https://github.com/Clement-Poupelin/vernissage/issues>

## Author

**Maintainer**: Clément Poupelin <clementjc.poupelin@gmail.com>

Authors:

- Clément Poupelin <clementjc.poupelin@gmail.com>
