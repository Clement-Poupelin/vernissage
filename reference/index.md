# Package index

## Import and names

- [`read_cohort_csv()`](https://clement-poupelin.github.io/vernissage/reference/read_cohort_csv.md)
  : Read a "French" CSV file
- [`path_resolve_nfc()`](https://clement-poupelin.github.io/vernissage/reference/path_resolve_nfc.md)
  : Resolve a path whose accented characters are stored differently on
  disk
- [`clean_colnames()`](https://clement-poupelin.github.io/vernissage/reference/clean_colnames.md)
  : Clean column names
- [`rename_with_map()`](https://clement-poupelin.github.io/vernissage/reference/rename_with_map.md)
  : Rename columns with a named vector
- [`catalog_vars()`](https://clement-poupelin.github.io/vernissage/reference/catalog_vars.md)
  : Catalogue of the variables, by block

## Visits

- [`visit_add_deltas()`](https://clement-poupelin.github.io/vernissage/reference/visit_add_deltas.md)
  : Change between two visits

- [`visit_map_suffix()`](https://clement-poupelin.github.io/vernissage/reference/visit_map_suffix.md)
  :

  Map unusual visit suffixes to the `<ROOT>_<VISIT>` convention

- [`visit_root()`](https://clement-poupelin.github.io/vernissage/reference/visit_root.md)
  [`visit_swap()`](https://clement-poupelin.github.io/vernissage/reference/visit_root.md)
  : Visit suffixes of variable names

- [`visit_to_long()`](https://clement-poupelin.github.io/vernissage/reference/visit_to_long.md)
  :

  Wide `<ROOT>_<VISIT>` data to long format

- [`combine_bilateral()`](https://clement-poupelin.github.io/vernissage/reference/combine_bilateral.md)
  : Mean of the left and right sides of a bilateral measure

## Outliers

- [`outlier_detect()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md)
  [`outlier_mask()`](https://clement-poupelin.github.io/vernissage/reference/outlier_detect.md)
  : Table of outliers and masking
- [`outlier_flag_mad()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md)
  [`outlier_flag_iqr()`](https://clement-poupelin.github.io/vernissage/reference/outlier_flag_mad.md)
  : Robust outlier rules

## Transformations

- [`transform_boxcox()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md)
  [`transform_boxcox_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md)
  [`transform_apply_resid()`](https://clement-poupelin.github.io/vernissage/reference/transform_boxcox.md)
  : Box-Cox decision with car's documented rule
- [`transform_compare()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)
  [`transform_choose()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)
  [`transform_propagate()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)
  [`transform_apply()`](https://clement-poupelin.github.io/vernissage/reference/transform_compare.md)
  : Compare, choose and apply transformations

## Description

- [`describe_cohort()`](https://clement-poupelin.github.io/vernissage/reference/describe_cohort.md)
  : Overview table of a cohort
- [`describe_normality()`](https://clement-poupelin.github.io/vernissage/reference/describe_normality.md)
  : Normality of each variable
- [`na_summary()`](https://clement-poupelin.github.io/vernissage/reference/na_summary.md)
  [`na_complete_cases()`](https://clement-poupelin.github.io/vernissage/reference/na_summary.md)
  : Missing values per variable and complete cases per variable set
- [`cor_partial_spearman()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md)
  [`cor_matrix_test()`](https://clement-poupelin.github.io/vernissage/reference/cor_partial_spearman.md)
  : Correlations
- [`pca_compute()`](https://clement-poupelin.github.io/vernissage/reference/pca_compute.md)
  [`pca_scores_join()`](https://clement-poupelin.github.io/vernissage/reference/pca_compute.md)
  : Principal component analysis
- [`score_composite()`](https://clement-poupelin.github.io/vernissage/reference/score_composite.md)
  : Composite score per domain

## Figures

- [`plot_cor_heatmap()`](https://clement-poupelin.github.io/vernissage/reference/plot_cor_heatmap.md)
  [`plot_cor_cross()`](https://clement-poupelin.github.io/vernissage/reference/plot_cor_heatmap.md)
  : Correlation heatmaps
- [`plot_delta_vs_baseline()`](https://clement-poupelin.github.io/vernissage/reference/plot_delta_vs_baseline.md)
  : Change versus baseline value
- [`plot_distribution()`](https://clement-poupelin.github.io/vernissage/reference/plot_distribution.md)
  : Distribution of one or several variables
- [`plot_distribution_overview()`](https://clement-poupelin.github.io/vernissage/reference/plot_distribution_overview.md)
  : Overlaid standardised densities of a block of variables
- [`plot_forest()`](https://clement-poupelin.github.io/vernissage/reference/plot_forest.md)
  : Annotated forest plot
- [`plot_na_map()`](https://clement-poupelin.github.io/vernissage/reference/plot_na_map.md)
  : Missing-data map
- [`plot_paired_visits()`](https://clement-poupelin.github.io/vernissage/reference/plot_paired_visits.md)
  : Paired visits: one line per subject between two visits
- [`plot_pca_scree()`](https://clement-poupelin.github.io/vernissage/reference/plot_pca_scree.md)
  [`plot_pca_ind()`](https://clement-poupelin.github.io/vernissage/reference/plot_pca_scree.md)
  [`plot_pca_var()`](https://clement-poupelin.github.io/vernissage/reference/plot_pca_scree.md)
  [`plot_pca_contrib()`](https://clement-poupelin.github.io/vernissage/reference/plot_pca_scree.md)
  [`plot_pca_distribution()`](https://clement-poupelin.github.io/vernissage/reference/plot_pca_scree.md)
  : Figures of a principal component analysis
- [`plot_radar()`](https://clement-poupelin.github.io/vernissage/reference/plot_radar.md)
  : Radar plot comparing groups on several variables
- [`plot_trajectories()`](https://clement-poupelin.github.io/vernissage/reference/plot_trajectories.md)
  [`plot_trajectory_grid()`](https://clement-poupelin.github.io/vernissage/reference/plot_trajectories.md)
  : Individual trajectories across visits (spaghetti plot)
- [`theme_pub()`](https://clement-poupelin.github.io/vernissage/reference/theme_pub.md)
  : Publication theme for ggplot2
- [`theme_rotate_x()`](https://clement-poupelin.github.io/vernissage/reference/theme_rotate_x.md)
  : Rotated x-axis labels that stay attached to their tick
- [`pal_okabe_ito()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md)
  [`pal_levels()`](https://clement-poupelin.github.io/vernissage/reference/pal_okabe_ito.md)
  : Colour palettes

## Formatting and labels

- [`fmt_sci()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)
  [`fmt_num()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)
  [`fmt_p()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)
  [`fmt_stars()`](https://clement-poupelin.github.io/vernissage/reference/fmt_sci.md)
  : Format numbers and p-values for figures and tables
- [`label_get()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md)
  [`label_expand()`](https://clement-poupelin.github.io/vernissage/reference/label_get.md)
  : Readable labels of variables

## Tables and Quarto

- [`gt_pub()`](https://clement-poupelin.github.io/vernissage/reference/gt_pub.md)
  : Publication table with gt

- [`gt_sig_colors()`](https://clement-poupelin.github.io/vernissage/reference/gt_sig_colors.md)
  : Colours of significance highlighting

- [`gt_signif()`](https://clement-poupelin.github.io/vernissage/reference/gt_signif.md)
  [`gt_highlight_rows()`](https://clement-poupelin.github.io/vernissage/reference/gt_signif.md)
  [`gt_signif_legend()`](https://clement-poupelin.github.io/vernissage/reference/gt_signif.md)
  : Highlight significant results in gt tables

- [`dt_export()`](https://clement-poupelin.github.io/vernissage/reference/dt_export.md)
  : Interactive table with export buttons

- [`qmd_tabset()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md)
  [`qmd_callout_raw()`](https://clement-poupelin.github.io/vernissage/reference/qmd_tabset.md)
  :

  Quarto output from a `results: asis` chunk

## Data

- [`cohort_sim`](https://clement-poupelin.github.io/vernissage/reference/cohort_sim.md)
  : Simulated clinical cohort with two visits
