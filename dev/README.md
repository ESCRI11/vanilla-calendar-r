# Development notes

Not part of the built package (`.Rbuildignore`d).

* `PLAN.md` — the gap analysis the 2.0.0 release was built from.
* `capture/` — regenerates `man/figures/`.

## Regenerating the README screenshots and GIFs

The images come from the gallery app, captured in headless Chromium, so they
can be refreshed rather than going stale.

```sh
# 1. serve the demo app
R -e 'devtools::load_all("."); shiny::runApp("inst/examples/gallery", port = 8100)'

# 2. capture, from dev/capture
npm install
npx playwright install chromium
FRAMES=1 node capture.js          # PNG + GIFs, and the frames the GIFs are built from
SCALE=2 OUT_DIR=$PWD/out2x node capture.js   # the hero PNG, at 2x

# 3. optionally re-time the GIFs without re-driving the browser
STEP=1200 HOLD=2600 node reencode.js

# 4. install
cp out2x/calendar.png ../../man/figures/
cp out/*.gif ../../man/figures/
```
