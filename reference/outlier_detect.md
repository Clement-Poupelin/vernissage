# Table of outliers and masking

`outlier_detect()` lists the flagged values (one row per subject x
variable). `outlier_mask()` sets the listed values to `NA`.

## Usage

``` r
outlier_detect(
  df,
  vars,
  id_col = NULL,
  rule = c("mad", "iqr", "both", "any"),
  mad_z_threshold = 3.5,
  iqr_k = 1.5,
  iqr_method = c("quantile", "hinges")
)

outlier_mask(df, outliers, id_col)
```

## Arguments

- df:

  A data frame.

- vars:

  Numeric variables (names or tidyselect).

- id_col:

  Identifier column (default: row numbers).

- rule:

  Which values are listed: `"mad"` (MAD rule), `"iqr"` (Tukey), `"both"`
  (flagged by both rules, most conservative) or `"any"` (flagged by at
  least one rule).

- mad_z_threshold:

  Cut-off of the modified z-score.

- iqr_k:

  Multiplier of the Tukey fences.

- iqr_method:

  `"quantile"` or `"hinges"`, see
  [`outlier_flag_iqr()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md).

- outliers:

  Output of `outlier_detect()`.

## Value

`outlier_detect()`: a tibble `id`, `Variable`, `Value`, `modified_z`,
`MAD`, `IQR` (logical: rule that flagged the value). `outlier_mask()`:
`df` with the listed values set to `NA`.

## Examples

``` r
out <- outlier_detect(cohort_sim, c(CRP_V0, NFL_V0), id_col = ID, rule = "any")
out
#> # A tibble: 19 × 6
#>    id    Variable Value modified_z MAD   IQR  
#>    <chr> <chr>    <dbl>      <dbl> <lgl> <lgl>
#>  1 P007  CRP_V0   31.4       21.3  TRUE  TRUE 
#>  2 P011  CRP_V0    8.67       4.87 TRUE  TRUE 
#>  3 P022  CRP_V0   17.2       11.1  TRUE  TRUE 
#>  4 P046  CRP_V0    7.2        3.81 TRUE  TRUE 
#>  5 P055  CRP_V0   17.7       11.4  TRUE  TRUE 
#>  6 P058  CRP_V0    7.65       4.13 TRUE  TRUE 
#>  7 P074  CRP_V0   12.4        7.62 TRUE  TRUE 
#>  8 P090  CRP_V0    8.2        4.53 TRUE  TRUE 
#>  9 P100  CRP_V0   14.2        8.87 TRUE  TRUE 
#> 10 P114  CRP_V0   10.2        5.98 TRUE  TRUE 
#> 11 P120  CRP_V0    8.76       4.94 TRUE  TRUE 
#> 12 P015  NFL_V0   33.7        3.07 FALSE TRUE 
#> 13 P032  NFL_V0   32.5        2.89 FALSE TRUE 
#> 14 P047  NFL_V0   31.3        2.71 FALSE TRUE 
#> 15 P073  NFL_V0   43.7        4.55 TRUE  TRUE 
#> 16 P087  NFL_V0   32.9        2.95 FALSE TRUE 
#> 17 P100  NFL_V0   69.4        8.36 TRUE  TRUE 
#> 18 P109  NFL_V0   37.3        3.60 TRUE  TRUE 
#> 19 P110  NFL_V0   32.1        2.83 FALSE TRUE 
masked <- outlier_mask(cohort_sim, out, id_col = ID)
```
