# Forest plot ------------------------------------------------------------------------

#' Annotated forest plot
#'
#' One row per term: point estimate and confidence interval on the left, a
#' text column "estimate \[95% CI\]" and a column "p" with stars on the right
#' (aligned on the same rows), and optionally a column of adjusted p-values.
#' Several estimates per term (`group`, e.g. two models) are offset inside the
#' row rather than dodged along x, which would change the estimate.
#'
#' @param df Data frame, one row per term (and per `group`).
#' @param label,estimate,low,high,p Columns of the term label, estimate, CI
#'   bounds and p-value (names or bare symbols).
#' @param p_adj Optional column of adjusted p-values (third text column).
#' @param group Optional column distinguishing several estimates per term.
#' @param ref Reference line (0 for differences, 1 for ratios).
#' @param log_x Logarithmic x axis (odds ratios).
#' @param effect_label Header of the estimate column, e.g. `"OR"`.
#' @param xlab X-axis title (default: `effect_label`).
#' @param title,subtitle,caption Titles; the caption also explains the
#'   symbols.
#' @param palette Colours of the groups.
#' @param digits Decimals of the estimates.
#' @param base_size Base font size.
#' @param widths Relative widths of the plot and text panels.
#' @return A patchwork, or `NULL` when no estimate is available.
#' @export
#' @examples
#' res <- data.frame(label = c("NfL", "IL-6", "CRP"), estimate = c(0.4, -0.1, 0.2),
#'                   conf.low = c(0.1, -0.4, -0.1), conf.high = c(0.7, 0.2, 0.5),
#'                   p.value = c(0.01, 0.5, 0.2))
#' plot_forest(res, effect_label = "\u03b2", title = "Effect per SD")
plot_forest <- function(df, label = "label", estimate = "estimate", low = "conf.low", high = "conf.high",
                        p = "p.value", p_adj = NULL, group = NULL, ref = 0, log_x = FALSE,
                        effect_label = "\u03b2", xlab = NULL, title = NULL, subtitle = NULL,
                        caption = NULL, palette = NULL, digits = 2, base_size = 11, widths = c(3, 1.7)) {
  d <- as.data.frame(.as_df(df, "df"))
  label <- .select(rlang::enquo(label), d, "label", single = TRUE)
  estimate <- .select(rlang::enquo(estimate), d, "estimate", single = TRUE)
  low <- .select(rlang::enquo(low), d, "low", single = TRUE)
  high <- .select(rlang::enquo(high), d, "high", single = TRUE)
  p <- .select(rlang::enquo(p), d, "p", single = TRUE)
  p_adj <- .select(rlang::enquo(p_adj), d, "p_adj", single = TRUE)
  group <- .select(rlang::enquo(group), d, "group", single = TRUE)
  d <- d[!is.na(d[[estimate]]), , drop = FALSE]
  if (!nrow(d)) return(NULL)
  lab_levels <- rev(unique(as.character(d[[label]])))
  n <- length(lab_levels)
  d$.grp <- if (!is.null(group)) factor(d[[group]], levels = unique(d[[group]])) else factor("Estimate")
  k <- nlevels(d$.grp)
  step <- if (k > 1) min(0.8 / k, 0.3) else 0
  d$.y <- match(as.character(d[[label]]), lab_levels) - (as.integer(d$.grp) - (k + 1) / 2) * step
  effect_label <- .u(effect_label)
  sig_levels <- .u(c("p < 0.05", "p \u2265 0.05"))
  d$.sig <- factor(ifelse(!is.na(d[[p]]) & d[[p]] < 0.05, sig_levels[1], sig_levels[2]), levels = sig_levels)
  pal <- pal_levels(levels(d$.grp), palette %||% c("#0072B2", "#E69F00", "#009E73", "#CC79A7"))
  y_scale <- function(labs) ggplot2::scale_y_continuous(breaks = seq_len(n), labels = labs,
                                                        limits = c(0.5 - 0.1, n + 1.1), expand = c(0, 0))
  fs <- base_size / 3.4

  p_left <- ggplot2::ggplot(d, ggplot2::aes(x = .data[[estimate]], y = .y, colour = .grp)) +
    ggplot2::geom_vline(xintercept = ref, linetype = "dashed", colour = "grey50") +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = .data[[low]], xmax = .data[[high]]), orientation = "y",
                           width = if (k > 1) step * 0.6 else 0.25) +
    ggplot2::geom_point(ggplot2::aes(shape = .sig), size = 2.4, fill = "white") +
    ggplot2::scale_shape_manual(values = stats::setNames(c(16, 21), sig_levels), limits = sig_levels,
                                name = NULL, drop = FALSE,
                                guide = ggplot2::guide_legend(override.aes = list(colour = "grey20", fill = "white", size = 2.4))) +
    ggplot2::scale_colour_manual(values = pal, name = NULL, guide = if (k > 1) "legend" else "none") +
    y_scale(lab_levels) +
    ggplot2::labs(x = xlab %||% effect_label, y = NULL) +
    theme_pub(base_size) + ggplot2::theme(legend.position = "bottom", panel.grid.minor = ggplot2::element_blank())
  if (log_x) p_left <- p_left + ggplot2::scale_x_log10()

  d$.est_txt <- .u(sprintf("%s [%s; %s]", fmt_num(d[[estimate]], digits), fmt_num(d[[low]], digits),
                           fmt_num(d[[high]], digits)))
  ptxt <- function(v) .u(ifelse(is.na(v), "\u2013", trimws(paste(fmt_p(v), fmt_stars(v, ns = "", trend = FALSE)))))
  d$.p_txt <- ptxt(d[[p]])
  show_adj <- !is.null(p_adj)
  if (show_adj) d$.padj_txt <- ptxt(d[[p_adj]])
  x_max <- if (show_adj) 2.2 else 1.6
  p_right <- ggplot2::ggplot(d, ggplot2::aes(y = .y)) +
    ggplot2::geom_text(ggplot2::aes(x = 0, label = .est_txt, colour = .grp), hjust = 0, size = fs, show.legend = FALSE) +
    ggplot2::geom_text(ggplot2::aes(x = 1.05, label = .p_txt, colour = .grp), hjust = 0, size = fs, show.legend = FALSE) +
    ggplot2::annotate("text", x = 0, y = n + 0.75, hjust = 0, fontface = "bold", size = fs,
                      label = paste0(effect_label, " [95% CI]")) +
    ggplot2::annotate("text", x = 1.05, y = n + 0.75, hjust = 0, fontface = "bold", size = fs, label = "p") +
    ggplot2::scale_colour_manual(values = if (k > 1) pal else c(Estimate = "#222222")) +
    ggplot2::scale_x_continuous(limits = c(0, x_max), expand = c(0, 0)) +
    y_scale(NULL) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_void(base_size = base_size) +
    ggplot2::theme(plot.margin = ggplot2::margin(8, 8, 8, 4))
  if (show_adj) {
    p_right <- p_right +
      ggplot2::geom_text(ggplot2::aes(x = 1.6, label = .padj_txt, colour = .grp), hjust = 0, size = fs, show.legend = FALSE) +
      ggplot2::annotate("text", x = 1.6, y = n + 0.75, hjust = 0, fontface = "bold", size = fs, label = "p FDR")
  }
  patchwork::wrap_plots(p_left, p_right, nrow = 1, widths = widths) +
    patchwork::plot_layout(guides = "collect") +
    patchwork::plot_annotation(title = title, subtitle = subtitle,
                               caption = paste(c(caption, "Filled symbol: p < 0.05. * p < 0.05, ** p < 0.01, *** p < 0.001"),
                                               collapse = "\n"),
                               theme = theme_pub(base_size)) &
    ggplot2::theme(legend.position = "bottom", legend.box = "vertical")
}
