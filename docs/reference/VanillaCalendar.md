# Vanilla Calendar Widget

Creates a [Vanilla Calendar Pro](https://vanilla-calendar.pro/) calendar
or date picker for use in R, R Markdown and Shiny applications.

## Usage

``` r
VanillaCalendar(
  options = list(),
  width = NULL,
  height = NULL,
  elementId = NULL
)
```

## Arguments

- options:

  A named list of Vanilla Calendar Pro options, passed to the JavaScript
  library. Every option documented in the [upstream
  reference](https://vanilla-calendar.pro/docs/reference/additionally/settings)
  is accepted; names are validated against the bundled library version
  and unknown names raise a warning. `Date` and `POSIXct` values are
  converted to the `"YYYY-MM-DD"` strings the library expects, and
  options that must be arrays (such as `selectedDates`) are boxed for
  you, so a single date works. JavaScript callbacks can be supplied with
  [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html);
  they run in addition to, not instead of, the Shiny inputs described
  below. Note that options keep the library's own conventions, so
  `selectedMonth` counts months from 0 (`11` is December) even though
  `input$<id>_selected_month` is reported to R as 1-12.

- width, height:

  Must be a valid CSS unit (like `'100\%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- elementId:

  An optional ID for the widget element.

## Value

An object of class `htmlwidget`.

## Shiny inputs

When rendered in Shiny, the widget reports its state back to the server.
For an output with id `"cal"`:

- `input$cal_selected`:

  A `Date` vector of the selected dates (length 0 when nothing is
  selected).

- `input$cal_selected_month`:

  Selected month, 1-12.

- `input$cal_selected_year`:

  Selected year.

- `input$cal_displayed`:

  First day of the displayed month, as a `Date`, updated when the user
  clicks the arrows.

- `input$cal_time`:

  Selected time as a string, e.g. `"14:30"`, when `selectionTimeMode` is
  enabled.

- `input$cal_week`:

  A list with `week` and `year`, when `enableWeekNumbers` is enabled and
  a week number is clicked.

- `input$cal_ready`:

  `TRUE` once the calendar has initialised.

## Input mode

With `options = list(inputMode = TRUE)` the widget renders a text input
and shows the calendar as a popup, the behaviour documented under [input
mode](https://vanilla-calendar.pro/docs/reference/additionally/settings)
upstream. Pair it with `height = "auto"`.

## Theming

`selectedTheme` accepts `"light"`, `"dark"` or `"system"`. In system
mode the library reads the theme from the attribute named by
`themeAttrDetect`, which defaults to `"html[data-theme]"`. Shiny apps
using bslib should set `themeAttrDetect = "html[data-bs-theme]"` to
follow the app theme.

## See also

[`VanillaCalendarProxy()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md)
to update a calendar in place from Shiny.

## Examples

``` r
# Basic calendar with default settings
VanillaCalendar()

{"x":{"options":[]},"evals":[],"jsHooks":[]}
# Calendar with custom options
VanillaCalendar(
  options = list(
    type = "default",
    locale = "en",
    selectionDatesMode = "multiple",
    selectedDates = Sys.Date(),
    selectedTheme = "light"
  ),
  width = "500px",
  height = "400px"
)

{"x":{"options":{"type":"default","locale":"en","selectionDatesMode":"multiple","selectedDates":["2026-08-20"],"selectedTheme":"light"}},"evals":[],"jsHooks":[]}
# Date picker attached to a text input
VanillaCalendar(
  options = list(inputMode = TRUE, selectionDatesMode = "single"),
  height = "auto"
)

{"x":{"options":{"inputMode":true,"selectionDatesMode":"single"}},"evals":[],"jsHooks":[]}
```
