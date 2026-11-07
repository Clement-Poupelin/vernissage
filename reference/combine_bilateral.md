# Mean of the left and right sides of a bilateral measure

`<ROOT>_L_<V>` and `<ROOT>_R_<V>` give `<ROOT>_<V>`. If only one side is
available its value is used (`allow_one_side = TRUE`).

## Usage

``` r
combine_bilateral(
  df,
  roots,
  visits = c("V0", "V3"),
  sides = c("L", "R"),
  allow_one_side = TRUE,
  suffix_new = NULL
)
```

## Arguments

- df:

  A data frame.

- roots:

  Root names of the bilateral measures.

- visits:

  Visit suffixes.

- sides:

  Side codes.

- allow_one_side:

  Use the single available side when the other is missing.

- suffix_new:

  Optional text appended to the root of the new columns.

## Value

`df` with the new columns.

## Examples

``` r
d <- combine_bilateral(cohort_sim, "PUT")
head(d[, c("PUT_L_V0", "PUT_R_V0", "PUT_V0")])
#>   PUT_L_V0 PUT_R_V0 PUT_V0
#> 1     4.05     3.74  3.895
#> 2     3.88     3.77  3.825
#> 3     4.52     4.50  4.510
#> 4     4.80     4.65  4.725
#> 5     5.05     5.32  5.185
#> 6     5.02     5.05  5.035
```
