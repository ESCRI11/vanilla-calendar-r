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
* The version number starts at 2.0.1 because the package was previously
  distributed on GitHub only; 2.0.0 was the release that moved the bundled
  library from 2.x to 3.x.
* Tests that drive a headless browser are wrapped in `skip_on_cran()`.
