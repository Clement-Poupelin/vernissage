# Change between two visits

Adds `DELTA_<ROOT> = <ROOT>_<to> - <ROOT>_<from>` for every root
measured (numeric) at both visits.

## Usage

``` r
visit_add_deltas(df, roots, from = "V0", to = "V3", prefix = "DELTA_")
```

## Arguments

- df:

  A data frame in wide format.

- roots:

  Root names.

- from, to:

  Visit suffixes.

- prefix:

  Prefix of the new columns.

## Value

`df` with the new columns.

## Examples

``` r
d <- visit_add_deltas(cohort_sim, c("NFL", "MOCA"))
summary(d$DELTA_MOCA)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.     NAs 
#> -4.0000 -1.0000 -1.0000 -0.6509  0.0000  2.0000      14 
```
