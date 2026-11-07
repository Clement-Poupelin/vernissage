# Change versus baseline value

Shows regression to the mean and floor / ceiling effects: change between
two visits against the first-visit value, LOESS smooth with its 95% band
and the Spearman correlation between baseline and change.

## Usage

``` r
plot_delta_vs_baseline(
  data,
  roots,
  from = "V0",
  to = "V3",
  labels = NULL,
  group = NULL,
  palette = NULL,
  ncol = 3,
  base_size = 10
)
```

## Arguments

- data:

  Wide format.

- roots:

  Root names (one panel each).

- from, to:

  Visit suffixes.

- labels:

  Optional named vector of labels.

- group:

  Optional colour variable.

- palette:

  Colours of the groups.

- ncol:

  Number of columns of panels.

- base_size:

  Base font size.

## Value

A patchwork, or `NULL` when no root has at least 10 complete pairs.

## Examples

``` r
plot_delta_vs_baseline(cohort_sim, c("NFL", "MOCA"), group = GROUP)
```
