# Readable labels of variables

`label_get()` looks variable names up in a named vector of labels and
falls back to the raw name. `label_expand()` builds labels of derived
variables from a dictionary of *root* names: the visit suffix is removed
first, then the prefixes one by one, so that `DELTA_LOG_NFL` becomes
`"Delta log(NfL)"` and `BIN_IL6_V0` becomes `"IL-6 (high) V0"`.

## Usage

``` r
label_get(var, labels = NULL)

label_expand(
  vars,
  base_labels,
  visit_map = c(V0 = "V0", V3 = "V3"),
  prefix_map = c(LOG = "log(%s)", LOG10 = "log10(%s)", LOG1P = "log(1+%s)", BC =
    "Box-Cox(%s)", SQRT = "√%s", BIN = NA, DELTA = "Δ %s", Z = "%s (z)"),
  bin_format = "%s (high)",
  bin_format_root = NULL
)
```

## Arguments

- var, vars:

  Character vector of variable names.

- labels:

  Named character vector `name -> label`, or `NULL`.

- base_labels:

  Named character vector of labels of the root names.

- visit_map:

  Named vector `suffix -> text appended to the label`.

- prefix_map:

  Named vector `prefix -> sprintf() format`. The `BIN` entry, when `NA`,
  is replaced by `bin_format`.

- bin_format:

  Format of the categorised variables (`BIN_` prefix), e.g.
  `"%s (high)"` for a median split or `"%s (tertiles)"`.

- bin_format_root:

  Optional named vector `root -> format` overriding `bin_format` for
  some roots (e.g. from `lodestar::cut_label_formats()`).

## Value

`label_get()`: an unnamed character vector of labels. `label_expand()`:
a character vector named by `vars`.

## Examples

``` r
labs <- c(NFL = "NfL", IL6 = "IL-6")
label_get(c("NFL", "AGE"), labs)
#> [1] "NfL" "AGE"
label_expand(c("NFL_V0", "LOG_NFL_V3", "DELTA_LOG_NFL", "BIN_IL6_V0"), labs)
#>           NFL_V0       LOG_NFL_V3    DELTA_LOG_NFL       BIN_IL6_V0 
#>         "NfL V0"    "log(NfL) V3"     "Δ log(NfL)" "IL-6 (high) V0" 
```
