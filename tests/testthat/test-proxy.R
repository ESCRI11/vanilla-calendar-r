# The proxy is only reachable from a Shiny session, so the whole file goes
# when Shiny is not installed.
skip_if_not_installed("shiny")

fake_session <- function() {
  sent <- list()
  list(
    ns = function(id) id,
    sendCustomMessage = function(type, message) {
      sent[[length(sent) + 1]] <<- list(type = type, message = message)
      invisible(TRUE)
    },
    messages = function() sent
  )
}

test_that("the proxy needs a session", {
  expect_error(VanillaCalendarProxy("cal", session = NULL), "Shiny session")
})

test_that("the proxy namespaces the id", {
  session <- fake_session()
  session$ns <- function(id) paste0("mod-", id)
  proxy <- VanillaCalendarProxy("cal", session = session)
  expect_s3_class(proxy, "VanillaCalendarProxy")
  expect_identical(proxy$id, "mod-cal")
})

test_that("vcSet sends coerced options", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcSet(proxy, list(selectedDates = as.Date("2026-01-01")))

  msg <- session$messages()[[1]]
  expect_identical(msg$type, "VanillaCalendar-call")
  expect_identical(msg$message$id, "cal")
  expect_identical(msg$message$method, "set")
  expect_equal(msg$message$args[[1]]$selectedDates, list("2026-01-01"))
})

test_that("vcSet warns on unknown options, like the constructor", {
  proxy <- VanillaCalendarProxy("cal", session = fake_session())
  expect_warning(vcSet(proxy, list(nope = 1)), "Unknown Vanilla Calendar option")
})

test_that("reset is passed through, and verbs that take nothing send nothing", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcSet(proxy, list(locale = "fr"), reset = list(dates = TRUE))
  vcShow(proxy)

  msgs <- session$messages()
  expect_length(msgs[[1]]$message$args, 2)      # options, then the reset spec
  expect_true(msgs[[1]]$message$args[[2]]$dates)
  expect_true(msgs[[1]]$message$args[[2]]$locale)  # locale is being set
  expect_length(msgs[[2]]$message$args, 0)
})

test_that("every proxy verb sends its method name", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcUpdate(proxy)
  vcShow(proxy)
  vcHide(proxy)
  vcDestroy(proxy)

  methods <- vapply(session$messages(), function(m) m$message$method, character(1))
  expect_identical(methods, c("update", "show", "hide", "destroy"))
})

test_that("proxy calls return the proxy invisibly for piping", {
  proxy <- VanillaCalendarProxy("cal", session = fake_session())
  expect_invisible(vcShow(proxy))
  expect_identical(vcShow(proxy), proxy)
})

test_that("proxy verbs reject objects that are not proxies", {
  expect_error(vcShow("cal"), "must be a VanillaCalendarProxy")
  expect_error(vcSet(list(), list()), "must be a VanillaCalendarProxy")
})

test_that("the proxy explains itself when shiny is missing", {
  local_mocked_bindings(requireNamespace = function(...) FALSE, .package = "base")
  expect_error(VanillaCalendarProxy("cal", session = fake_session()),
               "requires the 'shiny' package")
})

test_that("only the parts being set are reset", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcSet(proxy, list(selectedTheme = "dark"))
  reset <- session$messages()[[1]]$message$args[[2]]
  expect_false(any(unlist(reset)))   # a theme change must not clear the selection
  expect_setequal(names(reset), c("year", "month", "dates", "time", "locale"))

  vcSet(proxy, list(selectedDates = as.Date("2026-01-01")))
  reset <- session$messages()[[2]]$message$args[[2]]
  expect_true(reset$dates)           # ... but new dates have to be applied
  expect_false(reset$month)
})

test_that("an explicit reset wins over the derived one", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcSet(proxy, list(selectedTheme = "dark"), reset = list(dates = TRUE))
  reset <- session$messages()[[1]]$message$args[[2]]
  expect_true(reset$dates)
  expect_false(reset$month)
})

test_that("vcUpdate() keeps the live state unless told otherwise", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  vcUpdate(proxy)
  expect_false(any(unlist(session$messages()[[1]]$message$args[[1]])))

  vcUpdate(proxy, reset = list(time = TRUE))
  expect_true(session$messages()[[2]]$message$args[[1]]$time)
})

test_that("callbacks are refused rather than sent as dead strings", {
  session <- fake_session()
  proxy <- VanillaCalendarProxy("cal", session = session)

  expect_warning(
    vcSet(proxy, list(selectedTheme = "dark",
                      onClickDate = htmlwidgets::JS("function(c) {}"))),
    "cannot be sent through a proxy"
  )
  sent <- session$messages()[[1]]$message$args[[1]]
  expect_null(sent$onClickDate)
  expect_identical(sent$selectedTheme, "dark")
})
