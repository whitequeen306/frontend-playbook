# Motion Templates — 8 domain signature moments

Real, adapt-don't-copy code templates for Stage 3 signature moments. Each is a **floor, not a ceiling** — adapt the metaphor to the project's subject. All use **free GSAP plugins only** (ScrollTrigger, CustomEase, Flip, Observer, MotionPathPlugin, TextPlugin). For SplitText, use the manual char-split pattern shown in the Photography template — do not require the premium SplitText plugin.

Each template below assumes:
- React 19 + Vite + Tailwind v4 (`@tailwindcss/vite`, `@import "tailwindcss"`)
- `useLenis` hook installed site-wide (see Common at the bottom)
- DESIGN.md tokens exported to `theme.css` as `--color-*`, `--font-*`, `--text-*` custom properties
- `gsap.registerPlugin(...)` called at module top

A Stage-3 signature moment is **FAIL** if it has fewer than 60 lines of GSAP timeline code OR fewer than 40 lines of supporting CSS. These templates are the floor — your adapted version should match or exceed them.

---

## 1. Photography — aperture iris open

The signature moment for any photography / film / darkroom brand. Six SVG blades rotate outward + clip-path circle opens + exposure brightens + grain ambient. Cool serves the subject (a camera opening to admit light).

```jsx
// src/components/Hero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { CustomEase } from 'gsap/CustomEase';
import { useLenis } from '../hooks/useLenis';

gsap.registerPlugin(ScrollTrigger, CustomEase, useGSAP);
CustomEase.create('iris', 'M0,0 C0.4,0 0.2,1 1,1');

const BLADES = 6;
const STEP = 360 / BLADES;
const BRAND = 'HALIDE';

export default function Hero() {
  const { contextRef } = useGSAP();
  useLenis();

  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: { trigger: contextRef.current, start: 'top top', end: '+=900', scrub: 0.6, pin: true, anticipatePin: 1 },
    });
    // 1. iris clip-path opens from 0% to 130%
    tl.fromTo('.iris-mask', { '--iris': '0%' }, { '--iris': '130%', duration: 1.2, ease: 'iris' }, 0)
      // 2. blades rotate outward in radial stagger
      .fromTo('.blade',
        { rotate: 0, scale: 0.4, opacity: 0 },
        { rotate: (i) => STEP * (i + 1) * 1.5, scale: 1, opacity: 1, stagger: 0.06, ease: 'power3.out' }, 0.2)
      // 3. exposure brightens as iris opens (drives a CSS calc)
      .fromTo('.iris-mask', { '--ev': -2 }, { '--ev': 0, duration: 1.4, ease: 'power2.inOut' }, 0)
      // 4. title chars rise per-letter with the iris easing
      .from('.hero-title .char', { yPercent: 120, rotate: 8, stagger: 0.04, ease: 'iris' }, 0.5)
      // 5. subtitle fades in after iris settles
      .from('.hero-sub', { opacity: 0, y: 20, duration: 0.6, ease: 'power2.out' }, 1.0);
    // ambient grain drift — continuous, low-amp
    gsap.to('.grain', { x: '+=4', y: '-=4', duration: 0.12, repeat: -1, yoyo: true, ease: 'none' });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="hero">
      <div className="iris-mask" style={{ clipPath: 'circle(var(--iris, 130%) at 50% 50%)' }}>
        {Array.from({ length: BLADES }).map((_, i) => (
          <svg key={i} className="blade" viewBox="0 0 100 100" style={{ rotate: `${STEP * i}deg` }} aria-hidden="true">
            <path d="M50,50 L90,20 A50,50 0 0,1 90,80 Z" fill="var(--color-ink)" />
          </svg>
        ))}
        <h1 className="hero-title">{[...BRAND].map((c, i) => (
          <span key={i} className="char">{c}</span>
        ))}</h1>
        <p className="hero-sub">Light, recorded.</p>
      </div>
      <div className="grain" aria-hidden="true" />
    </section>
  );
}
```

```css
/* src/styles/hero.css */
.hero {
  position: relative;
  min-height: 100vh;
  background: var(--color-ink);
  display: grid;
  place-items: center;
  overflow: hidden;
}
.iris-mask {
  --iris: 130%; /* progressive enhancement default = visible */
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  background: color-mix(in oklab, var(--color-ink) calc((var(--ev, 0) + 2) * 25%), var(--color-bone));
  transition: background 0.4s linear;
}
.blade {
  position: absolute;
  width: 60vmin;
  height: 60vmin;
  transform-origin: 50% 50%;
  mix-blend-mode: multiply;
  filter: drop-shadow(0 0 20px rgba(0, 0, 0, 0.4));
}
.hero-title {
  font-family: var(--font-display);
  font-size: clamp(3rem, 12vw, 7rem);
  color: var(--color-amber);
  display: flex;
  gap: 0.05em;
  letter-spacing: 0.02em;
}
.hero-title .char {
  display: inline-block;
  will-change: transform;
}
.hero-sub {
  font-family: var(--font-body);
  color: var(--color-bone);
  margin-top: 1rem;
  opacity: 0.8;
}
.grain {
  position: absolute;
  inset: 0;
  pointer-events: none;
  background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="240" height="240"><filter id="n"><feTurbulence baseFrequency="0.9" numOctaves="2"/></filter><rect width="100%25" height="100%25" filter="url(%23n)"/></svg>');
  opacity: 0.08;
  mix-blend-mode: overlay;
}
@media (prefers-reduced-motion: reduce) {
  .iris-mask { --iris: 130% !important; --ev: 0 !important; }
  .hero-title .char { transform: none !important; }
  .hero-sub { opacity: 1 !important; transform: none !important; }
  .grain { animation: none !important; }
}
```

---

## 2. Finance / data — count-up dashboard

For fintech / analytics / SaaS dashboards. Numbers roll up with decimals, tick-flashes when each settles, chart lines draw on with `stroke-dashoffset`, data points cascade in.

```jsx
// src/components/DashboardHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { CustomEase } from 'gsap/CustomEase';
import { useLenis } from '../hooks/useLenis';

gsap.registerPlugin(ScrollTrigger, CustomEase, useGSAP);
CustomEase.create('snap', 'M0,0 C0.2,0 0.1,1 1,1'); // overshoot then settle

const METRICS = [
  { id: 'rev', value: 4827193, prefix: '$', label: 'ARR' },
  { id: 'mrr', value: 401287, prefix: '$', label: 'MRR' },
  { id: 'churn', value: 0.018, suffix: '%', label: 'Churn' },
  { id: 'nps', value: 72, label: 'NPS' },
];

export default function DashboardHero({ paths }) {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: { trigger: contextRef.current, start: 'top 75%', once: true },
    });
    // 1. counters roll up — snap to 0.01 for decimals
    tl.fromTo('.metric-value', { textContent: 0 },
      { textContent: (i, t) => t.dataset.target, duration: 1.6, ease: 'snap',
        snap: { textContent: 0.01 }, stagger: 0.12,
        onUpdate: function () {
          const t = this.targets()[0];
          const v = +t.textContent;
          t.textContent = t.dataset.fmt === 'pct' ? (v * 100).toFixed(1) + '%' :
                          t.dataset.fmt === 'usd' ? '$' + Math.round(v).toLocaleString() :
                          Math.round(v).toLocaleString();
        }}, 0);
    // 2. tick-flash when each metric settles
    tl.fromTo('.metric-value', { '--flash': 1 }, { '--flash': 0, duration: 0.6, ease: 'power2.out', stagger: 0.12 }, 0.4);
    // 3. chart lines draw on via stroke-dashoffset
    tl.fromTo('.chart-line',
      { strokeDashoffset: (i, t) => t.getTotalLength(), strokeDasharray: (i, t) => t.getTotalLength() },
      { strokeDashoffset: 0, duration: 1.4, ease: 'power2.inOut', stagger: 0.08 }, 0.2);
    // 4. data points cascade
    tl.fromTo('.chart-point', { scale: 0, transformOrigin: 'center' },
      { scale: 1, duration: 0.4, ease: 'back.out(2)', stagger: 0.04 }, 0.6);
    // 5. ambient pulse on KPI hero
    gsap.to('.kpi-hero', { scale: 1.02, duration: 1.2, repeat: -1, yoyo: true, ease: 'sine.inOut' });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="dashboard-hero">
      <div className="metric-grid">
        {METRICS.map((m, i) => (
          <div key={m.id} className={'metric ' + (i === 0 ? 'kpi-hero' : '')}>
            <div className="metric-value" data-target={m.value} data-fmt={typeof m.value === 'number' && m.value < 1 ? 'pct' : m.prefix ? 'usd' : 'num'}>0</div>
            <div className="metric-label">{m.label}</div>
          </div>
        ))}
      </div>
      <svg className="chart" viewBox="0 0 400 200">
        {paths.map((p, i) => (
          <g key={i}>
            <path className="chart-line" d={p.d} stroke={p.color} fill="none" strokeWidth="2" />
            {p.points.map((pt, j) => <circle key={j} className="chart-point" cx={pt.x} cy={pt.y} r="3" fill={p.color} />)}
          </g>
        ))}
      </svg>
    </section>
  );
}
```

```css
.dashboard-hero { min-height: 80vh; background: var(--color-ink); color: var(--color-bone); padding: 6rem 2rem; }
.metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 2rem; margin-bottom: 3rem; }
.metric-value {
  font-family: var(--font-mono);
  font-size: clamp(2rem, 5vw, 3.5rem);
  color: var(--color-amber);
  text-shadow: 0 0 calc(var(--flash, 0) * 14px) var(--color-amber);
}
.metric-label { font-family: var(--font-body); opacity: 0.6; margin-top: 0.25rem; }
.chart-line { stroke-linecap: round; }
.chart-point { transform-box: fill-box; transform-origin: center; }
@media (prefers-reduced-motion: reduce) {
  .chart-line { stroke-dashoffset: 0 !important; stroke-dasharray: none !important; }
  .chart-point { transform: none !important; }
}
```

---

## 3. Music / audio — waveform + beat-synced pulse + vinyl spin

For music labels / players / podcasts. Vinyl spins, equalizer bars pulse with random FFT simulation, waveform draws on, central orb beats.

```jsx
// src/components/PlayerHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, useGSAP);

export default function PlayerHero({ waveformPath }) {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    // 1. vinyl continuous spin
    gsap.to('.vinyl', { rotate: 360, duration: 8, repeat: -1, ease: 'none' });
    // 2. equalizer bars — random scaleY simulating FFT bins
    const bars = gsap.utils.toArray('.eq-bar');
    bars.forEach((bar, i) => {
      gsap.to(bar, {
        scaleY: () => 0.3 + Math.random() * 0.7,
        duration: () => 0.18 + Math.random() * 0.18,
        repeat: -1, yoyo: true, ease: 'sine.inOut', delay: i * 0.02,
      });
    });
    // 3. waveform draw-on
    gsap.fromTo('.waveform path',
      { strokeDashoffset: (i, t) => t.getTotalLength(), strokeDasharray: (i, t) => t.getTotalLength() },
      { strokeDashoffset: 0, duration: 1.4, ease: 'power2.inOut', stagger: 0.05,
        scrollTrigger: { trigger: '.waveform', start: 'top 80%' } });
    // 4. beat-synced pulse on central orb (120 BPM = 0.5s)
    gsap.to('.orb', { scale: 1.1, duration: 0.25, repeat: -1, yoyo: true, ease: 'power2.inOut' });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="player-hero">
      <div className="vinyl-wrap">
        <div className="vinyl" />
        <div className="orb" />
      </div>
      <svg className="waveform" viewBox="0 0 400 80">
        <path d={waveformPath} stroke="var(--color-amber)" fill="none" strokeWidth="2" />
      </svg>
      <div className="eq">
        {Array.from({ length: 32 }).map((_, i) => (
          <span key={i} className="eq-bar" />
        ))}
      </div>
    </section>
  );
}
```

```css
.player-hero { min-height: 80vh; background: var(--color-ink); display: grid; place-items: center; gap: 3rem; padding: 4rem 2rem; }
.vinyl-wrap { position: relative; width: 40vmin; aspect-ratio: 1; }
.vinyl {
  position: absolute; inset: 0; border-radius: 50%;
  background: radial-gradient(circle at center,
    #2a2a2a 30%, #0a0a0a 31% 60%, #2a2a2a 61% 70%, #0a0a0a 71% 100%);
}
.orb {
  position: absolute; inset: 30%; border-radius: 50%;
  background: var(--color-amber); filter: blur(20px); opacity: 0.7;
  transform-origin: center;
}
.waveform { width: 100%; max-width: 600px; }
.eq { display: flex; gap: 3px; align-items: flex-end; height: 80px; }
.eq-bar { display: inline-block; width: 5px; height: 100%; background: var(--color-amber); transform-origin: bottom; transform: scaleY(0.3); }
@media (prefers-reduced-motion: reduce) {
  .vinyl, .orb, .eq-bar { animation: none !important; transform: none !important; }
  .waveform path { stroke-dashoffset: 0 !important; stroke-dasharray: none !important; }
}
```

---

## 4. Architecture — blueprint grid reveal + cross-section

For architecture / construction / engineering brands. Grid lines draw on with stroke-dashoffset, elevation cross-section rises, dimension annotations fade in, multi-layer parallax.

```jsx
// src/components/BlueprintSection.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, useGSAP);

export default function BlueprintSection({ gridLines, elevationPath, dims }) {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: { trigger: contextRef.current, start: 'top top', end: '+=1200', scrub: 1, pin: true },
    });
    // 1. blueprint grid draws on
    tl.fromTo('.grid-line',
      { strokeDashoffset: (i, t) => t.getTotalLength(), strokeDasharray: (i, t) => t.getTotalLength() },
      { strokeDashoffset: 0, duration: 1.5, ease: 'power2.inOut', stagger: 0.02 }, 0);
    // 2. elevation cross-section draws on
    tl.fromTo('.elevation path',
      { strokeDashoffset: (i, t) => t.getTotalLength(), strokeDasharray: (i, t) => t.getTotalLength() },
      { strokeDashoffset: 0, duration: 2, ease: 'power2.inOut' }, 0.2);
    // 3. dimension annotations cascade
    tl.fromTo('.dim-line', { opacity: 0, scale: 0.8 }, { opacity: 1, scale: 1, duration: 0.4, stagger: 0.04, ease: 'back.out(2)' }, 0.8);
    // 4. multi-layer parallax (bg slower than fg)
    gsap.to('.layer-bg', { yPercent: -30, ease: 'none', scrollTrigger: { trigger: contextRef.current, start: 'top bottom', end: 'bottom top', scrub: true } });
    gsap.to('.layer-fg', { yPercent: 10, ease: 'none', scrollTrigger: { trigger: contextRef.current, start: 'top bottom', end: 'bottom top', scrub: true } });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="blueprint-section">
      <div className="layer-bg" aria-hidden="true" />
      <svg className="blueprint" viewBox="0 0 1200 800" preserveAspectRatio="xMidYMid meet">
        {gridLines.map((d, i) => <path key={i} className="grid-line" d={d} stroke="var(--color-amber)" strokeWidth="0.5" fill="none" opacity="0.5" />)}
        <g className="elevation"><path d={elevationPath} stroke="var(--color-bone)" strokeWidth="2" fill="none" /></g>
        {dims.map((d, i) => <line key={i} className="dim-line" x1={d.x1} y1={d.y1} x2={d.x2} y2={d.y2} stroke="var(--color-amber)" strokeWidth="1" strokeDasharray="4 4" />)}
      </svg>
      <div className="layer-fg" aria-hidden="true" />
    </section>
  );
}
```

```css
.blueprint-section { position: relative; min-height: 100vh; background: var(--color-ink); overflow: hidden; }
.layer-bg { position: absolute; inset: -10%; background: radial-gradient(ellipse at center, rgba(212,162,78,0.08), transparent 70%); }
.blueprint { position: relative; width: 100%; height: 100%; max-width: 1200px; margin: 0 auto; }
.grid-line, .elevation path, .dim-line { transform-box: fill-box; transform-origin: center; }
.layer-fg { position: absolute; inset: 0; pointer-events: none; background: linear-gradient(to bottom, transparent 70%, var(--color-ink)); }
@media (prefers-reduced-motion: reduce) {
  .grid-line, .elevation path { stroke-dashoffset: 0 !important; stroke-dasharray: none !important; }
}
```

---

## 5. Fashion / editorial — runway curtain reveal + spread flip

For fashion brands / magazines / editorial sites. Two-panel curtain opens via clip-path inset, magazine spread flips in 3D, typographic kerning sweep.

```jsx
// src/components/EditorialHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { CustomEase } from 'gsap/CustomEase';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, CustomEase, useGSAP);
CustomEase.create('curtain', 'M0,0 C0.4,0 0.2,1 1,1');

const HEADLINE = 'Autumn Collection 2026';

export default function EditorialHero() {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    const tl = gsap.timeline({
      scrollTrigger: { trigger: contextRef.current, start: 'top top', end: '+=900', scrub: 0.6, pin: true },
    });
    // 1. curtain panels split (clip-path inset drives reveal)
    tl.fromTo('.curtain-l', { '--inset': 0 }, { '--inset': 100, duration: 1.2, ease: 'curtain' }, 0);
    tl.fromTo('.curtain-r', { '--inset': 0 }, { '--inset': 100, duration: 1.2, ease: 'curtain' }, 0);
    // 2. magazine spread 3D flip in
    tl.fromTo('.spread',
      { rotateY: 90, opacity: 0, transformOrigin: 'center' },
      { rotateY: 0, opacity: 1, duration: 1.2, ease: 'power3.out' }, 0.4);
    // 3. typographic kerning sweep — letter-spacing animates open
    tl.fromTo('.headline', { letterSpacing: '-0.5em', opacity: 0 },
      { letterSpacing: '0.02em', opacity: 1, duration: 1.4, ease: 'curtain' }, 0.3);
    // 4. per-char rise
    tl.from('.headline .char', { yPercent: 100, stagger: 0.03, ease: 'power3.out' }, 0.4);
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="editorial-hero">
      <div className="curtain curtain-l" aria-hidden="true" style={{ clipPath: 'inset(0 0 0 calc(var(--inset, 0) * -1%))' }} />
      <div className="curtain curtain-r" aria-hidden="true" style={{ clipPath: 'inset(0 calc(var(--inset, 0) * -1%) 0 0)' }} />
      <div className="spread">
        <h1 className="headline">{[...HEADLINE].map((c, i) => <span key={i} className="char">{c === ' ' ? '\u00A0' : c}</span>)}</h1>
      </div>
    </section>
  );
}
```

```css
.editorial-hero { position: relative; min-height: 100vh; background: var(--color-ink); display: grid; place-items: center; perspective: 1500px; overflow: hidden; }
.curtain { position: absolute; top: 0; bottom: 0; width: 50%; background: var(--color-bone); z-index: 2; }
.curtain-l { left: 0; }
.curtain-r { right: 0; }
.spread { transform-style: preserve-3d; z-index: 1; }
.headline {
  font-family: var(--font-display); font-size: clamp(2.5rem, 8vw, 6rem);
  color: var(--color-amber); text-transform: uppercase; white-space: nowrap;
}
.headline .char { display: inline-block; will-change: transform; }
@media (prefers-reduced-motion: reduce) {
  .curtain { display: none !important; }
  .spread, .headline, .headline .char { transform: none !important; opacity: 1 !important; letter-spacing: 0.02em !important; }
}
```

---

## 6. Gaming — glitch slice + scanline + CRT flicker

For game studios / esports / cyberpunk brands. RGB split via duplicated layers with mix-blend-mode, scanline overlay scrolls, CRT flicker on hover, particle burst on click.

```jsx
// src/components/GlitchHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, useGSAP);

const TITLE = 'SYSTEM/07';

export default function GlitchHero() {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    const tl = gsap.timeline({ scrollTrigger: { trigger: contextRef.current, start: 'top 80%', once: true } });
    // 1. RGB split — three layers offset, blend modes
    tl.fromTo(['.title-r', '.title-g', '.title-b'],
      { xPercent: -2, opacity: 0 },
      { xPercent: (i) => [-2, 0, 2][i], opacity: 1, duration: 0.4, ease: 'power2.out', stagger: 0.04 }, 0);
    // 2. scanline scrolls down continuously
    gsap.to('.scanline', { yPercent: 100, duration: 4, repeat: -1, ease: 'none' });
    // 3. CRT flicker — opacity micro-steps
    gsap.to('.crt', { opacity: () => 0.92 + Math.random() * 0.08, duration: 0.06, repeat: -1, yoyo: true, ease: 'none' });
    // 4. glitch slice on title (random clip-path jumps)
    gsap.to('.title-r', { x: () => (Math.random() - 0.5) * 10, duration: 0.05, repeat: -1, yoyo: true, ease: 'none' });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="glitch-hero crt">
      <div className="title-stack">
        <h1 className="title title-r">{TITLE}</h1>
        <h1 className="title title-g">{TITLE}</h1>
        <h1 className="title title-b">{TITLE}</h1>
      </div>
      <div className="scanline" aria-hidden="true" />
    </section>
  );
}
```

```css
.glitch-hero { position: relative; min-height: 100vh; background: #050505; display: grid; place-items: center; overflow: hidden; }
.title-stack { position: relative; }
.title { font-family: var(--font-mono); font-size: clamp(2rem, 8vw, 5rem); margin: 0; position: absolute; top: 0; left: 0; }
.title-r { color: #ff0044; mix-blend-mode: screen; }
.title-g { color: #00ff66; mix-blend-mode: screen; }
.title-b { color: #0066ff; mix-blend-mode: screen; position: relative; }
.scanline { position: absolute; inset: 0; background: linear-gradient(to bottom, transparent 0%, rgba(255,255,255,0.05) 50%, transparent 100%); height: 30%; pointer-events: none; }
.crt { position: relative; }
.crt::after { content: ''; position: absolute; inset: 0; background: repeating-linear-gradient(0deg, rgba(0,0,0,0.15) 0px, rgba(0,0,0,0.15) 1px, transparent 1px, transparent 3px); pointer-events: none; }
@media (prefers-reduced-motion: reduce) {
  .title-r, .title-g { display: none !important; }
  .scanline, .crt::after { display: none !important; }
}
```

---

## 7. Food / drink — steam particles + pour fill

For restaurants / cafés / spirits brands. Steam particles drift up with staggered scale/opacity, slow macro zoom on hero image, pour-fill via clip-path driven by scroll scrub.

```jsx
// src/components/PourHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, useGSAP);

export default function PourHero() {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    // 1. steam particles rise with random stagger
    const steams = gsap.utils.toArray('.steam-particle');
    steams.forEach((p, i) => {
      gsap.to(p, {
        yPercent: -120, opacity: 0, scale: 1.6,
        duration: () => 2.5 + Math.random() * 1.5,
        delay: i * 0.3, repeat: -1, ease: 'sine.inOut',
      });
    });
    // 2. slow macro zoom on hero image
    gsap.to('.hero-image', { scale: 1.1, duration: 8, ease: 'none',
      scrollTrigger: { trigger: contextRef.current, start: 'top top', end: 'bottom top', scrub: true } });
    // 3. pour fill — clip-path driven by scroll
    gsap.fromTo('.pour-glass',
      { '--pour': 0 },
      { '--pour': 100, ease: 'none',
        scrollTrigger: { trigger: '.pour-section', start: 'top center', end: 'bottom center', scrub: 0.5 } });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="pour-hero">
      <div className="hero-image" />
      <div className="steam">
        {Array.from({ length: 12 }).map((_, i) => (
          <span key={i} className="steam-particle" style={{ left: `${10 + Math.random() * 80}%`, bottom: `${Math.random() * 20}%` }} />
        ))}
      </div>
      <div className="pour-section">
        <div className="pour-glass" style={{ clipPath: 'inset(calc((100 - var(--pour, 0)) * 1%) 0 0 0)' }} />
      </div>
    </section>
  );
}
```

```css
.pour-hero { position: relative; min-height: 100vh; background: var(--color-ink); overflow: hidden; }
.hero-image { position: absolute; inset: 0; background: var(--color-ink); background-size: cover; transform-origin: center; }
.steam { position: absolute; inset: 0; pointer-events: none; }
.steam-particle { position: absolute; width: 80px; height: 80px; border-radius: 50%;
  background: radial-gradient(circle, rgba(240,236,225,0.4), transparent 70%); filter: blur(8px); }
.pour-section { position: relative; height: 60vh; display: grid; place-items: center; }
.pour-glass { width: 120px; height: 200px; background: linear-gradient(to top, var(--color-amber), rgba(212,162,78,0.6)); border-radius: 0 0 12px 12px; }
@media (prefers-reduced-motion: reduce) {
  .steam-particle { display: none !important; }
  .pour-glass { clip-path: none !important; --pour: 100 !important; }
}
```

---

## 8. Outdoor / sport — momentum parallax + trail streaks + elevation gain

For outdoor / sport / adventure brands. Multi-layer parallax (different yPercent per layer), trail streaks draw on with stroke-dashoffset, elevation gain counter scrubs with scroll.

```jsx
// src/components/TrailHero.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { useLenis } from '../hooks/useLenis';
gsap.registerPlugin(ScrollTrigger, useGSAP);

export default function TrailHero({ trailPath }) {
  const { contextRef } = useGSAP();
  useLenis();
  useGSAP(() => {
    // 1. multi-layer parallax — bg moves slower than fg
    const layers = gsap.utils.toArray('.parallax-layer');
    layers.forEach((layer, i) => {
      const depth = (i + 1) * 15;
      gsap.to(layer, { yPercent: -depth, ease: 'none',
        scrollTrigger: { trigger: contextRef.current, start: 'top top', end: 'bottom top', scrub: true } });
    });
    // 2. trail streaks draw on
    gsap.fromTo('.trail path',
      { strokeDashoffset: (i, t) => t.getTotalLength(), strokeDasharray: (i, t) => t.getTotalLength() },
      { strokeDashoffset: 0, duration: 2, ease: 'power2.inOut',
        scrollTrigger: { trigger: '.trail', start: 'top 70%', end: 'bottom 30%', scrub: 0.6 } });
    // 3. elevation counter scrubs with scroll
    gsap.to({}, {
      scrollTrigger: {
        trigger: contextRef.current, start: 'top top', end: 'bottom bottom', scrub: true,
        onUpdate: (self) => {
          const elev = Math.round(self.progress * 2847);
          document.querySelector('.elevation-value').textContent = elev.toLocaleString() + 'm';
        },
      },
    });
  }, { scope: contextRef });

  return (
    <section ref={contextRef} className="trail-hero">
      <div className="parallax-layer" data-depth="1" />
      <div className="parallax-layer" data-depth="2" />
      <svg className="trail parallax-layer" data-depth="3" viewBox="0 0 1200 400">
        <path d={trailPath} stroke="var(--color-amber)" strokeWidth="2" fill="none" />
      </svg>
      <div className="elevation">
        <div className="elevation-value">0m</div>
        <div className="elevation-label">elevation gain</div>
      </div>
    </section>
  );
}
```

```css
.trail-hero { position: relative; min-height: 120vh; background: var(--color-ink); overflow: hidden; }
.parallax-layer { position: absolute; inset: -10%; }
.parallax-layer[data-depth="1"] { background: radial-gradient(ellipse at top, rgba(212,162,78,0.1), transparent 60%); }
.parallax-layer[data-depth="2"] { background: linear-gradient(to bottom, transparent 50%, var(--color-ink)); }
.trail { inset: 30% 0 0 0; }
.trail path { stroke-linecap: round; }
.elevation { position: absolute; bottom: 2rem; right: 2rem; text-align: right; color: var(--color-amber); }
.elevation-value { font-family: var(--font-mono); font-size: clamp(2rem, 5vw, 4rem); }
.elevation-label { font-family: var(--font-body); opacity: 0.6; }
@media (prefers-reduced-motion: reduce) {
  .parallax-layer { transform: none !important; }
  .trail path { stroke-dashoffset: 0 !important; stroke-dasharray: none !important; }
}
```

---

## Common — Lenis hook + reduced-motion guard

Every domain template above uses these shared pieces. Put them in `src/hooks/useLenis.js` and ensure they're called from each component that needs site-wide smooth scroll + reduced-motion respect.

```js
// src/hooks/useLenis.js
import { useEffect } from 'react';
import Lenis from 'lenis';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function useLenis() {
  useEffect(() => {
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (prefersReducedMotion) return; // no Lenis under reduced-motion

    const lenis = new Lenis({ lerp: 0.08, smoothWheel: true });
    lenis.on('scroll', ScrollTrigger.update);
    const raf = (time) => { lenis.raf(time * 1000); };
    gsap.ticker.add(raf);
    gsap.ticker.lagSmoothing(0);
    return () => {
      gsap.ticker.remove(raf);
      lenis.destroy();
    };
  }, []);
}
```

```css
/* src/styles/base.css — progressive-enhancement floor */
html { background: var(--color-ink); }
body { margin: 0; font-family: var(--font-body); color: var(--color-bone); }
.no-js .reveal { opacity: 1 !important; transform: none !important; }
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```

---

## Motion Taste Principles (mirror frontend-design methodology)

`frontend-design` achieves the **demo→enterprise leap** by being **taste-forward, not code-forward**: it commits to a bold direction, picks one unforgettable moment, refuses AI-generic choices. Apply the same discipline to motion. The depth floor above sets the *quantity* bar; this section sets the *quality* bar. Both must pass.

### Commit to an extreme motion direction

Pick one — never "some animations". State it before coding:
- **Physical / simulated** — real weight, momentum, drag, restitution (silver halide dispersion, magnetic repel, water ripple, cloth drape)
- **Mechanical / industrial** — gears, shutters, ratchets, deterministic clicks (aperture iris, film advance, CRT scanline)
- **Organic / natural** — growth, bloom, drift, breathing (vine reveal, steam rise, ambient grain)
- **Maximalist chaos** — every surface moves, dense and layered (glitch field, particle storm)
- **Restrained / surgical** — one perfect beat, nothing else moves (curtain lift, single wipe)

A page that mixes physical + maximalist + organic has no POV. Pick one, kill the others.

### Differentiation — the one screenshot moment

Name the one frame people would screenshot. If you can't name it in one sentence, the design is generic. "The cursor parts a field of silver halide crystals" is a moment. "The hero fades in" is not.

### Motion is physical, not triggered

Cursor should be a **force** in the world — displacing, attracting, repelling — not a hover trigger. The interaction model:
- Cursor approaches → nearby elements **physically respond** (translate, rotate, scale, deflect) with **distance falloff**
- Cursor leaves → elements **spring back** with elastic/restitution, never linear
- Avoid: cursor as a state toggle (hover → on, leave → off). That is a button, not a signature.

### Asymmetric motion

Uniform stagger is the AI default. Vary it:
- `stagger: { each: 0.04, from: 'center' }` — radiates outward
- `stagger: { each: 0.04, from: 'random' }` — organic, no pattern
- Function-based: `rotate: (i) => i * 7 + Math.sin(i) * 3` — breaks visual symmetry
- Distance-from-cursor-based stagger — elements nearer the cursor react first

### Atmosphere — the page is alive

A static page between interactions is dead. Add **ambient breathing**:
- Continuous `gsap.to(el, { repeat: -1, yoyo: true })` with very small amplitudes (1–3px, 1–4s)
- Grain drift, slow rotation, subtle parallax — always at low amplitude so it never competes with content
- The user should not notice it consciously; remove it and the page should feel dead

### NEVER use AI-generic motion

Banned (any one = FAIL):
- `gsap.from(el, { y: 20, opacity: 0 })` on every section — the universal AI default
- Single `ease: 'power2.out'` for all tweens — no POV
- Fade-up as the only entrance — copy-paste laziness
- Hover states that only change color — button, not signature
- Cursor effects that only change color/brightness — trigger, not force
- Centered, symmetric motion — predictable, no tension
- "Reveal on scroll" with no spatial metaphor — fade-ups dressed as reveals

### Match complexity to vision

A physical simulation needs real per-frame math (rAF + vector math), not a gsap tween. A curtain lift needs one timeline. Don't write 200 lines for a fade, don't write 5 lines for a particle field. The motion-templates below show the *right* complexity for each metaphor.

---

## 9. Photography / Scientific — silver halide crystal dispersion

The signature for photography / scientific / material brands. A field of small "silver halide" crystals (the light-sensitive crystals on real film) sits on a surface. As the cursor moves through the field, nearby crystals **physically disperse** outward — translating, rotating, scaling down — then **spring back** with elastic restitution when the cursor leaves. The cursor is a wave of light; the crystals are the photographic substrate parting around it. Cool serves the literal subject of photography.

This is the most demanding template — it requires per-frame vector math, not a tween. Use it when the page warrants a real physical moment.

```jsx
// src/components/SilverHalideField.jsx
import { useGSAP } from '@gsap/react';
import gsap from 'gsap';
import { useRef, useMemo } from 'react';
import { useLenis } from '../hooks/useLenis';

gsap.registerPlugin(useGSAP);

const COLS = 28;           // grid columns
const ROWS = 18;           // grid rows
const RADIUS = 160;        // cursor influence radius (px)
const MAX_PUSH = 80;       // max displacement (px)
const ROTATION_AMP = 1.5;  // rotation amplification (radians per push unit)

// Generate crystal grid with per-crystal jitter so it doesn't read as a perfect grid
function useCrystals() {
  return useMemo(() => {
    const cells = [];
    for (let r = 0; r < ROWS; r++) {
      for (let c = 0; c < COLS; c++) {
        const jx = (Math.random() - 0.5) * 6;
        const jy = (Math.random() - 0.5) * 6;
        const size = 2 + Math.random() * 3;
        const delay = Math.random() * 0.4;  // spring-back stagger
        cells.push({ id: r * COLS + c, c, r, jx, jy, size, delay });
      }
    }
    return cells;
  }, []);
}

export default function SilverHalideField({ className }) {
  const containerRef = useRef(null);
  const fieldRef = useRef(null);
  const crystals = useCrystals();
  useLenis();

  useGSAP(() => {
    const els = gsap.utils.toArray('.crystal');
    if (!els.length) return;

    // Store home position as data attribute (relative to field, in px)
    const fieldRect = () => fieldRef.current.getBoundingClientRect();

    els.forEach((el) => {
      const r = el.dataset.row | 0;
      const c = el.dataset.col | 0;
      // home position = relative cell origin + jitter (computed at layout)
      // we re-read on each pointermove since rect changes with scroll/resize
      el._home = null;  // lazy compute
    });

    const computeHome = (el) => {
      const fr = fieldRect();
      const er = el.getBoundingClientRect();
      return {
        x: er.left - fr.left + er.width / 2,
        y: er.top - fr.top + er.height / 2,
      };
    };

    // === Per-frame dispersion (rAF-throttled) ===
    let cursor = { x: -9999, y: -9999, active: false };
    let raf = null;
    let needsUpdate = false;

    const apply = () => {
      needsUpdate = false;
      const fr = fieldRect();
      // cursor in field-local coords
      const cx = cursor.x - fr.left;
      const cy = cursor.y - fr.top;

      for (const el of els) {
        if (!el._home) el._home = computeHome(el);
        const dx = el._home.x - cx;
        const dy = el._home.y - cy;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < RADIUS) {
          const force = (1 - dist / RADIUS);
          const nx = dx / (dist || 1);
          const ny = dy / (dist || 1);
          const push = force * MAX_PUSH;
          const rot = force * ROTATION_AMP * (Math.sign(dy) || 1);
          const scale = 1 - force * 0.4;
          el.style.transform = `translate(${nx * push}px, ${ny * push}px) rotate(${rot}rad) scale(${scale})`;
          el.style.opacity = 1 - force * 0.3;
        } else {
          // outside influence — let spring-back handle it
        }
      }
    };

    const scheduleApply = () => {
      if (needsUpdate) return;
      needsUpdate = true;
      raf = requestAnimationFrame(apply);
    };

    // === Spring back when cursor leaves the field ===
    const springBack = () => {
      els.forEach((el, i) => {
        gsap.to(el, {
          x: 0, y: 0, rotation: 0, scale: 1, opacity: 1,
          duration: 1.2,
          ease: 'elastic.out(1, 0.4)',
          delay: el._springDelay || (i * 0.002),
          overwrite: 'auto',
        });
        el.style.transform = '';
      });
    };

    const onMove = (e) => {
      cursor.x = e.clientX;
      cursor.y = e.clientY;
      cursor.active = true;
      // kill any spring-back in progress
      gsap.killTweensOf(els);
      scheduleApply();
    };
    const onLeave = () => {
      cursor.active = false;
      cursor.x = -9999; cursor.y = -9999;
      springBack();
    };

    window.addEventListener('pointermove', onMove, { passive: true });
    fieldRef.current?.addEventListener('pointerleave', onLeave);

    // === Ambient breathing (atmosphere — page is alive) ===
    gsap.to('.crystal', {
      scale: (i) => 0.96 + (i % 7) * 0.008,
      duration: () => 2.4 + Math.random(),
      repeat: -1, yoyo: true,
      ease: 'sine.inOut',
      stagger: { each: 0.02, from: 'random' },
    });

    // === Scroll-in: field draws on via stroke-dashoffset metaphor (crystals fade up staggered) ===
    gsap.from('.crystal', {
      opacity: 0, scale: 0,
      duration: 0.6, ease: 'power2.out',
      stagger: { each: 0.005, from: 'center' },
      scrollTrigger: { trigger: fieldRef.current, start: 'top 75%', once: true },
    });

    return () => {
      window.removeEventListener('pointermove', onMove);
      fieldRef.current?.removeEventListener('pointerleave', onLeave);
      if (raf) cancelAnimationFrame(raf);
    };
  }, { scope: containerRef });

  return (
    <section ref={containerRef} className={className || 'halide-field-section'}>
      <div ref={fieldRef} className="halide-field">
        {crystals.map((c) => (
          <span
            key={c.id}
            className="crystal"
            data-row={c.r}
            data-col={c.c}
            style={{
              '--size': c.size + 'px',
              '--jx': c.jx + 'px',
              '--jy': c.jy + 'px',
            }}
          />
        ))}
      </div>
    </section>
  );
}
```

```css
/* src/styles/halide-field.css */
.halide-field-section {
  position: relative;
  min-height: 80vh;
  background: var(--color-ink);
  display: grid;
  place-items: center;
  overflow: hidden;
  cursor: none;  /* custom cursor or hidden — this is a "physical" surface */
}
.halide-field {
  position: relative;
  width: 100%;
  max-width: 1200px;
  aspect-ratio: 16 / 9;
  display: grid;
  grid-template-columns: repeat(28, 1fr);
  grid-template-rows: repeat(18, 1fr);
}
.crystal {
  display: block;
  width: var(--size, 3px);
  height: var(--size, 3px);
  background: var(--color-bone);
  opacity: 0.4;
  border-radius: 50%;
  transform: translate(var(--jx, 0), var(--jy, 0));
  transform-origin: center;
  will-change: transform, opacity;
  transition: opacity 0.3s;  /* opacity can transition; transform is rAF-driven */
  mix-blend-mode: screen;
}
/* A few crystals are amber — the "exposed" silver halide */
.crystal:nth-child(7n),
.crystal:nth-child(13n) {
  background: var(--color-amber);
  opacity: 0.7;
}
/* Subtle safelight glow that follows cursor within the field */
.halide-field-section::before {
  content: '';
  position: absolute;
  inset: 0;
  background: radial-gradient(circle 200px at var(--mx, -200%) var(--my, -200%),
    rgba(212, 162, 78, 0.12), transparent 60%);
  mix-blend-mode: screen;
  pointer-events: none;
  z-index: 1;
}
@media (prefers-reduced-motion: reduce) {
  .crystal { transform: none !important; opacity: 0.5 !important; }
  .halide-field-section::before { display: none !important; }
}
@media (hover: none) {
  /* on touch, no cursor — show a static "scattered" state so the field has personality */
  .crystal { transform: translate(var(--jx, 0), var(--jy, 0)) rotate(var(--rot, 0deg)); opacity: 0.5; }
}
```
