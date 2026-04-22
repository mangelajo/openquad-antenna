# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenQuad is a parametric, modular cubical quad antenna design for HF/VHF/UHF bands by EA4IPW. The repo combines OpenSCAD parametric 3D models, a multilingual web calculator, and construction/theory documentation in 6 languages (es, en, it, pt, ja, zh).

## Build Commands

Requires OpenSCAD installed (auto-detected on macOS via `/Applications/OpenSCAD.app`).

```bash
make all              # Build 3 default STLs into build/
make matrix           # Build all 54 parametric variants (2 shapes x 3 boom x 3 spreader dims)
make zip              # Build 18 per-combination zip files (STL + PNG per combo)
make renders          # Render PNG previews of every STL
make docs-images      # Render matrix PNGs and copy to docs/images/generated/
make clean            # Remove build/ directory
make -j4 <target>     # Parallel builds recommended
```

Override variables: `OPENSCAD`, `OPENSCAD_FLAGS`, `RENDER_COLORSCHEME` (e.g. `make renders RENDER_COLORSCHEME=Metallic`).

## Architecture

### OpenSCAD Models (`src/`)

Two source files produce all 3D-printable components:

- **`all_in_one.scad`** — Main antenna hub: 4 boom clamps arranged around a central boom collar on a circular base plate. Print-in-place assembly with configurable gaps. Uses `antenna_spreader_clamp.scad` via `use <...>`.
- **`antenna_spreader_clamp.scad`** — Wire clamp body for spreader spikes. Has two modes:
  - `near_boom_version=true`: adds pivot cylinders and lock bumps for the all-in-one hub assembly
  - `near_boom_version=false`: standalone clamp with wire pass-through holes
  - `driven_element` flag: switches between angled wire exits (for soldering) vs horizontal pass-through

**Parametric design pattern:** Each file has three sections:
1. **Free parameters** (boom dimensions, spreader diameter) — exposed to OpenSCAD Customizer
2. **Design constants** (wall thickness, hardware dims) — marked `[Hidden]`
3. **Derived values** — computed from parameters + constants, never set manually

The matrix build varies: boom shape (round/square), boom diameter (14.9/15.9/19.9mm), spreader diameter (8.10/4.05/6.07mm).

### Web Calculator (`web/`)

Single `index.html` — vanilla HTML/JS with i18n via `data-i18n` attributes, CSS variables for light/dark mode, language selector. Deployed to GitHub Pages.

### Documentation (`docs/`)

Multilingual build guides (`README.{lang}.md`) and theory documents (`TEORIA.{lang}.md`). Documentation is written in Spanish first (`*.es.md`), then propagated to the other 5 languages.

### CI/CD (`.github/workflows/`)

- **`build-stl.yml`** — Builds matrix STLs on push/PR/release; uploads zips to GitHub releases on tag push. Uses cached OpenSCAD nightly.
- **`deploy-pages.yml`** — Deploys `web/` to GitHub Pages on changes to that directory.
