# Import and names --------------------------------------------------------------

#' Resolve a path whose accented characters are stored differently on disk
#'
#' A file name with accents can be stored in Unicode NFC (one code point for
#' an accented letter) or NFD (letter + combining accent), e.g. folders created
#' on macOS or extracted from a zip. Each path component that does not exist
#' as typed is matched against the directory listing after NFC normalisation.
#'
#' @param path Path to a file or directory.
#' @return The path as it exists on disk (a message is printed when it
#'   differs from `path`). An error is raised if no match is found.
#' @export
#' @examples
#' path_resolve_nfc(system.file("extdata", "cohort_messy.csv", package = "vernissage"))
path_resolve_nfc <- function(path) {
  if (!is.character(path) || length(path) != 1 || is.na(path)) {
    cli::cli_abort("{.arg path} must be a single character string.")
  }
  path <- path.expand(path)
  if (file.exists(path)) return(path)
  .need("stringi", "to match accented file names (Unicode normalisation).")
  nfc <- function(x) stringi::stri_trans_nfc(x)
  parts <- strsplit(path, "/", fixed = TRUE)[[1]]
  cur <- if (startsWith(path, "/")) "/" else "."
  for (comp in parts[nzchar(parts)]) {
    cand <- file.path(cur, comp)
    if (!file.exists(cand)) {
      hits <- list.files(cur, all.files = TRUE, no.. = TRUE)
      hit <- hits[nfc(hits) == nfc(comp)]
      if (!length(hit)) {
        cli::cli_abort("File not found: {.file {path}} (no entry matching {.val {comp}} in {.file {cur}}).")
      }
      cand <- file.path(cur, hit[1])
    }
    cur <- cand
  }
  if (!identical(cur, path)) cli::cli_inform("Path resolved with Unicode normalisation: {.file {cur}}.")
  cur
}

#' Read a "French" CSV file
#'
#' Robust reader for CSV files exported by French versions of spreadsheet
#' software: `;` separator, possible `,` decimal mark, several missing-value
#' codes, automatic encoding detection (UTF-8 or Latin-1 / Windows-1252).
#' Character columns that are actually numeric (e.g. `"12,5"`) are converted.
#'
#' @param path Path to the file (accents resolved with [path_resolve_nfc()]).
#' @param sep Field separator.
#' @param na Strings read as missing values.
#' @param convert_comma_decimal Convert character columns whose every
#'   non-missing value is a number written with a comma or a point.
#' @param encoding `"auto"` (UTF-8 if the file is valid UTF-8, `"latin1"`
#'   otherwise) or an explicit file encoding.
#' @param ... Passed to [utils::read.csv()].
#' @return A data frame (column names unchanged, see [clean_colnames()]).
#' @export
#' @examples
#' f <- system.file("extdata", "cohort_messy.csv", package = "vernissage")
#' raw <- read_cohort_csv(f)
#' str(raw)
read_cohort_csv <- function(path, sep = ";", na = c("", "NA", "NaN", ".", "NR", "ND"),
                            convert_comma_decimal = TRUE, encoding = "auto", ...) {
  path <- path_resolve_nfc(path)
  if (identical(encoding, "auto")) {
    bytes <- readBin(path, "raw", n = file.info(path)$size)
    txt <- rawToChar(bytes[bytes != as.raw(0)])
    encoding <- if (validUTF8(txt)) "UTF-8" else "latin1"
    cli::cli_inform("Detected encoding: {.val {encoding}}.")
  }
  df <- utils::read.csv(path, sep = sep, na.strings = na, stringsAsFactors = FALSE,
                        check.names = FALSE, fileEncoding = encoding, ...)
  fix_enc <- function(x) {                       # safety net: re-encode invalid strings
    bad <- !is.na(x) & !validUTF8(x)
    if (any(bad)) x[bad] <- iconv(x[bad], from = "latin1", to = "UTF-8", sub = "?")
    x
  }
  names(df) <- fix_enc(names(df))
  if (convert_comma_decimal) {
    df[] <- lapply(df, function(x) {
      if (!is.character(x)) return(x)
      x <- fix_enc(x)
      x_trim <- trimws(x)
      num <- suppressWarnings(as.numeric(gsub(",", ".", x_trim, fixed = TRUE)))
      empty <- is.na(x_trim) | x_trim == ""
      # converted only if ALL non-missing values are numbers
      if (sum(!empty) > 0 && all(is.na(num) == empty)) num else x
    })
  }
  df
}

#' Clean column names
#'
#' Spaces removed, runs of dashes and dots replaced by `_`, upper case
#' (optional), names made unique.
#'
#' @param df A data frame.
#' @param upper Convert to upper case.
#' @return `df` with cleaned names.
#' @export
#' @examples
#' clean_colnames(data.frame(`nfl v0` = 1, `il-6.v0` = 2, check.names = FALSE))
clean_colnames <- function(df, upper = TRUE) {
  df <- .as_df(df, "df")
  nm <- names(df)
  nm <- gsub("\\s+", "", nm)
  nm <- gsub("[-.]+", "_", nm)
  if (upper) nm <- toupper(nm)
  names(df) <- make.unique(nm, sep = "_")
  df
}

#' Rename columns with a named vector
#'
#' @param df A data frame.
#' @param map Named character vector `c(OLD = "NEW")`. Old names absent from
#'   `df` are ignored with a message.
#' @return `df` with renamed columns.
#' @export
#' @examples
#' rename_with_map(data.frame(a = 1, b = 2), c(a = "AGE", z = "ZZ"))
rename_with_map <- function(df, map) {
  df <- .as_df(df, "df")
  if (!is.character(map) || is.null(names(map))) {
    cli::cli_abort("{.arg map} must be a named character vector {.code c(OLD = \"NEW\")}.")
  }
  present <- names(map)[names(map) %in% names(df)]
  if (length(present) < length(map)) {
    cli::cli_inform("{length(map) - length(present)} name(s) not found, ignored: {.val {setdiff(names(map), present)}}.")
  }
  names(df)[match(present, names(df))] <- unname(map[present])
  df
}

#' Catalogue of the variables, by block
#'
#' One row per root variable: block, label, description, detected type
#' (categorical, binary, discrete, continuous), visits available and share of
#' missing values at the first visit found.
#'
#' @param df A data frame in wide format.
#' @param blocks Named list `block -> root names` (without visit suffix).
#' @param labels Optional named vector of labels.
#' @param desc Optional named vector of descriptions.
#' @param visits Visit suffixes looked for.
#' @return A tibble.
#' @export
#' @examples
#' catalog_vars(cohort_sim, list(Biomarkers = c("NFL", "IL6"), Clinical = c("AGE", "MOCA")))
catalog_vars <- function(df, blocks, labels = NULL, desc = NULL, visits = c("V0", "V3")) {
  df <- .as_df(df, "df")
  if (!is.list(blocks) || is.null(names(blocks))) cli::cli_abort("{.arg blocks} must be a named list.")
  rows <- lapply(names(blocks), function(blk) {
    dplyr::bind_rows(lapply(blocks[[blk]], function(r) {
      cols <- intersect(c(r, paste0(r, "_", visits)), names(df))
      if (!length(cols)) return(NULL)
      x <- df[[cols[1]]]
      type <- if (is.factor(x) || is.character(x) || is.logical(x)) "Categorical"
        else if (is.numeric(x) && dplyr::n_distinct(x, na.rm = TRUE) <= 2) "Binary"
        else if (is.numeric(x) && all(abs(x - round(x)) < 1e-8, na.rm = TRUE)) "Discrete"
        else "Continuous"
      vis <- sub(paste0("^", r, "_?"), "", cols)
      vis[vis == ""] <- "\u2014"
      tibble::tibble(
        Block = blk, Variable = r, Label = label_get(r, labels),
        Description = if (!is.null(desc) && r %in% names(desc)) unname(desc[[r]]) else "",
        Type = type, Visits = paste(vis, collapse = ", "),
        `% missing (first visit)` = round(100 * mean(is.na(x)), 1))
    }))
  })
  dplyr::bind_rows(rows)
}
