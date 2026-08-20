# Changelog

## VanillaCalendar 2.0.0

Upgrade to Vanilla Calendar Pro 3.2.0, whose options are flat rather
than nested. This is a breaking change.

### Breaking changes

- The bundled library moves from 2.9.3 to 3.2.0. Options are no longer
  nested under `settings`: `settings$lang` is now `locale`,
  `settings$selection$day` is now `selectionDatesMode`, and
  `settings$visibility$theme` is now `selectedTheme`. See the [upstream
  reference](https://vanilla-calendar.pro/docs/reference/additionally/settings).
  Unknown option names now raise a warning instead of being silently
  ignored.
- `input$<id>_selected` is now a `Date` vector rather than a character
  vector, and is `Date(0)` rather than
  [`list()`](https://rdrr.io/r/base/list.html) when nothing is selected.
- `input$<id>_selected_month` is now 1-12 rather than the JavaScript
  0-11.
- `input$<id>_selected_arrow` is renamed to `input$<id>_displayed` and
  is a `Date` (the first day of the displayed month) rather than an
  unpadded string.
- [`VanillaCalendarOutput()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md)
  defaults to `width = "100%"` rather than `"1000px"`.

### New features

- [`VanillaCalendarProxy()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md)
  with
  [`vcSet()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcUpdate()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcShow()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcHide()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md)
  and
  [`vcDestroy()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md)
  change a rendered calendar in place from the Shiny server, without
  re-rendering it.
- `inputMode = TRUE` renders a text input with a popup calendar.
- New Shiny inputs: `input$<id>_time` (time selection),
  `input$<id>_week` (week number clicks) and `input$<id>_ready`
  (calendar initialised).
- `Date` and `POSIXct` values in `options` are converted to the
  `"YYYY-MM-DD"` strings the library expects, and options that must be
  JSON arrays are boxed, so `selectedDates = Sys.Date()` works.
- `options` defaults to [`list()`](https://rdrr.io/r/base/list.html), so
  [`VanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar.md)
  renders a calendar.
- Callbacks supplied with
  [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html) now
  run in addition to the built-in Shiny handlers rather than replacing
  them.

### Bug fixes

- Clicking a date outside Shiny (RStudio viewer, R Markdown) no longer
  throws `Shiny is not defined`.
- Re-rendering a calendar destroys the previous instance instead of
  leaving stale event handlers behind.
- Repeated identical selections are sent to Shiny with event priority,
  so they are no longer swallowed by deduplication.

## VanillaCalendar 1.0.0

- First release, bundling Vanilla Calendar Pro 2.9.3.
