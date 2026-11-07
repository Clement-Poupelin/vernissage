# Publication table with gt

Numbers rounded (scientific notation when they would print as 0, see
[`fmt_num()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)),
whole-number columns without decimals, p-value columns detected from
their name (a separate token `p`, e.g. `p`, `p.value`, `p_adj`,
`McNemar p`, or `FDR`) and formatted with
[`fmt_p()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md),
bold when below 0.05, missing p-values shown as a dash; optional source
note.

## Usage

``` r
gt_pub(
  df,
  title = NULL,
  subtitle = NULL,
  groupname_col = NULL,
  p_cols = NULL,
  decimals = 2,
  font_size = 12,
  note = NULL,
  auto_p = TRUE
)
```

## Arguments

- df:

  A data frame.

- title, subtitle:

  Title and subtitle (Markdown).

- groupname_col:

  Optional column defining row groups.

- p_cols:

  Columns of p-values, in addition to those detected.

- decimals:

  Decimals of the other numeric columns.

- font_size:

  Font size, in pixels.

- note:

  Optional source note (Markdown), e.g. model, adjustment, N.

- auto_p:

  Detect p-value columns from their names.

## Value

A `gt_tbl`.

## Examples

``` r
tab <- describe_normality(cohort_sim, c(AGE, NFL_V0, CRP_V0))
gt_pub(tab, title = "Normality", note = "Shapiro-Wilk test")


  


Normality
```
