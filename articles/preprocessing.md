# Preprocessing: from raw files to analysis variables

``` r

library(vernissage)
```

The key rule for longitudinal data: **a transformation is decided at the
reference visit (V0) and applied unchanged to the other visits**.
Otherwise a V3 - V0 change mixes biology and a change of scale.

## Import and names

[`read_cohort_csv()`](https://clement-poupelin.github.io/vernissage/reference/read_cohort_csv.md)
reads CSV files exported by French spreadsheets (`;` separator, `,`
decimals, Latin-1 encoding, codes such as `NR` or `ND` for missing
values).

``` r

f <- system.file("extdata", "cohort_messy.csv", package = "vernissage")
raw <- read_cohort_csv(f)
#> Detected encoding: "latin1".
raw
#>   Numéro patient  Groupe Sexe Âge NfL V0 NfL V3 Score MoCA V0
#> 1           P001 Placebo    F  64   12.4   13.1            27
#> 2           P002   Actif    M  71   18.9     NA            24
#> 3           P003 Placebo    M  58    9.7   10.2            29
#> 4           P004   Actif    F  66     NA   14.8            26
#> 5           P005   Actif    M  73   21.3   22.6            NA
#> 6           P006 Placebo    F  61   11.0   11.5            28
#>            Commentaire
#> 1                  RAS
#> 2 prélèvement hémolysé
#> 3                 <NA>
#> 4                 <NA>
#> 5      patient fatigué
#> 6                 <NA>
raw <- clean_colnames(raw)
names(raw)
#> [1] "NUMÉROPATIENT" "GROUPE"        "SEXE"          "ÂGE"          
#> [5] "NFLV0"         "NFLV3"         "SCOREMOCAV0"   "COMMENTAIRE"
map <- c("ID", "NFL_V0", "NFL_V3")
names(map) <- names(raw)[c(1, 5, 6)]     # c(OLD = "NEW")
map
#> NUMÉROPATIENT         NFLV0         NFLV3 
#>          "ID"      "NFL_V0"      "NFL_V3"
raw <- rename_with_map(raw, map)
names(raw)
#> [1] "ID"          "GROUPE"      "SEXE"        "ÂGE"         "NFL_V0"     
#> [6] "NFL_V3"      "SCOREMOCAV0" "COMMENTAIRE"
```

Unusual visit suffixes are mapped to the convention, and bilateral
measures averaged:

``` r

visit_map_suffix(c("MRI_GPI_L0", "MRI_GPI_L36"), select = "^MRI_")
#>     MRI_GPI_L0    MRI_GPI_L36 
#> "MRI_GPI_L_V0" "MRI_GPI_L_V3"
d <- combine_bilateral(cohort_sim, "PUT")
head(d[, c("PUT_L_V0", "PUT_R_V0", "PUT_V0")])
#>   PUT_L_V0 PUT_R_V0 PUT_V0
#> 1     4.05     3.74  3.895
#> 2     3.88     3.77  3.825
#> 3     4.52     4.50  4.510
#> 4     4.80     4.65  4.725
#> 5     5.05     5.32  5.185
#> 6     5.02     5.05  5.035
```

A catalogue of the variables:

``` r

catalog_vars(cohort_sim, list(Biomarkers = c("NFL", "IL6", "CRP"),
                              Scores = c("MOCA", "UPDRS", "FALL"),
                              Demography = c("AGE", "SEX", "BMI")))
#> # A tibble: 9 × 7
#>   Block      Variable Label Description Type       Visits % missing (first vis…¹
#>   <chr>      <chr>    <chr> <chr>       <chr>      <chr>                   <dbl>
#> 1 Biomarkers NFL      NFL   ""          Continuous V0, V3                    0  
#> 2 Biomarkers IL6      IL6   ""          Continuous V0, V3                    0  
#> 3 Biomarkers CRP      CRP   ""          Continuous V0, V3                    4.2
#> 4 Scores     MOCA     MOCA  ""          Discrete   V0, V3                    0  
#> 5 Scores     UPDRS    UPDRS ""          Discrete   V0, V3                    0  
#> 6 Scores     FALL     FALL  ""          Categoric… V0, V3                    0  
#> 7 Demography AGE      AGE   ""          Discrete   —                         0  
#> 8 Demography SEX      SEX   ""          Categoric… —                         0  
#> 9 Demography BMI      BMI   ""          Continuous —                         3.3
#> # ℹ abbreviated name: ¹​`% missing (first visit)`
```

## Outliers

Two robust rules (see
[`?outlier_flag_mad`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md)):
the modified z-score (Iglewicz & Hoaglin) and Tukey’s fences. A flag is
a prompt to look, not a reason to delete.

``` r

out <- outlier_detect(cohort_sim, c(NFL_V0, CRP_V0), id_col = ID, rule = "any")
out
#> # A tibble: 19 × 6
#>    id    Variable Value modified_z MAD   IQR  
#>    <chr> <chr>    <dbl>      <dbl> <lgl> <lgl>
#>  1 P015  NFL_V0   33.7        3.07 FALSE TRUE 
#>  2 P032  NFL_V0   32.5        2.89 FALSE TRUE 
#>  3 P047  NFL_V0   31.3        2.71 FALSE TRUE 
#>  4 P073  NFL_V0   43.7        4.55 TRUE  TRUE 
#>  5 P087  NFL_V0   32.9        2.95 FALSE TRUE 
#>  6 P100  NFL_V0   69.4        8.36 TRUE  TRUE 
#>  7 P109  NFL_V0   37.3        3.60 TRUE  TRUE 
#>  8 P110  NFL_V0   32.1        2.83 FALSE TRUE 
#>  9 P007  CRP_V0   31.4       21.3  TRUE  TRUE 
#> 10 P011  CRP_V0    8.67       4.87 TRUE  TRUE 
#> 11 P022  CRP_V0   17.2       11.1  TRUE  TRUE 
#> 12 P046  CRP_V0    7.2        3.81 TRUE  TRUE 
#> 13 P055  CRP_V0   17.7       11.4  TRUE  TRUE 
#> 14 P058  CRP_V0    7.65       4.13 TRUE  TRUE 
#> 15 P074  CRP_V0   12.4        7.62 TRUE  TRUE 
#> 16 P090  CRP_V0    8.2        4.53 TRUE  TRUE 
#> 17 P100  CRP_V0   14.2        8.87 TRUE  TRUE 
#> 18 P114  CRP_V0   10.2        5.98 TRUE  TRUE 
#> 19 P120  CRP_V0    8.76       4.94 TRUE  TRUE
masked <- outlier_mask(cohort_sim, out[out$MAD & out$IQR, ], id_col = ID)
```

## Transformations

``` r

cmp <- transform_compare(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0), methods = c("none", "log", "sqrt"))
choice <- transform_choose(cmp)
choice[, c("Variable", "Method", "skewness", "W", "Reason")]
#> # A tibble: 3 × 5
#>   Variable Method skewness     W Reason                          
#>   <chr>    <chr>     <dbl> <dbl> <chr>                           
#> 1 NFL_V0   log      0.102  0.986 Preferred (W within 0.01 of max)
#> 2 IL6_V0   log      0.689  0.936 Preferred (W within 0.01 of max)
#> 3 CRP_V0   log      0.0723 0.989 Preferred (W within 0.01 of max)
res <- transform_apply(cohort_sim, transform_propagate(choice))
res$map
#> # A tibble: 6 × 4
#>   Variable New        Method lambda
#>   <chr>    <chr>      <chr>   <dbl>
#> 1 NFL_V0   LOG_NFL_V0 log        NA
#> 2 IL6_V0   LOG_IL6_V0 log        NA
#> 3 CRP_V0   LOG_CRP_V0 log        NA
#> 4 NFL_V3   LOG_NFL_V3 log        NA
#> 5 IL6_V3   LOG_IL6_V3 log        NA
#> 6 CRP_V3   LOG_CRP_V3 log        NA
```

With the car package,
[`transform_boxcox()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md)
uses car’s documented rule (maximum-likelihood lambda and its rounded
power), and
[`transform_boxcox_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md)
decides the transformation of a score on the residuals of
`score ~ covariates`.

``` r

transform_boxcox(cohort_sim, c(NFL_V0, CRP_V0))[, c("Variable", "lambda_ml", "rounded", "Method", "Reason")]
#> # A tibble: 2 × 5
#>   Variable lambda_ml rounded Method Reason                           
#>   <chr>        <dbl>   <dbl> <chr>  <chr>                            
#> 1 NFL_V0     -0.0641       0 log    lambda = 0 inside the 95% CI: log
#> 2 CRP_V0     -0.0199       0 log    lambda = 0 inside the 95% CI: log
```

## Labels of derived variables

Labels of transformed, categorised or change variables follow from the
labels of the roots:

``` r

labs <- c(NFL = "NfL", IL6 = "IL-6", CRP = "CRP")
label_expand(c("NFL_V0", "BIN_IL6_V0", "LOG_NFL_V3", "DELTA_NFL"), labs)
#>           NFL_V0       BIN_IL6_V0       LOG_NFL_V3        DELTA_NFL 
#>         "NfL V0" "IL-6 (high) V0"    "log(NfL) V3"          "Δ NfL"
label_expand("BIN_IL6_V0", labs, bin_format = "%s (tertiles)")
#>           BIN_IL6_V0 
#> "IL-6 (tertiles) V0"
```

Limits of detection and cut-offs are handled by the companion package
[lodestar](https://github.com/Clement-Poupelin/lodestar)
(`lod_handle()`, `cut_compute()`, `cut_apply()`…).

## Visits

``` r

d <- visit_add_deltas(cohort_sim, c("NFL", "MOCA"))
long <- visit_to_long(cohort_sim, c("NFL", "MOCA"), id_col = ID, keep = GROUP,
                      time_values = c(V0 = 0, V3 = 36))
head(long)
#> # A tibble: 6 × 6
#>   ID    GROUP   VISIT   NFL  MOCA  TIME
#>   <chr> <fct>   <fct> <dbl> <dbl> <dbl>
#> 1 P001  Placebo V0     26.8    24     0
#> 2 P001  Placebo V3     NA      NA    36
#> 3 P002  Placebo V0      6.6    26     0
#> 4 P002  Placebo V3      8.5    27    36
#> 5 P003  Placebo V0      4.9    28     0
#> 6 P003  Placebo V3      5.2    27    36
```

## Composite scores

``` r

d <- score_composite(cohort_sim, list(inflammation = c("IL6_V0", "CRP_V0"),
                                      motor = c("UPDRS_V0", "FALL_V0")))
summary(d[, c("COMP_INFLAMMATION", "COMP_MOTOR")])
#>  COMP_INFLAMMATION      COMP_MOTOR      
#>  Min.   :-0.7651235   Min.   :-1.46772  
#>  1st Qu.:-0.4759153   1st Qu.:-0.56526  
#>  Median :-0.2513240   Median :-0.08749  
#>  Mean   : 0.0004771   Mean   : 0.00000  
#>  3rd Qu.: 0.1434328   3rd Qu.: 0.34315  
#>  Max.   : 3.1544804   Max.   : 2.16592
```
