# Tables and Quarto reports

``` r

library(vernissage)
```

## Formatting numbers

``` r

fmt_p(c(0.21, 0.031, 0.00042, 1e-20))
#> [1] "0.21"       "0.031"      "4.2×10⁻⁴"   "<2.2×10⁻¹⁶"
fmt_num(c(1.2345, 0.00002, 2.5e7), digits = 2)
#> [1] "1.23"     "2.0×10⁻⁵" "2.5×10⁷"
fmt_stars(c(0.2, 0.07, 0.03, 0.004))
#> [1] "ns" "."  "*"  "**"
```

## Publication tables

[`gt_pub()`](https://clement-poupelin.github.io/vernissage/reference/gt_pub.md)
rounds numbers, detects and formats p-value columns, and puts p \< 0.05
in bold.
[`gt_signif()`](https://clement-poupelin.github.io/vernissage/reference/gt_signif.md)
adds shades of green for nominal and FDR-significant results.

``` r

cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0))
gt_pub(cm$long, title = "Spearman correlations", note = "Pairwise complete observations") |>
  gt_signif(p_cols = "p", fdr_cols = "p_adj")
```

| Spearman correlations |  |  |  |  |  |
|----|----|----|----|----|----|
| Var1 | Var2 | r | p | n | p_adj |
| NFL_V0 | IL6_V0 | 0.06 | 0.48 | 120 | 0.65 |
| NFL_V0 | CRP_V0 | -0.06 | 0.54 | 115 | 0.65 |
| IL6_V0 | CRP_V0 | 0.05 | 0.6 | 115 | 0.65 |
| NFL_V0 | MOCA_V0 | -0.55 | 7.0×10⁻¹¹ | 120 | 7.0×10⁻¹⁰ |
| IL6_V0 | MOCA_V0 | -0.05 | 0.6 | 120 | 0.65 |
| CRP_V0 | MOCA_V0 | -0.07 | 0.43 | 115 | 0.65 |
| NFL_V0 | UPDRS_V0 | 0.40 | 5.3×10⁻⁶ | 120 | 2.7×10⁻⁵ |
| IL6_V0 | UPDRS_V0 | 0.04 | 0.65 | 120 | 0.65 |
| CRP_V0 | UPDRS_V0 | -0.11 | 0.23 | 115 | 0.57 |
| MOCA_V0 | UPDRS_V0 | -0.20 | 0.027 | 120 | 0.088 |
| Pairwise complete observations |  |  |  |  |  |
| p \< 0.05significant after FDR (\< 0.05) |  |  |  |  |  |

[`dt_export()`](https://clement-poupelin.github.io/vernissage/reference/dt_export.md)
gives an interactive table (column filters, CSV and Excel export
buttons) in an HTML report. It is not run here: the documentation
website cannot load its JavaScript.

``` r

dt_export(na_summary(cohort_sim, list(All = names(cohort_sim))))
```

## Quarto tabsets and callouts

In a Quarto report, a chunk with `#| results: asis` can print a named
list of figures and tables as tabs, and raw console output in a
collapsed callout:

```` markdown
```{r}
#| results: asis
qmd_tabset(list(
  Distribution = plot_distribution(cohort_sim, NFL_V0, group = GROUP),
  Normality    = describe_normality(cohort_sim, c(NFL_V0, CRP_V0))
))
qmd_callout_raw(`Linear model` = summary(lm(MOCA_V0 ~ AGE, data = cohort_sim)))
```
````

The Markdown they write:

``` r

qmd_tabset(list(First = "Some text", Second = "Other text"))
#> 
#> 
#> ::: panel-tabset
#> 
#> 
#> 
#> ### First 
#> 
#> Some text
#> 
#> 
#> 
#> 
#> ### Second 
#> 
#> Other text
#> 
#> 
#> 
#> :::
```
