# Visits: names, reshaping, changes ----------------------------------------------

#' Visit suffixes of variable names
#'
#' Names follow the `<ROOT>_<VISIT>` convention. `visit_root()` removes the
#' visit suffix; `visit_swap()` replaces one visit suffix by another
#' (`NFL_V0` -> `NFL_V3`).
#'
#' @param x Character vector of variable names.
#' @param visits Visit suffixes to remove.
#' @param from,to Visit suffixes (without the underscore).
#' @return A character vector of the same length as `x`.
#' @export
#' @examples
#' visit_root(c("NFL_V0", "MDS_TOT_V3", "AGE"))
#' visit_swap(c("NFL_V0", "IL6_V0"), "V0", "V3")
visit_root <- function(x, visits = c("V0", "V3")) {
  sub(paste0("_(", paste(visits, collapse = "|"), ")$"), "", as.character(x))
}

#' @rdname visit_root
#' @export
visit_swap <- function(x, from = "V0", to = "V3") {
  sub(paste0("_", from, "$"), paste0("_", to), as.character(x))
}

#' Map unusual visit suffixes to the `<ROOT>_<VISIT>` convention
#'
#' E.g. `MRI_GPI_L0` / `MRI_GPI_L36` -> `MRI_GPI_L_V0` / `MRI_GPI_L_V3`.
#' The longest suffixes are tried first (`"36"` before `"6"` or `"0"`).
#'
#' @param cols Column names.
#' @param select Regular expression selecting the columns to rename (e.g.
#'   `"^MRI_"`). Required: renaming every column ending with a digit would
#'   break names such as `AGE_V0`.
#' @param suffix_map Named vector `old suffix -> visit`.
#' @return Named character vector `c(OLD = "NEW")` for [rename_with_map()].
#' @export
#' @examples
#' visit_map_suffix(c("MRI_GPI_L0", "MRI_GPI_L36", "AGE"), select = "^MRI_")
visit_map_suffix <- function(cols, select, suffix_map = c("36" = "V3", "0" = "V0")) {
  if (missing(select)) cli::cli_abort("{.arg select} is required (e.g. {.code select = \"^MRI_\"}).")
  cols <- grep(select, cols, value = TRUE)
  sfx <- suffix_map[order(-nchar(names(suffix_map)))]
  out <- character(0)
  for (cl in cols) {
    for (s in names(sfx)) {
      if (grepl(paste0(s, "$"), cl)) {
        out[cl] <- paste0(sub(paste0(s, "$"), "", cl), "_", sfx[[s]])
        break
      }
    }
  }
  out
}

#' Mean of the left and right sides of a bilateral measure
#'
#' `<ROOT>_L_<V>` and `<ROOT>_R_<V>` give `<ROOT>_<V>`. If only one side is
#' available its value is used (`allow_one_side = TRUE`).
#'
#' @param df A data frame.
#' @param roots Root names of the bilateral measures.
#' @param visits Visit suffixes.
#' @param sides Side codes.
#' @param allow_one_side Use the single available side when the other is
#'   missing.
#' @param suffix_new Optional text appended to the root of the new columns.
#' @return `df` with the new columns.
#' @export
#' @examples
#' d <- combine_bilateral(cohort_sim, "PUT")
#' head(d[, c("PUT_L_V0", "PUT_R_V0", "PUT_V0")])
combine_bilateral <- function(df, roots, visits = c("V0", "V3"), sides = c("L", "R"),
                              allow_one_side = TRUE, suffix_new = NULL) {
  df <- .as_df(df, "df")
  for (r in roots) for (v in visits) {
    cols <- paste0(r, "_", sides, "_", v)
    if (!all(cols %in% names(df))) next
    m <- as.matrix(as.data.frame(df)[, cols, drop = FALSE])
    new <- if (allow_one_side) rowMeans(m, na.rm = TRUE) else rowMeans(m)
    new[is.nan(new)] <- NA_real_
    df[[paste0(r, suffix_new %||% "", "_", v)]] <- new
  }
  df
}

#' Wide `<ROOT>_<VISIT>` data to long format
#'
#' One row per subject and visit, one column per root. Derived variables are
#' roots like any other (`LOG_NFL_V0` -> root `LOG_NFL`). Columns are re-typed
#' after reshaping: numeric when possible, otherwise factor (levels of the
#' first visit kept).
#'
#' @param df A data frame in wide format.
#' @param roots Root names to reshape.
#' @param id_col Identifier column (name or bare symbol).
#' @param visits Visit suffixes, in chronological order.
#' @param keep Time-invariant columns to keep (names or tidyselect).
#' @param visit_col Name of the visit column created.
#' @param time_values Optional named vector `visit -> time` (e.g.
#'   `c(V0 = 0, V3 = 36)`), stored in a `TIME` column.
#' @return A tibble.
#' @export
#' @examples
#' long <- visit_to_long(cohort_sim, c("NFL", "MOCA"), id_col = ID, keep = c(GROUP, AGE),
#'                       time_values = c(V0 = 0, V3 = 36))
#' head(long)
visit_to_long <- function(df, roots, id_col, visits = c("V0", "V3"), keep = NULL,
                          visit_col = "VISIT", time_values = NULL) {
  df <- .as_df(df, "df")
  id_col <- .select(rlang::enquo(id_col), df, "id_col", single = TRUE)
  keep <- .select(rlang::enquo(keep), df, "keep")
  cols <- intersect(unlist(lapply(roots, function(r) paste0(r, "_", visits))), names(df))
  if (!length(cols)) cli::cli_abort("No column {.code <root>_<visit>} found for {.arg roots}.")
  long <- tibble::as_tibble(df[, unique(c(id_col, keep, cols)), drop = FALSE])
  long <- dplyr::mutate(long, dplyr::across(dplyr::all_of(cols), as.character))
  long <- tidyr::pivot_longer(long, cols = dplyr::all_of(cols),
                              names_to = c("root_", visit_col),
                              names_pattern = paste0("^(.*)_(", paste(visits, collapse = "|"), ")$"),
                              values_to = "value_")
  long <- tidyr::pivot_wider(long, names_from = "root_", values_from = "value_")
  for (r in intersect(roots, names(long))) {
    ref_col <- paste0(r, "_", visits[1])
    ref <- if (ref_col %in% names(df)) df[[ref_col]] else NULL
    if (is.factor(ref)) {
      long[[r]] <- factor(long[[r]], levels = levels(ref))
    } else {
      num <- suppressWarnings(as.numeric(long[[r]]))
      long[[r]] <- if (all(is.na(num) == is.na(long[[r]]))) num else factor(long[[r]])
    }
  }
  long[[visit_col]] <- factor(long[[visit_col]], levels = visits)
  if (!is.null(time_values)) long$TIME <- unname(time_values[as.character(long[[visit_col]])])
  long
}

#' Change between two visits
#'
#' Adds `DELTA_<ROOT> = <ROOT>_<to> - <ROOT>_<from>` for every root measured
#' (numeric) at both visits.
#'
#' @param df A data frame in wide format.
#' @param roots Root names.
#' @param from,to Visit suffixes.
#' @param prefix Prefix of the new columns.
#' @return `df` with the new columns.
#' @export
#' @examples
#' d <- visit_add_deltas(cohort_sim, c("NFL", "MOCA"))
#' summary(d$DELTA_MOCA)
visit_add_deltas <- function(df, roots, from = "V0", to = "V3", prefix = "DELTA_") {
  df <- .as_df(df, "df")
  for (r in roots) {
    a <- paste0(r, "_", from)
    b <- paste0(r, "_", to)
    if (all(c(a, b) %in% names(df)) && is.numeric(df[[a]]) && is.numeric(df[[b]])) {
      df[[paste0(prefix, r)]] <- df[[b]] - df[[a]]
    }
  }
  df
}
