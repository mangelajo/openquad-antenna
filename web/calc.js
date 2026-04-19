// OpenQuad cubical quad — pure computation.
// No DOM or i18n here; see ui.js for the user-facing layer.
// See docs/TEORIA.es.md for the physics behind the constants and formulas.

export const MM_PER_INCH = 25.4;
export const SQRT2_OVER_2 = Math.SQRT2 / 2;

// Speed of light (SI, exact): c = 299,792,458 m/s.
// Expressed so λ(mm) = C_MM_MHZ / f(MHz).
export const C_MM_MHZ = 299792.458;

// Geometric resonance factors k for each element (dimensionless). A square loop
// resonates with a purely real impedance when the perimeter is k × λ. Derived
// from the classic empirical constants 1005/1030/975 ft·MHz divided by c in
// ft·MHz (983.57), but expressed directly in SI. See TEORIA.es.md §1.
export const CONSTANTS = {
  reflector: 1.047, // k_reflector = k_driven × 1.025
  driven:    1.022, // k_driven — loop geometric resonance factor
  director:  0.991, // k_director_1 = k_driven × 0.970
};
export const DIRECTOR_RATIO = 0.97;
export const SPACING_R_DE = 0.20;
export const SPACING_DIR = 0.15;

// Hub geometry (from src/all_in_one.scad): collar extends boom_around=3 mm
// total around the boom; clamp sits clamp_collar_gap=0.85 mm outside the collar.
export const BOOM_AROUND = 3;
export const CLAMP_COLLAR_GAP = 0.85;

// Half of the tip-clamp body length (regular_wire_clamp body_length=30 mm).
// Cutting the rod 15 mm short puts the rod tip near the centre of the tip
// clamp so it can slide ±15 mm for Vf fine-tuning without recutting.
export const TIP_SLIDE_MARGIN = 15;

// Pre-rendered spreader sizes (standard pultruded fiberglass: 5/32", 1/4", 5/16").
export const ROD_DIAMETERS = {
  small: 4.05,
  medium: 6.07,
  large: 8.10,
};

export const PERFORMANCE = {
  2: { gainDbd: 5.5, fbMin: 10, fbMax: 15 },
  3: { gainDbd: 7.5, fbMin: 15, fbMax: 20 },
  4: { gainDbd: 8.5, fbMin: 18, fbMax: 22 },
  5: { gainDbd: 9.2, fbMin: 20, fbMax: 25 },
  6: { gainDbd: 9.7, fbMin: 20, fbMax: 25 },
  7: { gainDbd: 10.0, fbMin: 20, fbMax: 25 },
};
export const DBD_TO_DBI = 2.15;

// Element indexing convention:
//   0 = reflector, 1 = driven, 2 = director 1, 3 = director 2, ...
export function elementConstant(index) {
  if (index === 0) return CONSTANTS.reflector;
  if (index === 1) return CONSTANTS.driven;
  const dirIdx = index - 2;
  return CONSTANTS.director * Math.pow(DIRECTOR_RATIO, dirIdx);
}

export function computePerimeterMm(kFactor, freq, vf) {
  // Perimeter = k × λ × Vf, with λ(mm) = c / f.
  return kFactor * (C_MM_MHZ / freq) * vf;
}

export function wavelengthMm(freq) {
  return C_MM_MHZ / freq;
}

export function hubOffset(boomDim) {
  // Distance from boom axis to the inner face of the spreader clamp where the
  // rod is gripped. collar_side/2 + clamp_collar_gap = (boom_dim + 3)/2 + 0.85.
  return (boomDim + BOOM_AROUND) / 2 + CLAMP_COLLAR_GAP;
}

export function rodLength(spreader, boomDim) {
  // Rod starts at the inner face of the hub clamp. Cut 15 mm shorter than the
  // corner distance so the rod tip sits near the centre of the 30 mm tip
  // clamp, giving ±15 mm of slide for Vf tuning without recutting.
  const rod = spreader - hubOffset(boomDim) - TIP_SLIDE_MARGIN;
  return rod > 0 ? rod : 0;
}

export function recommendRodDiameter(maxSpreaderMm) {
  if (!isFinite(maxSpreaderMm) || maxSpreaderMm <= 0) return null;
  if (maxSpreaderMm < 150) return ROD_DIAMETERS.small;
  if (maxSpreaderMm < 2000) return ROD_DIAMETERS.medium;
  return ROD_DIAMETERS.large;
}

// Returns an array of element records indexed 0 = reflector, 1 = driven,
// 2..N+1 = director 1..N. No names (UI layer handles i18n).
export function buildElements(freq, vf, numDirectors, boomDim) {
  const total = 2 + numDirectors;
  const out = [];
  for (let i = 0; i < total; i++) {
    const k = elementConstant(i);
    const perimeter = computePerimeterMm(k, freq, vf);
    const side = perimeter / 4;
    const spreader = side * SQRT2_OVER_2;
    out.push({
      index: i,
      perimeter,
      side,
      spreader,
      rod: rodLength(spreader, boomDim),
    });
  }
  return out;
}

// Performance estimate. Returns null for <2 elements. For >7 elements the
// result is extrapolated with diminishing returns (~0.3 dB per extra director).
export function performanceFor(totalElements) {
  if (totalElements < 2) return null;
  if (PERFORMANCE[totalElements]) {
    return { ...PERFORMANCE[totalElements], extrapolated: false };
  }
  const base = PERFORMANCE[7];
  const extra = totalElements - 7;
  return {
    gainDbd: base.gainDbd + extra * 0.3,
    fbMin: base.fbMin,
    fbMax: base.fbMax,
    extrapolated: true,
  };
}

// Returns an array of spacing records with { type, i?, j?, distance, accumulated }.
// type is one of "r-de" | "de-d1" | "d-d" (for director N → N+1, i and j are the indices).
// UI layer turns `type` + indices into a localized label.
export function buildSpacings(freq, numDirectors) {
  const lambda = C_MM_MHZ / freq;
  const out = [];
  out.push({ type: "r-de", distance: lambda * SPACING_R_DE });
  if (numDirectors >= 1) {
    out.push({ type: "de-d1", distance: lambda * SPACING_DIR });
  }
  for (let i = 1; i < numDirectors; i++) {
    out.push({ type: "d-d", i, j: i + 1, distance: lambda * SPACING_DIR });
  }
  let acc = 0;
  return out.map(s => { acc += s.distance; return { ...s, accumulated: acc }; });
}

// Recalibrate Vf from a measured resonance frequency.
// Vf_new = Vf_initial × f_measured / f_target
export function recalibrateVf(vfInitial, freqTarget, freqMeasured) {
  return (freqMeasured / freqTarget) * vfInitial;
}
