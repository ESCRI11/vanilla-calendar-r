test_that("the date input handler is registered on load", {
  skip_if_not_installed("shiny")
  expect_true("VanillaCalendar.dates" %in% shiny:::inputHandlers$keys())
})

test_that("the handler converts javascript dates to a Date vector", {
  skip_if_not_installed("shiny")
  handler <- .vc_dates_handler

  expect_identical(handler(list("2026-01-01", "2026-01-02"), NULL, "x"),
                   as.Date(c("2026-01-01", "2026-01-02")))
  expect_identical(handler(list("2026-01-01"), NULL, "x"), as.Date("2026-01-01"))
})

test_that("an empty selection becomes Date(0), not an error", {
  skip_if_not_installed("shiny")
  handler <- .vc_dates_handler

  empty <- handler(list(), NULL, "x")
  expect_s3_class(empty, "Date")
  expect_length(empty, 0)
  expect_length(handler(NULL, NULL, "x"), 0)
})

test_that("the registered handler is the package handler", {
  skip_if_not_installed("shiny")
  expect_identical(shiny:::inputHandlers$get("VanillaCalendar.dates"),
                   .vc_dates_handler)
})
