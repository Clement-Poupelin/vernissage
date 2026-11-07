# Resolve a path whose accented characters are stored differently on disk

A file name with accents can be stored in Unicode NFC (one code point
for an accented letter) or NFD (letter + combining accent), e.g. folders
created on macOS or extracted from a zip. Each path component that does
not exist as typed is matched against the directory listing after NFC
normalisation.

## Usage

``` r
path_resolve_nfc(path)
```

## Arguments

- path:

  Path to a file or directory.

## Value

The path as it exists on disk (a message is printed when it differs from
`path`). An error is raised if no match is found.

## Examples

``` r
path_resolve_nfc(system.file("extdata", "cohort_messy.csv", package = "vernissage"))
#> [1] "/home/runner/work/_temp/Library/vernissage/extdata/cohort_messy.csv"
```
