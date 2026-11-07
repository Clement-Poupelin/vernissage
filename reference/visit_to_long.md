# Wide `<ROOT>_<VISIT>` data to long format

One row per subject and visit, one column per root. Derived variables
are roots like any other (`LOG_NFL_V0` -\> root `LOG_NFL`). Columns are
re-typed after reshaping: numeric when possible, otherwise factor
(levels of the first visit kept).

## Usage

``` r
visit_to_long(
  df,
  roots,
  id_col,
  visits = c("V0", "V3"),
  keep = NULL,
  visit_col = "VISIT",
  time_values = NULL
)
```

## Arguments

- df:

  A data frame in wide format.

- roots:

  Root names to reshape.

- id_col:

  Identifier column (name or bare symbol).

- visits:

  Visit suffixes, in chronological order.

- keep:

  Time-invariant columns to keep (names or tidyselect).

- visit_col:

  Name of the visit column created.

- time_values:

  Optional named vector `visit -> time` (e.g. `c(V0 = 0, V3 = 36)`),
  stored in a `TIME` column.

## Value

A tibble.

## Examples

``` r
long <- visit_to_long(cohort_sim, c("NFL", "MOCA"), id_col = ID, keep = c(GROUP, AGE),
                      time_values = c(V0 = 0, V3 = 36))
head(long)
#> # A tibble: 6 × 7
#>   ID    GROUP     AGE VISIT   NFL  MOCA  TIME
#>   <chr> <fct>   <dbl> <fct> <dbl> <dbl> <dbl>
#> 1 P001  Placebo    80 V0     26.8    24     0
#> 2 P001  Placebo    80 V3     NA      NA    36
#> 3 P002  Placebo    82 V0      6.6    26     0
#> 4 P002  Placebo    82 V3      8.5    27    36
#> 5 P003  Placebo    67 V0      4.9    28     0
#> 6 P003  Placebo    67 V3      5.2    27    36
```
