# VanillaCalendar (R) — gap plan against Vanilla Calendar Pro 3.2.0

## 1. Where the port stands

The whole port is 103 lines of R (`R/VanillaCalendar.R`) and 58 lines of JS (`inst/htmlwidgets/VanillaCalendar.js`) exporting three functions (`NAMESPACE:3-5`): a constructor that stuffs a user list into `x$options` untouched (`R/VanillaCalendar.R:38-40`) and the standard `*Output`/`render*` pair. The JS news up `VanillaCalendarPro.Calendar(el, options)` and calls `init()` (`VanillaCalendar.js:44-46`), after injecting four default callbacks that push state into Shiny (`VanillaCalendar.js:25-39`). The bundled asset is the full `index.css` (theme rules under `[data-vc-theme=light|dark]` are present) plus the UMD `vanilla-calendar.min.js` exposing `window.VanillaCalendarPro`, wired via `VanillaCalendar.yaml:1-6`. That makes it a *correct but thin* pass-through: every v3 option name and every `htmlwidgets::JS()` callback already reaches the library, and theming already works out of the box. What is missing is everything on the two boundaries — **R values → JSON** (no Date/vector/`I()` handling, so the most obvious first call throws) and **JS state → R** (4 of 18 callbacks, raw JS types, 0-indexed months, no time state) — plus the fact that the widget can only ever be *re-created*, never `update()`d, `show()`n or `hide()`n, which also makes v3's headline `inputMode` datepicker unreachable from R.

## 2. Ranked gaps

| # | Gap | Size | Prio | One-line why |
|---|-----|------|------|--------------|
| 1 | R scalars/Dates don't survive the JSON hop into array options | S | **P0** | `selectedDates = "2026-01-01"` is a hard TypeError in the library |
| 2 | Time selection never reaches Shiny (`onChangeTime` unbound) | S | **P0** | `selectionTimeMode = 24` gives R nothing at all |
| 3 | `input$id_selected_month` is JS 0-indexed | XS | **P0** | Silent off-by-one month, worst kind of bug |
| 4 | `options` has no default value | XS | **P0** | `VanillaCalendar()` errors; README implies it works |
| 5 | A user callback silently kills the matching Shiny input | XS | **P1** | Can't have `onClickDate` *and* `input$id_selected` |
| 6 | No proxy: `update`/`set`/`show`/`hide`/`destroy` unreachable | M | **P1** | Any option change re-renders and drops widget state |
| 7 | `inputMode` unreachable — htmlwidgets renders a `<div>` | M | **P1** | v3's flagship "datepicker attached to a text box" is off-limits |
| 8 | Dates arrive as `character` / `list()` not `Date` | S | **P1** | `as.Date(input$x)` errors on empty selection |
| 9 | Typo'd option names silently ignored | S | P2 | `selectionDateMode` (sic) = a calendar that just ignores you |
| 10 | 7 more callbacks unbound (weekday, week no., title, lifecycle) | S | P2 | Week-number click and `onInit` are the only ones with real demand |
| 11 | `setInputValue` dedup swallows repeat identical clicks | XS | P2 | Clicking month "May" twice fires once |
| 12 | Upstream MIT `LICENSE` not shipped, no `ctb` for the JS author | S | P2 | CRAN blocker for any bundled-JS package |
| 13 | `themeAttrDetect` default doesn't match bslib | XS | P2 | Dark-mode Shiny app, light calendar |
| 14 | Zero tests, no `NEWS.md`, no R CMD check evidence | S | P2 | 1.0.0 with no check log |
| 15 | `VanillaCalendarOutput` defaults to `width = "1000px"` | XS | P3 | Non-idiomatic; breaks fluid layouts |
| 16 | README screenshot is still a TODO comment | XS | P3 | `README.md:7` |

---

## 3. Detail, in priority order

### 1. R → JSON coercion (S, P0)

**What.** `R/VanillaCalendar.R:38-40` hands `options` straight to `createWidget`. htmlwidgets serialises with `auto_unbox = TRUE, POSIXt = "ISO8601", UTC = TRUE` (`htmlwidgets:::toJSON2`). Verified behaviour:

| R input | JSON produced | v3 expects |
|---|---|---|
| `selectedDates = "2026-01-01"` | `"2026-01-01"` | `DatesArr` = `Array` (`types.d.ts:19`) |
| `selectedDates = as.Date("2026-01-01")` | `"2026-01-01"` | array |
| `disableWeekdays = 0` | `0` | `Range<7>[]` (`options.d.ts:24`) |
| `dateMin = as.POSIXct(...)` | `"2026-01-01T10:00:00Z"` | `FormatDateString` (`types.d.ts:8`) |
| `dateMin = as.Date(...)` | `"2026-01-01"` | ✅ already fine |

The array case is not a soft failure: the library calls `parseDates(self.selectedDates)` (4 call sites in `index.mjs`; `utils/index.d.ts:2`) which does `dates.reduce(...)` — a bare string throws `TypeError` and the calendar never renders.

**Affected options:** `selectedDates`, `disableDates`, `enableDates`, `selectedHolidays` (`options.d.ts:20,26,36,39`), `disableWeekdays`, `selectedWeekends` (`options.d.ts:24,40`), `positionToInput` when given as `c("bottom","left")` (`types.d.ts:13`). Scalar-safe already: `dateToday/dateMin/dateMax/displayDateMin/displayDateMax` (`DateAny`, `options.d.ts:12-16`), `locale` as a full `LocaleStated` list (`types.d.ts:25-34` — 12/7-element vectors never unbox), `labels`/`styles`/`layouts`/`popups` nested lists.

**Sketch** — one helper called from the constructor, ~12 lines:

```r
.vc_arrays <- c("selectedDates","disableDates","enableDates","selectedHolidays",
                "disableWeekdays","selectedWeekends","positionToInput")

.vc_fix <- function(options) {
  fmt <- function(v) if (inherits(v, c("Date","POSIXt"))) format(v, "%Y-%m-%d") else v
  options[] <- lapply(options, fmt)                       # Date/POSIXct -> FormatDateString
  for (k in intersect(names(options), .vc_arrays))
    options[[k]] <- as.list(options[[k]])                 # force JSON array
  options
}
```

`as.list()` on a length-1 vector is what makes jsonlite emit `["2026-01-01"]` (verified). Skips `popups`/`labels` deliberately — they're nested and already correct.

### 2. Time state never reaches Shiny (S, P0)

**What.** `options.d.ts:35` `selectionTimeMode: false | 12 | 24` and `options.d.ts:58` `onChangeTime` exist; `VanillaCalendar.js:25-39` binds neither. `ContextVariables` carries `selectedTime`, `selectedHours`, `selectedMinutes`, `selectedKeeping` (`types.d.ts:82-85`).

**Scenario.** "Pick a meeting slot" — user builds `list(selectionTimeMode = 24)`, picks 14:30, and `input$cal_*` never changes. There is currently no workaround short of writing raw JS.

**Sketch** — 3 lines in the defaults block:

```js
onChangeTime: function(self, event, isError) {
  if (!isError) send("_time", self.context.selectedTime);   // "14:30" or "02:30 PM"
}
```

`selectedTime` is the already-formatted string; ship that one input and skip `_hours`/`_minutes`/`_keeping` (derivable in R with `strsplit`). R receives `character(1)`.

### 3. `_selected_month` is 0-indexed (XS, P0)

`VanillaCalendar.js:29-31` forwards `self.context.selectedMonth`, typed `Range<12>` = 0..11 (`types.d.ts:80`). R users read 0 for January. Fix is `+ 1` in the JS; also pad `onClickArrow` (`VanillaCalendar.js:36-37` emits `"2026-8-1"`, not a `FormatDateString`):

```js
onClickMonth: function(self) { send("_selected_month", self.context.selectedMonth + 1); },
onClickArrow: function(self) {
  send("_displayed", self.context.selectedYear + "-" +
       String(self.context.selectedMonth + 1).padStart(2, "0") + "-01");
}
```

Breaking change for `_selected_month` → needs a `NEWS.md` line (see #14).

### 4. `options` is a required argument (XS, P0)

`R/VanillaCalendar.R:35` — `VanillaCalendar()` errors. Change to `options = list()`. The JS already tolerates it (`VanillaCalendar.js:22`).

### 5. Custom callback disables the Shiny input (XS, P1)

`VanillaCalendar.js:40-42` `if (!options[k]) options[k] = defaults[k]` — supplying `onClickDate = JS(...)` for a tooltip loses `input$cal_selected` entirely. Chain instead:

```js
for (var k in defaults) {
  var user = options[k], def = defaults[k];
  options[k] = user ? function(u, d) {
    return function() { d.apply(null, arguments); u.apply(null, arguments); };
  }(user, def) : def;
}
```

### 6. `VanillaCalendarProxy` (M, P1)

**What.** `index.d.ts:7-12` exposes `init/update(resetOptions?)/destroy/show/hide/set(options, resetOptions?)` with `Reset = {year, month, dates, time, locale}` (`types.d.ts:50-56`). None reachable. Today the only way to change an option is to re-run `renderVanillaCalendar`, which hits `VanillaCalendar.js:44-45` `destroy()` + `new Calendar(...)` — full teardown, lost focus, visible flicker, and every other reactive dependency in that render block re-evaluated.

**Scenario.** A `dateMin` that depends on another input: today the calendar blinks and resets on every keystroke elsewhere.

**Sketch** — follows `leafletProxy`/`dataTableProxy`: one R constructor, one generic sender, one JS handler. ~20 lines total.

```r
VanillaCalendarProxy <- function(id, session = shiny::getDefaultReactiveDomain())
  structure(list(id = session$ns(id), session = session), class = "VanillaCalendarProxy")

.vc_call <- function(proxy, method, ...) {
  proxy$session$sendCustomMessage("VanillaCalendar-call",
    list(id = proxy$id, method = method, args = list(...)))
  invisible(proxy)
}
vcSet    <- function(proxy, options, reset = NULL) .vc_call(proxy, "set", .vc_fix(options), reset)
vcUpdate <- function(proxy, reset = NULL)          .vc_call(proxy, "update", reset)
vcShow   <- function(proxy)                        .vc_call(proxy, "show")
vcHide   <- function(proxy)                        .vc_call(proxy, "hide")
```

```js
// bottom of VanillaCalendar.js, outside the factory
if (typeof Shiny !== "undefined") {
  Shiny.addCustomMessageHandler("VanillaCalendar-call", function(msg) {
    var inst = HTMLWidgets.getInstance(document.getElementById(msg.id));
    if (inst && inst.calendar) inst.calendar[msg.method].apply(inst.calendar, msg.args || []);
  });
}
```

Requires the factory to return `{ renderValue: ..., resize: ..., calendar: null }` and assign `this.calendar = calendar` — `HTMLWidgets.getInstance(el)` (htmlwidgets.js:809) hands back exactly the object the factory returned, so no instance registry is needed. Note `.vc_fix()` reuse from gap #1 — the proxy path has the identical boxing problem. `shiny` moves from `Suggests` to a `requireNamespace` guard in the proxy constructor (keep it in `Suggests`, it's only reachable from a Shiny session).

### 7. `inputMode` datepicker (M, P1)

**What.** `options.d.ts:6-8` `inputMode`, `openOnFocus`, `positionToInput`; `onChangeToInput` (`options.d.ts:59`). In `index.mjs`, `createToInput` promotes `context.mainElement` to `context.inputElement` and builds a floating calendar next to it — i.e. **the element passed to `new Calendar()` must be an `<input>`**. htmlwidgets always renders a `<div>`, so `inputMode = TRUE` cannot work today, at all.

**Scenario.** The single most common ask: a date field in a form, not a 400px block of calendar. Currently impossible without hand-written JS.

**Minimal design** — do it in JS, not by inventing a second R widget:

```js
var target = el;
if (options.inputMode) {
  el.innerHTML = '<input type="text" class="form-control" readonly>';
  target = el.firstChild;
}
calendar = new VanillaCalendarPro.Calendar(target, options);
```

Plus `onChangeToInput: function(self){ send("_selected", self.context.selectedDates); }` so the input fires while the popup is open. Set `VanillaCalendarOutput(height = "auto")` for this mode (see #15). Deliberately *not* building a `vcDateInput()` Shiny input widget with `updateVcDateInput()` — the proxy from #6 plus `input$id_selected` covers it.

### 8. Dates as `Date` not `character`/`list()` (S, P1)

**What.** `VanillaCalendar.js:27` sends `context.selectedDates` (`FormatDateString[]`, `types.d.ts:79`) raw. R gets `character(n)` — except an empty selection arrives as `list()`, so `as.Date(input$cal_selected)` *errors* rather than returning `Date(0)`.

**Sketch** — Shiny's own type-tag mechanism, 6 lines, no per-app boilerplate:

```r
.onLoad <- function(libname, pkgname) {
  if (requireNamespace("shiny", quietly = TRUE))
    shiny::registerInputHandler("VanillaCalendar.dates", function(x, session, name)
      as.Date(unlist(x) %||% character(0)), force = TRUE)
}
```
```js
send("_selected:VanillaCalendar.dates", self.context.selectedDates);
```
`input$cal_selected` is then always a `Date` vector, length 0 when nothing is selected. Same tag reusable for `_displayed`.

### 9. Unknown option names (S, P2)

v3 ignores unknown keys silently — a typo produces a working-but-wrong calendar with no message anywhere. One `setdiff` against a hardcoded character vector of the 50 names in `options.d.ts:4-72`, warn (never error — forward-compat with 3.3):

```r
unknown <- setdiff(names(options), .vc_option_names)
if (length(unknown)) warning("Unknown VanillaCalendar option(s): ", toString(unknown))
```
Vector must be regenerated on each library bump — add a line to `NEWS.md` process, not a codegen script.

### 10. Remaining callbacks (S, P2)

Unbound from `options.d.ts`: `onClickWeekDay` (52), `onClickWeekNumber` (53), `onClickTitle` (54), `onInit` (64), `onUpdate` (65), `onDestroy` (66), `onShow` (67), `onHide` (68). Ship only two — the rest are reachable via `JS()` once #5 makes chaining safe:

```js
onClickWeekNumber: function(self, number, year) { send("_week", list(week: number, year: year)); },
onInit: function(self) { send("_ready", true); }
```
`_ready` matters because it's the only way an app can tell the widget exists before firing a proxy call.

### 11. `setInputValue` dedup (XS, P2)

`VanillaCalendar.js:14` — Shiny drops a set to an unchanged value. Clicking the same month twice, or re-selecting the same single date after a deselect, fires once. Add `{priority: "event"}` to the click-derived sends. One-token change to `send()`; leave `_ready` on default priority.

### 12. Bundled-JS licence (S, P2)

`inst/htmlwidgets/lib/VanillaCalendar-3.2.0/` ships only `.min.js`/`.min.css`; the upstream MIT `LICENSE` (Yury Uvarov, 2024) is not included and `DESCRIPTION:4-5` lists one author. CRAN will bounce this. Fix: copy `LICENSE` next to the minified files, add `person("Yury","Uvarov", role = c("ctb","cph"), comment = "Vanilla Calendar Pro library")` and a `Copyright:` field. Also add `Version: 3.2.0` of the JS to the `Description:` text.

### 13. Theming (XS, P2 — docs only)

Already works: `selectedTheme` defaults to `"system"`, the bundled CSS carries `[data-vc-theme=light|dark]`, and `themeAttrDetect` defaults to `"html[data-theme]"` (all verified in `index.mjs`). The one real gap is that **bslib writes `data-bs-theme`, not `data-theme`**, so a dark-mode Shiny app renders a light calendar. Pure documentation:

```r
VanillaCalendar(options = list(themeAttrDetect = "html[data-bs-theme]"))
```
`locale` as a `LocaleStated` list (`types.d.ts:25-34`) already round-trips correctly — verified, no code needed.

### 14. Tests / NEWS / check (S, P2)

Nothing exists: no `tests/`, no `NEWS.md`, no `.github/`, no check log. Minimum that would have caught gap #1:

```r
# tests/testthat/test-options.R
test_that("array options survive the JSON hop", {
  j <- htmlwidgets:::toJSON2(list(options = .vc_fix(list(selectedDates = as.Date("2026-01-01")))))
  expect_match(as.character(j), '"selectedDates":\\["2026-01-01"\\]')
})
```
One file, three expectations (array boxing, Date formatting, POSIXct formatting). Plus a `NEWS.md` recording the 2.9.3 → 3.2.0 bump and the `_selected_month` breaking change from #3. No CI workflow — `R CMD check` locally before release is enough at this size.

### 15/16. Cosmetics (XS, P3)

`R/VanillaCalendar.R:94` defaults to `width = "1000px"` — should be `"100%"`, with `"auto"` height for input mode. `README.md:7` still holds the screenshot placeholder comment.

---

## 4. Not worth doing (YAGNI)

| Thing | Why not |
|---|---|
| Bundle `utils/index.js` (`window.VanillaCalendarProUtils`) | `getDateString`/`getDate` are `format(x, "%Y-%m-%d")`/`as.Date()`; `getWeekNumber` is `format(x, "%V")`. Nothing in the port calls them. +6 KB for zero R-visible benefit. |
| Named R arguments for all 50 options | 50 arguments to maintain per upstream bump vs. one `options` list that already works. Docs link to upstream. |
| R helpers for `popups`/`labels`/`layouts`/`styles` | Nested R lists already serialise correctly (verified). A `vc_popup()` constructor saves zero characters over `list("2026-01-01" = list(html = "..."))`. |
| `onCreateDateEls`/`onCreateMonthEls`/`onCreateYearEls`/`onCreateDateRangeTooltip` bindings | Per-DOM-element callbacks — they only make sense as raw JS, and `htmlwidgets::JS()` already delivers them. |
| Wrapping `sanitizerHTML` | Same: a JS function option, `JS()` covers it. |
| R6/S4 calendar object mirroring the `Calendar` class | Proxy + custom message handler (#6) is the htmlwidgets idiom and one twentieth the code. |
| Splitting the CSS into `layout.css` + selectable themes | `index.css` is 51 KB and contains both themes; the theme switch is a runtime attribute. Splitting buys nothing but a dependency matrix. |
| pkgdown site / vignette | README + two `.Rd` files cover a three-function package. Revisit if the proxy API lands and grows past ~8 exports. |
| Validating option *values* (ranges, enums) | v3 already errors loudly on bad `locale`/`selectionTimeMode`/`displayMonthsCount` (error strings are in `index.mjs`). Only the *name* check (#9) is worth adding, because that one is silent. |
| `resize()` implementation | Calendar is fluid; the existing no-op (`VanillaCalendar.js:50-54`) is correct. |
| `_selected_hours` / `_selected_minutes` / `_selected_keeping` inputs | `_time` (#2) plus `strsplit` gives all three. |
| CI workflow | One maintainer, one file of code. `R CMD check` before release. |
