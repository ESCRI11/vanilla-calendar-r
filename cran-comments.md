## Test environments

* local Ubuntu 24.04, R 4.3.3

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewer

* The package bundles the Vanilla Calendar Pro JavaScript library (version
  3.2.0, MIT). Its licence ships in
  `inst/htmlwidgets/lib/VanillaCalendar-3.2.0/`, its author is credited as
  `ctb`/`cph` in `Authors@R`, and the bundled files are the ones distributed by
  upstream on npm.
* The unminified sources for the bundled library are included in
  `tools/vanilla-calendar-pro-3.2.0/`, with a README recording the upstream
  tag and the command that regenerates the bundled files. That directory is
  not installed.
* Tests that drive a headless browser are wrapped in `skip_on_cran()`.
