#!/usr/bin/env node
// extract-from-url.mjs — sample a live URL's computed styles, output DESIGN.md token candidates as JSON.
// Requires: `playwright` installed (npm i -D playwright) + chromium (npx playwright install chromium).
// Usage: node extract-from-url.mjs <url>
// The agent names + dedupes these candidates, adds rationale, writes DESIGN.md, then runs `designmd lint`.
import { chromium } from 'playwright';

const url = process.argv[2];
if (!url) {
  console.error('Usage: node extract-from-url.mjs <url>');
  process.exit(2);
}

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
try {
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
} catch (e) {
  console.error('navigation failed:', e.message, '\n(fallback: use webfetch on the URL + its CSS files and parse manually)');
  await browser.close();
  process.exit(1);
}

const targets = [
  { sel: 'h1', role: 'display' },
  { sel: 'h2', role: 'heading' },
  { sel: 'h3', role: 'heading' },
  { sel: 'p', role: 'body' },
  { sel: 'a', role: 'link' },
  { sel: 'button, [class*=btn i], [class*=button i]', role: 'cta' },
  { sel: '[class*=card i], [class*=surface i]', role: 'card' },
  { sel: 'body', role: 'canvas' },
];

const props = [
  'color','background-color','font-family','font-size','font-weight',
  'line-height','letter-spacing','border-radius','padding','margin',
  'box-shadow','border-color','border-width'
];

const sampled = [];
for (const t of targets) {
  const els = await page.$$(t.sel).catch(() => []);
  for (const el of els.slice(0, 3)) {
    const styles = await el.evaluate((el, props) => {
      const cs = getComputedStyle(el);
      const o = {};
      props.forEach(p => o[p] = cs.getPropertyValue(p));
      return o;
    }, props);
    const tag = await el.evaluate(el => el.tagName.toLowerCase() + '.' + (el.className || '').toString().slice(0, 40));
    sampled.push({ selector: t.sel, role: t.role, tag, styles });
  }
}

const uniq = (arr) => [...new Set(arr.filter(v => v && v !== '0px' && v !== 'rgba(0, 0, 0, 0)'))];
const colors = uniq(sampled.flatMap(s => [s.styles['color'], s.styles['background-color'], s.styles['border-color']]));
const fonts = uniq(sampled.map(s => s.styles['font-family']));
const fontSizes = uniq(sampled.map(s => s.styles['font-size']));
const fontWeights = uniq(sampled.map(s => s.styles['font-weight']));
const radii = uniq(sampled.map(s => s.styles['border-radius']));
const spacing = uniq(sampled.flatMap(s => [s.styles['padding'], s.styles['margin']]));

console.log(JSON.stringify({
  url,
  note: 'Token candidates sampled from live computed styles. Agent: name them, dedupe, normalize color formats, add rationale, write DESIGN.md, then `designmd lint`.',
  sampled,
  candidates: { colors, fonts, fontSizes, fontWeights, radii, spacing }
}, null, 2));

await browser.close();
