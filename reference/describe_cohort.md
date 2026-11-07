# Overview table of a cohort

A preliminary table describing the data set at the start of an analysis:
one block of rows per variable with its type, number observed, missing
values, summary (overall and by group), a group comparison and a small
text histogram of the observed values.

## Usage

``` r
describe_cohort(
  data,
  vars = NULL,
  by = NULL,
  id_col = NULL,
  blocks = NULL,
  labels = NULL,
  test = TRUE,
  digits = 1,
  spark = TRUE,
  discrete_max = 15,
  missing_warn = 20,
  title = "Cohort overview",
  subtitle = NULL,
  output = c("gt", "data")
)
```

## Arguments

- data:

  A data frame, one row per subject.

- vars:

  Variables to describe (names or tidyselect; default: all but `id_col`
  and `by`).

- by:

  Optional grouping column (e.g. treatment arm).

- id_col:

  Optional identifier column: the subtitle reports the number of unique
  identifiers and warns about duplicates.

- blocks:

  Optional named list `block -> variables`, shown as row groups
  (variables not listed go to "Other variables").

- labels:

  Optional named vector of labels.

- test:

  Compare the groups of `by`.

- digits:

  Decimals of the summaries.

- spark:

  Add the text-histogram column.

- discrete_max:

  Numeric variables with integer values and at most this number of
  distinct values are typed "Discrete".

- missing_warn:

  Share of missing values (%) above which the cell is highlighted.

- title, subtitle:

  Title and subtitle (`subtitle = NULL`: automatic summary of the data
  set).

- output:

  `"gt"` (formatted table, needs the gt package) or `"data"` (the
  underlying tibble).

## Value

A `gt_tbl` or a tibble (`output = "data"`).

## Details

- Continuous and discrete variables: median \[Q1; Q3\] and range; text
  histogram of the observed values (8 bins).

- Categorical and binary variables: a header row, then one row per level
  with n (%) of the observed values and a bar proportional to the share.

- Dates: range.

- Group comparison (`by`, `test = TRUE`): Wilcoxon / Kruskal-Wallis for
  numeric variables, chi-squared or Fisher (expected counts \< 5) for
  categorical ones; unadjusted p-values, for description only.

- Variables with more than `missing_warn` percent missing values are
  highlighted.

## Examples

``` r
describe_cohort(cohort_sim, vars = c(AGE, SEX, BMI, NFL_V0, MOCA_V0, FALL_V0),
                by = GROUP, id_col = ID, output = "data")
#> # A tibble: 10 × 15
#>    Variable Type      N Missing Overall Range Placebo Active      p Distribution
#>    <chr>    <chr> <int> <chr>   <chr>   <chr> <chr>   <chr>   <dbl> <chr>       
#>  1 AGE      "Con…   120 "0 (0%… "67.0 … "45.… "68.0 … "66.0…  0.548 "▁▁▅▆█▅▂▂"  
#>  2 SEX      "Bin…   120 "0 (0%… ""      ""    ""      ""      0.636 ""          
#>  3 Female   ""       NA ""      "47 (3… ""    "28 (4… "19 (… NA     "████"      
#>  4 Male     ""       NA ""      "73 (6… ""    "39 (5… "34 (… NA     "██████"    
#>  5 BMI      "Con…   116 "4 (3%… "26.0 … "16.… "26.0 … "26.1…  0.885 "▂▂▄▇██▅▄"  
#>  6 NFL_V0   "Con…   120 "0 (0%… "13.0 … "4.1… "13.0 … "13.2…  0.924 "█▇▂▁▁  ▁"  
#>  7 MOCA_V0  "Dis…   120 "0 (0%… "27.0 … "21.… "27.0 … "27.0…  0.747 "▁▂▂▄▆▄▅█"  
#>  8 FALL_V0  "Bin…   120 "0 (0%… ""      ""    ""      ""      1.00  ""          
#>  9 No       ""       NA ""      "96 (8… ""    "54 (8… "42 (… NA     "████████"  
#> 10 Yes      ""       NA ""      "24 (2… ""    "13 (1… "11 (… NA     "██"        
#> # ℹ 5 more variables: .test <chr>, .is_level <lgl>, .pct_missing <dbl>,
#> #   .var <chr>, .block <chr>
describe_cohort(cohort_sim, vars = c(AGE, SEX, BMI, NFL_V0, IL6_V0, MOCA_V0, FALL_V0),
                by = GROUP, id_col = ID,
                blocks = list(Demography = c("AGE", "SEX", "BMI"),
                              Biomarkers = c("NFL_V0", "IL6_V0"),
                              Clinical = c("MOCA_V0", "FALL_V0")))


  


Cohort overview
```
