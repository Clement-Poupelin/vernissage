# Missing values per variable and complete cases per variable set

`na_summary()` gives the number and share of missing values of each
variable, with its block. `na_complete_cases()` gives the number of
subjects with every variable of a set observed, for several sets (useful
to anticipate the N of a multivariable model).

## Usage

``` r
na_summary(data, blocks, labels = NULL)

na_complete_cases(data, var_sets)
```

## Arguments

- data:

  A data frame.

- blocks:

  Named list `block -> variables`.

- labels:

  Optional named vector of labels.

- var_sets:

  Named list of variable vectors.

## Value

A tibble.

## Examples

``` r
na_summary(cohort_sim, list(Biomarkers = c("NFL_V0", "IL6_V0", "CRP_V0"),
                            Scores = c("MOCA_V0", "UPDRS_V0")))
#> # A tibble: 5 × 5
#>   Block      Variable Label    N_missing Pct_missing
#>   <chr>      <chr>    <chr>        <int>       <dbl>
#> 1 Biomarkers CRP_V0   CRP_V0           5         4.2
#> 2 Biomarkers NFL_V0   NFL_V0           0         0  
#> 3 Biomarkers IL6_V0   IL6_V0           0         0  
#> 4 Scores     MOCA_V0  MOCA_V0          0         0  
#> 5 Scores     UPDRS_V0 UPDRS_V0         0         0  
na_complete_cases(cohort_sim, list(Baseline = c("NFL_V0", "IL6_V0", "MOCA_V0"),
                                   Both_visits = c("NFL_V0", "NFL_V3")))
#> # A tibble: 2 × 4
#>   `Variable set` `N variables` `N complete` `% complete`
#>   <chr>                  <int>        <int>        <dbl>
#> 1 Baseline                   3          120        100  
#> 2 Both_visits                2          107         89.2
```
