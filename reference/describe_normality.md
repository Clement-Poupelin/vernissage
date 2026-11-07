# Normality of each variable

Shapiro-Wilk test (on a random sample of 5000 values above that size),
Anderson-Darling test (if the nortest package is installed), skewness
and excess kurtosis, with a verdict combining p and shape: with N above
about 100, Shapiro-Wilk rejects minor departures that do not matter for
a linear model.

## Usage

``` r
describe_normality(data, vars, labels = NULL, alpha = 0.05, seed = 1)
```

## Arguments

- data:

  A data frame.

- vars:

  Numeric variables (names or tidyselect).

- labels:

  Optional named vector of labels.

- alpha:

  Significance level of the verdict.

- seed:

  Seed of the subsample used above 5000 values.

## Value

A tibble, one row per variable with at least 8 values and some variance.

## Examples

``` r
describe_normality(cohort_sim, c(AGE, NFL_V0, CRP_V0, MOCA_V0))
#> # A tibble: 4 × 9
#>   Variable Label       N     W p_Shapiro     p_AD Skewness Kurtosis Verdict     
#>   <chr>    <chr>   <int> <dbl>     <dbl>    <dbl>    <dbl>    <dbl> <chr>       
#> 1 AGE      AGE       120 0.989  4.37e- 1 2.12e- 1  -0.0891    0.229 Compatible …
#> 2 NFL_V0   NFL_V0    120 0.808  3.08e-11 1.49e-10   2.48     10.5   Strong skew…
#> 3 CRP_V0   CRP_V0    115 0.589  2.00e-16 3.7 e-24   3.93     20.2   Strong skew…
#> 4 MOCA_V0  MOCA_V0   120 0.947  1.22e- 4 1.16e- 4  -0.335    -0.561 Slight depa…
```
