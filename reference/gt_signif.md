# Highlight significant results in gt tables

- `gt_signif()` colours cells: numeric unadjusted p-values below `alpha`
  (light green), numeric adjusted p-values below `alpha` (medium green,
  bold), and text cells "effect; p = ..." (light green when p \<
  `alpha`, medium green bold when the cell ends with `*`).

- `gt_highlight_rows()` colours whole rows (selected columns), e.g.
  robust associations (dark green, white bold text).

- `gt_signif_legend()` adds a legend of the colours under the table.

Use after any theme function: the cell styles are added on top of it.

## Usage

``` r
gt_signif(
  x,
  p_cols = NULL,
  fdr_cols = NULL,
  text_cols = NULL,
  alpha = 0.05,
  colors = gt_sig_colors(),
  legend = TRUE
)

gt_highlight_rows(
  x,
  rows,
  columns = NULL,
  level = c("robust", "fdr", "nominal"),
  colors = gt_sig_colors()
)

gt_signif_legend(
  x,
  colors = gt_sig_colors(),
  alpha = 0.05,
  robust = TRUE,
  fdr = TRUE
)
```

## Arguments

- x:

  A `gt_tbl`.

- p_cols:

  Numeric columns of unadjusted p-values.

- fdr_cols:

  Numeric columns of adjusted p-values.

- text_cols:

  Text columns containing `"p = ..."`.

- alpha:

  Significance level.

- colors:

  Named colours `nominal`, `fdr`, `robust` (see
  [`gt_sig_colors()`](https://clement-poupelin.github.io/vernissage/reference/gt_sig_colors.md)).

- legend:

  Add the colour legend.

- rows:

  Logical vector or indices of the rows to highlight.

- columns:

  Columns to colour (default: the first two).

- level:

  `"robust"`, `"fdr"` or `"nominal"`.

- robust, fdr:

  Show these entries in the legend.

## Value

A `gt_tbl`.

## Examples

``` r
cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0))
gt_pub(cm$long) |>
  gt_signif(p_cols = "p", fdr_cols = "p_adj") |>
  gt_highlight_rows(cm$long$p_adj < 0.01, columns = c("Var1", "Var2"))


  

Var1
```
