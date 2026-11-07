# Deprecated functions

Former names of the functions, from the analysis scripts the package
comes from. They forward their arguments to the new function. The
limit-of-detection and cut-off functions (`make_cuts()`, `handle_lod()`,
`bin_transition_table()`...) moved to the lodestar package.

## Usage

``` r
make_palette(...)

get_label(...)

p_to_stars(...)

rotate_x(...)

forest_plot(...)

export_table(...)

render_tabset(...)

raw_output_callout(...)

resolve_path(...)

var_catalog(...)

to_long(...)

add_deltas(...)

detect_outliers(...)

mask_outliers(...)

choose_transformation(...)

propagate_choice(...)

apply_transformation(...)

transform_boxcox_car(...)

transform_outcomes_car(...)

apply_outcome_transformation(...)

na_map(...)

complete_case_count(...)

composite_scores(...)

normality_table(...)

partial_rank_cor(...)

cor_test_matrix(...)

paired_visits_plot(...)

radar_plot(...)

expand_labels(vars, base_labels, visit_map = c(V0 = "V0", V3 = "V3"), ...)

visit_suffix_map(
  cols,
  select = "^MRI_",
  suffix_map = c(`36` = "V3", `0` = "V0")
)

outliers_table(
  df,
  vars,
  id_col,
  mad_threshold = 3.5,
  iqr_coef = 1.5,
  rule = c("mad", "iqr", "both", "any")
)

ggNA(
  data,
  Title = "Heatmap of missing values (NA)",
  colorNA = "#FDE725",
  colorPres = "#440154",
  show_na_stats = TRUE,
  ...
)
```

## Arguments

- ...:

  Arguments passed to the new function.

- vars, base_labels, visit_map:

  See
  [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md)
  (`vars` is also the variable selection of
  [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md)).

- cols, select, suffix_map:

  See
  [`visit_map_suffix()`](https://clement-poupelin.github.io/vernissage/reference/visit_map_suffix.md).

- df, id_col:

  See
  [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md).

- mad_threshold, iqr_coef, rule:

  See
  [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md)
  (`mad_z_threshold`, `iqr_k`, `rule`).

- data:

  See
  [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md).

- Title, colorNA, colorPres, show_na_stats:

  Former arguments of `ggNA()`: title, colours of the missing and
  observed cells, labels with the count of missing values.

## Value

The value of the new function.

## Details

|  |  |
|----|----|
| Former name | New name |
| `make_palette()` | [`pal_levels()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md) |
| `get_label()` | [`label_get()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md) |
| `p_to_stars()` | [`fmt_stars()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md) |
| `rotate_x()` | [`theme_rotate_x()`](https://clement-poupelin.github.io/vernissage/reference/theme_rotate_x.md) |
| `forest_plot()` | [`plot_forest()`](https://clement-poupelin.github.io/vernissage/reference/plot_forest.md) |
| `export_table()` | [`dt_export()`](https://clement-poupelin.github.io/vernissage/reference/dt_export.md) |
| `render_tabset()` | [`qmd_tabset()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md) |
| `raw_output_callout()` | [`qmd_callout_raw()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md) |
| `resolve_path()` | [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md) |
| `var_catalog()` | [`catalog_vars()`](https://clement-poupelin.github.io/vernissage/reference/catalog_vars.md) |
| `to_long()` | [`visit_to_long()`](https://clement-poupelin.github.io/vernissage/reference/visit_to_long.md) |
| `add_deltas()` | [`visit_add_deltas()`](https://clement-poupelin.github.io/vernissage/reference/visit_add_deltas.md) |
| `detect_outliers()` | [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md) |
| `mask_outliers()` | [`outlier_mask()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md) |
| `choose_transformation()` | [`transform_choose()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md) |
| `propagate_choice()` | [`transform_propagate()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md) |
| `apply_transformation()` | [`transform_apply()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md) |
| `transform_boxcox_car()` | [`transform_boxcox()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md) |
| `transform_outcomes_car()` | [`transform_boxcox_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md) |
| `apply_outcome_transformation()` | [`transform_apply_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md) |
| `na_map()` | [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md) |
| `complete_case_count()` | [`na_complete_cases()`](https://clement-poupelin.github.io/vernissage/reference/na_summary.md) |
| `composite_scores()` | [`score_composite()`](https://clement-poupelin.github.io/vernissage/reference/score_composite.md) |
| `normality_table()` | [`describe_normality()`](https://clement-poupelin.github.io/vernissage/reference/describe_normality.md) |
| `partial_rank_cor()` | [`cor_partial_spearman()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md) |
| `cor_test_matrix()` | [`cor_matrix_test()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md) |
| `paired_visits_plot()` | [`plot_paired_visits()`](https://clement-poupelin.github.io/vernissage/reference/plot_paired_visits.md) |
| `radar_plot()` | [`plot_radar()`](https://clement-poupelin.github.io/vernissage/reference/plot_radar.md) |
| `expand_labels()` | [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md) |
| `visit_suffix_map()` | [`visit_map_suffix()`](https://clement-poupelin.github.io/vernissage/reference/visit_map_suffix.md) |
| `outliers_table()` | [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md) |
| `ggNA()` | [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md) |

Differences:

- `expand_labels()` reads the former options `fairpark.bin_label` and
  `fairpark.bin_label_root`;
  [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md)
  takes them as arguments;

- `visit_suffix_map()` keeps the former default `select = "^MRI_"`;

- `outliers_table()` keeps its argument names (`mad_threshold`,
  `iqr_coef`) and Tukey's hinges (`iqr_method = "hinges"`);

- `ggNA()` keeps its argument names (`Title`, `colorNA`, `colorPres`,
  `show_na_stats`).
