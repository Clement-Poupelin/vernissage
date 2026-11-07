# Visit suffixes of variable names

Names follow the `<ROOT>_<VISIT>` convention. `visit_root()` removes the
visit suffix; `visit_swap()` replaces one visit suffix by another
(`NFL_V0` -\> `NFL_V3`).

## Usage

``` r
visit_root(x, visits = c("V0", "V3"))

visit_swap(x, from = "V0", to = "V3")
```

## Arguments

- x:

  Character vector of variable names.

- visits:

  Visit suffixes to remove.

- from, to:

  Visit suffixes (without the underscore).

## Value

A character vector of the same length as `x`.

## Examples

``` r
visit_root(c("NFL_V0", "MDS_TOT_V3", "AGE"))
#> [1] "NFL"     "MDS_TOT" "AGE"    
visit_swap(c("NFL_V0", "IL6_V0"), "V0", "V3")
#> [1] "NFL_V3" "IL6_V3"
```
