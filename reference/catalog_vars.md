# Catalogue of the variables, by block

One row per root variable: block, label, description, detected type
(categorical, binary, discrete, continuous), visits available and share
of missing values at the first visit found.

## Usage

``` r
catalog_vars(df, blocks, labels = NULL, desc = NULL, visits = c("V0", "V3"))
```

## Arguments

- df:

  A data frame in wide format.

- blocks:

  Named list `block -> root names` (without visit suffix).

- labels:

  Optional named vector of labels.

- desc:

  Optional named vector of descriptions.

- visits:

  Visit suffixes looked for.

## Value

A tibble.

## Examples

``` r
catalog_vars(cohort_sim, list(Biomarkers = c("NFL", "IL6"), Clinical = c("AGE", "MOCA")))
#> # A tibble: 4 × 7
#>   Block      Variable Label Description Type       Visits % missing (first vis…¹
#>   <chr>      <chr>    <chr> <chr>       <chr>      <chr>                   <dbl>
#> 1 Biomarkers NFL      NFL   ""          Continuous V0, V3                      0
#> 2 Biomarkers IL6      IL6   ""          Continuous V0, V3                      0
#> 3 Clinical   AGE      AGE   ""          Discrete   —                           0
#> 4 Clinical   MOCA     MOCA  ""          Discrete   V0, V3                      0
#> # ℹ abbreviated name: ¹​`% missing (first visit)`
```
