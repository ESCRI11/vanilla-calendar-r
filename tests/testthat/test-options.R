test_that("array options are boxed so a single value stays a JSON array", {
  fixed <- .vc_fix(list(selectedDates = "2026-01-01"))
  expect_type(fixed$selectedDates, "list")
  expect_length(fixed$selectedDates, 1)

  json <- as.character(htmlwidgets:::toJSON2(fixed))
  expect_match(json, '"selectedDates":\\["2026-01-01"\\]')
})

test_that("every array option is boxed", {
  for (opt in .vc_array_options) {
    fixed <- .vc_fix(stats::setNames(list(1), opt))
    expect_type(fixed[[opt]], "list")
  }
})

test_that("longer array options survive unchanged", {
  fixed <- .vc_fix(list(disableWeekdays = c(0, 6)))
  expect_equal(fixed$disableWeekdays, list(0, 6))
  expect_match(as.character(htmlwidgets:::toJSON2(fixed)),
               '"disableWeekdays":\\[0,6\\]')
})

test_that("Date and POSIXct become YYYY-MM-DD strings", {
  fixed <- .vc_fix(list(
    dateMin = as.Date("2026-01-01"),
    dateMax = as.POSIXct("2026-12-31 10:00:00", tz = "UTC"),
    selectedDates = as.Date(c("2026-01-01", "2026-01-02"))
  ))
  expect_identical(fixed$dateMin, "2026-01-01")
  expect_identical(fixed$dateMax, "2026-12-31")
  expect_equal(fixed$selectedDates, list("2026-01-01", "2026-01-02"))

  json <- as.character(htmlwidgets:::toJSON2(fixed))
  expect_match(json, '"dateMax":"2026-12-31"')
  expect_false(grepl("T10:00", json, fixed = TRUE))
})

test_that("non-date options are left alone", {
  fixed <- .vc_fix(list(type = "month", displayMonthsCount = 2,
                        enableWeekNumbers = TRUE))
  expect_identical(fixed$type, "month")
  expect_identical(fixed$displayMonthsCount, 2)
  expect_true(fixed$enableWeekNumbers)
})

test_that("nested list options round-trip", {
  locale <- list(months = list(long = month.name), weekdays = list(short = LETTERS[1:7]))
  fixed <- .vc_fix(list(locale = locale))
  expect_identical(fixed$locale, locale)
  expect_match(as.character(htmlwidgets:::toJSON2(fixed)), '"months":\\{"long":\\[')
})

test_that("unknown option names warn but are passed through", {
  expect_warning(fixed <- .vc_fix(list(selectionDateMode = "single")),
                 "Unknown Vanilla Calendar option")
  expect_identical(fixed$selectionDateMode, "single")
})

test_that("known option names do not warn", {
  expect_no_warning(.vc_fix(list(type = "default", locale = "en")))
})

test_that("the option name list matches the bundled library version", {
  # A guard against forgetting to regenerate .vc_option_names on a JS upgrade.
  expect_true(all(c("inputMode", "selectionDatesMode", "selectedTheme",
                    "onChangeTime", "themeAttrDetect") %in% .vc_option_names))
  expect_false("settings" %in% .vc_option_names)  # the v2 nesting is gone
  expect_true(all(.vc_array_options %in% .vc_option_names))
})

test_that("empty and NULL options are accepted", {
  expect_identical(.vc_fix(list()), list())
  expect_identical(.vc_fix(NULL), list())
})

test_that("malformed options error", {
  expect_error(.vc_fix("single"), "must be a list")
  expect_error(.vc_fix(list("single")), "named list")
})
