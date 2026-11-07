# Publication theme -----------------------------------------------------------

#' Publication theme for ggplot2
#'
#' A complete theme (`complete = TRUE`): the rendering is identical whatever
#' the global theme of the session. White panels with a light border, light
#' major grid, bold left-aligned title, grey subtitle and caption.
#'
#' @param base_size Base font size, in points.
#' @param legend_position Position of the legend (`"right"`, `"bottom"`,
#'   `"top"`, `"left"` or `"none"`).
#' @return A [ggplot2::theme()] object.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(cohort_sim, aes(AGE, NFL_V0)) +
#'   geom_point() +
#'   labs(title = "NfL by age") +
#'   theme_pub()
theme_pub <- function(base_size = 11, legend_position = "right") {
  .check_number(base_size, "base_size", min = 1)
  half <- base_size / 2
  third <- base_size / 3
  ggplot2::theme(
    text = ggplot2::element_text(family = "", face = "plain", size = base_size, colour = "#222222",
                                 hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9,
                                 margin = ggplot2::margin()),
    plot.title    = ggplot2::element_text(face = "bold", size = base_size + 2, colour = "#2C3E50",
                                          hjust = 0, vjust = 1, margin = ggplot2::margin(b = half)),
    plot.subtitle = ggplot2::element_text(size = base_size - 1, colour = "#5D6D7E",
                                          hjust = 0, vjust = 1, margin = ggplot2::margin(b = half)),
    plot.caption  = ggplot2::element_text(size = base_size - 2, colour = "#7F8C8D",
                                          hjust = 0, vjust = 0, margin = ggplot2::margin(t = half)),
    plot.title.position = "plot", plot.caption.position = "plot",
    plot.background = ggplot2::element_rect(fill = "white", colour = NA),
    plot.margin = ggplot2::margin(8, 12, 8, 8),
    axis.title   = ggplot2::element_text(size = base_size, colour = "#333333"),
    axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = half)),
    axis.title.y = ggplot2::element_text(angle = 90, margin = ggplot2::margin(r = half)),
    axis.text    = ggplot2::element_text(size = base_size - 1, colour = "#444444"),
    axis.text.x  = ggplot2::element_text(margin = ggplot2::margin(t = third)),
    axis.text.y  = ggplot2::element_text(margin = ggplot2::margin(r = third), hjust = 1),
    axis.line    = ggplot2::element_blank(),
    axis.ticks   = ggplot2::element_line(colour = "grey70", linewidth = 0.3),
    axis.ticks.length = ggplot2::unit(3, "pt"),
    panel.background = ggplot2::element_rect(fill = "white", colour = NA),
    panel.border     = ggplot2::element_rect(fill = NA, colour = "grey80", linewidth = 0.5),
    panel.grid.major = ggplot2::element_line(colour = "grey92", linewidth = 0.3),
    panel.grid.minor = ggplot2::element_blank(),
    panel.spacing    = ggplot2::unit(half, "pt"),
    strip.background = ggplot2::element_rect(fill = "#ECF0F1", colour = NA),
    strip.text       = ggplot2::element_text(face = "bold", size = base_size - 1, colour = "#2C3E50",
                                             margin = ggplot2::margin(half, half, half, half)),
    strip.text.y     = ggplot2::element_text(angle = -90),
    strip.placement  = "outside",
    legend.background = ggplot2::element_rect(fill = "white", colour = NA),
    legend.key        = ggplot2::element_rect(fill = "white", colour = NA),
    legend.key.size   = ggplot2::unit(base_size * 1.2, "pt"),
    legend.text       = ggplot2::element_text(size = base_size - 1, colour = "#333333"),
    legend.title      = ggplot2::element_text(face = "bold", size = base_size, colour = "#333333"),
    legend.position   = legend_position,
    complete = TRUE
  )
}

#' Rotated x-axis labels that stay attached to their tick
#'
#' `hjust = 1` and `vjust = 1` anchor the end of the text on the tick; the
#' default `vjust = 0.5` pushes long labels below the plot, where they get cut.
#'
#' @param angle Angle of the labels, in degrees.
#' @param size Font size of the labels (`NULL`: unchanged).
#' @return A [ggplot2::theme()] object to add to a plot.
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(cohort_sim, aes(GROUP, AGE)) + geom_boxplot() + theme_pub() + theme_rotate_x(45)
theme_rotate_x <- function(angle = 45, size = NULL) {
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = angle, hjust = 1, vjust = 1, size = size))
}
