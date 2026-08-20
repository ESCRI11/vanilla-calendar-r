# The smallest app that does something useful. Run with:
#   shiny::runApp(system.file("examples/minimal", package = "VanillaCalendar"))
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
