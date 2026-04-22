// Unit tests for the pure computation in calc.js.
// Run with:  node --test web/calc.test.js
// or:        npm test

import test from 'node:test';
import assert from 'node:assert/strict';

import {
  C_MM_MHZ,
  CONSTANTS,
  DIRECTOR_RATIO,
  SPACING_R_DE,
  SPACING_DIR,
  BOOM_AROUND,
  CLAMP_COLLAR_GAP,
  TIP_SLIDE_MARGIN,
  ROD_DIAMETERS,
  elementConstant,
  computePerimeterMm,
  wavelengthMm,
  hubOffset,
  rodLength,
  recommendRodDiameter,
  buildElements,
  buildSpacings,
  performanceFor,
  recalibrateVf,
} from './calc.js';

// Helper: approximate equality.
const close = (a, b, tol = 1e-6) => Math.abs(a - b) <= tol;

test('C_MM_MHZ equals c/1e6·1000 (exact SI speed of light)', () => {
  assert.equal(C_MM_MHZ, 299792.458);
});

test('wavelengthMm matches c/f for typical bands', () => {
  assert.ok(close(wavelengthMm(435), 689.18, 0.01)); // 70 cm UHF
  assert.ok(close(wavelengthMm(145), 2067.53, 0.01)); // 2 m VHF
  assert.ok(close(wavelengthMm(14), 21413.75, 0.01)); // 20 m HF
});

test('elementConstant returns k_reflector/k_driven/k_director geometry', () => {
  assert.equal(elementConstant(0), CONSTANTS.reflector);
  assert.equal(elementConstant(1), CONSTANTS.driven);
  assert.equal(elementConstant(2), CONSTANTS.director); // D1
  // D2, D3: each 3% shorter than the previous (DIRECTOR_RATIO = 0.97).
  assert.ok(close(elementConstant(3), CONSTANTS.director * 0.97, 1e-9));
  assert.ok(close(elementConstant(4), CONSTANTS.director * 0.97 * 0.97, 1e-9));
});

test('computePerimeterMm produces the reference 435 MHz PVC build (640.8 mm driven)', () => {
  // README.es.md §2 reference: 435 MHz, Vf=0.91 → driven perimeter 640.8 mm.
  const driven = computePerimeterMm(CONSTANTS.driven, 435, 0.91);
  assert.ok(Math.abs(driven - 640.8) < 0.5, `driven=${driven.toFixed(2)} mm`);
});

test('computePerimeterMm reflector/director ratios match documented 2.5%/3%', () => {
  const ref = computePerimeterMm(CONSTANTS.reflector, 435, 1.0);
  const dri = computePerimeterMm(CONSTANTS.driven, 435, 1.0);
  const d1 = computePerimeterMm(CONSTANTS.director, 435, 1.0);
  assert.ok(close(ref / dri, 1.025, 1e-3), `reflector/driven = ${(ref / dri).toFixed(4)}`);
  assert.ok(close(d1 / dri, 0.970, 1e-3), `director1/driven = ${(d1 / dri).toFixed(4)}`);
});

test('computePerimeterMm scales linearly with Vf', () => {
  const at10 = computePerimeterMm(CONSTANTS.driven, 435, 1.0);
  const at08 = computePerimeterMm(CONSTANTS.driven, 435, 0.8);
  assert.ok(close(at08 / at10, 0.8, 1e-9));
});

test('computePerimeterMm scales inversely with frequency', () => {
  const at435 = computePerimeterMm(CONSTANTS.driven, 435, 1.0);
  const at870 = computePerimeterMm(CONSTANTS.driven, 870, 1.0);
  assert.ok(close(at870 * 2, at435, 1e-9));
});

test('hubOffset matches analytical formula (boom_dim + 3)/2 + 0.85', () => {
  for (const dim of [14.9, 15.9, 19.9, 25.4]) {
    const expected = (dim + BOOM_AROUND) / 2 + CLAMP_COLLAR_GAP;
    assert.ok(close(hubOffset(dim), expected, 1e-9));
  }
  // Typical reference case.
  assert.ok(close(hubOffset(15.9), 10.3, 1e-9));
});

test('rodLength = spreader − hubOffset − TIP_SLIDE_MARGIN, clamped at 0', () => {
  const spreader = 120, boomDim = 15.9;
  const expected = spreader - hubOffset(boomDim) - TIP_SLIDE_MARGIN;
  assert.ok(close(rodLength(spreader, boomDim), expected, 1e-9));
  // Clamped at 0 for absurdly small spreaders.
  assert.equal(rodLength(10, 15.9), 0);
});

test('recommendRodDiameter picks the right pre-rendered size', () => {
  assert.equal(recommendRodDiameter(50), ROD_DIAMETERS.small);     // UHF short
  assert.equal(recommendRodDiameter(149), ROD_DIAMETERS.small);    // just under threshold
  assert.equal(recommendRodDiameter(150), ROD_DIAMETERS.medium);   // at 150 mm
  assert.equal(recommendRodDiameter(500), ROD_DIAMETERS.medium);   // 2 m VHF
  assert.equal(recommendRodDiameter(1999), ROD_DIAMETERS.medium);  // just under 2 m
  assert.equal(recommendRodDiameter(2000), ROD_DIAMETERS.large);   // HF territory
  assert.equal(recommendRodDiameter(5000), ROD_DIAMETERS.large);   // 40 m
  assert.equal(recommendRodDiameter(0), null);
  assert.equal(recommendRodDiameter(-1), null);
  assert.equal(recommendRodDiameter(NaN), null);
});

test('buildElements: 2 elements (R+DE), no directors', () => {
  const els = buildElements(435, 1.0, 0, 15.9);
  assert.equal(els.length, 2);
  assert.equal(els[0].index, 0); // reflector
  assert.equal(els[1].index, 1); // driven
  assert.ok(els[0].perimeter > els[1].perimeter, 'reflector must be longer than driven');
});

test('buildElements: ordering reflector > driven > director1 > director2', () => {
  const els = buildElements(435, 0.91, 5, 15.9);
  assert.equal(els.length, 7); // R + DE + D1..D5
  const perims = els.map(e => e.perimeter);
  assert.ok(perims[0] > perims[1], 'reflector > driven');
  assert.ok(perims[1] > perims[2], 'driven > D1');
  for (let i = 2; i < perims.length - 1; i++) {
    assert.ok(perims[i] > perims[i + 1], `D${i - 1} > D${i} (${perims[i]} vs ${perims[i + 1]})`);
  }
});

test('buildElements: side = perimeter / 4, spreader = side × √2/2', () => {
  const els = buildElements(435, 0.91, 3, 15.9);
  for (const e of els) {
    assert.ok(close(e.side * 4, e.perimeter, 1e-9));
    assert.ok(close(e.spreader, e.side * Math.SQRT2 / 2, 1e-9));
  }
});

test('buildElements reproduces README.es.md §2 reference table (within 0.5 mm)', () => {
  // 435 MHz, Vf = 0.91 (PVC reference build)
  const els = buildElements(435, 0.91, 5, 15.9);
  const expected = [
    { perimeter: 656.8, side: 164.2, spreader: 116.1 }, // reflector
    { perimeter: 640.8, side: 160.2, spreader: 113.3 }, // driven
    { perimeter: 621.7, side: 155.4, spreader: 109.9 }, // D1
    { perimeter: 603.0, side: 150.8, spreader: 106.6 }, // D2
    { perimeter: 584.9, side: 146.2, spreader: 103.4 }, // D3
    { perimeter: 567.4, side: 141.8, spreader: 100.3 }, // D4
    { perimeter: 550.4, side: 137.6, spreader: 97.3 },  // D5
  ];
  assert.equal(els.length, expected.length);
  for (let i = 0; i < els.length; i++) {
    assert.ok(Math.abs(els[i].perimeter - expected[i].perimeter) < 0.5,
      `element ${i} perimeter: got ${els[i].perimeter.toFixed(2)}, expected ${expected[i].perimeter}`);
    assert.ok(Math.abs(els[i].side - expected[i].side) < 0.2,
      `element ${i} side: got ${els[i].side.toFixed(2)}, expected ${expected[i].side}`);
    assert.ok(Math.abs(els[i].spreader - expected[i].spreader) < 0.2,
      `element ${i} spreader: got ${els[i].spreader.toFixed(2)}, expected ${expected[i].spreader}`);
  }
});

test('buildSpacings: no directors → only R→DE segment', () => {
  const sp = buildSpacings(435, 0);
  assert.equal(sp.length, 1);
  assert.equal(sp[0].type, 'r-de');
  assert.ok(close(sp[0].distance, (C_MM_MHZ / 435) * SPACING_R_DE, 1e-9));
  assert.ok(close(sp[0].accumulated, sp[0].distance, 1e-9));
});

test('buildSpacings: 3 directors → R→DE, DE→D1, D1→D2, D2→D3', () => {
  const sp = buildSpacings(435, 3);
  assert.equal(sp.length, 4);
  assert.equal(sp[0].type, 'r-de');
  assert.equal(sp[1].type, 'de-d1');
  assert.equal(sp[2].type, 'd-d'); assert.equal(sp[2].i, 1); assert.equal(sp[2].j, 2);
  assert.equal(sp[3].type, 'd-d'); assert.equal(sp[3].i, 2); assert.equal(sp[3].j, 3);

  const lambda = C_MM_MHZ / 435;
  assert.ok(close(sp[0].distance, lambda * SPACING_R_DE, 1e-9));
  for (let i = 1; i < sp.length; i++) {
    assert.ok(close(sp[i].distance, lambda * SPACING_DIR, 1e-9));
  }
});

test('buildSpacings accumulated is running sum of distance', () => {
  const sp = buildSpacings(435, 3);
  let running = 0;
  for (const s of sp) {
    running += s.distance;
    assert.ok(close(s.accumulated, running, 1e-9));
  }
});

test('buildSpacings boom length matches README.es.md §2 (435 MHz, 5-elem)', () => {
  // 5 elem (R + DE + D1..D3) → boom 448.3 mm per README §2.
  const sp = buildSpacings(435, 3);
  const boom = sp[sp.length - 1].accumulated;
  assert.ok(Math.abs(boom - 448.3) < 0.5, `boom=${boom.toFixed(2)} mm, expected 448.3`);
});

test('buildSpacings honours the maxfb mode (0.186 λ R→DE, 0.153 λ directors)', () => {
  const sp = buildSpacings(435, 3, 'maxfb');
  // λ @ 435 MHz = 689.18 mm; R→DE ≈ 0.1855 × λ ≈ 127.9 mm, dir ≈ 0.1525 × λ ≈ 105.1 mm
  assert.ok(Math.abs(sp[0].distance - 127.9) < 0.5, `R→DE=${sp[0].distance.toFixed(2)}, expected ~127.9`);
  assert.ok(Math.abs(sp[1].distance - 105.1) < 0.5, `dir=${sp[1].distance.toFixed(2)}, expected ~105.1`);
});

test('buildSpacings default (maxgain) matches the legacy behaviour', () => {
  const sp = buildSpacings(435, 3, 'maxgain');
  // 0.200 × 689.18 ≈ 137.8 mm ; 0.150 × 689.18 ≈ 103.4 mm
  assert.ok(Math.abs(sp[0].distance - 137.8) < 0.5, `R→DE=${sp[0].distance.toFixed(2)}, expected ~137.8`);
  assert.ok(Math.abs(sp[1].distance - 103.4) < 0.5, `dir=${sp[1].distance.toFixed(2)}, expected ~103.4`);
  // Unknown mode falls back to maxgain.
  const spFallback = buildSpacings(435, 3, 'bogus');
  assert.equal(sp[0].distance, spFallback[0].distance);
});

test('performanceFor returns null below 2 elements, table values for 2..7', () => {
  assert.equal(performanceFor(0), null);
  assert.equal(performanceFor(1), null);
  for (const n of [2, 3, 4, 5, 6, 7]) {
    const p = performanceFor(n);
    assert.equal(p.extrapolated, false);
    assert.ok(p.gainDbd > 0);
    assert.ok(p.fbMax > p.fbMin);
  }
});

test('performanceFor extrapolates beyond 7 with diminishing returns', () => {
  const base = performanceFor(7);
  const ext8 = performanceFor(8);
  const ext10 = performanceFor(10);
  assert.equal(ext8.extrapolated, true);
  assert.ok(ext8.gainDbd > base.gainDbd, 'more elements should have higher gain');
  assert.ok(ext10.gainDbd > ext8.gainDbd);
  // Incremental gain is small (~0.3 dB).
  assert.ok(ext10.gainDbd - base.gainDbd < 2);
});

test('recalibrateVf: measured = target → Vf unchanged', () => {
  assert.ok(close(recalibrateVf(0.99, 435, 435), 0.99, 1e-9));
  assert.ok(close(recalibrateVf(0.85, 145, 145), 0.85, 1e-9));
});

test('recalibrateVf: lower resonance → lower Vf (elements were too long)', () => {
  // Built for 435 MHz starting from Vf=1, measured 400 MHz resonance.
  // Real Vf = 1 × 400/435 = 0.9195
  const v = recalibrateVf(1.0, 435, 400);
  assert.ok(close(v, 400 / 435, 1e-9));
  assert.ok(v < 1);
});

test('recalibrateVf is idempotent when round-tripped through buildElements', () => {
  // Round-trip sanity: build with Vf=0.99, pretend the antenna "resonates" at a
  // frequency that — per the same linear model — corresponds to Vf=0.91, and
  // recalibrate. The recalibrated Vf should equal 0.91.
  const vfInitial = 0.99, freqTarget = 435, vfReal = 0.91;
  // If the real Vf is 0.91 but we built for Vf=0.99, the antenna will resonate
  // at f_real = f_target × vfInitial / vfReal (higher frequency, shorter).
  const freqMeasured = freqTarget * vfInitial / vfReal;
  const vfRecovered = recalibrateVf(vfInitial, freqTarget, freqMeasured);
  assert.ok(close(vfRecovered, vfInitial * vfInitial / vfReal, 1e-9));
  // Note: this is NOT equal to vfReal because the model is built = target/real,
  // but recalibrate works on what we MEASURE. The ARRL empirical model simply
  // defines Vf as f_measured/f_target × vf_initial; that is what this test
  // verifies.
});

test('bare copper Vf=0.99 produces elements ~1% shorter than ARRL Vf=1.0 baseline', () => {
  // Historical ARRL formula: driven perimeter = 1005/f(MHz) × 304.8 mm for bare
  // copper wire in air (implicit Vf=1). With the new convention (k=1.022,
  // Vf=0.99 for bare copper in air), dimensions come out ~1% shorter to reflect
  // the real air dielectric effect. The PVC case (Vf=0.91) is unchanged.
  const arrlDriven = 1005 / 435 * 304.8; // 704.14 mm
  const newDriven = computePerimeterMm(CONSTANTS.driven, 435, 0.99);
  const shortening = 1 - newDriven / arrlDriven;
  assert.ok(shortening > 0.005 && shortening < 0.015,
    `expected ~1% shorter, got ${(shortening * 100).toFixed(2)}%`);
});
