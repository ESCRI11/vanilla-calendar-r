# Test app exercising every JS -> R path of the widget.
library(shiny)
library(VanillaCalendar)

ui <- fluidPage(
  VanillaCalendarOutput("cal", height = "500px"),
  VanillaCalendarOutput("picker", height = "auto"),
  actionButton("dark", "Dark"),
  actionButton("rerender", "Re-render"),
  actionButton("destroy", "Destroy"),
  actionButton("clear", "Clear"),
  actionButton("hide", "Hide picker"),
  verbatimTextOutput("out_class"),
  verbatimTextOutput("out_dates"),
  verbatimTextOutput("out_month"),
  verbatimTextOutput("out_year"),
  verbatimTextOutput("out_displayed"),
  verbatimTextOutput("out_time"),
  verbatimTextOutput("out_week"),
  verbatimTextOutput("out_ready"),
  verbatimTextOutput("out_custom")
)

server <- function(input, output, session) {
  output$cal <- renderVanillaCalendar({
    input$rerender  # a reactive dependency, so the block can be re-run
    VanillaCalendar(list(
      locale = "en",
      selectionDatesMode = "multiple",
      selectionTimeMode = 24,
      enableWeekNumbers = TRUE,
      selectedTheme = "light",
      # a user callback must not disable the built-in Shiny input
      onClickDate = htmlwidgets::JS(
        "function(self) { Shiny.setInputValue('custom_fired', true); }"
      )
    ))
  })

  output$picker <- renderVanillaCalendar(
    VanillaCalendar(list(inputMode = TRUE, selectionDatesMode = "single"),
                    height = "auto")
  )

  observeEvent(input$dark, {
    vcSet(VanillaCalendarProxy("cal"), list(selectedTheme = "dark"))
  })
  observeEvent(input$clear, {
    vcSet(VanillaCalendarProxy("cal"), list(selectedDates = list()),
          reset = list(dates = TRUE))
  })
  observeEvent(input$hide, {
    vcHide(VanillaCalendarProxy("picker"))
  })
  observeEvent(input$destroy, {
    vcDestroy(VanillaCalendarProxy("cal"))
  })

  output$out_class <- renderText(paste(class(input$cal_selected), collapse = "/"))
  output$out_dates <- renderText(paste(format(input$cal_selected), collapse = ","))
  output$out_month <- renderText(as.character(input$cal_selected_month))
  output$out_year <- renderText(as.character(input$cal_selected_year))
  output$out_displayed <- renderText(format(input$cal_displayed))
  output$out_time <- renderText(input$cal_time)
  output$out_week <- renderText(paste(input$cal_week$week, input$cal_week$year))
  output$out_ready <- renderText(as.character(isTRUE(input$cal_ready)))
  output$out_custom <- renderText(as.character(isTRUE(input$custom_fired)))
}

shinyApp(ui, server)
