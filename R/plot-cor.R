# Correlation heatmaps -----------------------------------------------------------------

#' Correlation heatmaps
#'
#' @description
#' * `plot_cor_heatmap()`: lower triangle (diagonal included) of a
#'   correlation matrix from [cor_matrix_test()], with values and stars,
#'   variables optionally ordered by hierarchical clustering.
#' * `plot_cor_cross()`: rectangular heatmap of the correlations between two
#'   sets of variables (e.g. biomarkers x scores), optionally partial
#'   (adjusted for covariates, see [cor_partial_spearman()]).
#'
#' @param cm Output of [cor_matrix_test()].
#' @param labels Optional named vector of labels.
#' @param use_adj Stars on adjusted (`TRUE`) or raw p-values.
#' @param order `"hclust"` (Ward clustering on 1 - r) or `"original"`.
#' @param show_values Print the correlations and stars.
#' @param base_size Base font size.
#' @param title Title.
#' @param value_size Size of the printed values.
#' @param data A data frame.
#' @param x_vars,y_vars Variables in rows and columns (names or tidyselect).
#' @param covariates Optional adjustment covariates (names or tidyselect).
#' @param p_adjust Multiplicity correction over all the pairs.
#' @return `plot_cor_heatmap()`: a ggplot. `plot_cor_cross()`:
#'   `list(table, plot)`.
#' @export
#' @examples
#' cm <- cor_matrix_test(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0, MOCA_V0, UPDRS_V0, AGE))
#' plot_cor_heatmap(cm)
#' res <- plot_cor_cross(cohort_sim, c(NFL_V0, IL6_V0, CRP_V0), c(MOCA_V0, UPDRS_V0),
#'                       covariates = c(AGE, SEX))
#' res$plot
plot_cor_heatmap <- function(cm, labels = NULL, use_adj = TRUE, order = c("hclust", "original"),
                             show_values = TRUE, base_size = 10, title = NULL, value_size = 2.6) {
  order <- match.arg(order)
  if (!is.list(cm) || !all(c("r", "p", "p_adj", "n") %in% names(cm))) {
    cli::cli_abort("{.arg cm} must be the output of {.fn cor_matrix_test}.")
  }
  R <- cm$r
  P <- if (use_adj) cm$p_adj else cm$p
  if (order == "hclust" && nrow(R) > 2) {
    Rf <- R
    Rf[is.na(Rf)] <- 0
    o <- stats::hclust(stats::as.dist(1 - Rf), method = "ward.D2")$order
    R <- R[o, o]
    P <- P[o, o]
  }
  lv <- label_get(rownames(R), labels)
  nmin <- suppressWarnings(min(cm$n[upper.tri(cm$n)], na.rm = TRUE))
  nmax <- suppressWarnings(max(cm$n[upper.tri(cm$n)], na.rm = TRUE))
  long <- tibble::tibble(i = as.vector(row(R)), j = as.vector(col(R)), r = as.vector(R), p = as.vector(P))
  long <- long[long$i >= long$j, , drop = FALSE]
  long$x <- factor(lv[long$j], levels = lv)
  long$y <- factor(lv[long$i], levels = rev(lv))
  long$lab <- ifelse(is.na(long$r), "", ifelse(long$i == long$j, "1",
                     paste0(sprintf("%.2f", long$r), "\n", fmt_stars(long$p, ns = "", trend = FALSE))))
  p <- ggplot2::ggplot(long, ggplot2::aes(x = x, y = y, fill = r)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, limits = c(-1, 1),
                                  name = if (identical(cm$method, "spearman")) .u("\u03c1") else "r") +
    ggplot2::labs(title = title %||% "Correlation matrix",
                  subtitle = .u(sprintf("%s correlation | pairwise complete N = %s", .capitalise(cm$method %||% ""),
                                        if (is.finite(nmin) && nmin != nmax) paste0(nmin, "\u2013", nmax) else nmin)),
                  caption = sprintf("Stars: %s p-value (* < 0.05, ** < 0.01, *** < 0.001)%s",
                                    if (use_adj) paste0("adjusted (", cm$p_adjust, ")") else "raw",
                                    if (order == "hclust") "; variables ordered by hierarchical clustering" else ""),
                  x = NULL, y = NULL) +
    ggplot2::coord_fixed() +
    theme_pub(base_size) + theme_rotate_x(45) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
  if (show_values) p <- p + ggplot2::geom_text(ggplot2::aes(label = lab), size = value_size, lineheight = 0.8)
  p
}

#' @rdname plot_cor_heatmap
#' @export
plot_cor_cross <- function(data, x_vars, y_vars, covariates = NULL, labels = NULL,
                           p_adjust = "BH", base_size = 10, title = NULL) {
  data <- as.data.frame(.as_df(data))
  x_vars <- .select(rlang::enquo(x_vars), data, "x_vars")
  y_vars <- .select(rlang::enquo(y_vars), data, "y_vars")
  covariates <- .select(rlang::enquo(covariates), data, "covariates")
  Z <- if (length(covariates)) data[, covariates, drop = FALSE] else NULL
  tab <- tidyr::expand_grid(X = x_vars, Y = y_vars)
  res <- lapply(seq_len(nrow(tab)), function(k) {
    cor_partial_spearman(as.numeric(data[[tab$X[k]]]), as.numeric(data[[tab$Y[k]]]), Z)
  })
  tab$rho <- vapply(res, function(r) r$estimate, numeric(1))
  tab$p <- vapply(res, function(r) r$p.value, numeric(1))
  tab$n <- vapply(res, function(r) as.integer(r$n), integer(1))
  tab$p_adj <- stats::p.adjust(tab$p, p_adjust)
  pd <- tab
  pd$Xl <- factor(label_get(pd$X, labels), levels = rev(label_get(x_vars, labels)))
  pd$Yl <- factor(label_get(pd$Y, labels), levels = label_get(y_vars, labels))
  pd$lab <- paste0(sprintf("%.2f", pd$rho), fmt_stars(pd$p_adj, ns = "", trend = FALSE))
  pl <- ggplot2::ggplot(pd, ggplot2::aes(x = Yl, y = Xl, fill = rho)) +
    ggplot2::geom_tile(colour = "white") +
    ggplot2::geom_text(ggplot2::aes(label = lab), size = 2.8) +
    ggplot2::scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0,
                                  limits = c(-1, 1), name = .u("\u03c1")) +
    ggplot2::labs(title = title %||% "Spearman correlations",
                  subtitle = .u(sprintf("%s | N = %d\u2013%d",
                                        if (length(covariates)) paste0("Partial, adjusted for ", paste(label_get(covariates, labels), collapse = ", "))
                                        else "Unadjusted", min(tab$n), max(tab$n))),
                  caption = sprintf("Stars: %s-adjusted p over %d tests (* < 0.05, ** < 0.01, *** < 0.001)", p_adjust, nrow(tab)),
                  x = NULL, y = NULL) +
    theme_pub(base_size) + theme_rotate_x(45) + ggplot2::theme(panel.grid = ggplot2::element_blank())
  list(table = tab, plot = pl)
}
