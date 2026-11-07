# Correlations

- `cor_partial_spearman()`: partial rank correlation: Spearman
  correlation between `x` and `y` after removing (linear regression) the
  effect of the covariates `Z` on the ranks of `x` and `y`; t test with
  n - 2 - k degrees of freedom (k = number of covariate columns).
  Without covariates it is the ordinary Spearman correlation.

- `cor_matrix_test()`: correlation, p-value, adjusted p-value and N
  matrices on pairwise complete observations.

## Usage

``` r
cor_partial_spearman(x, y, Z = NULL)

cor_matrix_test(data, vars, method = "spearman", p_adjust = "BH")
```

## Arguments

- x, y:

  Numeric vectors.

- Z:

  Optional data frame of covariates (same number of rows).

- data:

  A data frame.

- vars:

  Numeric variables (names or tidyselect).

- method:

  Correlation method of
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html).

- p_adjust:

  Multiplicity correction
  ([`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method).

## Value

`cor_partial_spearman()`: `list(estimate, p.value, n)`.
`cor_matrix_test()`: `list(r, p, p_adj, n, long, method, p_adjust)`,
`long` holding one row per pair.

## Examples

``` r
cor_partial_spearman(cohort_sim$NFL_V0, cohort_sim$MOCA_V0, cohort_sim[, c("AGE", "SEX")])
#> $estimate
#> [1] -0.5133259
#> 
#> $p.value
#> [1] 2.783139e-09
#> 
#> $n
#> [1] 120
#> 
cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0))
round(cm$r, 2)
#>          NFL_V0 IL6_V0 CRP_V0 MOCA_V0 UPDRS_V0
#> NFL_V0     1.00   0.06  -0.06   -0.55     0.40
#> IL6_V0     0.06   1.00   0.05   -0.05     0.04
#> CRP_V0    -0.06   0.05   1.00   -0.07    -0.11
#> MOCA_V0   -0.55  -0.05  -0.07    1.00    -0.20
#> UPDRS_V0   0.40   0.04  -0.11   -0.20     1.00
```
