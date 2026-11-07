# Format numbers and p-values for figures and tables

- `fmt_sci()` writes numbers in scientific notation with a
  multiplication sign and Unicode superscript exponents (2.1 x 10 to the
  power -6 is printed with a raised `-6`), readable in gt tables, DT
  tables, ggplot2 texts and inline text without LaTeX.

- `fmt_num()` uses fixed decimals, and switches to scientific notation
  when the value would print as 0 (`|x| < 0.5 x 10^-digits`) or is very
  large (`|x| >= 1e6`).

- `fmt_p()` formats p-values: `"0.023"`, `"0.0024"`, and scientific
  notation below `sci_below`; values under the machine precision are
  written as "\< 2.2 x 10 to the power -16".

- `fmt_stars()` converts p-values into significance stars.

## Usage

``` r
fmt_sci(x, digits = 2)

fmt_num(x, digits = 2, sci_digits = 2)

fmt_p(p, digits = 2, sci_below = 0.001)

fmt_stars(p, ns = "ns", trend = TRUE)
```

## Arguments

- x, p:

  Numeric vector (`NA` allowed).

- digits:

  Significant digits of the mantissa (`fmt_sci()`, `fmt_p()`) or number
  of decimals (`fmt_num()`).

- sci_digits:

  Significant digits used when `fmt_num()` switches to scientific
  notation.

- sci_below:

  p-values below this threshold are written in scientific notation.

- ns:

  Symbol of a non-significant p-value.

- trend:

  If `TRUE`, `"."` marks `0.05 <= p < 0.10`.

## Value

A character vector of the same length as the input (`"NA"` for missing
values, `""` in `fmt_stars()`).

## Examples

``` r
fmt_sci(c(0.000021, 123456789))
#> [1] "2.1×10⁻⁵" "1.2×10⁸" 
fmt_num(c(1.23456, 0.0001, NA), digits = 2)
#> [1] "1.23"     "1.0×10⁻⁴" "NA"      
fmt_p(c(0.2, 0.0312, 0.00012, 1e-20))
#> [1] "0.2"        "0.031"      "1.2×10⁻⁴"   "<2.2×10⁻¹⁶"
fmt_stars(c(0.2, 0.07, 0.03, 0.004, 0.0001))
#> [1] "ns"  "."   "*"   "**"  "***"
```
