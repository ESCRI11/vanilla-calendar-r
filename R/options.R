# Option names accepted by Vanilla Calendar Pro 3.2.0 (upstream `options.d.ts`).
# Regenerate when the bundled library is upgraded.
.vc_option_names <- c(
  "dateMax", "dateMin", "dateToday", "disableAllDates", "disableDates",
  "disableDatesGaps", "disableDatesPast", "disableToday", "disableWeekdays",
  "displayDateMax", "displayDateMin", "displayDatesOutside",
  "displayDisabledDates", "displayMonthsCount", "enableDateToggle",
  "enableDates", "enableEdgeDatesOnly", "enableJumpToSelectedDate",
  "enableMonthChangeOnDayClick", "enableWeekNumbers", "firstWeekday",
  "inputMode", "labels", "layouts", "locale", "monthsToSwitch",
  "onChangeTime", "onChangeToInput", "onClickArrow", "onClickDate",
  "onClickMonth", "onClickTitle", "onClickWeekDay", "onClickWeekNumber",
  "onClickYear", "onCreateDateEls", "onCreateDateRangeTooltip",
  "onCreateMonthEls", "onCreateYearEls", "onDestroy", "onHide", "onInit",
  "onShow", "onUpdate", "openOnFocus", "popups", "positionToInput",
  "sanitizerHTML", "selectedDates", "selectedHolidays", "selectedMonth",
  "selectedTheme", "selectedTime", "selectedWeekends", "selectedYear",
  "selectionDatesMode", "selectionMonthsMode", "selectionTimeMode",
  "selectionYearsMode", "styles", "themeAttrDetect", "timeControls",
  "timeMaxHour", "timeMaxMinute", "timeMinHour", "timeMinMinute",
  "timeStepHour", "timeStepMinute", "type"
)

# Options the library reads with array methods: a length-1 R vector must still
# serialise as a JSON array, or the library throws.
.vc_array_options <- c(
  "selectedDates", "disableDates", "enableDates", "selectedHolidays",
  "disableWeekdays", "selectedWeekends"
)

# Dates the library wants as "YYYY-MM-DD" strings, never ISO8601 timestamps.
.vc_format_dates <- function(v) {
  if (inherits(v, c("Date", "POSIXt"))) format(v, "%Y-%m-%d") else v
}

.vc_fix <- function(options) {
  if (is.null(options)) return(list())
  if (!is.list(options)) stop("`options` must be a list.", call. = FALSE)
  if (length(options) && is.null(names(options))) {
    stop("`options` must be a named list.", call. = FALSE)
  }

  unknown <- setdiff(names(options), .vc_option_names)
  if (length(unknown)) {
    warning("Unknown Vanilla Calendar option(s) ignored by the calendar: ",
            toString(unknown), call. = FALSE)
  }

  options[] <- lapply(options, .vc_format_dates)
  for (k in intersect(names(options), .vc_array_options)) {
    options[[k]] <- as.list(options[[k]])
  }
  options
}

# Turns the JavaScript "YYYY-MM-DD" strings into a Date vector, and an empty
# selection into Date(0) rather than list().
.vc_dates_handler <- function(x, session, name) {
  x <- unlist(x, use.names = FALSE)
  if (is.null(x)) return(as.Date(character(0)))
  as.Date(x)
}

.onLoad <- function(libname, pkgname) {
  if (requireNamespace("shiny", quietly = TRUE)) {
    shiny::registerInputHandler("VanillaCalendar.dates", .vc_dates_handler,
                                force = TRUE)
  }
}
