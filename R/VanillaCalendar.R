#' Vanilla Calendar Widget
#'
#' Creates a [Vanilla Calendar Pro](https://vanilla-calendar.pro/) calendar or
#' date picker for use in R, R Markdown and Shiny applications.
#'
#' @param options A named list of Vanilla Calendar Pro options, passed to the
#'   JavaScript library. Every option documented in the
#'   [upstream reference](https://vanilla-calendar.pro/docs/reference/additionally/settings)
#'   is accepted; names are validated against the bundled library version and
#'   unknown names raise a warning. `Date` and `POSIXct` values are converted to
#'   the `"YYYY-MM-DD"` strings the library expects, and options that must be
#'   arrays (such as `selectedDates`) are boxed for you, so a single date works.
#'   JavaScript callbacks can be supplied with [htmlwidgets::JS()]; they run in
#'   addition to, not instead of, the Shiny inputs described below. Note that
#'   options keep the library's own conventions, so `selectedMonth` counts
#'   months from 0 (`11` is December) even though `input$<id>_selected_month`
#'   is reported to R as 1-12.
#' @param width,height Must be a valid CSS unit (like `'100\%'`, `'400px'`,
#'   `'auto'`) or a number, which will be coerced to a string and have `'px'`
#'   appended.
#' @param elementId An optional ID for the widget element.
#'
#' @section Shiny inputs:
#' When rendered in Shiny, the widget reports its state back to the server.
#' For an output with id `"cal"`:
#'
#' \describe{
#'   \item{`input$cal_selected`}{A `Date` vector of the selected dates
#'     (length 0 when nothing is selected).}
#'   \item{`input$cal_selected_month`}{Selected month, 1-12.}
#'   \item{`input$cal_selected_year`}{Selected year.}
#'   \item{`input$cal_displayed`}{First day of the displayed month, as a
#'     `Date`, updated when the user clicks the arrows.}
#'   \item{`input$cal_time`}{Selected time as a string, e.g. `"14:30"`, when
#'     `selectionTimeMode` is enabled.}
#'   \item{`input$cal_week`}{A list with `week` and `year`, when
#'     `enableWeekNumbers` is enabled and a week number is clicked.}
#'   \item{`input$cal_ready`}{`TRUE` once the calendar has initialised.}
#' }
#'
#' @section Input mode:
#' With `options = list(inputMode = TRUE)` the widget renders a text input and
#' shows the calendar as a popup, the behaviour documented under
#' [input mode](https://vanilla-calendar.pro/docs/reference/additionally/settings)
#' upstream. Pair it with `height = "auto"`.
#'
#' @section Theming:
#' `selectedTheme` accepts `"light"`, `"dark"` or `"system"`. In system mode the
#' library reads the theme from the attribute named by `themeAttrDetect`, which
#' defaults to `"html[data-theme]"`. Shiny apps using \pkg{bslib} should set
#' `themeAttrDetect = "html[data-bs-theme]"` to follow the app theme.
#'
#' @return An object of class `htmlwidget`.
#'
#' @examples
#' # Basic calendar with default settings
#' VanillaCalendar()
#'
#' # Calendar with custom options
#' VanillaCalendar(
#'   options = list(
#'     type = "default",
#'     locale = "en",
#'     selectionDatesMode = "multiple",
#'     selectedDates = Sys.Date(),
#'     selectedTheme = "light"
#'   ),
#'   width = "500px",
#'   height = "400px"
#' )
#'
#' # Date picker attached to a text input
#' VanillaCalendar(
#'   options = list(inputMode = TRUE, selectionDatesMode = "single"),
#'   height = "auto"
#' )
#'
#' @seealso [VanillaCalendarProxy()] to update a calendar in place from Shiny.
#'
#' @import htmlwidgets
#'
#' @export
VanillaCalendar <- function(options = list(), width = NULL, height = NULL,
                            elementId = NULL) {

  # forward options using x
  x <- list(
    options = .vc_fix(options)
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
#'   string and have \code{'px'} appended. Use \code{height = 'auto'} with
#'   \code{inputMode = TRUE}.
#' @param expr An expression that generates a VanillaCalendar
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @return `VanillaCalendarOutput()` returns a Shiny output element;
#'   `renderVanillaCalendar()` returns a Shiny render function.
#'
#' @examples
#' # Only run examples in interactive R sessions
#' if (interactive()) {
#'   library(shiny)
#'   library(VanillaCalendar)
#'
#'   ui <- fluidPage(
#'     VanillaCalendarOutput("calendar"),
#'     verbatimTextOutput("dates")
#'   )
#'
#'   server <- function(input, output) {
#'     output$calendar <- renderVanillaCalendar({
#'       VanillaCalendar(
#'         options = list(
#'           type = "default",
#'           locale = "en",
#'           selectionDatesMode = "multiple"
#'         )
#'       )
#'     })
#'     output$dates <- renderPrint(input$calendar_selected)
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @name VanillaCalendar-shiny
#'
#' @export
VanillaCalendarOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'VanillaCalendar', width, height, package = 'VanillaCalendar')
}

#' @rdname VanillaCalendar-shiny
#' @export
renderVanillaCalendar <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, VanillaCalendarOutput, env, quoted = TRUE)
}
