# Sources for the bundled JavaScript

`inst/htmlwidgets/lib/VanillaCalendar-3.2.0/` ships the minified build of
Vanilla Calendar Pro. `vanilla-calendar-pro-3.2.0-src.tar.gz` holds the
unminified sources it is built from, so the minified files can be audited and
regenerated. They are archived rather than unpacked because upstream's own
paths are longer than the 100 characters R considers portable.

* Upstream: https://github.com/uvarov-frontend/vanilla-calendar-pro
* Version: 3.2.0, from the `v3.2.0` tag
* Licence: MIT, see `LICENSE`

The bundled files are the ones upstream distributes on npm as
`vanilla-calendar-pro@3.2.0`, renamed:

| Bundled file | npm file |
|---|---|
| `vanilla-calendar.min.js` | `index.js` (UMD, exposes `window.VanillaCalendarPro`) |
| `vanilla-calendar.min.css` | `styles/index.css` |

To rebuild them from these sources:

```sh
tar xzf vanilla-calendar-pro-3.2.0-src.tar.gz
cd vanilla-calendar-pro-3.2.0
yarn install
yarn build          # writes the same files to package/
```

This directory is not installed with the R package; it is here so that the
sources travel with the source tarball.
