# Principal component analysis figures ----------------------------------------------

#' Figures of a principal component analysis
#'
#' @description
#' * `plot_pca_scree()`: variance explained per component and cumulative
#'   variance, with the Kaiser line (100 / p %).
#' * `plot_pca_ind()`: individuals map, coloured by a variable of `data`
#'   (90% normal-theory ellipses for groups).
#' * `plot_pca_var()`: correlation circle.
#' * `plot_pca_contrib()`: contribution of each variable to each component,
#'   `100 * loading^2` (sums to 100% per component), with the expected
#'   contribution if all variables contributed equally.
#' * `plot_pca_distribution()`: distribution of the component scores by the
#'   levels of categorical variables, with [plot_distribution()].
#'
#' @param pca_obj Output of [pca_compute()].
#' @param n_pc Number of components shown.
#' @param base_size Base font size.
#' @param title Title.
#' @param data Data frame holding the colour / grouping variables.
#' @param id_col Identifier column used in [pca_compute()].
#' @param color_var Colour variable (name or bare symbol).
#' @param labels Optional named vector of labels.
#' @param axes Components shown (two for the maps, any number for the
#'   contributions).
#' @param palette Colours of the groups.
#' @param ellipse Draw 90% ellipses per group.
#' @param groups Optional named list `group -> variables` (colour of the
#'   arrows or bars).
#' @param top_n Keep the `top_n` contributions per component.
#' @param group_vars Categorical variables (names or tidyselect).
#' @param pcs Components shown.
#' @param ... Passed to [plot_distribution()].
#' @return A ggplot; `plot_pca_distribution()` returns a named list of
#'   patchworks, one per grouping variable.
#' @export
#' @examples
#' pc <- pca_compute(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0, AGE), id_col = ID)
#' plot_pca_scree(pc)
#' plot_pca_ind(pc, cohort_sim, id_col = ID, color_var = GROUP)
#' plot_pca_var(pc, groups = list(Biomarkers = c("NFL_V0", "IL6_V0", "CRP_V0")))
#' plot_pca_contrib(pc, axes = 1:2)
#' plot_pca_distribution(pc, cohort_sim, GROUP, id_col = ID)[[1]]
plot_pca_scree <- function(pca_obj, n_pc = 10, base_size = 11, title = "Scree plot") {
  .check_pca(pca_obj)
  n <- min(n_pc, length(pca_obj$ve))
  d <- tibble::tibble(PC = seq_len(n), ve = pca_obj$ve[seq_len(n)], cv = cumsum(pca_obj$ve)[seq_len(n)])
  sf <- max(d$ve) / 100
  ggplot2::ggplot(d, ggplot2::aes(x = PC)) +
    ggplot2::geom_col(ggplot2::aes(y = ve), fill = "#0072B2", alpha = 0.85, width = 0.7) +
    ggplot2::geom_text(ggplot2::aes(y = ve, label = sprintf("%.1f", ve)), vjust = -0.4, size = 3) +
    ggplot2::geom_line(ggplot2::aes(y = cv * sf), colour = "#D55E00", linewidth = 1) +
    ggplot2::geom_point(ggplot2::aes(y = cv * sf), colour = "#D55E00", size = 2) +
    ggplot2::geom_hline(yintercept = 100 / length(pca_obj$ve), linetype = "dashed", colour = "grey50") +
    ggplot2::scale_y_continuous(name = "Explained variance (%)",
                                sec.axis = ggplot2::sec_axis(~ . / sf, name = "Cumulative variance (%)")) +
    ggplot2::scale_x_continuous(breaks = seq_len(n)) +
    ggplot2::labs(title = title,
                  subtitle = sprintf("N = %d | %d variables (centred, scaled)", pca_obj$n, length(pca_obj$vars)),
                  caption = "Bars: variance per component; orange line: cumulative; dashed: Kaiser criterion (100/p %)",
                  x = "Principal component") +
    theme_pub(base_size)
}

#' @noRd
.check_pca <- function(pca_obj, call = rlang::caller_env()) {
  if (!is.list(pca_obj) || !all(c("pca", "ve", "scores") %in% names(pca_obj))) {
    cli::cli_abort("{.arg pca_obj} must be the output of {.fn pca_compute}.", call = call)
  }
}

#' @rdname plot_pca_scree
#' @export
plot_pca_ind <- function(pca_obj, data = NULL, id_col = NULL, color_var = NULL, labels = NULL,
                         axes = c(1, 2), palette = NULL, ellipse = TRUE, base_size = 11,
                         title = "PCA: individuals") {
  .check_pca(pca_obj)
  sc <- pca_obj$scores
  ax <- paste0("PC", axes)
  if (!is.null(data)) {
    data <- as.data.frame(.as_df(data))
    id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
    color_var <- .select(rlang::enquo(color_var), data, "color_var", single = TRUE)
    if (!is.null(color_var)) {
      key <- if (!is.null(id_col)) as.character(data[[id_col]]) else as.character(seq_len(nrow(data)))
      sc$.col <- data[[color_var]][match(sc$.id, key)]
    }
  }
  p <- ggplot2::ggplot(sc, ggplot2::aes(x = .data[[ax[1]]], y = .data[[ax[2]]]))
  is_grp <- FALSE
  if (".col" %in% names(sc)) {
    if (is.numeric(sc$.col) && dplyr::n_distinct(sc$.col) > 5) {
      p <- p + ggplot2::geom_point(ggplot2::aes(colour = .col), size = 2, alpha = 0.8) +
        ggplot2::scale_colour_viridis_c(name = label_get(color_var, labels), option = "D", direction = -1)
    } else {
      is_grp <- TRUE
      sc$.col <- as.factor(sc$.col)
      p <- p + ggplot2::geom_point(data = sc, ggplot2::aes(colour = .col), size = 2, alpha = 0.8) +
        ggplot2::scale_colour_manual(values = pal_levels(levels(sc$.col), palette),
                                     name = label_get(color_var, labels), na.value = "grey70")
      if (ellipse) p <- p + ggplot2::stat_ellipse(data = sc[!is.na(sc$.col), ], ggplot2::aes(colour = .col), level = 0.9)
    }
  } else {
    p <- p + ggplot2::geom_point(colour = "#0072B2", size = 2, alpha = 0.7)
  }
  p + ggplot2::geom_hline(yintercept = 0, colour = "grey60") + ggplot2::geom_vline(xintercept = 0, colour = "grey60") +
    ggplot2::labs(title = title, subtitle = sprintf("N = %d", pca_obj$n),
                  caption = if (ellipse && is_grp) "Ellipses: 90% normal-theory contour per group" else NULL,
                  x = sprintf("%s (%.1f%%)", ax[1], pca_obj$ve[axes[1]]),
                  y = sprintf("%s (%.1f%%)", ax[2], pca_obj$ve[axes[2]])) +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom")
}

#' @rdname plot_pca_scree
#' @export
plot_pca_var <- function(pca_obj, labels = NULL, axes = c(1, 2), base_size = 11, groups = NULL,
                         title = "PCA: correlation circle") {
  .check_pca(pca_obj)
  cv <- pca_obj$cor_var
  ax <- paste0("PC", axes)
  cv$lab <- label_get(cv$Variable, labels)
  cv$grp <- if (!is.null(groups)) {
    g <- rep(NA_character_, nrow(cv))
    for (nm in names(groups)) g[cv$Variable %in% groups[[nm]]] <- nm
    ifelse(is.na(g), "Other", g)
  } else "Variable"
  circ <- tibble::tibble(t = seq(0, 2 * pi, length.out = 200))
  circ$x <- cos(circ$t)
  circ$y <- sin(circ$t)
  text_layer <- if (requireNamespace("ggrepel", quietly = TRUE)) {
    ggrepel::geom_text_repel(ggplot2::aes(x = .data[[ax[1]]], y = .data[[ax[2]]], label = lab, colour = grp),
                             size = 3, show.legend = FALSE)
  } else {
    ggplot2::geom_text(ggplot2::aes(x = .data[[ax[1]]], y = .data[[ax[2]]], label = lab, colour = grp),
                       size = 3, vjust = -0.5, show.legend = FALSE)
  }
  ggplot2::ggplot(cv) +
    ggplot2::geom_path(data = circ, ggplot2::aes(x = x, y = y), colour = "grey70") +
    ggplot2::geom_segment(ggplot2::aes(x = 0, y = 0, xend = .data[[ax[1]]], yend = .data[[ax[2]]], colour = grp),
                          arrow = ggplot2::arrow(length = ggplot2::unit(0.15, "cm"))) +
    text_layer +
    ggplot2::scale_colour_manual(values = pal_levels(unique(cv$grp)), name = NULL) +
    ggplot2::coord_equal(xlim = c(-1.1, 1.1), ylim = c(-1.1, 1.1)) +
    ggplot2::labs(title = title, subtitle = sprintf("N = %d | arrow = correlation of the variable with each PC", pca_obj$n),
                  x = sprintf("%s (%.1f%%)", ax[1], pca_obj$ve[axes[1]]),
                  y = sprintf("%s (%.1f%%)", ax[2], pca_obj$ve[axes[2]])) +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom")
}

#' @rdname plot_pca_scree
#' @export
plot_pca_contrib <- function(pca_obj, axes = 1:2, labels = NULL, groups = NULL, palette = NULL,
                             top_n = NULL, base_size = 11, title = "PCA: variable contributions") {
  .check_pca(pca_obj)
  rot <- pca_obj$pca$rotation[, axes, drop = FALSE]
  p <- nrow(rot)
  d <- tidyr::pivot_longer(tibble::as_tibble(100 * rot^2, rownames = "Variable"), -"Variable",
                           names_to = "PC_raw", values_to = "contrib")
  d$PC <- sprintf("%s (%.1f%% variance)", d$PC_raw, pca_obj$ve[as.integer(sub("PC", "", d$PC_raw))])
  d$Label <- label_get(d$Variable, labels)
  d$sign <- sign(rot[cbind(match(d$Variable, rownames(rot)), match(d$PC_raw, colnames(rot)))])
  d$Group <- if (!is.null(groups)) {
    g <- rep("Other", nrow(d))
    for (nm in names(groups)) g[d$Variable %in% groups[[nm]]] <- nm
    g
  } else "Variable"
  if (!is.null(top_n)) d <- dplyr::slice_max(d, .data$contrib, n = top_n, by = "PC")
  d$ord <- paste(d$PC, d$Label, sep = "___")
  d$ord <- factor(d$ord, levels = unique(d$ord[order(d$contrib)]))
  pal <- pal_levels(unique(d$Group), palette)
  ggplot2::ggplot(d, ggplot2::aes(x = contrib, y = ord, fill = Group)) +
    ggplot2::geom_col(width = 0.75, alpha = 0.9) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f%% (%s)", contrib, ifelse(sign > 0, "+", .u("\u2212")))),
                       hjust = -0.1, size = base_size / 3.6) +
    ggplot2::geom_vline(xintercept = 100 / p, linetype = "dashed", colour = "#D55E00") +
    ggplot2::facet_wrap(~ PC, scales = "free_y") +
    ggplot2::scale_y_discrete(labels = function(x) sub("^.*___", "", x)) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.25))) +
    ggplot2::scale_fill_manual(values = pal, name = NULL, guide = if (is.null(groups)) "none" else "legend") +
    ggplot2::labs(title = title,
                  subtitle = sprintf("N = %d | %d variables | contribution = squared loading x 100 (sums to 100%% per axis)",
                                     pca_obj$n, p),
                  caption = .u(sprintf("Dashed: expected contribution if all variables contributed equally (100/%d = %.1f%%). (+/\u2212): sign of the loading, i.e. direction on the axis.",
                                       p, 100 / p)),
                  x = "Contribution (%)", y = NULL) +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom")
}

#' @rdname plot_pca_scree
#' @export
plot_pca_distribution <- function(pca_obj, data, group_vars, id_col = NULL, pcs = 1:2,
                                  labels = NULL, palette = NULL, base_size = 10, ...) {
  .check_pca(pca_obj)
  data <- as.data.frame(.as_df(data))
  id_col <- .select(rlang::enquo(id_col), data, "id_col", single = TRUE)
  group_vars <- .select(rlang::enquo(group_vars), data, "group_vars")
  d <- pca_scores_join(pca_obj, data, id_col = id_col, n_pc = max(pcs))
  pc_names <- paste0("PC", pcs)
  pc_labels <- stats::setNames(sprintf("%s (%.1f%% variance)", pc_names, pca_obj$ve[pcs]), pc_names)
  all_labels <- c(labels, pc_labels)
  stats::setNames(lapply(group_vars, function(g) {
    plot_distribution(d, vars = pc_names, group = g, labels = all_labels, palette = palette,
                      type = "density", ncol = length(pcs), base_size = base_size,
                      show_stats = "median", outlier_iqr = FALSE,
                      title = sprintf("PC scores by %s", label_get(g, labels)), ...)
  }), group_vars)
}
