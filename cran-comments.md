## Test environments

* local Ubuntu 24.04, R 4.3.3
* win-builder, R-devel
* win-builder, R-release

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Previous submission

An earlier version of this package was submitted and not accepted. Benjamin
Altmann raised four points; all four have been addressed, and the package has
been substantially reworked since.

1. **Software names in single quotes in the Title and Description.** The Title
   no longer names any software. The Description quotes 'Vanilla Calendar Pro',
   'JavaScript' and 'Shiny'.

2. **Missing `\value` tags.** Every exported function now documents its return
   value and what the value means: `VanillaCalendar()` returns an `htmlwidget`,
   `VanillaCalendarOutput()` a Shiny output element,
   `renderVanillaCalendar()` a Shiny render function, and
   `VanillaCalendarProxy()` and the `vc*()` verbs return the proxy object
   invisibly so that calls can be chained.

3. **Tests, since Shiny interfaces cannot be checked automatically.** The
   package now has 129 tests. The unexported option coercion and validation and
   the proxy message construction are tested directly. Because most of the
   behaviour lives in the widget's JavaScript, there is also a `shinytest2`
   suite that runs a real Shiny app in a headless browser and asserts what
   reaches the server: the selected dates, the displayed month, time and week
   selection, input mode, re-rendering, and each proxy verb. Those tests are
   wrapped in `skip_on_cran()`, so CRAN runs the remainder.

4. **Package size and completeness.** The package was three exported functions
   when it was last submitted. It now exports nine, and the package is fully
   developed for what it wraps: every option and callback of the bundled
   library is reachable from R, `Date` and `POSIXct` values are converted to
   the strings the library expects, unknown option names warn rather than
   failing silently, `inputMode` provides a popup date picker, and
   `VanillaCalendarProxy()` with `vcSet()`, `vcUpdate()`, `vcShow()`,
   `vcHide()` and `vcDestroy()` changes a calendar that is already on the page
   without re-rendering it. There are two vignettes and a documented example
   app. I do not have further functionality planned; the bundled library
   defines the scope, and this release covers it.

## Notes for the reviewer

* The package bundles the Vanilla Calendar Pro JavaScript library (version
  3.2.0, MIT). Its licence ships in
  `inst/htmlwidgets/lib/VanillaCalendar-3.2.0/`, its author is credited as
  `ctb`/`cph` in `Authors@R`, and the bundled files are the ones distributed by
  upstream on npm.
* The unminified sources for the bundled library are included in
  `tools/vanilla-calendar-pro-3.2.0-src.tar.gz`, with a README recording the
  upstream tag and the command that regenerates the bundled files. They are
  archived rather than unpacked because upstream's own paths are longer than
  the 100 characters R considers portable. That directory is not installed.
