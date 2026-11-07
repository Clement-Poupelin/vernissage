# Rotated x-axis labels that stay attached to their tick

`hjust = 1` and `vjust = 1` anchor the end of the text on the tick; the
default `vjust = 0.5` pushes long labels below the plot, where they get
cut.

## Usage

``` r
theme_rotate_x(angle = 45, size = NULL)
```

## Arguments

- angle:

  Angle of the labels, in degrees.

- size:

  Font size of the labels (`NULL`: unchanged).

## Value

A
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
object to add to a plot.

## Examples

``` r
library(ggplot2)
ggplot(cohort_sim, aes(GROUP, AGE)) + geom_boxplot() + theme_pub() + theme_rotate_x(45)
```
