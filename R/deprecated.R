# Deprecated names ---------------------------------------------------------------------
#
# Former names of the analysis scripts, kept so that existing reports keep running.
# Each one forwards its arguments to the new function and warns once per session
# (lifecycle::deprecate_soft(): the warning is shown when called from the global
# environment or a package other than vernissage).

#' Deprecated functions
#'
#' Former names of the functions, from the analysis scripts the package comes
#' from. They forward their arguments to the new function. The limit-of-detection
#' and cut-off functions (`make_cuts()`, `handle_lod()`, `bin_transition_table()`...)
#' moved to the lodestar package.
#'
#' | Former name | New name |
#' |---|---|
#' | `make_palette()` | [pal_levels()] |
#' | `get_label()` | [label_get()] |
#' | `p_to_stars()` | [fmt_stars()] |
#' | `rotate_x()` | [theme_rotate_x()] |
#' | `forest_plot()` | [plot_forest()] |
#' | `export_table()` | [dt_export()] |
#' | `render_tabset()` | [qmd_tabset()] |
#' | `raw_output_callout()` | [qmd_callout_raw()] |
#' | `resolve_path()` | [path_resolve_nfc()] |
#' | `var_catalog()` | [catalog_vars()] |
#' | `to_long()` | [visit_to_long()] |
#' | `add_deltas()` | [visit_add_deltas()] |
#' | `detect_outliers()` | [outlier_detect()] |
#' | `mask_outliers()` | [outlier_mask()] |
#' | `choose_transformation()` | [transform_choose()] |
#' | `propagate_choice()` | [transform_propagate()] |
#' | `apply_transformation()` | [transform_apply()] |
#' | `transform_boxcox_car()` | [transform_boxcox()] |
#' | `transform_outcomes_car()` | [transform_boxcox_resid()] |
#' | `apply_outcome_transformation()` | [transform_apply_resid()] |
#' | `na_map()` | [plot_na_map()] |
#' | `complete_case_count()` | [na_complete_cases()] |
#' | `composite_scores()` | [score_composite()] |
#' | `normality_table()` | [describe_normality()] |
#' | `partial_rank_cor()` | [cor_partial_spearman()] |
#' | `cor_test_matrix()` | [cor_matrix_test()] |
#' | `paired_visits_plot()` | [plot_paired_visits()] |
#' | `radar_plot()` | [plot_radar()] |
#' | `expand_labels()` | [label_expand()] |
#' | `visit_suffix_map()` | [visit_map_suffix()] |
#' | `outliers_table()` | [outlier_detect()] |
#' | `ggNA()` | [plot_na_map()] |
#'
#' Differences:
#' * `expand_labels()` reads the former options `fairpark.bin_label` and
#'   `fairpark.bin_label_root`; `label_expand()` takes them as arguments;
#' * `visit_suffix_map()` keeps the former default `select = "^MRI_"`;
#' * `outliers_table()` keeps its argument names (`mad_threshold`,
#'   `iqr_coef`) and Tukey's hinges (`iqr_method = "hinges"`);
#' * `ggNA()` keeps its argument names (`Title`, `colorNA`, `colorPres`,
#'   `show_na_stats`).
#'
#' @param ... Arguments passed to the new function.
#' @param vars,base_labels,visit_map See [label_expand()] (`vars` is also the variable selection of [outlier_detect()]).
#' @param cols,select,suffix_map See [visit_map_suffix()].
#' @param df,id_col See [outlier_detect()].
#' @param mad_threshold,iqr_coef,rule See [outlier_detect()]
#'   (`mad_z_threshold`, `iqr_k`, `rule`).
#' @param data See [plot_na_map()].
#' @param Title,colorNA,colorPres,show_na_stats Former arguments of `ggNA()`:
#'   title, colours of the missing and observed cells, labels with the count
#'   of missing values.
#' @return The value of the new function.
#' @keywords internal
#' @name vernissage-deprecated
NULL

#' @rdname vernissage-deprecated
#' @export
make_palette <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "make_palette()", "pal_levels()")
  pal_levels(...)
}

#' @rdname vernissage-deprecated
#' @export
get_label <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "get_label()", "label_get()")
  label_get(...)
}

#' @rdname vernissage-deprecated
#' @export
p_to_stars <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "p_to_stars()", "fmt_stars()")
  fmt_stars(...)
}

#' @rdname vernissage-deprecated
#' @export
rotate_x <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "rotate_x()", "theme_rotate_x()")
  theme_rotate_x(...)
}

#' @rdname vernissage-deprecated
#' @export
forest_plot <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "forest_plot()", "plot_forest()")
  plot_forest(...)
}

#' @rdname vernissage-deprecated
#' @export
export_table <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "export_table()", "dt_export()")
  dt_export(...)
}

#' @rdname vernissage-deprecated
#' @export
render_tabset <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "render_tabset()", "qmd_tabset()")
  qmd_tabset(...)
}

#' @rdname vernissage-deprecated
#' @export
raw_output_callout <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "raw_output_callout()", "qmd_callout_raw()")
  qmd_callout_raw(...)
}

#' @rdname vernissage-deprecated
#' @export
resolve_path <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "resolve_path()", "path_resolve_nfc()")
  path_resolve_nfc(...)
}

#' @rdname vernissage-deprecated
#' @export
var_catalog <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "var_catalog()", "catalog_vars()")
  catalog_vars(...)
}

#' @rdname vernissage-deprecated
#' @export
to_long <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "to_long()", "visit_to_long()")
  visit_to_long(...)
}

#' @rdname vernissage-deprecated
#' @export
add_deltas <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "add_deltas()", "visit_add_deltas()")
  visit_add_deltas(...)
}

#' @rdname vernissage-deprecated
#' @export
detect_outliers <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "detect_outliers()", "outlier_detect()")
  outlier_detect(...)
}

#' @rdname vernissage-deprecated
#' @export
mask_outliers <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "mask_outliers()", "outlier_mask()")
  outlier_mask(...)
}

#' @rdname vernissage-deprecated
#' @export
choose_transformation <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "choose_transformation()", "transform_choose()")
  transform_choose(...)
}

#' @rdname vernissage-deprecated
#' @export
propagate_choice <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "propagate_choice()", "transform_propagate()")
  transform_propagate(...)
}

#' @rdname vernissage-deprecated
#' @export
apply_transformation <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "apply_transformation()", "transform_apply()")
  transform_apply(...)
}

#' @rdname vernissage-deprecated
#' @export
transform_boxcox_car <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "transform_boxcox_car()", "transform_boxcox()")
  transform_boxcox(...)
}

#' @rdname vernissage-deprecated
#' @export
transform_outcomes_car <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "transform_outcomes_car()", "transform_boxcox_resid()")
  transform_boxcox_resid(...)
}

#' @rdname vernissage-deprecated
#' @export
apply_outcome_transformation <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "apply_outcome_transformation()", "transform_apply_resid()")
  transform_apply_resid(...)
}

#' @rdname vernissage-deprecated
#' @export
na_map <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "na_map()", "plot_na_map()")
  plot_na_map(...)
}

#' @rdname vernissage-deprecated
#' @export
complete_case_count <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "complete_case_count()", "na_complete_cases()")
  na_complete_cases(...)
}

#' @rdname vernissage-deprecated
#' @export
composite_scores <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "composite_scores()", "score_composite()")
  score_composite(...)
}

#' @rdname vernissage-deprecated
#' @export
normality_table <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "normality_table()", "describe_normality()")
  describe_normality(...)
}

#' @rdname vernissage-deprecated
#' @export
partial_rank_cor <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "partial_rank_cor()", "cor_partial_spearman()")
  cor_partial_spearman(...)
}

#' @rdname vernissage-deprecated
#' @export
cor_test_matrix <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "cor_test_matrix()", "cor_matrix_test()")
  cor_matrix_test(...)
}

#' @rdname vernissage-deprecated
#' @export
paired_visits_plot <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "paired_visits_plot()", "plot_paired_visits()")
  plot_paired_visits(...)
}

#' @rdname vernissage-deprecated
#' @export
radar_plot <- function(...) {
  lifecycle::deprecate_soft("0.1.0", "radar_plot()", "plot_radar()")
  plot_radar(...)
}

#' @rdname vernissage-deprecated
#' @export
expand_labels <- function(vars, base_labels, visit_map = c(V0 = "V0", V3 = "V3"), ...) {
  lifecycle::deprecate_soft("0.1.0", "expand_labels()", "label_expand()")
  label_expand(vars, base_labels, visit_map = visit_map,
               bin_format = getOption("fairpark.bin_label", "%s (high)"),
               bin_format_root = getOption("fairpark.bin_label_root"), ...)
}

#' @rdname vernissage-deprecated
#' @export
visit_suffix_map <- function(cols, select = "^MRI_", suffix_map = c("36" = "V3", "0" = "V0")) {
  lifecycle::deprecate_soft("0.1.0", "visit_suffix_map()", "visit_map_suffix()")
  visit_map_suffix(cols, select = select, suffix_map = suffix_map)
}

#' @rdname vernissage-deprecated
#' @export
outliers_table <- function(df, vars, id_col, mad_threshold = 3.5, iqr_coef = 1.5,
                           rule = c("mad", "iqr", "both", "any")) {
  lifecycle::deprecate_soft("0.1.0", "outliers_table()", "outlier_detect()")
  outlier_detect(df, {{ vars }}, id_col = {{ id_col }}, rule = rule, mad_z_threshold = mad_threshold,
                 iqr_k = iqr_coef, iqr_method = "hinges")
}

#' @rdname vernissage-deprecated
#' @export
ggNA <- function(data, Title = "Heatmap of missing values (NA)", colorNA = "#FDE725", colorPres = "#440154",
                 show_na_stats = TRUE, ...) {
  lifecycle::deprecate_soft("0.1.0", "ggNA()", "plot_na_map()")
  plot_na_map(data, title = Title, palette = c(Missing = colorNA, Observed = colorPres),
              show_pct = show_na_stats, ...)
}
