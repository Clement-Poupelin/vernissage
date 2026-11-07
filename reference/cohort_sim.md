# Simulated clinical cohort with two visits

A simulated cohort (no real patient) in wide format, used in the
examples, tests and vignettes: 120 subjects randomised to two arms,
measured at baseline (`_V0`) and at follow-up (`_V3`). It reproduces the
usual difficulties of cohort data: skewed biomarkers, values piled at a
limit of detection, gross outliers, bounded integer scores, a bilateral
measure and missing values, more frequent at follow-up.

## Usage

``` r
cohort_sim
```

## Format

A data frame with 120 rows and 21 columns:

- ID:

  Subject identifier (`P001` to `P120`).

- GROUP:

  Treatment arm, factor (`Placebo`, `Active`).

- SEX:

  Factor (`Female`, `Male`).

- AGE:

  Age at baseline, years.

- BMI:

  Body mass index, kg/m2 (a few missing values).

- NFL_V0, NFL_V3:

  Neurofilament light chain, pg/mL (log-normal, increasing with age).

- IL6_V0, IL6_V3:

  Interleukin-6, pg/mL; values below the limit of detection are reported
  at 0.5.

- CRP_V0, CRP_V3:

  C-reactive protein, mg/L (skewed; two gross outliers at baseline).

- MOCA_V0, MOCA_V3:

  Montreal Cognitive Assessment, integer 10-30.

- UPDRS_V0, UPDRS_V3:

  Motor score (UPDRS part III), integer.

- FALL_V0, FALL_V3:

  Falls in the last year, factor (`No`, `Yes`).

- PUT_L_V0, PUT_R_V0, PUT_L_V3, PUT_R_V3:

  Left and right putamen volume, mL.

## Source

Simulated, see `data-raw/cohort_sim.R` in the source package.

## Examples

``` r
str(cohort_sim)
#> 'data.frame':    120 obs. of  21 variables:
#>  $ ID      : chr  "P001" "P002" "P003" "P004" ...
#>  $ GROUP   : Factor w/ 2 levels "Placebo","Active": 1 1 1 2 1 1 1 2 2 2 ...
#>  $ SEX     : Factor w/ 2 levels "Female","Male": 2 2 1 1 2 2 2 2 2 2 ...
#>  $ AGE     : num  80 82 67 72 51 69 61 64 69 73 ...
#>  $ BMI     : num  27.1 26.4 30.8 28.9 26 25.9 26.6 21.7 30.9 23.8 ...
#>  $ NFL_V0  : num  26.8 6.6 4.9 7.7 14.7 19.4 7.6 12 17.2 17.5 ...
#>  $ NFL_V3  : num  NA 8.5 5.2 7.2 21 27.1 9.6 14.7 15.6 14 ...
#>  $ IL6_V0  : num  2.59 1.04 1.2 1.81 0.83 1.01 0.76 0.9 0.52 2.25 ...
#>  $ IL6_V3  : num  NA 0.68 2.13 2.31 1.31 0.5 0.5 0.71 0.54 2.08 ...
#>  $ CRP_V0  : num  2.8 1.21 5.63 0.97 2.37 ...
#>  $ CRP_V3  : num  NA 0.73 4.09 1.01 1.64 4.28 9.22 1.26 1.62 0.88 ...
#>  $ MOCA_V0 : num  24 26 28 30 25 26 27 29 27 25 ...
#>  $ MOCA_V3 : num  NA 27 27 29 26 24 28 29 23 24 ...
#>  $ UPDRS_V0: num  20 7 15 4 34 22 1 33 29 5 ...
#>  $ UPDRS_V3: num  NA 12 21 1 36 25 5 37 32 6 ...
#>  $ FALL_V0 : Factor w/ 2 levels "No","Yes": 1 2 1 1 1 1 1 2 1 1 ...
#>  $ FALL_V3 : Factor w/ 2 levels "No","Yes": NA 2 1 1 2 1 1 1 1 1 ...
#>  $ PUT_L_V0: num  4.05 3.88 4.52 4.8 5.05 5.02 4.58 4.34 4.51 4.78 ...
#>  $ PUT_R_V0: num  3.74 3.77 4.5 4.65 5.32 5.05 4.41 4.24 4.29 4.68 ...
#>  $ PUT_L_V3: num  NA 3.88 4.44 4.76 5.03 5 4.56 4.32 4.53 4.76 ...
#>  $ PUT_R_V3: num  NA 3.74 4.47 4.62 5.22 5.03 4.37 4.23 4.32 4.54 ...
```
