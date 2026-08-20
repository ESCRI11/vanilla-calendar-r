# Shiny bindings for VanillaCalendar

Output and render functions for using VanillaCalendar within Shiny
applications and interactive Rmd documents.

## Usage

``` r
VanillaCalendarOutput(outputId, width = "100%", height = "400px")

renderVanillaCalendar(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  output variable to read from

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.
  Use `height = 'auto'` with `inputMode = TRUE`.

- expr:

  An expression that generates a VanillaCalendar

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Is `expr` a quoted expression (with
  [`quote()`](https://rdrr.io/r/base/substitute.html))? This is useful
  if you want to save an expression in a variable.

## Value

`VanillaCalendarOutput()` returns a Shiny output element;
`renderVanillaCalendar()` returns a Shiny render function.

## Examples

``` r
# Only run examples in interactive R sessions
if (interactive()) {
  library(shiny)
  library(VanillaCalendar)

  ui <- fluidPage(
    VanillaCalendarOutput("calendar"),
    verbatimTextOutput("dates")
  )

  server <- function(input, output) {
    output$calendar <- renderVanillaCalendar({
      VanillaCalendar(
        options = list(
          type = "default",
          locale = "en",
          selectionDatesMode = "multiple"
        )
      )
    })
    output$dates <- renderPrint(input$calendar_selected)
  }

  shinyApp(ui, server)
}
```
