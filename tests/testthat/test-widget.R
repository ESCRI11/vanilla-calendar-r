test_that("VanillaCalendar() works with no arguments", {
  w <- VanillaCalendar()
  expect_s3_class(w, "htmlwidget")
  expect_s3_class(w, "VanillaCalendar")
  expect_identical(w$x$options, list())
})

test_that("options reach the widget payload, coerced", {
  w <- VanillaCalendar(list(selectedDates = as.Date("2026-01-01")))
  expect_equal(w$x$options$selectedDates, list("2026-01-01"))
})

test_that("width, height and elementId are forwarded", {
  w <- VanillaCalendar(list(), width = "500px", height = "400px",
                       elementId = "cal1")
  expect_identical(w$width, "500px")
  expect_identical(w$height, "400px")
  expect_identical(w$elementId, "cal1")
})

test_that("the widget declares the bundled dependency", {
  w <- VanillaCalendar()
  html <- as.character(htmltools::as.tags(w))
  expect_match(html, "VanillaCalendar")
})

test_that("the calendar renders to HTML without a Shiny session", {
  file <- tempfile(fileext = ".html")
  on.exit(unlink(file), add = TRUE)
  htmlwidgets::saveWidget(VanillaCalendar(list(locale = "en")), file,
                          selfcontained = FALSE)
  expect_true(file.exists(file))
  expect_match(paste(readLines(file, warn = FALSE), collapse = ""),
               "vanilla-calendar.min.js")
})

test_that("Shiny output and render bindings have the expected shape", {
  skip_if_not_installed("shiny")
  out <- VanillaCalendarOutput("cal")
  expect_s3_class(out, "shiny.tag.list")
  expect_match(as.character(out), 'id="cal"')
  expect_match(as.character(out), "width:100%")

  r <- renderVanillaCalendar(VanillaCalendar())
  expect_type(r, "closure")
})

test_that("bundled assets and the dependency file agree", {
  yaml <- readLines(system.file("htmlwidgets/VanillaCalendar.yaml",
                               package = "VanillaCalendar"), warn = FALSE)
  expect_true(any(grepl("version: 3.2.0", yaml)))
  expect_true(any(grepl("VanillaCalendar-3.2.0", yaml)))

  lib <- system.file("htmlwidgets/lib/VanillaCalendar-3.2.0",
                     package = "VanillaCalendar")
  expect_true(all(c("vanilla-calendar.min.js", "vanilla-calendar.min.css",
                    "LICENSE") %in% list.files(lib)))
})

test_that("the widget javascript exposes the v3 API and the proxy handler", {
  js <- paste(readLines(system.file("htmlwidgets/VanillaCalendar.js",
                                    package = "VanillaCalendar"), warn = FALSE),
              collapse = "\n")
  expect_match(js, "VanillaCalendarPro.Calendar", fixed = TRUE)
  expect_match(js, "VanillaCalendar-call", fixed = TRUE)
  expect_match(js, "selectedMonth + 1", fixed = TRUE)  # 1-indexed months
  expect_match(js, "typeof Shiny === 'undefined'", fixed = TRUE)  # guarded
})
