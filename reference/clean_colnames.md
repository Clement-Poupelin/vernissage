# Clean column names

Spaces removed, runs of dashes and dots replaced by `_`, upper case
(optional), names made unique.

## Usage

``` r
clean_colnames(df, upper = TRUE)
```

## Arguments

- df:

  A data frame.

- upper:

  Convert to upper case.

## Value

`df` with cleaned names.

## Examples

``` r
clean_colnames(data.frame(`nfl v0` = 1, `il-6.v0` = 2, check.names = FALSE))
#>   NFLV0 IL_6_V0
#> 1     1       2
```
