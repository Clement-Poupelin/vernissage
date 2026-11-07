# Robust outlier rules

- `outlier_flag_mad()`: modified z-score of Iglewicz & Hoaglin (1993),
  `|0.6745 (x - median) / MAD| > threshold` with the raw
  `MAD = median(|x - median|)`. When more than half of the values are
  identical (MAD = 0, e.g. values piled at a detection floor) no value
  is flagged by this rule.

- `outlier_flag_iqr()`: Tukey's fences (Tukey 1977), `x < Q1 - k IQR` or
  `x > Q3 + k IQR`. `method = "quantile"` uses the type-7 quartiles of
  [`stats::quantile()`](https://rdrr.io/r/stats/quantile.html);
  `method = "hinges"` uses Tukey's hinges of
  [`grDevices::boxplot.stats()`](https://rdrr.io/r/grDevices/boxplot.stats.html)
  (the boxplot whiskers).

Normal data: the IQR rule (about 2.7 SD) is stricter than the MAD rule
(3.5 SD), so nearly every MAD outlier is also an IQR outlier. "MAD only"
values appear with skewed or bimodal distributions; values flagged by
both rules are the most robust signals.

## Usage

``` r
outlier_flag_mad(x, threshold = 3.5)

outlier_flag_iqr(x, k = 1.5, method = c("quantile", "hinges"))
```

## Arguments

- x:

  Numeric vector (`NA` allowed).

- threshold:

  Cut-off on the absolute modified z-score (3.5 recommended).

- k:

  Fence multiplier (1.5 = outlier, 3 = far out).

- method:

  `"quantile"` or `"hinges"`, see Description.

## Value

A logical vector of the same length as `x` (`NA` everywhere when fewer
than 5 values are observed; `FALSE` for missing values otherwise).

## References

Tukey JW (1977). *Exploratory Data Analysis*. Addison-Wesley.

Hoaglin DC, Iglewicz B, Tukey JW (1986). Performance of some resistant
rules for outlier labeling. *J Am Stat Assoc* 81:991-999.

Iglewicz B, Hoaglin DC (1993). *How to Detect and Handle Outliers*. ASQC
Quality Press.

Leys C, Ley C, Klein O, Bernard P, Licata L (2013). Detecting outliers:
do not use standard deviation around the mean, use absolute deviation
around the median. *J Exp Soc Psychol* 49:764-766.

## Examples

``` r
x <- c(rnorm(50), 8)
which(outlier_flag_mad(x))
#> [1] 27 39 51
which(outlier_flag_iqr(x))
#> [1] 18 27 31 38 39 51
```
