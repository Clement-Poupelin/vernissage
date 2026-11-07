# Compare, choose and apply transformations

Workflow based on the shape of the marginal distribution:

- `transform_compare()`: skewness, excess kurtosis, Shapiro-Wilk W and p
  of every variable under every transformation (a decision tool, to be
  read with the plots);

- `transform_choose()`: one transformation per variable: the highest W,
  but the preferred method (log, interpretable as a multiplicative
  effect) is kept when its W is within `tol` of the best, and `"none"`
  is kept when the variable is already about symmetric
  (`|skewness| < skew_ok`);

- `transform_propagate()`: copies the reference-visit choice (same
  method and same lambda) to the other visits;

- `transform_apply()`: adds the transformed variables as new prefixed
  columns (`LOG_`, `BC_`, ...).

## Usage

``` r
transform_compare(
  df,
  vars,
  methods = c("none", "log", "log1p", "sqrt", "boxcox")
)

transform_choose(cmp, prefer = c("log", "log1p"), tol = 0.01, skew_ok = 0.5)

transform_propagate(choice, from = "_V0$", to = "_V3")

transform_apply(
  df,
  choice,
  prefixes = c(log = "LOG", log10 = "LOG10", log1p = "LOG1P", sqrt = "SQRT", boxcox =
    "BC")
)
```

## Arguments

- df:

  A data frame.

- vars:

  Numeric variables (names or tidyselect).

- methods:

  Transformations compared, among `"none"`, `"log"`, `"log10"`,
  `"log1p"`, `"sqrt"`, `"boxcox"` (the latter needs the car package).

- cmp:

  Output of `transform_compare()`.

- prefer:

  Preferred methods, in order.

- tol:

  Tolerance on W for the preferred method.

- skew_ok:

  Absolute skewness below which no transformation is applied.

- choice:

  Output of `transform_choose()` (columns `Variable`, `Method`, and
  `lambda`, `shift` for Box-Cox).

- from:

  Regular expression of the reference-visit suffix.

- to:

  Replacement suffix(es) of the other visits.

- prefixes:

  Named vector `method -> prefix of the new column`.

## Value

`transform_compare()`: one row per variable x method.
`transform_choose()`: one row per variable with a `Reason` column.
`transform_propagate()`: the choice with extra rows for the other
visits. `transform_apply()`: `list(data, map)` with `map` = original
variable, new column, method and lambda.

## Examples

``` r
cmp <- transform_compare(cohort_sim, c(NFL_V0, CRP_V0), methods = c("none", "log", "sqrt"))
choice <- transform_choose(cmp)
choice <- transform_propagate(choice)
res <- transform_apply(cohort_sim, choice)
res$map
#> # A tibble: 4 × 4
#>   Variable New        Method lambda
#>   <chr>    <chr>      <chr>   <dbl>
#> 1 NFL_V0   LOG_NFL_V0 log        NA
#> 2 CRP_V0   LOG_CRP_V0 log        NA
#> 3 NFL_V3   LOG_NFL_V3 log        NA
#> 4 CRP_V3   LOG_CRP_V3 log        NA
```
