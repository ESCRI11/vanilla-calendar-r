# Changelog

## VanillaCalendar 1.0.0

First release.

- [`VanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar.md)
  creates a calendar, date picker or time picker from a list of [Vanilla
  Calendar Pro
  options](https://vanilla-calendar.pro/docs/reference/settings),
  bundling version 3.2.0 of the library. `Date` and `POSIXct` values are
  converted to the strings it expects, options that must be JSON arrays
  are boxed, and unknown option names warn.
- [`VanillaCalendarOutput()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md)
  and
  [`renderVanillaCalendar()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendar-shiny.md)
  place a calendar in a Shiny app, reporting the selected dates, month,
  year, time, week number, displayed month and readiness as inputs.
- [`VanillaCalendarProxy()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  with
  [`vcSet()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcUpdate()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcShow()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  [`vcHide()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md)
  and
  [`vcDestroy()`](https://escri11.github.io/vanilla-calendar-r/reference/VanillaCalendarProxy.md),
  changes a calendar that is already on the page without re-rendering
  it.
- `inputMode = TRUE` renders a text box with a popup calendar.

### Upgrading from the GitHub-only version

Earlier versions of this package were distributed on GitHub and bundled
Vanilla Calendar Pro 2.9.3, whose options were nested under `settings`.
Those options no longer exist: `settings$lang` is now `locale`,
`settings$selection$day` is now `selectionDatesMode`, and
`settings$visibility$theme` is now `selectedTheme`. Unknown names warn
rather than being ignored, so the change is visible rather than silent.

`input$<id>_selected` is now a `Date` vector rather than character,
`input$<id>_selected_month` counts from 1 rather than 0, and
`input$<id>_selected_arrow` is now `input$<id>_displayed`.
