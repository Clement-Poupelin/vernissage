# vernissage

Documentation: <https://clement-poupelin.github.io/vernissage/>

**Put your cohort on show.** A *vernissage* is the opening of an
exhibition, when the works are hung and shown at their best. This
package prepares clinical cohort data and shows them: overview table,
distributions, missing-data maps, paired visits, correlations, PCA,
radar and forest plots, with a publication theme, colour-blind safe
palettes and polished `gt` tables.

Data are in **wide format** (one row per subject, one column per
variable and visit, names such as `NFL_V0`, `NFL_V3`).

- **Preparation**: French CSV import, name cleaning, visits and long
  format, bilateral measures, robust outlier rules, log / Box-Cox
  transformations decided at baseline and applied at follow-up,
  composite scores.
- **Description and figures**:
  [`describe_cohort()`](https://clement-poupelin.github.io/vernissage/reference/describe_cohort.md),
  [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md),
  [`plot_distribution()`](https://clement-poupelin.github.io/vernissage/reference/plot_distribution.md),
  [`plot_paired_visits()`](https://clement-poupelin.github.io/vernissage/reference/plot_paired_visits.md),
  [`plot_trajectories()`](https://clement-poupelin.github.io/vernissage/reference/plot_trajectories.md),
  [`plot_cor_heatmap()`](https://clement-poupelin.github.io/vernissage/reference/plot_cor_heatmap.md),
  `plot_pca_*()`,
  [`plot_radar()`](https://clement-poupelin.github.io/vernissage/reference/plot_radar.md),
  [`plot_forest()`](https://clement-poupelin.github.io/vernissage/reference/plot_forest.md).
- **Reports**: number and p-value formatting, `gt` publication tables
  with significance highlighting, Quarto tabsets and callouts.

Companion packages:

- [lodestar](https://github.com/Clement-Poupelin/lodestar): limits of
  detection and cut-offs (median split, tertiles, reclassification
  between visits);
- statistical modelling lives in a separate package.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("Clement-Poupelin/vernissage")
```

Optional features use suggested packages:

``` r

install.packages(c("gt", "car", "DT", "ggrepel", "nortest", "stringi", "RColorBrewer"))
```

## Quick start

``` r

library(vernissage)

# 1. the cohort at a glance
describe_cohort(cohort_sim, vars = c(AGE, SEX, NFL_V0, MOCA_V0, FALL_V0),
                by = GROUP, id_col = ID)
plot_na_map(cohort_sim, vars = c(NFL_V0:CRP_V3), id_col = ID)

# 2. preparation: decided at V0, applied at V3
choice <- transform_choose(transform_compare(cohort_sim, c(NFL_V0, CRP_V0)))
cohort <- transform_apply(cohort_sim, transform_propagate(choice))$data
outlier_detect(cohort, c(NFL_V0, CRP_V0), id_col = ID, rule = "any")

# 3. figures
plot_distribution(cohort, c(NFL_V0, MOCA_V0, SEX), group = GROUP)
plot_paired_visits(cohort, c(NFL_V0, MOCA_V0), id_col = ID, transitions = TRUE)
plot_radar(cohort, c(AGE, NFL_V0, IL6_V0, MOCA_V0, UPDRS_V0), group = GROUP)
```

Columns can be given as strings, character vectors stored in a variable,
bare names or tidyselect helpers (`starts_with("NFL")`).

Figures use Unicode symbols (rho, Delta, \>=). To keep them in a PDF,
save with `ggsave("figure.pdf", p, device = cairo_pdf)`; the classic
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device gets ASCII
equivalents automatically (see
[`?vernissage`](https://clement-poupelin.github.io/vernissage/reference/vernissage-package.md),
option `vernissage.unicode`).

## Tutorials

- [Getting
  started](https://clement-poupelin.github.io/vernissage/articles/vernissage.html):
  the example cohort, a first look, the families of functions
- [Preprocessing](https://clement-poupelin.github.io/vernissage/articles/preprocessing.html):
  import, names, visits, outliers, transformations
- [Describing a
  cohort](https://clement-poupelin.github.io/vernissage/articles/describing.html):
  overview table, missing data, correlations, PCA
- [Figures](https://clement-poupelin.github.io/vernissage/articles/figures.html):
  distributions, paired visits, trajectories, radar and forest plots
- [Tables and Quarto
  reports](https://clement-poupelin.github.io/vernissage/articles/reporting.html):
  formatting, `gt` tables, tabsets

## Coming from the analysis scripts

The former function names
([`get_label()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md),
[`paired_visits_plot()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md),
[`radar_plot()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md)…)
still work, with a deprecation warning; see `?vernissage-deprecated`.
The former limit-of-detection and cut-off functions are in
[lodestar](https://github.com/Clement-Poupelin/lodestar).
