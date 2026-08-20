// Captures README screenshots and GIFs from the live gallery Shiny app.
const { chromium } = require('playwright');
const GIFEncoder = require('gif-encoder-2');
const { PNG } = require('pngjs');
const fs = require('fs');
const path = require('path');

const URL = process.env.APP_URL || 'http://127.0.0.1:8100';
const OUT = process.env.OUT_DIR || path.resolve(__dirname, 'out');
fs.mkdirSync(OUT, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function shot(locator, name) {
  await locator.screenshot({ path: path.join(OUT, name + '.png') });
  console.log('png  ' + name);
}

// Record a GIF by screenshotting `locator` while `steps` run.
async function gif(shooter, name, steps, { delay = 500, fps = 4 } = {}) {
  const frames = [];
  let encoder = null;
  const take = typeof shooter === 'function' ? shooter : (o) => shooter.screenshot(o);

  const grab = async () => {
    const buf = await take();
    if (process.env.FRAMES) {
      fs.mkdirSync(path.join(OUT, 'frames'), { recursive: true });
      fs.writeFileSync(path.join(OUT, 'frames', name + '-' + frames.length + '.png'), buf);
    }
    const png = PNG.sync.read(buf);
    if (!encoder) {
      encoder = new GIFEncoder(png.width, png.height, 'neuquant', true);
      encoder.setDelay(1000 / fps);
      encoder.setRepeat(0);
      encoder.setQuality(10);
      encoder.start();
    }
    if (png.width === encoder.width && png.height === encoder.height) {
      encoder.addFrame(png.data);
      frames.push(1);
    }
  };

  await grab();
  for (const step of steps) {
    await step();
    await sleep(delay);
    await grab();
  }
  await sleep(delay);
  await grab();

  encoder.finish();
  fs.writeFileSync(path.join(OUT, name + '.gif'), encoder.out.getData());
  console.log('gif  ' + name + ' (' + frames.length + ' frames)');
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 880, height: 900 },
    deviceScaleFactor: Number(process.env.SCALE || 1),
  });
  await page.goto(URL, { waitUntil: 'networkidle' });
  await page.waitForSelector('#range [data-vc-date-btn]');
  await sleep(800);

  const panel = (n) => page.locator('.panel').nth(n);
  const day = (id, i) => page.locator(`#${id} [data-vc-date-btn]`).nth(i);

  // 1. Hero shot: the two-month calendar with weekends and holidays
  await page.evaluate(() => {
    document.getElementById('months').style.height = 'auto';
  });
  await sleep(300);
  await shot(page.locator('#months'), 'calendar');

  // 2. Range selection, with the Shiny readout updating underneath
  await gif(panel(0), 'range-selection', [
    () => day('range', 9).click(),
    () => day('range', 15).click(),
    () => page.locator('#range [data-vc-arrow="next"]').click(),
    () => day('range', 12).click(),
    () => day('range', 20).click(),
  ], { delay: 700 });

  // 3. Input-mode date picker: the popup is attached to the body, so capture a
  // region that covers both the panel and the popup underneath it.
  await panel(1).scrollIntoViewIfNeeded();
  await page.evaluate(() => window.scrollBy(0, -40));
  await sleep(400);
  const pickerBox = await panel(1).boundingBox();  // viewport-relative
  const pickerClip = {
    x: Math.max(0, pickerBox.x - 8),
    y: Math.max(0, pickerBox.y - 8),
    width: Math.min(880, pickerBox.width + 16),
    height: 420,
  };
  const pickerShot = () => page.screenshot({ clip: pickerClip });
  await gif(pickerShot, 'input-mode', [
    () => page.locator('#picker input').click(),
    () => sleep(400),
    () => page.locator('body > [data-vc=calendar] [data-vc-date-btn]').nth(16).click(),
    () => sleep(500),
    () => page.mouse.click(830, 20),   // close the popup, revealing the R readout
  ], { delay: 800 });
  await page.mouse.click(5, 5);
  await page.evaluate(() => window.scrollTo(0, 0));
  await sleep(300);

  // 4. Date and time
  await gif(panel(2), 'time-picker', [
    () => day('time', 11).click(),
    () => page.locator('#time [data-vc-time-range="hour"] input').fill('14'),
    () => page.locator('#time [data-vc-time-range="hour"] input').dispatchEvent('input'),
    () => page.locator('#time [data-vc-time-range="minute"] input').fill('30'),
    () => page.locator('#time [data-vc-time-range="minute"] input').dispatchEvent('input'),
  ], { delay: 600 });

  // 5. Theme switched in place from the server, no re-render
  await gif(panel(3), 'themes', [
    () => page.locator('input[value="dark"]').check(),
    () => sleep(400),
    () => page.locator('input[value="light"]').check(),
    () => sleep(400),
    () => page.locator('input[value="dark"]').check(),
  ], { delay: 700 });

  // 6. Month and year pickers
  await gif(panel(0), 'month-year', [
    () => page.locator('#range [data-vc="month"]').click(),
    () => page.locator('#range [data-vc-months-month]').nth(11).click(),
    () => page.locator('#range [data-vc="year"]').click(),
    () => page.locator('#range [data-vc-years-year]').nth(8).click(),
  ], { delay: 700 });

  await browser.close();
  console.log('done -> ' + OUT);
})().catch((e) => { console.error(e); process.exit(1); });
