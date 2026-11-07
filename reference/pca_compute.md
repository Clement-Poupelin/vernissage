# Principal component analysis

`pca_compute()` runs
[`stats::prcomp()`](https://rdrr.io/r/stats/prcomp.html) on a set of
variables (factors and logicals coded numerically). `pca_scores_join()`
joins the component scores back to the data.

## Usage

``` r
pca_compute(
  data,
  vars,
  id_col = NULL,
  scale = TRUE,
  impute = c("none", "median")
)

pca_scores_join(pca_obj, data, id_col = NULL, n_pc = 2)
```

## Arguments

- data:

  A data frame.

- vars:

  Variables (names or tidyselect).

- id_col:

  Identifier column (default: row numbers).

- scale:

  Scale the variables to unit variance.

- impute:

  `"none"` (complete cases only) or `"median"` (simple median
  imputation, for visualisation only, never for inference).

- pca_obj:

  Output of `pca_compute()`.

- n_pc:

  Number of components joined.

## Value

`pca_compute()`: list with `pca` (prcomp object), `ve` (variance
explained, %), `scores` (tibble with `.id`), `keep`, `vars`, `n`,
`impute`, `loadings` and `cor_var` (correlations of the variables with
the components). `pca_scores_join()`: the rows of `data` kept in the
PCA, with the columns `PC1`, `PC2`, ...

## Examples

``` r
pc <- pca_compute(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0, AGE), id_col = ID)
round(pc$ve, 1)
#> [1] 31.5 19.5 16.4 14.0 10.0  8.6
head(pca_scores_join(pc, cohort_sim, id_col = ID)[, c("ID", "PC1", "PC2")])
#>     ID         PC1        PC2
#> 1 P001 -2.27995419  1.0463946
#> 2 P002  0.01221179  1.4245590
#> 3 P003  1.18786860  0.9402560
#> 4 P004  1.59959226  1.2156418
#> 5 P005  0.12387455 -1.6087485
#> 6 P006 -0.57484024  0.1797266
```
