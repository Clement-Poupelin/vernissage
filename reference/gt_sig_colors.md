# Colours of significance highlighting

Three shades of green (ColorBrewer "Greens", colour-blind safe, readable
in print): `nominal` (p \< 0.05 unadjusted, light), `fdr` (significant
after Benjamini-Hochberg, medium) and `robust` (association found again
across analyses, dark).

## Usage

``` r
gt_sig_colors()
```

## Value

Named character vector.

## Examples

``` r
gt_sig_colors()
#>   nominal       fdr    robust 
#> "#E5F5E0" "#A1D99B" "#238B45" 
```
