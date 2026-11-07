# Rename columns with a named vector

Rename columns with a named vector

## Usage

``` r
rename_with_map(df, map)
```

## Arguments

- df:

  A data frame.

- map:

  Named character vector `c(OLD = "NEW")`. Old names absent from `df`
  are ignored with a message.

## Value

`df` with renamed columns.

## Examples

``` r
rename_with_map(data.frame(a = 1, b = 2), c(a = "AGE", z = "ZZ"))
#> 1 name(s) not found, ignored: "z".
#>   AGE b
#> 1   1 2
```
