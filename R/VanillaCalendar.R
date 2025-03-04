#' Vanilla Calendar Widget
#'
#' Creates a Vanilla Calendar widget for use in R and Shiny applications.
#'
#' @param options A list of options to configure the calendar widget
#' @param width The width of the widget. Must be a valid CSS unit (like '100%', '400px', 'auto') or a number, which will be coerced to a string and have 'px' appended.
#' @param height The height of the widget. Must be a valid CSS unit (like '100%', '400px', 'auto') or a number, which will be coerced to a string and have 'px' appended.
#' @param elementId An optional ID for the widget element
#'
#' @import htmlwidgets
#'
#' @export
VanillaCalendar <- function(options, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    options = options
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'VanillaCalendar',
    x,
    width = width,
    height = height,
    package = 'VanillaCalendar',
    elementId = elementId
  )
}

#' Shiny bindings for VanillaCalendar
#'
#' Output and render functions for using VanillaCalendar within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a VanillaCalendar
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name VanillaCalendar-shiny
#'
#' @export
VanillaCalendarOutput <- function(outputId, width = '1000px', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'VanillaCalendar', width, height, package = 'VanillaCalendar')
}

#' @rdname VanillaCalendar-shiny
#' @export
renderVanillaCalendar <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, VanillaCalendarOutput, env, quoted = TRUE)
}
