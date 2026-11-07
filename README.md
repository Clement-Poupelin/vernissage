# vernissage

<!-- badges: start -->
[![R-CMD-check](https://github.com/Clement-Poupelin/vernissage/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Clement-Poupelin/vernissage/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**Put your cohort on show.** A *vernissage* is the opening of an exhibition,
when the works are hung and shown at their best. This package prepares
clinical cohort data and shows them: overview table, distributions,
missing-data maps, paired visits, correlations, PCA, radar and forest plots,
with a publication theme, colour-blind safe palettes and polished `gt`
tables.

Data are in **wide format** (one row per subject, one column per variable and
visit, names such as `NFL_V0`, `NFL_V3`).

- **Preparation**: French CSV import, name cleaning, visits and long format,
  bilateral measures, robust outlier rules, log / Box-Cox transformations
  decided at baseline and applied at follow-up, composite scores.
- **Description and figures**: `describe_cohort()`, `plot_na_map()`,
  `plot_distribution()`, `plot_paired_visits()`, `plot_trajectories()`,
  `plot_cor_heatmap()`, `plot_pca_*()`, `plot_radar()`, `plot_forest()`.
- **Reports**: number and p-value formatting, `gt` publication tables with
  significance highlighting, Quarto tabsets and callouts.

Companion packages:

- [lodestar](https://github.com/Clement-Poupelin/lodestar): limits of
  detection and cut-offs (median split, tertiles, reclassification between
  visits);
- statistical modelling lives in a separate package.

## Installation

```r
# install.packages("remotes")
remotes::install_github("Clement-Poupelin/vernissage")
```

Optional features use suggested packages:

```r
install.packages(c("gt", "car", "DT", "ggrepel", "nortest", "stringi", "RColorBrewer"))
```

## Quick start

```r
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

Figures use Unicode symbols (rho, Delta, >=). To keep them in a PDF, save with
`ggsave("figure.pdf", p, device = cairo_pdf)`; the classic `pdf()` device gets
ASCII equivalents automatically (see `?vernissage`, option
`vernissage.unicode`).

## Vignettes

- *Getting started* (`vignette("vernissage")`)
- *Preprocessing: from raw files to analysis variables*
- *Describing a cohort*
- *Figures*
- *Tables and Quarto reports*

## Coming from the analysis scripts

The former function names (`get_label()`, `paired_visits_plot()`,
`radar_plot()`...) still work: they call the new function and give a
deprecation warning. The correspondence table is in `?vernissage-deprecated`
and in `NEWS.md`. The former limit-of-detection and cut-off functions
(`handle_lod()`, `make_cuts()`, `binarize_vars()`...) are in lodestar.

## Renaming the package

From a terminal at the package root (on macOS use `sed -i ''`):

```sh
grep -rl "vernissage" --exclude-dir=.git . | xargs sed -i 's/vernissage/newname/g'
git mv R/vernissage-package.R R/newname-package.R
git mv vignettes/vernissage.qmd vignettes/newname.qmd
git mv vernissage.Rproj newname.Rproj
```

Check the result with `git diff`, rename the GitHub repository (*Settings >
General*; GitHub redirects the old address), update the remote
(`git remote set-url origin https://github.com/Clement-Poupelin/newname.git`)
and run `devtools::document()` and `devtools::check()`.

## License

MIT
