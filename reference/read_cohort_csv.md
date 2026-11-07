# Read a "French" CSV file

Robust reader for CSV files exported by French versions of spreadsheet
software: `;` separator, possible `,` decimal mark, several
missing-value codes, automatic encoding detection (UTF-8 or Latin-1 /
Windows-1252). Character columns that are actually numeric (e.g.
`"12,5"`) are converted.

## Usage

``` r
read_cohort_csv(
  path,
  sep = ";",
  na = c("", "NA", "NaN", ".", "NR", "ND"),
  convert_comma_decimal = TRUE,
  encoding = "auto",
  ...
)
```

## Arguments

- path:

  Path to the file (accents resolved with
  [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md)).

- sep:

  Field separator.

- na:

  Strings read as missing values.

- convert_comma_decimal:

  Convert character columns whose every non-missing value is a number
  written with a comma or a point.

- encoding:

  `"auto"` (UTF-8 if the file is valid UTF-8, `"latin1"` otherwise) or
  an explicit file encoding.

- ...:

  Passed to
  [`utils::read.csv()`](https://rdrr.io/r/utils/read.table.html).

## Value

A data frame (column names unchanged, see
[`clean_colnames()`](https://clement-poupelin.github.io/vernissage/reference/clean_colnames.md)).

## Examples

``` r
f <- system.file("extdata", "cohort_messy.csv", package = "vernissage")
raw <- read_cohort_csv(f)
#> Detected encoding: "latin1".
str(raw)
#> 'data.frame':    6 obs. of  8 variables:
#>  $ Numéro patient: chr  "P001" "P002" "P003" "P004" ...
#>  $ Groupe        : chr  "Placebo" "Actif" "Placebo" "Actif" ...
#>  $ Sexe          : chr  "F" "M" "M" "F" ...
#>  $ Âge           : int  64 71 58 66 73 61
#>  $ NfL V0        : num  12.4 18.9 9.7 NA 21.3 11
#>  $ NfL V3        : num  13.1 NA 10.2 14.8 22.6 11.5
#>  $ Score MoCA V0 : int  27 24 29 26 NA 28
#>  $ Commentaire   : chr  "RAS" "prélèvement hémolysé" NA NA ...
```
