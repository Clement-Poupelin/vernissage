# Colour-blind safe palettes (Okabe & Ito 2008) -------------------------------

#' Colour palettes
#'
#' `pal_okabe_ito()` returns the nine colours of the Okabe-Ito palette
#' (Okabe & Ito 2008), safe for colour-blind readers. `pal_levels()` gives one
#' colour per level of a factor.
#'
#' `palette` in `pal_levels()` can be:
#' * `NULL`: Okabe-Ito colours (orange, sky blue, green, vermillion, blue,
#'   pink, yellow, grey), interpolated when there are more levels;
#' * a named vector covering every level: returned as is (in level order);
#' * an unnamed vector of colours, used in order (interpolated if too short);
#' * the name of a palette: `"okabe"`, one of [grDevices::hcl.pals()],
#'   [grDevices::palette.pals()] or an RColorBrewer palette;
#' * a function of the number of colours, e.g. [grDevices::rainbow].
#'
#' @param levels Levels (character or factor levels) to colour.
#' @param palette See Details.
#' @return A named character vector of hexadecimal colours.
#' @references Okabe M, Ito K (2008). Color Universal Design (CUD): how to make
#'   figures and presentations that are friendly to colorblind people.
#' @export
#' @examples
#' pal_okabe_ito()
#' pal_levels(c("Placebo", "Active"))
#' pal_levels(c("A", "B", "C"), palette = "Dark 3")
#' pal_levels(c("Low", "High"), palette = c(Low = "grey70", High = "firebrick"))
pal_okabe_ito <- function() {
  c(orange = "#E69F00", skyblue = "#56B4E9", green = "#009E73", yellow = "#F0E442",
    blue = "#0072B2", vermillion = "#D55E00", pink = "#CC79A7", grey = "#999999",
    black = "#000000")
}

#' @rdname pal_okabe_ito
#' @export
pal_levels <- function(levels, palette = NULL) {
  levels <- as.character(levels)
  n <- length(levels)
  if (is.function(palette)) palette <- palette(n)
  if (is.character(palette) && length(palette) == 1 && is.null(names(palette)) && !.is_colour(palette)) {
    palette <- .palette_by_name(palette, n)
  }
  if (!is.null(palette) && !is.null(names(palette)) && all(levels %in% names(palette))) {
    return(palette[levels])
  }
  base <- unname(palette %||% pal_okabe_ito()[c("orange", "skyblue", "green", "vermillion",
                                                 "blue", "pink", "yellow", "grey")])
  cols <- if (n <= length(base)) base[seq_len(n)] else grDevices::colorRampPalette(base)(n)
  stats::setNames(cols, levels)
}

#' @noRd
.is_colour <- function(x) {
  !inherits(tryCatch(grDevices::col2rgb(x), error = function(e) e), "error")
}

#' @noRd
.palette_by_name <- function(name, n, call = rlang::caller_env()) {
  if (tolower(name) %in% c("okabe", "okabe-ito", "okabeito")) {
    base <- unname(pal_okabe_ito()[c("orange", "skyblue", "green", "vermillion",
                                      "blue", "pink", "yellow", "black")])
    return(if (n <= length(base)) base[seq_len(n)] else grDevices::colorRampPalette(base)(n))
  }
  if (name %in% grDevices::hcl.pals()) return(grDevices::hcl.colors(max(n, 1), name)[seq_len(n)])
  if (name %in% grDevices::palette.pals()) {
    cols <- unname(grDevices::palette.colors(NULL, name))
    return(rep_len(cols, n))
  }
  if (requireNamespace("RColorBrewer", quietly = TRUE) &&
      name %in% rownames(RColorBrewer::brewer.pal.info)) {
    return(rep_len(RColorBrewer::brewer.pal(max(3, n), name), n))
  }
  cli::cli_abort("Unknown palette {.val {name}}.", call = call)
}
