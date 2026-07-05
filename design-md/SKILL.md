---
name: design-md
description: Establish a design-system baseline for a frontend project using Google's DESIGN.md format (a single file with YAML design tokens plus markdown rationale that gives coding agents a persistent, structured understanding of the visual identity). Use when starting or restyling a frontend project, when the user mentions DESIGN.md, design tokens, design system, brand-to-UI, or wants colors/typography/spacing/radius locked down before UI work. Author and lint a DESIGN.md, then export tokens to Tailwind or W3C DTCG so frontend-design and gsap skills build against concrete values instead of guessing.
license: Apache-2.0 (source: github.com/google-labs-code/design.md, npm: @google/design.md)
---

# DESIGN.md — design-system baseline for frontend projects

Google's DESIGN.md is a **format specification for describing a visual identity to coding agents**. A single `DESIGN.md` file gives the agent a persistent, structured understanding of a design system: machine-readable tokens (exact values) plus human-readable prose (why those values exist and how to apply them). Put one at the project root before any UI is built, and every later skill (frontend-design, gsap, etc.) works against the same concrete source of truth instead of inventing its own palette.

Source: `github.com/google-labs-code/design.md` · npm: `@google/design.md` (current: v0.3.0, alpha).

## The two-layer format

A DESIGN.md file has exactly two layers:

1. **YAML front matter** — machine-readable design tokens, delimited by `---` fences at the top of the file. These tokens are the **normative values**.
2. **Markdown body** — human-readable design rationale organized into `##` sections. The prose provides context for how to apply the tokens.

```md
---
name: Heritage
colors:
  primary: "#1A1C1E"
  secondary: "#6C7278"
  tertiary: "#B8422E"
  neutral: "#F7F5F2"
typography:
  h1:
    fontFamily: Public Sans
    fontSize: 3rem
  body-md:
    fontFamily: Public Sans
    fontSize: 1rem
  label-caps:
    fontFamily: Space Grotesk
    fontSize: 0.75rem
rounded:
  sm: 4px
  md: 8px
spacing:
  sm: 8px
  md: 16px
components:
  button-primary:
    backgroundColor: "{colors.tertiary}"
    textColor: "{colors.on-tertiary}"
    rounded: "{rounded.sm}"
    padding: 12px
  button-primary-hover:
    backgroundColor: "{colors.tertiary-container}"
---

## Overview

Architectural Minimalism meets Journalistic Gravitas. The UI evokes a
premium matte finish — a high-end broadsheet or contemporary gallery.

## Colors

The palette is rooted in high-contrast neutrals and a single accent color.

- **Primary (#1A1C1E):** Deep ink for headlines and core text.
- **Tertiary (#B8422E):** "Boston Clay" — the sole driver for interaction.
```

An agent that reads this file produces a UI with deep ink headlines in Public Sans, a warm limestone background, and Boston Clay call-to-action buttons.

## Token schema

```yaml
version: <string>          # optional, current: "alpha"
name: <string>
description: <string>      # optional
colors:
  <token-name>: <Color>
typography:
  <token-name>: <Typography>
rounded:
  <scale-level>: <Dimension>
spacing:
  <scale-level>: <Dimension | number>
components:
  <component-name>:
    <token-name>: <string | token reference>
```

### Token types

| Type | Format | Example |
|:-----|:------|:--------|
| Color | Any CSS color (hex, `rgb()`, `oklch()`, named, etc.) | `"#1A1C1E"`, `"oklch(62% 0.18 250)"` |
| Dimension | number + unit (`px`, `em`, `rem`) | `48px`, `-0.02em` |
| Token Reference | `{path.to.token}` | `{colors.primary}` |
| Typography | object with `fontFamily`, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing`, `fontFeature`, `fontVariation` | see example above |

### Section order

Sections use `##` headings. They can be omitted, but those present **must** appear in this order:

| # | Section | Aliases |
|:--|:--------|:--------|
| 1 | Overview | Brand & Style |
| 2 | Colors | |
| 3 | Typography | |
| 4 | Layout | Layout & Spacing |
| 5 | Elevation & Depth | Elevation |
| 6 | Shapes | |
| 7 | Components | |
| 8 | Do's and Don'ts | |

### Component tokens

Components map a name to a group of sub-token properties. Variants (hover, active, pressed) are expressed as **separate** component entries with a related key name (e.g. `button-primary` → `button-primary-hover`).

Valid component properties: `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`.

### Consumer behavior for unknown content

| Scenario | Behavior |
|:---------|:---------|
| Unknown section heading | Preserve; do not error |
| Unknown color token name | Accept if value is valid |
| Unknown typography token name | Accept as valid typography |
| Unknown component property | Accept with warning |
| Duplicate section heading | Error; reject the file |

## Workflow

1. **Author** a `DESIGN.md` at the project root. Front matter first (normative tokens), then `##` sections in canonical order.
2. **Lint** it to catch broken token refs, WCAG contrast failures, orphaned tokens, section-order issues.
3. **Export** tokens to the format the frontend stack expects (Tailwind v3/v4, or W3C DTCG).
4. **Hand off** to UI-building skills (frontend-design, gsap) — they now have exact colors, fonts, spacing, radii to execute against.

## CLI — `@google/design.md`

> **Windows-critical:** the original bin name is `design.md`, whose `.md` suffix collides with the Windows Markdown file association and silently misbehaves (no output, or the file opens in an editor). Always invoke the dot-free **`designmd`** alias via `npx -p`. This is verified working on this machine.

Run any command (resolves from the public npm registry, no global install needed):

```bash
npx -p "@google/design.md" designmd lint DESIGN.md
npx -p "@google/design.md" designmd diff DESIGN.md DESIGN-v2.md
npx -p "@google/design.md" designmd export --format css-tailwind DESIGN.md > theme.css
```

All commands accept a file path or `-` for stdin. Output is JSON for `lint`/`diff`, code for `export`.

### `lint` — validate structure

```bash
npx -p "@google/design.md" designmd lint DESIGN.md
npx -p "@google/design.md" designmd lint --format json DESIGN.md
cat DESIGN.md | npx -p "@google/design.md" designmd lint -
```

Exit code `1` if errors are found, `0` otherwise.

### `diff` — detect token-level regressions between two versions

```bash
npx -p "@google/design.md" designmd diff DESIGN.md DESIGN-v2.md
```

Exit code `1` if the "after" file has more errors/warnings than the "before" file (i.e. a regression).

### `export` — emit tokens for the frontend stack

```bash
npx -p "@google/design.md" designmd export --format json-tailwind DESIGN.md > tailwind.theme.json
npx -p "@google/design.md" designmd export --format css-tailwind  DESIGN.md > theme.css
npx -p "@google/design.md" designmd export --format dtcg          DESIGN.md > tokens.json
```

| `--format` | Output | Use case |
|:-----------|:-------|:---------|
| `json-tailwind` (alias `tailwind`) | JSON | Tailwind v3 `theme.extend` object for `tailwind.config.js` |
| `css-tailwind` | CSS | Tailwind v4 `@theme { ... }` block (CSS custom properties `--color-*`, `--font-*`, `--text-*`, `--radius-*`, `--spacing-*`) |
| `dtcg` | JSON | W3C Design Tokens Format Module — interoperable with other design-token tooling |

Exit `0` on success, `1` on invalid `--format`/emitter error, `2` if input file unreadable.

### `spec` — output the format spec

> **Status: broken in v0.3.0.** The published npm package omits `dist/spec.md`, so `designmd spec` fails with "Failed to load spec.md." Do not rely on it. The condensed spec embedded in this skill is the current workaround; for the authoritative full spec see `docs/spec.md` in the source repository.

## Linting rules (9)

The linter runs these rules; each produces findings at a fixed severity.

| Rule | Severity | What it checks |
|:-----|:---------|:---------------|
| `broken-ref` | error | Token references (`{colors.primary}`) that don't resolve to any defined token |
| `missing-primary` | warning | Colors defined but no `primary` color — agents will auto-generate one |
| `contrast-ratio` | warning | Component `backgroundColor`/`textColor` pairs below WCAG AA minimum (4.5:1) |
| `orphaned-tokens` | warning | Color tokens defined but never referenced by any component |
| `token-summary` | info | Summary of how many tokens are defined in each section |
| `missing-sections` | info | Optional sections (spacing, rounded) absent when other tokens exist |
| `missing-typography` | warning | Colors defined but no typography tokens — agents will use default fonts |
| `section-order` | warning | Sections appear out of canonical order |
| `unknown-key` | warning | A top-level YAML key that looks like a typo of a known schema key (e.g. `colours:` → `colors:`); custom extension keys stay silent |

## How this skill fits with the rest of the toolbox

- **frontend-design** executes the *look* — give it the DESIGN.md (or the exported Tailwind theme) so its bold aesthetic choices land on the project's real tokens instead of generic defaults.
- **gsap-\*** skills execute *motion* — feed them the DESIGN.md's `rounded`, `spacing`, and component tokens so easing/durations/stagers match the system's rhythm.
- **performance-optimization** benefits from `export` producing a single sourced token set (fewer ad-hoc values, smaller runtime CSS).
- Treat DESIGN.md as the **upstream** artifact: tokens flow `DESIGN.md → export → tailwind theme / css vars → frontend-design + gsap implementation`.

## Status & limits

The DESIGN.md format is at version `alpha`. The spec, token schema, and CLI are under active development — expect changes. This project is not in Google's OSS Vulnerability Rewards Program.
