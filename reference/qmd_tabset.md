# Quarto output from a `results: asis` chunk

- `qmd_tabset()` prints a named list of objects (ggplot / patchwork, gt
  tables, kable tables, character vectors, data frames, nested lists) as
  a Quarto `panel-tabset`, one tab per element.

- `qmd_callout_raw()` prints the raw console output of one or several
  objects (`summary(fit)`, anova tables...) in a collapsed callout.

Both write Markdown with [`cat()`](https://rdrr.io/r/base/cat.html): use
them in a chunk with the option `#| results: asis`.

## Usage

``` r
qmd_tabset(items, level = 3)

qmd_callout_raw(..., title = "Raw model output", collapse = TRUE, width = 120)
```

## Arguments

- items:

  Named list of objects; the names become the tab titles.

- level:

  Heading level of the tab titles.

- ...:

  Named objects: each name becomes a sub-heading in the callout.

- title:

  Title of the callout.

- collapse:

  Collapse the callout.

- width:

  Console width used to print the objects.

## Value

`NULL`, invisibly (called for the printed Markdown).

## Examples

``` r
qmd_tabset(list(Summary = "Some text", Data = "More text"))
#> 
#> 
#> ::: panel-tabset
#> 
#> 
#> 
#> ### Summary 
#> 
#> Some text
#> 
#> 
#> 
#> 
#> ### Data 
#> 
#> More text
#> 
#> 
#> 
#> :::
#> 
qmd_callout_raw(`Linear model` = summary(lm(MOCA_V0 ~ AGE, data = cohort_sim)))
#> 
#> 
#> ::: {.callout-note collapse="true"}
#> ## Raw model output
#> 
#> **Linear model**
#> 
#> ```
#> 
#> Call:
#> lm(formula = MOCA_V0 ~ AGE, data = cohort_sim)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -5.3772 -1.2669  0.3106  1.4749  3.7590 
#> 
#> Coefficients:
#>             Estimate Std. Error t value Pr(>|t|)    
#> (Intercept) 33.78094    1.65615  20.397  < 2e-16 ***
#> AGE         -0.10329    0.02485  -4.156 6.15e-05 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 2.054 on 118 degrees of freedom
#> Multiple R-squared:  0.1277, Adjusted R-squared:  0.1203 
#> F-statistic: 17.28 on 1 and 118 DF,  p-value: 6.154e-05
#> 
#> ```
#> 
#> :::
#> 
```
