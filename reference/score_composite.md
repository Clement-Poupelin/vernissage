# Composite score per domain

Mean of the z-scored variables of each domain (binary factors coded 0/1
before scaling). The z-scores use the mean and SD of `ref` (default: the
data itself), so that the same scaling can be applied to another visit
or population.

## Usage

``` r
score_composite(
  data,
  domains,
  direction = NULL,
  ref = data,
  min_prop = 0.5,
  prefix = "COMP_"
)
```

## Arguments

- data:

  A data frame.

- domains:

  Named list `composite name -> variables`.

- direction:

  Optional named vector `variable -> +1 / -1` (sign flip, e.g. so that
  higher always means worse).

- ref:

  Data giving the mean and SD of the z-scores.

- min_prop:

  Minimal share of observed variables to compute a score.

- prefix:

  Prefix of the new columns (the domain name is upper-cased,
  non-alphanumeric characters replaced by `_`).

## Value

`data` with one column per domain.

## Examples

``` r
d <- score_composite(cohort_sim, list(inflammation = c("IL6_V0", "CRP_V0"),
                                      cognition = c("MOCA_V0", "UPDRS_V0")),
                     direction = c(MOCA_V0 = -1))
summary(d[, c("COMP_INFLAMMATION", "COMP_COGNITION")])
#>  COMP_INFLAMMATION    COMP_COGNITION    
#>  Min.   :-0.7651235   Min.   :-1.75784  
#>  1st Qu.:-0.4759153   1st Qu.:-0.55924  
#>  Median :-0.2513240   Median : 0.09252  
#>  Mean   : 0.0004771   Mean   : 0.00000  
#>  3rd Qu.: 0.1434328   3rd Qu.: 0.43757  
#>  Max.   : 3.1544804   Max.   : 1.51819  
```
