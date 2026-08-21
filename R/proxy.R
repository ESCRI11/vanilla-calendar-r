#' Update a calendar in place from Shiny
#'
#' `VanillaCalendarProxy()` creates a handle to a calendar that is already
#' rendered, so that it can be changed without re-rendering it — the calendar
#' keeps its position, focus and selection instead of flickering back to its
#' initial state. The methods map onto the
#' [Calendar instance methods](https://vanilla-calendar.pro/docs/reference/methods)
#' of Vanilla Calendar Pro.
#'
#' @param id The output id of the calendar, as used in
#'   [VanillaCalendarOutput()].
#' @param session The Shiny session object.
#' @param proxy A `VanillaCalendarProxy` object.
#' @param options A named list of options to apply, handled exactly as in
#'   [VanillaCalendar()].
#' @param reset Optional named list overriding which parts of the calendar are
#'   reset to their option values, with any of the logical entries `year`,
#'   `month`, `dates`, `time` and `locale`. By default only the parts you are
#'   actually setting are reset, so `vcSet(proxy, list(selectedTheme = "dark"))`
#'   leaves the user's selection and the displayed month alone. Pass
#'   `list(dates = TRUE)` to clear a selection you are not replacing.
#'
#' @return The proxy object, invisibly, so calls can be piped.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(VanillaCalendar)
#'
#'   ui <- fluidPage(
#'     selectInput("theme", "Theme", c("light", "dark")),
#'     actionButton("clear", "Clear selection"),
#'     VanillaCalendarOutput("cal")
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$cal <- renderVanillaCalendar(
#'       VanillaCalendar(list(selectionDatesMode = "multiple"))
#'     )
#'
#'     observeEvent(input$theme, {
#'       vcSet(VanillaCalendarProxy("cal"), list(selectedTheme = input$theme))
#'     })
#'
#'     observeEvent(input$clear, {
#'       vcSet(VanillaCalendarProxy("cal"), list(selectedDates = list()),
#'             reset = list(dates = TRUE))
#'     })
#'   }
#'
#'   shinyApp(ui, server)
#' }
#'
#' @name VanillaCalendarProxy
#' @export
VanillaCalendarProxy <- function(id, session = shiny::getDefaultReactiveDomain()) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("VanillaCalendarProxy() requires the 'shiny' package.", call. = FALSE)
  }
  if (is.null(session)) {
    stop("VanillaCalendarProxy() must be called from inside a Shiny session.",
         call. = FALSE)
  }
  structure(
    list(id = session$ns(id), session = session),
    class = "VanillaCalendarProxy"
  )
}

.vc_call <- function(proxy, method, ...) {
  if (!inherits(proxy, "VanillaCalendarProxy")) {
    stop("`proxy` must be a VanillaCalendarProxy object.", call. = FALSE)
  }
  proxy$session$sendCustomMessage(
    "VanillaCalendar-call",
    list(id = proxy$id, method = method,
         args = unname(Filter(Negate(is.null), list(...))))
  )
  invisible(proxy)
}

# The library resets the year, month, dates, time and locale to their option
# values unless told otherwise, which would throw away what the user has done.
# Reset only what this call is actually setting.
.vc_reset <- function(options, reset) {
  auto <- list(year = "selectedYear", month = "selectedMonth",
               dates = "selectedDates", time = "selectedTime", locale = "locale")
  auto <- lapply(auto, function(option) option %in% names(options))
  if (length(reset)) auto[names(reset)] <- reset
  auto
}

# Callbacks would arrive as plain strings: sendCustomMessage() has no
# equivalent of the widget payload's JS evaluation step.
.vc_check_js <- function(options) {
  js <- vapply(options, inherits, logical(1), "JS_EVAL")
  if (any(js)) {
    warning("JavaScript callbacks cannot be sent through a proxy; ",
            toString(names(options)[js]), " ignored. Set them on the calendar ",
            "with VanillaCalendar() instead.", call. = FALSE)
  }
  options[!js]
}

#' @rdname VanillaCalendarProxy
#' @description `vcSet()` applies new options to the calendar.
#' @export
vcSet <- function(proxy, options, reset = NULL) {
  options <- .vc_check_js(.vc_fix(options))
  .vc_call(proxy, "set", options, .vc_reset(options, reset))
}

#' @rdname VanillaCalendarProxy
#' @description `vcUpdate()` re-renders the calendar with its current options.
#' @export
vcUpdate <- function(proxy, reset = NULL) {
  .vc_call(proxy, "update", .vc_reset(list(), reset))
}

#' @rdname VanillaCalendarProxy
#' @description `vcShow()` and `vcHide()` show and hide a popup calendar in
#'   input mode.
#' @export
vcShow <- function(proxy) {
  .vc_call(proxy, "show")
}

#' @rdname VanillaCalendarProxy
#' @export
vcHide <- function(proxy) {
  .vc_call(proxy, "hide")
}

#' @rdname VanillaCalendarProxy
#' @description `vcDestroy()` removes the calendar from the page.
#' @export
vcDestroy <- function(proxy) {
  .vc_call(proxy, "destroy")
}
