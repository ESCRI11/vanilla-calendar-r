# End-to-end coverage of inst/htmlwidgets/VanillaCalendar.js: the JS -> Shiny
# inputs, the proxy message handler and input mode, driven in a real browser.
skip_on_cran()
skip_if_not_installed("shinytest2")
skip_if_not_installed("shiny")
skip_if(is.null(chromote::find_chrome()), "no chrome available")

app_dir <- testthat::test_path("apps/calendar")

click_dates <- function(app, indexes) {
  app$run_js(sprintf(
    "var d = document.querySelectorAll('#cal [data-vc-date-btn]'); %s",
    paste(sprintf("d[%d].click();", indexes), collapse = " ")
  ))
  app$wait_for_idle()
}

app <- shinytest2::AppDriver$new(app_dir, name = "calendar", load_timeout = 30000)
withr::defer(app$stop())

test_that("the calendar initialises and reports readiness", {
  app$wait_for_value(output = "out_ready")
  expect_identical(app$get_value(output = "out_ready"), "TRUE")
  expect_gt(app$get_js("document.querySelectorAll('#cal [data-vc-date-btn]').length"), 27)
})

test_that("clicking dates gives the server a Date vector", {
  click_dates(app, c(8, 10))

  expect_identical(app$get_value(output = "out_class"), "Date")
  dates <- strsplit(app$get_value(output = "out_dates"), ",")[[1]]
  expect_length(dates, 2)
  expect_false(anyNA(as.Date(dates)))
})

test_that("a user JS callback runs as well as the built-in input", {
  expect_identical(app$get_value(output = "out_custom"), "TRUE")
})

test_that("deselecting everything gives Date(0) rather than an error", {
  click_dates(app, c(8, 10))  # toggle the same two dates off
  expect_identical(app$get_value(output = "out_dates"), "")
  expect_identical(app$get_value(output = "out_class"), "Date")
})

test_that("the arrows report the displayed month as a Date", {
  before <- app$get_js("document.querySelector('#cal [data-vc=\"month\"]').innerText")
  app$run_js("document.querySelector('#cal [data-vc-arrow=\"next\"]').click()")
  app$wait_for_idle()

  displayed <- as.Date(app$get_value(output = "out_displayed"))
  expect_s3_class(displayed, "Date")
  expect_identical(format(displayed, "%d"), "01")
  after <- app$get_js("document.querySelector('#cal [data-vc=\"month\"]').innerText")
  expect_false(identical(before, after))
})

test_that("months arrive 1-indexed", {
  app$run_js("document.querySelector('#cal [data-vc=\"month\"]').click()")
  app$wait_for_idle()
  app$run_js("document.querySelectorAll('#cal [data-vc-months-month]')[0].click()")
  app$wait_for_idle()

  expect_identical(app$get_value(output = "out_month"), "1")  # January, not 0
})

test_that("years are reported", {
  app$run_js("document.querySelector('#cal [data-vc=\"year\"]').click()")
  app$wait_for_idle()
  app$run_js("document.querySelectorAll('#cal [data-vc-years-year]')[0].click()")
  app$wait_for_idle()

  expect_match(app$get_value(output = "out_year"), "^[0-9]{4}$")
})

test_that("time selection reaches the server", {
  app$run_js("
    var r = document.querySelector('#cal [data-vc-time-range=\"hour\"] input');
    r.value = 14;
    r.dispatchEvent(new Event('input', { bubbles: true }));
  ")
  app$wait_for_idle()

  expect_match(app$get_value(output = "out_time"), "^14:")
})

test_that("clicking a week number reports week and year", {
  app$run_js("document.querySelectorAll('#cal [data-vc-week-number]')[1].click()")
  app$wait_for_idle()

  week <- strsplit(app$get_value(output = "out_week"), " ")[[1]]
  expect_length(week, 2)
  expect_true(as.integer(week[1]) %in% 1:53)
})

test_that("the proxy changes a live calendar without re-rendering it", {
  expect_identical(app$get_js("document.getElementById('cal').dataset.vcTheme"), "light")
  # mark the live node: a re-render would replace it and lose the mark
  app$run_js("document.getElementById('cal').dataset.marker = 'kept'")

  app$click("dark")
  app$wait_for_idle()

  expect_identical(app$get_js("document.getElementById('cal').dataset.vcTheme"), "dark")
  expect_identical(app$get_js("document.getElementById('cal').dataset.marker"), "kept")
})

test_that("a proxy call keeps the selection and the displayed month", {
  click_dates(app, c(8, 10))
  before <- app$get_value(output = "out_dates")
  app$run_js("document.querySelector('#cal [data-vc-arrow=\"next\"]').click()")
  app$wait_for_idle()
  month_before <- app$get_js("document.querySelector('#cal [data-vc=\"month\"]').innerText")

  app$click("dark")   # vcSet(list(selectedTheme = ...)): touches nothing else
  app$wait_for_idle()

  expect_identical(app$get_value(output = "out_dates"), before)
  # the dates live in the month we scrolled away from, so ask the calendar itself
  expect_equal(
    app$get_js("HTMLWidgets.getInstance(document.getElementById('cal')).calendar.context.selectedDates.length"),
    2
  )
  expect_identical(
    app$get_js("document.querySelector('#cal [data-vc=\"month\"]').innerText"),
    month_before
  )
})

test_that("re-rendering leaves a working, addressable calendar", {
  app$click("rerender")
  app$wait_for_idle()

  expect_gt(app$get_js("document.querySelectorAll('#cal [data-vc-date-btn]').length"), 27)
  expect_true(app$get_js(
    "document.getElementById('cal') === document.querySelector('#cal[data-vc=calendar]')"))
  expect_true(app$get_js(
    "!!HTMLWidgets.getInstance(document.getElementById('cal'))"))

  # the calendar must still answer the server after being rebuilt
  app$click("dark")
  app$wait_for_idle()
  expect_identical(app$get_js("document.getElementById('cal').dataset.vcTheme"), "dark")

  # ... and still report clicks
  click_dates(app, c(9))
  expect_false(app$get_value(output = "out_dates") == "")
})

test_that("a destroyed calendar can be rendered again", {
  app$click("destroy")
  app$wait_for_idle()
  expect_equal(app$get_js("document.querySelectorAll('#cal [data-vc-date-btn]').length"), 0)

  app$click("rerender")
  app$wait_for_idle()
  expect_gt(app$get_js("document.querySelectorAll('#cal [data-vc-date-btn]').length"), 27)
})

test_that("the proxy can reset the selection", {
  click_dates(app, c(12))
  expect_false(app$get_value(output = "out_dates") == "")

  app$click("clear")
  app$wait_for_idle()
  expect_equal(
    app$get_js("document.querySelectorAll('#cal [data-vc-date-selected]').length"), 0
  )
})

test_that("input mode renders a text input with a popup calendar", {
  expect_identical(app$get_js("document.querySelector('#picker input').tagName"), "INPUT")

  # in input mode the popup is attached to the body, so reach it via the instance
  popup <- "HTMLWidgets.getInstance(document.getElementById('picker')).calendar.context.mainElement"

  app$run_js("document.querySelector('#picker input').click()")
  app$wait_for_idle()
  expect_gt(app$get_js(paste0(popup, ".querySelectorAll('[data-vc-date-btn]').length")), 27)
  expect_false(app$get_js(paste0(popup, ".hasAttribute('data-vc-calendar-hidden')")))

  app$click("hide")
  app$wait_for_idle()
  expect_true(app$get_js(paste0(popup, ".hasAttribute('data-vc-calendar-hidden')")))
})

test_that("picking a date in input mode fills the text box and the server", {
  popup <- "HTMLWidgets.getInstance(document.getElementById('picker')).calendar.context.mainElement"
  app$run_js("document.querySelector('#picker input').click()")
  app$wait_for_idle()
  app$run_js(paste0(popup, ".querySelectorAll('[data-vc-date-btn]')[10].click()"))
  app$wait_for_idle()

  expect_match(app$get_js("document.querySelector('#picker input').value"),
               "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
})
