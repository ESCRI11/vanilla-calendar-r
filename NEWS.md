# VanillaCalendar 2.0.1

Fixes found by auditing the 2.0.0 release against the library it wraps.

* Re-rendering a calendar left it detached from the page: the calendar
  disappeared for the rest of the session and every later proxy call silently
  did nothing. The library's `destroy()` replaces the widget element with a
  clone of it, which the widget now puts back. `vcDestroy()` followed by a
  re-render works too.
* `vcSet()` and `vcUpdate()` reset the selection, displayed month, year, time
  and locale on every call, because that is the library's default. They now
  reset only the parts you are actually setting, which is what the
  documentation always claimed: changing the theme no longer clears the user's
  dates. Pass `reset` to clear something you are not setting.
* `positionToInput = "auto"` (and `"left"`, `"center"`, `"right"`) was wrapped
  in an array, which the library does not accept, leaving popups positioned at
  `NaN`. Only the two-element form is an array.
* `input$<id>_displayed` was only updated by the arrows, so it went stale and
  reported the wrong month once the month or year picker was used.
* `vcSet()` now warns when passed an `htmlwidgets::JS()` callback instead of
  silently sending it as a dead string, which also disabled the matching Shiny
  input.
* `input$<id>_ready` fires again after a re-render.

# VanillaCalendar 2.0.0

Upgrade to Vanilla Calendar Pro 3.2.0, whose options are flat rather than
nested. This is a breaking change.

## Breaking changes

* The bundled library moves from 2.9.3 to 3.2.0. Options are no longer nested
  under `settings`: `settings$lang` is now `locale`, `settings$selection$day` is
  now `selectionDatesMode`, and `settings$visibility$theme` is now
  `selectedTheme`. See the
  [upstream reference](https://vanilla-calendar.pro/docs/reference/additionally/settings).
  Unknown option names now raise a warning instead of being silently ignored.
* `input$<id>_selected` is now a `Date` vector rather than a character vector,
  and is `Date(0)` rather than `list()` when nothing is selected.
* `input$<id>_selected_month` is now 1-12 rather than the JavaScript 0-11.
* `input$<id>_selected_arrow` is renamed to `input$<id>_displayed` and is a
  `Date` (the first day of the displayed month) rather than an unpadded string.
* `VanillaCalendarOutput()` defaults to `width = "100%"` rather than
  `"1000px"`.

## New features

* `VanillaCalendarProxy()` with `vcSet()`, `vcUpdate()`, `vcShow()`,
  `vcHide()` and `vcDestroy()` change a rendered calendar in place from the
  Shiny server, without re-rendering it.
* `inputMode = TRUE` renders a text input with a popup calendar.
* New Shiny inputs: `input$<id>_time` (time selection), `input$<id>_week`
  (week number clicks) and `input$<id>_ready` (calendar initialised).
* `Date` and `POSIXct` values in `options` are converted to the `"YYYY-MM-DD"`
  strings the library expects, and options that must be JSON arrays are boxed,
  so `selectedDates = Sys.Date()` works.
* `options` defaults to `list()`, so `VanillaCalendar()` renders a calendar.
* Callbacks supplied with `htmlwidgets::JS()` now run in addition to the
  built-in Shiny handlers rather than replacing them.

## Bug fixes

* Clicking a date outside Shiny (RStudio viewer, R Markdown) no longer throws
  `Shiny is not defined`.
* Re-rendering a calendar destroys the previous instance instead of leaving
  stale event handlers behind.
* Repeated identical selections are sent to Shiny with event priority, so they
  are no longer swallowed by deduplication.

# VanillaCalendar 1.0.0

* First release, bundling Vanilla Calendar Pro 2.9.3.
