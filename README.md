# VanillaCalendar

An `htmlwidget` bringing [Vanilla Calendar Pro](https://vanilla-calendar.pro/) to
R and Shiny — a modern, dependency-free calendar and date picker, configurable
from R.

<!-- SCREENSHOT: drop a screenshot of the widget here as man/figures/calendar.png -->

## Install

```r
remotes::install_github("ESCRI11/vanilla-calendar-r")
```

## Use

```r
library(VanillaCalendar)

VanillaCalendar(options = list())
```

Any [Vanilla Calendar Pro option](https://vanilla-calendar.pro/docs/reference/additionally/settings)
can be passed through as a nested list:

```r
VanillaCalendar(
  options = list(
    type = "default",
    settings = list(
      lang = "en",
      selection = list(day = "single"),
      visibility = list(theme = "light")
    )
  ),
  width = "500px",
  height = "400px"
)
```

## In Shiny

```r
ui <- fluidPage(
  VanillaCalendarOutput("cal")
)

server <- function(input, output) {
  output$cal <- renderVanillaCalendar(
    VanillaCalendar(options = list(settings = list(selection = list(day = "multiple"))))
  )
}
```

Bundles Vanilla Calendar Pro 2.9.3. GPL (>= 3).
