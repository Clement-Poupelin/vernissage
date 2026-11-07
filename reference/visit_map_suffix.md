# Map unusual visit suffixes to the `<ROOT>_<VISIT>` convention

E.g. `MRI_GPI_L0` / `MRI_GPI_L36` -\> `MRI_GPI_L_V0` / `MRI_GPI_L_V3`.
The longest suffixes are tried first (`"36"` before `"6"` or `"0"`).

## Usage

``` r
visit_map_suffix(cols, select, suffix_map = c(`36` = "V3", `0` = "V0"))
```

## Arguments

- cols:

  Column names.

- select:

  Regular expression selecting the columns to rename (e.g. `"^MRI_"`).
  Required: renaming every column ending with a digit would break names
  such as `AGE_V0`.

- suffix_map:

  Named vector `old suffix -> visit`.

## Value

Named character vector `c(OLD = "NEW")` for
[`rename_with_map()`](https://clement-poupelin.github.io/vernissage/reference/rename_with_map.md).

## Examples

``` r
visit_map_suffix(c("MRI_GPI_L0", "MRI_GPI_L36", "AGE"), select = "^MRI_")
#>     MRI_GPI_L0    MRI_GPI_L36 
#> "MRI_GPI_L_V0" "MRI_GPI_L_V3" 
```
