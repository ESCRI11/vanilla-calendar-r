# VanillaCalendar in Shiny

The code here is not run when the vignette is built, because it needs a
running Shiny app. Both apps it draws on ship with the package, so you
can run them before writing anything yourself:

``` r
# the smallest useful app, reproduced in full below
shiny::runApp(system.file("examples/minimal", package = "VanillaCalendar"))

# a tour of everything else on this page
shiny::runApp(system.file("examples/gallery", package = "VanillaCalendar"))
```

## The smallest app that works

There are three steps, and they are the same three as for any
htmlwidget:

1.  `VanillaCalendarOutput("cal")` in the UI, to say where the calendar
    goes.
2.  [`renderVanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md)
    in the server, to build it.
3.  Read what the user picked from `input$cal_selected`.

That is the whole app:

``` r
library(shiny)
library(VanillaCalendar)

ui <- fluidPage(
  titlePanel("Pick a date"),
  VanillaCalendarOutput("cal", height = "400px"),
  textOutput("chosen")
)

server <- function(input, output) {
  output$cal <- renderVanillaCalendar(VanillaCalendar())
  output$chosen <- renderText({
    if (length(input$cal_selected) == 0) "Nothing picked yet."
    else format(input$cal_selected, "%A, %d %B %Y")
  })
}

shinyApp(ui, server)
```

Nothing above is specific to this widget except the two function names.
What the calendar *does* is decided by the options you pass, and the
structure stays as it is:

``` r
# let the user drag out a range
output$cal <- renderVanillaCalendar(
  VanillaCalendar(list(selectionDatesMode = "multiple-ranged"))
)

# or make it a text box with a popup, for a form
output$cal <- renderVanillaCalendar(
  VanillaCalendar(list(inputMode = TRUE), height = "auto")
)

# or add a time picker under the dates
output$cal <- renderVanillaCalendar(
  VanillaCalendar(list(selectionTimeMode = 24), height = "440px")
)
```

## Reading what the user did

The widget reports its state through inputs named after the output id.
For an output called `"cal"`:

| Input                      | Type                       | Set when                     |
|----------------------------|----------------------------|------------------------------|
| `input$cal_selected`       | `Date` vector              | A date is clicked            |
| `input$cal_selected_month` | integer, 1-12              | A month is chosen            |
| `input$cal_selected_year`  | integer                    | A year is chosen             |
| `input$cal_displayed`      | `Date`, first of the month | The arrows are used          |
| `input$cal_time`           | character, e.g. `"14:30"`  | The time changes             |
| `input$cal_week`           | list of `week` and `year`  | A week number is clicked     |
| `input$cal_ready`          | `TRUE`                     | The calendar has initialised |

`input$cal_selected` is always a `Date` vector, and is `Date(0)` — not
`NULL`, not [`list()`](https://rdrr.io/r/base/list.html) — when the user
has selected nothing. That means the obvious code works without guards:

``` r
output$summary <- renderText({
  dates <- input$cal_selected
  if (length(dates) == 0) return("Nothing selected.")
  paste(length(dates), "date(s), the first being", format(min(dates)))
})
```

![Selecting a range of dates and reading it in
R](../reference/figures/range-selection.gif)

Selecting a range of dates and reading it in R

Selections are sent with event priority, so clicking the same date
twice, or re-picking a date you had just cleared, reaches the server
both times rather than being swallowed as an unchanged value.

## A date picker instead of a calendar

Forms usually want a date field, not a permanent block of calendar. That
is `inputMode`:

``` r
VanillaCalendarOutput("when", height = "auto")

output$when <- renderVanillaCalendar(
  VanillaCalendar(list(inputMode = TRUE, selectionDatesMode = "single"),
                  height = "auto")
)
```

The widget renders a text box, opens the calendar as a popup when the
box is clicked, and writes the chosen date into it.
`input$when_selected` updates as usual.

![A popup date picker filling its text
box](../reference/figures/input-mode.gif)

A popup date picker filling its text box

Use `height = "auto"` for input mode, and `positionToInput` (`"auto"`,
`"bottom"`, `"top"`, `"left"`, `"right"`, or a pair such as
`c("bottom", "left")`) to say where the popup goes.

## Changing a calendar without re-rendering it

Re-running
[`renderVanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md)
builds a whole new calendar: the selection is lost, the displayed month
jumps back, and the widget visibly flickers. To change something about a
calendar that is already on the page, use a proxy.

``` r
observeEvent(input$theme, {
  vcSet(VanillaCalendarProxy("cal"), list(selectedTheme = input$theme))
})
```

![Switching the theme from the server, in
place](../reference/figures/themes.gif)

Switching the theme from the server, in place

The verbs map onto the library’s [instance
methods](https://vanilla-calendar.pro/docs/reference/additionally/methods):

``` r
proxy <- VanillaCalendarProxy("cal")

vcSet(proxy, list(dateMin = input$start))   # apply new options
vcUpdate(proxy)                             # re-render with current options
vcShow(proxy)                               # show a popup calendar
vcHide(proxy)                               # hide it again
vcDestroy(proxy)                            # remove it entirely
```

`reset` says what should be thrown away when the change is applied — any
of `year`, `month`, `dates`, `time`, `locale`:

``` r
# clear the selection as well as changing the options
vcSet(proxy, list(selectedDates = list()), reset = list(dates = TRUE))
```

Inside a Shiny module, build the proxy with the *unnamespaced* id; it
uses the session to work out the full one:

``` r
calendarServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$cal <- renderVanillaCalendar(VanillaCalendar())
    observeEvent(input$go, vcHide(VanillaCalendarProxy("cal")))
  })
}
```

## Reacting to another input

The two pieces together — options from R, applied by proxy — give the
common “end date cannot be before start date” behaviour without any
re-rendering:

``` r
server <- function(input, output, session) {
  output$start <- renderVanillaCalendar(
    VanillaCalendar(list(inputMode = TRUE), height = "auto")
  )
  output$end <- renderVanillaCalendar(
    VanillaCalendar(list(inputMode = TRUE), height = "auto")
  )

  observeEvent(input$start_selected, {
    vcSet(VanillaCalendarProxy("end"), list(dateMin = input$start_selected))
  })
}
```

## Dropping down to JavaScript

Any option that takes a function takes one here too, through
[`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html). Your
callback runs in addition to the built-in one, so the Shiny inputs above
keep working:

``` r
VanillaCalendar(list(
  selectionDatesMode = "multiple",
  onClickDate = htmlwidgets::JS(
    "function(self) { console.log(self.context.selectedDates); }"
  ),
  onCreateDateEls = htmlwidgets::JS(
    "function(self, dateEl) { dateEl.title = 'Custom tooltip'; }"
  )
))
```

The callback signatures, and the `self.context` fields they can read,
are in the [upstream
reference](https://vanilla-calendar.pro/docs/reference/additionally/settings).

## Theming with bslib

`selectedTheme = "system"` follows the page rather than a fixed choice,
reading the attribute named by `themeAttrDetect`. bslib writes
`data-bs-theme`, so:

``` r
VanillaCalendar(list(
  selectedTheme = "system",
  themeAttrDetect = "html[data-bs-theme]"
))
```
