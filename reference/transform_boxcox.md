# Box-Cox decision with car's documented rule

Every decision is made by an existing function with its documented
default: lambda by maximum likelihood with its Wald 95% CI
([`car::powerTransform()`](https://rdrr.io/pkg/car/man/powerTransform.html)),
car's rounded power (the first of 1, 0, -1, 0.5, 0.33, -0.5, -0.33, 2,
-2 inside the CI) and likelihood-ratio tests of lambda = 0 (log) and
lambda = 1 (no transformation)
([`car::testTransform()`](https://rdrr.io/pkg/car/man/testTransform.html)).

- `transform_boxcox()`: marginal distribution of strictly positive
  variables (values \<= 0 or fewer than 10 values: kept raw);

- `transform_boxcox_resid()`: for a response, the normality assumption
  concerns the residuals: lambda is estimated for `<root><visit>` in the
  linear model `score ~ covariates`. Scores with zeros use the
  Yeo-Johnson family
  ([`car::yjPower()`](https://rdrr.io/pkg/car/man/bcPower.html), Yeo &
  Johnson 2000), equal to `log(1 + y)` for lambda = 0;

- `transform_apply_resid()`: adds the transformed scores at every visit
  (prefixes `LOG_`, `SQRT_`, `BC_`, `LOG1P_`, `YJ_`) with the reference
  decision.

## Usage

``` r
transform_boxcox(df, vars)

transform_boxcox_resid(df, roots, covariates, visit = "_V0")

transform_apply_resid(
  df,
  decision,
  visits = c("V0", "V3"),
  prefixes = c(log = "LOG", sqrt = "SQRT", boxcox = "BC", log1p = "LOG1P", yj = "YJ")
)
```

## Arguments

- df:

  A data frame.

- vars:

  Strictly positive variables (names or tidyselect).

- roots:

  Root names of the scores.

- covariates:

  Covariates of the linear model.

- visit:

  Suffix of the reference visit (with the underscore).

- decision:

  Output of `transform_boxcox_resid()`.

- visits:

  Visit suffixes where the transformation is applied.

- prefixes:

  Named vector `method -> prefix`.

## Value

`transform_boxcox()`: one row per variable with lambda, CI, rounded
power, LR p-values, `Method` / `lambda` / `shift` (input of
[`transform_apply()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)),
skewness and W before / after. `transform_boxcox_resid()`: one row per
root with the skewness of the residuals before / after.
`transform_apply_resid()`: `list(data, map)`.

## References

Box GEP, Cox DR (1964). An analysis of transformations. *J R Stat Soc B*
26:211-252. Fox J, Weisberg S (2019). *An R Companion to Applied
Regression*, 3rd ed. Yeo IK, Johnson RA (2000). A new family of power
transformations to improve normality or symmetry. *Biometrika*
87:954-959.

## Examples

``` r
transform_boxcox(cohort_sim, c(NFL_V0, CRP_V0))
#> # A tibble: 2 × 16
#>   Variable     N lambda_ml ci_low ci_high rounded p_log   p_none Method lambda
#>   <chr>    <int>     <dbl>  <dbl>   <dbl>   <dbl> <dbl>    <dbl> <chr>   <dbl>
#> 1 NFL_V0     120   -0.0641 -0.337   0.209       0 0.644 3.61e-16 log        NA
#> 2 CRP_V0     115   -0.0199 -0.160   0.120       0 0.781 1.46e-40 log        NA
#> # ℹ 6 more variables: shift <dbl>, skew_before <dbl>, W_before <dbl>,
#> #   Reason <chr>, skew_after <dbl>, W_after <dbl>
dec <- transform_boxcox_resid(cohort_sim, "UPDRS", covariates = c("AGE", "SEX"))
transform_apply_resid(cohort_sim, dec)$map
#> # A tibble: 1 × 4
#>   Root  New   Method lambda
#>   <chr> <chr> <chr>   <dbl>
#> 1 UPDRS UPDRS none       NA
```
