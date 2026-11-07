# vernissage 0.1.0

First version, gathering the preprocessing and visualisation helpers of the
analysis scripts (`00_common.R`, `01_preprocessing.R`, `02_distribution.R`,
`03_descriptive.R`, `04_longitudinal.R`, `07_transform_outliers.R` and
`09_radar_plot.R`). The limit-of-detection and cut-off functions are in the
companion package lodestar; the modelling functions are kept for a separate
package; the clustering functions are not included.

## New features

* `describe_cohort()`: overview table of a cohort (type, N, missing values,
  summaries overall and by group, group test, text histogram), replacing
  `table1()`, which depended on functions absent from the scripts
  (`bilille_gt_theme()`, `.is_typst()`).
* Column arguments accept character vectors, bare names and tidyselect
  helpers.
* New helpers from repeated code: `visit_root()`, `visit_swap()`,
  `gt_sig_colors()` (replaces the constant `GT_SIG_COLORS`), `pal_okabe_ito()`
  (replaces the object `okabe_ito`).
* `pal_levels()` also accepts a palette name (`"okabe"`, `hcl.pals()`,
  `palette.pals()`, RColorBrewer) or a function.
* `outlier_flag_mad()` and `outlier_flag_iqr()` are exported;
  `outlier_flag_iqr(method = "hinges")` reproduces the former
  `outliers_table()` (Tukey's hinges of `boxplot.stats()`).

## Renamed functions

| Former name | New name |
|---|---|
| `make_palette()` | `pal_levels()` |
| `get_label()`, `expand_labels()` | `label_get()`, `label_expand()` |
| `p_to_stars()` | `fmt_stars()` |
| `rotate_x()` | `theme_rotate_x()` |
| `forest_plot()` | `plot_forest()` |
| `export_table()` | `dt_export()` |
| `render_tabset()`, `raw_output_callout()` | `qmd_tabset()`, `qmd_callout_raw()` |
| `resolve_path()` | `path_resolve_nfc()` |
| `var_catalog()` | `catalog_vars()` |
| `visit_suffix_map()`, `to_long()`, `add_deltas()` | `visit_map_suffix()`, `visit_to_long()`, `visit_add_deltas()` |
| `.flag_mad()`, `.flag_iqr()`, `detect_outliers()`, `outliers_table()`, `mask_outliers()` | `outlier_flag_mad()`, `outlier_flag_iqr()`, `outlier_detect()`, `outlier_mask()` |
| `choose_transformation()`, `propagate_choice()`, `apply_transformation()` | `transform_choose()`, `transform_propagate()`, `transform_apply()` |
| `transform_boxcox_car()`, `transform_outcomes_car()`, `apply_outcome_transformation()` | `transform_boxcox()`, `transform_boxcox_resid()`, `transform_apply_resid()` |
| `na_map()`, `ggNA()`, `complete_case_count()` | `plot_na_map()`, `na_complete_cases()` |
| `composite_scores()` | `score_composite()` |
| `normality_table()` | `describe_normality()` |
| `partial_rank_cor()`, `cor_test_matrix()` | `cor_partial_spearman()`, `cor_matrix_test()` |
| `paired_visits_plot()`, `radar_plot()` | `plot_paired_visits()`, `plot_radar()` |

The former names still work (soft deprecation, see `?vernissage-deprecated`).

## Bug fixes and behaviour changes

* `transform_choose()` (former `choose_transformation()`): failed when none
  of the preferred methods had been computed (e.g. log impossible with values
  <= 0); the best W is then used. A variable without any Shapiro W keeps its
  first method with an explicit reason instead of disappearing.
* `plot_radar()`: its local `fmt_p()` and `%||%` masked the package ones; the
  label format (`p=0.012`) is kept in a private helper. Colours come from
  `pal_levels()`: with more groups than colours, the palette is now
  interpolated instead of recycled. With `seed`, the random state of the
  session is restored after the call.
* `plot_distribution()`: the identifier of the `metadata` join no longer
  defaults to the cohort-specific `"SampleName"`: `id_col` is required with
  `metadata`.
* `visit_map_suffix()`: `select` is now required (former default `"^MRI_"`,
  kept by the deprecated `visit_suffix_map()`).
* `label_expand()`: the format of categorised variables is an argument
  (`bin_format`, `bin_format_root`) instead of the global options
  `fairpark.bin_label` / `fairpark.bin_label_root` (still read by the
  deprecated `expand_labels()`).
* The seed of jitters and subsamples is an argument (`seed = 1`) instead of
  the global option `analysis.seed`.
* `read_cohort_csv()` and `path_resolve_nfc()`: their documentation was
  merged in the scripts; each function now has its own.
* Skewness and kurtosis are computed internally (same moment estimators as
  `e1071::skewness(type = 1)` / `kurtosis(type = 1)`), which removes the
  dependency on e1071.
* Every non-ASCII character of the code is written with `\u` escapes, as
  required by `R CMD check`.
