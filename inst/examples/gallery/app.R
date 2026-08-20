# A tour of what VanillaCalendar can do. Run with:
#   shiny::runApp(system.file("examples/gallery", package = "VanillaCalendar"))
library(shiny)
library(VanillaCalendar)

ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { font-family: system-ui, sans-serif; padding: 24px; max-width: 1100px; }
    h4 { margin-top: 0; font-weight: 600; }
    .panel { border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px;
             margin-bottom: 24px; background: #fff; }
    .readout { font-family: ui-monospace, monospace; background: #f8fafc;
               border-radius: 8px; padding: 10px 14px; margin-top: 12px; }
  "))),
  titlePanel("VanillaCalendar"),

  div(class = "panel",
      h4("Range selection"),
      VanillaCalendarOutput("range", height = "380px"),
      div(class = "readout", textOutput("range_out"))),

  div(class = "panel",
      h4("Date picker (input mode)"),
      VanillaCalendarOutput("picker", height = "auto"),
      div(class = "readout", textOutput("picker_out"))),

  div(class = "panel",
      h4("Date and time"),
      VanillaCalendarOutput("time", height = "440px"),
      div(class = "readout", textOutput("time_out"))),

  div(class = "panel",
      h4("Themes, changed in place from the server"),
      radioButtons("theme", NULL, c("light", "dark"), inline = TRUE),
      VanillaCalendarOutput("themed", height = "380px")),

  div(class = "panel",
      h4("Two months, weekends and holidays"),
      VanillaCalendarOutput("months", height = "400px"))
)

server <- function(input, output, session) {

  output$range <- renderVanillaCalendar(
    VanillaCalendar(list(
      locale = "en",
      selectionDatesMode = "multiple-ranged",
      selectedTheme = "light"
    ))
  )
  output$range_out <- renderText({
    dates <- input$range_selected
    if (length(dates) == 0) "Nothing selected yet."
    else paste0(length(dates), " date(s): ", paste(format(dates), collapse = " to "))
  })

  output$picker <- renderVanillaCalendar(
    VanillaCalendar(list(
      inputMode = TRUE,
      selectionDatesMode = "single",
      selectedTheme = "light"
    ), height = "auto")
  )
  output$picker_out <- renderText({
    if (length(input$picker_selected) == 0) "Click the box to pick a date."
    else format(input$picker_selected, "%A, %d %B %Y")
  })

  output$time <- renderVanillaCalendar(
    VanillaCalendar(list(
      locale = "en",
      selectionTimeMode = 24,
      selectedTime = "09:00",
      selectedTheme = "light"
    ))
  )
  output$time_out <- renderText({
    paste("Date:", if (length(input$time_selected)) format(input$time_selected) else "-",
          " Time:", if (is.null(input$time_time)) "-" else input$time_time)
  })

  output$themed <- renderVanillaCalendar(
    VanillaCalendar(list(locale = "en", selectedTheme = "light"))
  )
  observeEvent(input$theme, {
    vcSet(VanillaCalendarProxy("themed"), list(selectedTheme = input$theme))
  }, ignoreInit = TRUE)

  year <- as.integer(format(Sys.Date(), "%Y"))
  output$months <- renderVanillaCalendar(
    VanillaCalendar(list(
      locale = "en",
      type = "multiple",
      displayMonthsCount = 2,
      displayDatesOutside = FALSE,
      selectionDatesMode = "multiple",
      selectedMonth = 11,  # library months are 0-11, so 11 is December
      selectedYear = year,
      selectedWeekends = c(0, 6),
      selectedHolidays = as.Date(paste0(c(year, year, year + 1),
                                        c("-12-25", "-12-26", "-01-01"))),
      selectedTheme = "light"
    ))
  )
}

shinyApp(ui, server)
