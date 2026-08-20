// Re-encode the captured frames at a readable pace. No need to re-drive the browser.
const GIFEncoder = require('gif-encoder-2');
const { PNG } = require('pngjs');
const fs = require('fs');
const path = require('path');

const FRAMES = path.resolve(__dirname, 'out', 'frames');
const OUT = path.resolve(__dirname, 'out');
const STEP = Number(process.env.STEP || 1200);   // ms per frame
const HOLD = Number(process.env.HOLD || 2600);   // ms on the last frame

const names = [...new Set(fs.readdirSync(FRAMES).map((f) => f.replace(/-\d+\.png$/, '')))];

for (const name of names) {
  const files = fs.readdirSync(FRAMES)
    .filter((f) => f.startsWith(name + '-'))
    .sort((a, b) => Number(a.match(/-(\d+)\.png$/)[1]) - Number(b.match(/-(\d+)\.png$/)[1]));

  let encoder = null;
  files.forEach((f, i) => {
    const png = PNG.sync.read(fs.readFileSync(path.join(FRAMES, f)));
    if (!encoder) {
      encoder = new GIFEncoder(png.width, png.height, 'neuquant', true);
      encoder.setRepeat(0);
      encoder.setQuality(10);
      encoder.start();
    }
    if (png.width !== encoder.width || png.height !== encoder.height) return;
    encoder.setDelay(i === files.length - 1 ? HOLD : STEP);
    encoder.addFrame(png.data);
  });
  encoder.finish();
  fs.writeFileSync(path.join(OUT, name + '.gif'), encoder.out.getData());
  console.log(`${name}: ${files.length} frames, ${STEP}ms each, ${HOLD}ms hold`);
}
