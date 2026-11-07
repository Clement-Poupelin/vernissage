# Changelog

## vernissage 0.1.0

First version, gathering the preprocessing and visualisation helpers of
the analysis scripts (`00_common.R`, `01_preprocessing.R`,
`02_distribution.R`, `03_descriptive.R`, `04_longitudinal.R`,
`07_transform_outliers.R` and `09_radar_plot.R`). The limit-of-detection
and cut-off functions are in the companion package lodestar; the
modelling functions are kept for a separate package; the clustering
functions are not included.

### New features

- [`describe_cohort()`](https://clement-poupelin.github.io/vernissage/reference/describe_cohort.md):
  overview table of a cohort (type, N, missing values, summaries overall
  and by group, group test, text histogram), replacing `table1()`, which
  depended on functions absent from the scripts (`bilille_gt_theme()`,
  `.is_typst()`).
- Column arguments accept character vectors, bare names and tidyselect
  helpers.
- New helpers from repeated code:
  [`visit_root()`](https://clement-poupelin.github.io/vernissage/reference/visit_root.md),
  [`visit_swap()`](https://clement-poupelin.github.io/vernissage/reference/visit_root.md),
  [`gt_sig_colors()`](https://clement-poupelin.github.io/vernissage/reference/gt_sig_colors.md)
  (replaces the constant `GT_SIG_COLORS`),
  [`pal_okabe_ito()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md)
  (replaces the object `okabe_ito`).
- [`pal_levels()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md)
  also accepts a palette name (`"okabe"`,
  [`hcl.pals()`](https://rdrr.io/r/grDevices/palettes.html),
  [`palette.pals()`](https://rdrr.io/r/grDevices/palette.html),
  RColorBrewer) or a function.
- [`outlier_flag_mad()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md)
  and
  [`outlier_flag_iqr()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md)
  are exported; `outlier_flag_iqr(method = "hinges")` reproduces the
  former
  [`outliers_table()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md)
  (Tukey’s hinges of
  [`boxplot.stats()`](https://rdrr.io/r/grDevices/boxplot.stats.html)).

### Renamed functions

| Former name | New name |
|----|----|
| [`make_palette()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`pal_levels()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md) |
| [`get_label()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`expand_labels()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`label_get()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md), [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md) |
| [`p_to_stars()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`fmt_stars()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md) |
| [`rotate_x()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`theme_rotate_x()`](https://clement-poupelin.github.io/vernissage/reference/theme_rotate_x.md) |
| [`forest_plot()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`plot_forest()`](https://clement-poupelin.github.io/vernissage/reference/plot_forest.md) |
| [`export_table()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`dt_export()`](https://clement-poupelin.github.io/vernissage/reference/dt_export.md) |
| [`render_tabset()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`raw_output_callout()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`qmd_tabset()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md), [`qmd_callout_raw()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md) |
| [`resolve_path()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md) |
| [`var_catalog()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`catalog_vars()`](https://clement-poupelin.github.io/vernissage/reference/catalog_vars.md) |
| [`visit_suffix_map()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`to_long()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`add_deltas()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`visit_map_suffix()`](https://clement-poupelin.github.io/vernissage/reference/visit_map_suffix.md), [`visit_to_long()`](https://clement-poupelin.github.io/vernissage/reference/visit_to_long.md), [`visit_add_deltas()`](https://clement-poupelin.github.io/vernissage/reference/visit_add_deltas.md) |
| `.flag_mad()`, `.flag_iqr()`, [`detect_outliers()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`outliers_table()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`mask_outliers()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`outlier_flag_mad()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md), [`outlier_flag_iqr()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md), [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md), [`outlier_mask()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md) |
| [`choose_transformation()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`propagate_choice()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`apply_transformation()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`transform_choose()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md), [`transform_propagate()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md), [`transform_apply()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md) |
| [`transform_boxcox_car()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`transform_outcomes_car()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`apply_outcome_transformation()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`transform_boxcox()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md), [`transform_boxcox_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md), [`transform_apply_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md) |
| [`na_map()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`ggNA()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`complete_case_count()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md), [`na_complete_cases()`](https://clement-poupelin.github.io/vernissage/reference/na_summary.md) |
| [`composite_scores()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`score_composite()`](https://clement-poupelin.github.io/vernissage/reference/score_composite.md) |
| [`normality_table()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`describe_normality()`](https://clement-poupelin.github.io/vernissage/reference/describe_normality.md) |
| [`partial_rank_cor()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`cor_test_matrix()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`cor_partial_spearman()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md), [`cor_matrix_test()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md) |
| [`paired_visits_plot()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md), [`radar_plot()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md) | [`plot_paired_visits()`](https://clement-poupelin.github.io/vernissage/reference/plot_paired_visits.md), [`plot_radar()`](https://clement-poupelin.github.io/vernissage/reference/plot_radar.md) |

The former names still work (soft deprecation, see
`?vernissage-deprecated`).

### Bug fixes and behaviour changes

- [`transform_choose()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)
  (former
  [`choose_transformation()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md)):
  failed when none of the preferred methods had been computed (e.g. log
  impossible with values \<= 0); the best W is then used. A variable
  without any Shapiro W keeps its first method with an explicit reason
  instead of disappearing.
- [`plot_radar()`](https://clement-poupelin.github.io/vernissage/reference/plot_radar.md):
  its local
  [`fmt_p()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)
  and `%||%` masked the package ones; the label format (`p=0.012`) is
  kept in a private helper. Colours come from
  [`pal_levels()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md):
  with more groups than colours, the palette is now interpolated instead
  of recycled. With `seed`, the random state of the session is restored
  after the call.
- [`plot_distribution()`](https://clement-poupelin.github.io/vernissage/reference/plot_distribution.md):
  the identifier of the `metadata` join no longer defaults to the
  cohort-specific `"SampleName"`: `id_col` is required with `metadata`.
- [`visit_map_suffix()`](https://clement-poupelin.github.io/vernissage/reference/visit_map_suffix.md):
  `select` is now required (former default `"^MRI_"`, kept by the
  deprecated
  [`visit_suffix_map()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md)).
- [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md):
  the format of categorised variables is an argument (`bin_format`,
  `bin_format_root`) instead of the global options `fairpark.bin_label`
  / `fairpark.bin_label_root` (still read by the deprecated
  [`expand_labels()`](https://clement-poupelin.github.io/vernissage/reference/vernissage-deprecated.md)).
- The seed of jitters and subsamples is an argument (`seed = 1`) instead
  of the global option `analysis.seed`.
- [`read_cohort_csv()`](https://clement-poupelin.github.io/vernissage/reference/read_cohort_csv.md)
  and
  [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md):
  their documentation was merged in the scripts; each function now has
  its own.
- Skewness and kurtosis are computed internally (same moment estimators
  as `e1071::skewness(type = 1)` / `kurtosis(type = 1)`), which removes
  the dependency on e1071.
- Every non-ASCII character of the code is written with `\u` escapes, as
  required by `R CMD check`.
