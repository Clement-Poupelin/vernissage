# Publication theme for ggplot2

A complete theme (`complete = TRUE`): the rendering is identical
whatever the global theme of the session. White panels with a light
border, light major grid, bold left-aligned title, grey subtitle and
caption.

## Usage

``` r
theme_pub(base_size = 11, legend_position = "right")
```

## Arguments

- base_size:

  Base font size, in points.

- legend_position:

  Position of the legend (`"right"`, `"bottom"`, `"top"`, `"left"` or
  `"none"`).

## Value

A
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
object.

## Examples

``` r
library(ggplot2)
ggplot(cohort_sim, aes(AGE, NFL_V0)) +
  geom_point() +
  labs(title = "NfL by age") +
  theme_pub()
```
