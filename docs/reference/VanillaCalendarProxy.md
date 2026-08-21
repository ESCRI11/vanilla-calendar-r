# Update a calendar in place from Shiny

`VanillaCalendarProxy()` creates a handle to a calendar that is already
rendered, so that it can be changed without re-rendering it — the
calendar keeps its position, focus and selection instead of flickering
back to its initial state. The methods map onto the [Calendar instance
methods](https://vanilla-calendar.pro/docs/reference/methods) of Vanilla
Calendar Pro.

`vcSet()` applies new options to the calendar.

`vcUpdate()` re-renders the calendar with its current options.

`vcShow()` and `vcHide()` show and hide a popup calendar in input mode.

`vcDestroy()` removes the calendar from the page.

## Usage

``` r
VanillaCalendarProxy(id, session = shiny::getDefaultReactiveDomain())

vcSet(proxy, options, reset = NULL)

vcUpdate(proxy, reset = NULL)

vcShow(proxy)

vcHide(proxy)

vcDestroy(proxy)
```

## Arguments

- id:

  The output id of the calendar, as used in
  [`VanillaCalendarOutput()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md).

- session:

  The Shiny session object.

- proxy:

  A `VanillaCalendarProxy` object.

- options:

  A named list of options to apply, handled exactly as in
  [`VanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar.md).

- reset:

  Optional named list overriding which parts of the calendar are reset
  to their option values, with any of the logical entries `year`,
  `month`, `dates`, `time` and `locale`. By default only the parts you
  are actually setting are reset, so
  `vcSet(proxy, list(selectedTheme = "dark"))` leaves the user's
  selection and the displayed month alone. Pass `list(dates = TRUE)` to
  clear a selection you are not replacing.

## Value

The proxy object, invisibly, so calls can be piped.

## Examples

``` r
if (interactive()) {
  library(shiny)
  library(VanillaCalendar)

  ui <- fluidPage(
    selectInput("theme", "Theme", c("light", "dark")),
    actionButton("clear", "Clear selection"),
    VanillaCalendarOutput("cal")
  )

  server <- function(input, output, session) {
    output$cal <- renderVanillaCalendar(
      VanillaCalendar(list(selectionDatesMode = "multiple"))
    )

    observeEvent(input$theme, {
      vcSet(VanillaCalendarProxy("cal"), list(selectedTheme = input$theme))
    })

    observeEvent(input$clear, {
      vcSet(VanillaCalendarProxy("cal"), list(selectedDates = list()),
            reset = list(dates = TRUE))
    })
  }

  shinyApp(ui, server)
}
```
