# Theoretical foundations of the Cubical Quad antenna

**By EA4IPW — Theoretical companion to the OpenQuad guide**

This document gathers the theoretical foundations, formulas and references that underpin the design of a Cubical Quad antenna. The practical build case is documented in [README.en.md](README.en.md).

The cubical quad is a parasitic-element antenna (like a Yagi) where each element is a full-wavelength square loop. Compared to an equivalent Yagi, it offers ~2 dB more gain for the same number of elements, a better front-to-back ratio, and a feedpoint impedance closer to 50 Ω.

The formulas and procedures in this guide are valid for any frequency.

---

## 1. The formulas and where they come from

### 1.1. The base constant: from the speed of light to the magic value "1005"

This constant has appeared in the antenna literature since the 1960s (see references at the end), but let's see where it comes from.

The wavelength in vacuum is:

    λ = c / f

Where c = 299,792,458 m/s. Expressed in feet:

    λ (feet) = 983.57 / f(MHz)

A one-wavelength square loop does not resonate exactly at the theoretical λ. The effects of current flowing around the corners and the curvature of the field mean that it needs to be slightly longer (~2.2%) in order to resonate. This gives the classic empirical constant:

    983.57 × 1.021 ≈ 1005

**Note:** Unlike a dipole, which is *shortened* by ~5% with respect to theoretical (from 492 to 468) due to the "end effect" at its open ends, a closed loop needs to be *longer* because it has no open ends.

### 1.2. Formulas for each element

The formulas give the **total perimeter of the loop**:

| Element | Perimeter (feet) | Perimeter (mm) | Origin |
|---|---|---|---|
| Driven element | 1005 / f | 1005 / f × 304.8 | Resonance at f |
| Reflector | 1030 / f | 1030 / f × 304.8 | ~2.5% longer → inductive |
| Director 1 | 975 / f | 975 / f × 304.8 | ~3% shorter → capacitive |
| Director N+1 | Director_N × 0.97 | Director_N × 0.97 | 3% series |

Where f is in MHz.

**Derived dimensions:**

- Length of one side of the square: `side = perimeter / 4`
- Length of the spreader arm (from center to corner): `spreader = side × √2 / 2 = side × 0.7071`

### 1.3. Where the constants 1030 and 975 come from

They are not arbitrary. They start from the base constant of the driven element (1005):

| Constant | Calculation | Function |
|---|---|---|
| 1005 | 984 × 1.021 | Loop resonant at the working frequency |
| 1030 | 1005 × 1.025 | Reflector: 2.5% longer → resonates below → inductive |
| 975 | 1005 × 0.970 | Director: 3% shorter → resonates above → capacitive |

The inductive reflector and the capacitive director produce the phase shift needed for the antenna to radiate in a single direction (from the reflector toward the directors).

### 1.4. Spacings between elements

| Segment | Distance |
|---|---|
| Reflector → Driven | 0.20λ |
| Driven → Director 1 | 0.15λ |
| Director → Director | 0.15λ |

Where λ is the free-space wavelength:

    λ (mm) = 300,000 / f(MHz)
    λ (inches) = 11,811 / f(MHz)
    λ (feet) = 984 / f(MHz)

**Important:** Spacings depend on the free-space wavelength, NOT on the velocity factor of the wire. The boom always measures the same regardless of the type of wire you use for the elements.

### 1.5. Choice of reflector→driven spacing: gain vs F/B tradeoff

The literature shows some spread on the optimum spacing between the reflector and the driven.
The two most common references are:

| Source | R→Driven | Directors | Design goal |
|---|---|---|---|
| ARRL Antenna Book / Orr & Cowan | **0.200 λ** | 0.150 λ | Maximum gain |
| W6SAI / classic calculators (e.g. YT1VP) | **0.186 λ** | 0.153 λ | Gain/F/B compromise |

The 0.186 λ value used by the classic calculators comes from the historical constant
`730 ft·MHz` expressed in imperial units:

    spacing_ft = 730 / f(MHz) × 0.25  →  spacing/λ = 730×0.25 / 983.57 ≈ 0.1855 λ

#### NEC2 simulation result (5 elements, 435 MHz)

A k_reflector sweep was run with `nec2c` for both spacing configurations. The model mirrors
the real MOQUAD geometry: **loops rotated 45° (diamond orientation)**, with the feed on the
lower vertex (S-corner) for horizontal polarization. The gain difference between the two
spacings is **negligible** (< 0.05 dBi), but the maximum achievable F/B does change:

| Configuration | k_refl optimum | Peak gain | Maximum F/B |
|---|---|---|---|
| OpenQuad 0.200 λ | 1.110 | 10.10 dBi (7.95 dBd) | **37.8 dB** |
| YT1VP  0.186 λ | 1.108 | 10.12 dBi (7.97 dBd) | **42.3 dB** |

At nominal k_refl (1.047), both configurations give essentially the same result: ~10.1 dBi
and ~7.2 dB of F/B. The F/B difference only emerges when the reflector is tuned towards the
point of maximum cancellation (longer reflector → more inductive phase shift).

**Practical conclusion:** for a typical build where the reflector length is adjusted through
a stub or by trimming the loop, the shorter spacing of the classic calculators delivers
**~4.5 dB more F/B** at the optimum point with the same gain. If F/B is the top priority
(interference rejection, EME, fixed-direction contesting), use 0.186 λ; if maximum gain with
sufficient F/B is the goal, use 0.200 λ.

The NEC2 script that generates this analysis lives in `tools/nec2_spacing_analysis.py`
(see §6 of this document).

> **References:** see §5 — Cebik W4RNL *Cubical Quad Notes* vol. 1, ch. 3
> (https://antenna2.github.io/cebik/content/bookant.html); ARRL Antenna Book ch. 12;
> Tom Rauch W8JI — "Cubical Quad Antenna" (https://www.w8ji.com/quad_cubical_quad.htm);
> W6SAI *All About Cubical Quad Antennas*, pp. 44–52.

### 1.6. Fine-tuning the reflector: the gain ↔ F/B tradeoff

The nominal calculator values (k_reflector = 1.047, i.e. 2.5% longer than the driven) are
a reasonable starting point, but **not the optimum**. Any parasitic array carries a
fundamental tradeoff: the reflector can be tuned for **maximum forward gain** or for
**maximum rear cancellation (F/B)**, but the two optima do not coincide.

#### NEC2 sweep result (5 elements, 435 MHz, diamond geometry)

| k_refl | Reflector perimeter | Forward gain | Rear gain | F/B |
|---|---|---|---|---|
| 1.047 (nominal) | 722 mm | 9.94 dBi | +2.54 dBi | 7.4 dB |
| 1.068 (max gain) | 736 mm | **10.28 dBi** | −1.92 dBi | 12.2 dB |
| 1.090 (compromise) | 751 mm | 10.16 dBi | −9.74 dBi | 19.9 dB |
| 1.110 (max F/B) | 765 mm | 9.91 dBi | **−28.2 dBi** | **38.1 dB** |

Key observation: **forward gain barely moves** (0.37 dB range across the entire sweep),
while rear gain drops by **30 dB** from the nominal reflector to the F/B-optimised one.
F/B is not gained by increasing forward radiation, but by cancelling the rear lobe.

#### Demystification: "dBi of gain" is the pattern peak

`dBi` measures the gain in the direction of **maximum radiation** (the pattern peak), not
an average or the gain in a fixed direction. In a well-aimed quad that peak coincides with
the directors' direction (phi=0°), but if the array is misadjusted the peak can steer
sideways. In this analysis we always report gain at phi=0° (forward), which coincides with
the peak in every sweep configuration.

#### The feedpoint resonance shifts — but UPWARD

A common misconception: "lengthening the reflector lowers the resonant frequency." The
opposite is true in a parasitic array:

| k_refl | Z at 435 MHz | Feedpoint f_res (X=0) | SWR @ 50Ω @ 435 MHz |
|---|---|---|---|
| 1.047 | 45 − j39 Ω | 444 MHz (+9) | 2.24 |
| 1.068 | 60 − j33 Ω | 445 MHz (+10) | 1.86 |
| 1.090 | 75 − j37 Ω | 446 MHz (+11) | 2.04 |
| 1.110 | 84 − j45 Ω | 447 MHz (+12) | 2.33 |

The driven does not change — on its own it still resonates near 435 MHz. What changes is
the **mutual coupling** between reflector and driven. The impedance matrix is:

    Z_in = Z_11 − Z_12² / Z_22

where Z_11 is the driven self-impedance, Z_22 the reflector self-impedance, and Z_12 the
mutual. Lengthening the reflector makes Z_22 more inductive, which alters the Z_12²/Z_22
term in such a way that the reactance added to the driven is **capacitive**. This shifts
the X=0 frequency upwards, not downwards.

In practice, at 435 MHz the feedpoint is always left with moderate capacitive reactance
(X ≈ −35 to −45 Ω), manageable with a gamma match, L-match, or hairpin.

#### Iterative tuning procedure

To exploit the tradeoff and push the antenna to its optimum:

1. **Build** reflector, driven and directors with the calculator's nominal dimensions
   (k_refl = 1.047), adding 15–20 mm of extra wire to the reflector perimeter as adjustment
   margin.

2. **Measure** F/B by pointing at a known beacon, or measure impedance and resonance with a
   VNA.

3. **Lengthen the reflector in ~5 mm steps** (by adding wire or with an adjustable stub),
   noting F/B after each step. F/B will climb progressively.

4. **Stop** once F/B starts to drop or becomes unstable — you have passed the optimum point.
   Back off half a step.

5. **Re-tune the matching** (gamma/L/hairpin) after fixing the reflector length, because the
   feedpoint reactance will have changed relative to the starting point.

> **Operational note:** the reflector is ALWAYS adjusted by lengthening it from the nominal
> value. It is therefore wiser to build with extra margin and trim if you overshoot than to
> come up short and have to add wire.

#### Recommended typical tradeoffs

- **Long-range / DX applications**: k_refl ≈ 1.068 (736 mm @ 435 MHz) — maximises gain,
  reasonable F/B of ~12 dB.
- **Beacon reception with rear interference / intermodulation rejection**: k_refl ≈ 1.090
  (751 mm) — you lose 0.1 dB of gain and gain 7.7 dB of F/B.
- **EME, satellite, fixed-direction contesting**: k_refl ≈ 1.108 (764 mm) — maximum F/B of
  38 dB, gain almost identical to nominal.

These values are for 5 elements. For 2 or 3 elements the differences are sharper and the
tradeoff is harsher — see Cebik, *Cubical Quad Notes* Vol. 1 ch. 3 for the full analysis.

---

## 2. The Velocity Factor (Vf): why it matters and how to calculate it

### 2.1. What Vf is

The formulas in the previous section assume **bare copper in free space** (Vf = 1.0). If you use insulated wire (PVC, polyethylene, teflon), the wave travels more slowly along the conductor, which reduces the physical length needed to resonate at the same frequency.

The insulation increases the distributed capacitance along the conductor, slowing down the propagation. This means that you need **less wire** to complete one electrical wavelength.

### 2.2. Typical Vf values

| Type of wire | Approximate Vf |
|---|---|
| Bare copper | 1.00 |
| PTFE/Teflon insulation | 0.97–0.98 |
| Polyethylene insulation | 0.95–0.96 |
| Thin PVC insulation | 0.91–0.95 |
| Thick PVC insulation (450/750V installation wire) | 0.90–0.93 |

**Warning:** These are ballpark values. The real Vf depends on the thickness of the insulation relative to the diameter of the conductor. A domestic installation wire (H07V-K, UNE-EN 50525) of 1.5 mm² has a proportionally thicker PVC jacket than the same wire in 6 mm², and therefore a lower Vf.

### 2.3. Formulas corrected with Vf

Multiply each constant by the Vf:

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (inches)
    Driven = (1005 × Vf) / f(MHz)              (feet)

The same for the constants 1030 (reflector) and 975 (director 1).

### 2.4. How to measure the Vf of your wire

The most direct method is empirical:

1. Calculate the perimeter of the driven element using the formulas for bare copper (Vf = 1.0).
2. Build the loop.
3. Also build the reflector.
4. Measure its resonance using the NanoVNA
5. Calculate your real Vf: **Vf = f_measured_resonance / f_target**

For example: if you calculated for 435 MHz but the loop resonates at 400 MHz, your Vf is 400/435 = 0.92.

In my experience, calculating the Vf with only the director element will not work;
you need to have the reflector, whose installation shifts the frequency downward.

This works because a Vf lower than 1 means that the assembly is electrically "too long" and resonates lower than expected.

---

## 3. Calculating dimensions for any frequency

For a center frequency f (in MHz) and a velocity factor Vf:

**Perimeters (mm):**

    Reflector   = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Director 1  = (975 × Vf) / f × 304.8
    Director 2  = Director 1 × 0.97
    Director 3  = Director 2 × 0.97
    ...and so on

**Perimeters (inches):**

    Reflector   = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Director 1  = (975 × Vf) / f × 12
    Director 2  = Director 1 × 0.97
    ...

**Spacings (mm):** (independent of Vf)

    Reflector → Driven:   300,000 / f × 0.20
    Driven → Director:    300,000 / f × 0.15
    Director → Director:  300,000 / f × 0.15

**Spacings (inches):**

    Reflector → Driven:   11,811 / f × 0.20
    Driven → Director:    11,811 / f × 0.15
    Director → Director:  11,811 / f × 0.15

---

## 4. Expected theoretical performance

### 4.1. Gain and F/B by configuration

| Elements | Approx. gain (dBd) | Approx. gain (dBi) | F/B ratio |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

Values in dBd (over dipole) and dBi (over isotropic). dBi = dBd + 2.15.

Beyond 4–5 elements, returns are diminishing (~0.5 dB per additional director). For most applications, 3–5 elements is the sweet spot between gain, complexity and ease of tuning.

### 4.2. Equivalence with Yagi

As a general reference, a quad of N elements performs approximately like a Yagi of N+2 elements with a boom of similar length.

### 4.3. Practical verification of F/B

Tune in a known repeater or beacon, point the antenna toward the source, note the S-meter reading, rotate 180° and compare. Each S unit of difference corresponds to ~6 dB according to the IARU Region 1 R.1 (1981) standard, although the S-meter calibration in commercial equipment can vary significantly, especially below S3 where many receivers only provide 2–3 dB per S unit.

---

## 5. References

### Books and technical documents

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" — Volumes 1, 2 and 3.** The definitive reference on quad design. Available at: https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** The classic book that popularized the quad among radio amateurs.
- **ARRL Antenna Book — Chapter 12: Quad Arrays.** Source of the 1005/1030/975 formulas.

### Online articles

- **L. B. Cebik (W4RNL) — "Cubical Quad Notes" (3 volumes).** The definitive reference on
  quad design. All volumes available in PDF at:
  https://antenna2.github.io/cebik/content/bookant.html
- **L. B. Cebik (W4RNL) — "2-Element Quads as a Function of Wire Diameter"** — NEC
  optimisation methodology that fixes the driven at resonance and tunes the reflector for
  maximum F/B. Documents the gain↔F/B tradeoff with NEC-4 data.
  https://antenna2.github.io/cebik/content/quad/q2l1.html
- **L. B. Cebik (W4RNL) — "The Quad vs. Yagi Question"** — Comparative analysis with
  parametric sweeps. Confirms that 2-element quads do not exceed ~20 dB of F/B without
  directors. https://antenna2.github.io/cebik/content/quad/qyc.html
- **Tom Rauch (W8JI) — "Cubical Quad Antenna"** — Rigorous technical analysis with NEC
  data. Direct quote on the gain/F/B tradeoff: *"if we optimize F/B ratio we can expect
  lower gain from any parasitic array"*. https://www.w8ji.com/quad_cubical_quad.htm
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** —
  Vf effect on loops with PVC wire. https://q82.uk/1005overf
- **Electronics Notes — "Yagi Feed Impedance & Matching"** — Explains the effect of
  mutual coupling on the feedpoint impedance: *"altering the element spacing has a greater
  effect on the impedance than it does the gain"*. https://www.electronics-notes.com/articles/antennas-propagation/yagi-uda-antenna-aerial/feed-impedance-matching.php
- **Wikipedia — "Yagi–Uda antenna" (Mutual impedance section)** — Mathematical formulation
  of the Z_ij coupling between driven and parasites. Key to understanding why lengthening
  the reflector SHIFTS the feedpoint resonance upwards, not downwards.
  https://en.wikipedia.org/wiki/Yagi%E2%80%93Uda_antenna
- **KD2BD (John Magliacane) — "Thoughts on Perfect Impedance Matching of a Yagi"** —
  Matching non-zero-reactance feedpoints. Useful after optimising the reflector for F/B,
  when Z_in is no longer 50 Ω. https://www.qsl.net/kd2bd/impedance_matching.html
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Construction guides

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Online calculators

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm
  Uses R→DE spacing ≈ 0.186 λ (constant `730 ft·MHz`) and director spacing ≈ 0.153 λ
  (constant `600 ft·MHz`). See §1.5 for the comparison with the 0.200 λ value used by OpenQuad.
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Recommended books (print)

- **James L. Lawson (W2PV) — "Yagi Antenna Design"** (ARRL, 1986, ISBN 0-87259-041-0).
  The classic reference on computational optimisation of parasitic arrays. The parametric
  sweep methodology (varying k_refl while keeping the driven fixed) used by OpenQuad comes
  directly from this book.
- **William I. Orr (W6SAI) — "All About Cubical Quad Antennas"** (Radio Publications,
  1959 and later editions). Historical source of the empirical constants `730/f` and
  `600/f` for spacings; an absolute classic of the quad world.
- **David B. Leeson — "Physical Design of Yagi Antennas"** (ARRL, 1992, ISBN 0-87259-381-9).
  Complements Lawson with mechanical design and matching methods. Cebik recommends it as
  a *companion book* for understanding parasitic arrays in depth.
- **ARRL Antenna Book** (current edition, ARRL). Its quad chapter lists the classic
  1005/1030/975 formulas and the 0.14–0.25 λ spacing range.

### Cited standards

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definition of the S-meter. 1 S unit = 6 dB, S9 at VHF = −93 dBm (5 µV into 50 Ω).

---

## 6. NEC2 analysis of element spacing

### 6.1. Required tool

The analyses in this document were produced with **nec2c**, the free implementation of
NEC-2 (Numerical Electromagnetics Code). Installation on Debian/Ubuntu:

```bash
sudo apt-get install nec2c
```

On macOS with Homebrew:

```bash
brew install nec2c
```

### 6.2. Analysis script: `tools/nec2_spacing_analysis.py`

The script generates NEC2 input files, runs the simulations and produces comparison plots.
It supports three analysis modes:

```bash
# MODE 1 — k_refl sweep for both spacing configurations (§1.5 analysis)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5

# MODE 2 — reflector-tuning analysis: gain + F/B + Z_in (§1.6 data)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --reflector-tuning

# MODE 3 — impedance vs frequency sweep (Z_in, SWR, feedpoint resonance)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --impedance-sweep

# Single custom configuration
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 \
        --spacing-r-de 0.200 --spacing-dir 0.150

# Save results to CSV
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --csv results.csv
```

The `--reflector-tuning` mode reproduces the §1.6 table (k=1.047, 1.068, 1.090, 1.110 with
gain, F/B, R, X and SWR). It uses NEC2's `PT -1` card to read the feed-segment current
and compute Z_in = R + jX directly.

The `--impedance-sweep` mode sweeps the frequency ±15 MHz around the target, showing how
the electrical resonance of the feedpoint (where X=0) shifts upwards as the reflector is
lengthened — the phenomenon documented in §1.6.

### 6.3. How the NEC2 model works for a quad

The MOQUAD mounts the loops **rotated 45° (diamond orientation)**, with the spreader arms
pointing N/S/E/W and the wire joining their tips. The NEC2 model mirrors this real geometry.

Each loop element is modelled as **4 straight wires forming a diamond** in the YZ plane.
The boom runs along the X axis. The four vertices are at the cardinal positions:

```
              N (0, +r)
             / \
            /   \
W (-r, 0) ●       ● E (+r, 0)
            \   /
             \ /
              S (0, -r)  ← driven feedpoint
         +z
         |
    ─────●───── +y    r = side × √2 / 2  (radius = centre→vertex distance)
```

The feedpoint sits on the **S vertex (bottom)**, which is the natural feed point for
**horizontal polarization**. The reasoning:

- From S, the W→S and S→E wires arrive/leave at ±45°.
- Their horizontal components (±Y) **add** at S → net horizontal current.
- Their vertical components (±Z) **cancel** at S → no V-pol contamination.

The feed is placed in the **last segment of the W→S wire** (the one closest to vertex S).
The more segments per side, the closer the gap sits to the vertex and the better the XPD.
With SEG=19 the gap is ~4 mm from the vertex and XPD ≥ 27 dB. With SEG=99 XPD exceeds 38 dB.

Wires in clockwise order (seen from the front, +X):

```
W1:  S → E   (bottom-right wire)    ← direction (+y, +z)/√2
W2:  E → N   (top-right wire)       ← direction (-y, +z)/√2
W3:  N → W   (top-left wire)        ← direction (-y, -z)/√2
W4:  W → S   (bottom-left wire)     ← direction (+y, -z)/√2  ← FEED here
```

NEC2 GW card format:

```
GW  tag  nseg  x1  y1  z1  x2  y2  z2  radius
```

Example for the driven element at x=0.1378 m, side s=0.1760 m (r=0.1244 m), radius=0.0005 m,
SEG=19:

```
GW  5  19  0.1378   0.0000  -0.1244  0.1378  +0.1244   0.0000  0.0005   ← W1: S→E
GW  6  19  0.1378  +0.1244   0.0000  0.1378   0.0000  +0.1244  0.0005   ← W2: E→N
GW  7  19  0.1378   0.0000  +0.1244  0.1378  -0.1244   0.0000  0.0005   ← W3: N→W
GW  8  19  0.1378  -0.1244   0.0000  0.1378   0.0000  -0.1244  0.0005   ← W4: W→S (FEED)
```

Excitation is applied to the **last segment** of wire W4 (W→S), the one closest to vertex S:

```
EX  0  8  19  0  1  0     ← tag=8 (driven W4), seg=19 (last), unit voltage
```

The full horizontal radiation pattern is obtained with:

```
RP  0  1  361  1000  90  0  1  1       ← theta=90°, phi=0..360°, 1°/step
```

### 6.4. Interpreting the .out file columns

The `RADIATION PATTERNS` section of the output file uses this format:

```
  THETA    PHI    VERTC    HORIZ    TOTAL    AXIAL   TILT  SENSE  ...
 DEGREES  DEGREES   DB       DB       DB     RATIO  DEGREES
```

- **VERTC** (col 3): vertical-polarization gain (dBi)
- **HORIZ** (col 4): horizontal-polarization gain (dBi)
- **TOTAL** (col 5): total gain (dBi) — **this is the main column**

For the diamond MOQUAD with feed at S, HORIZ ≈ TOTAL and VERTC sits ≥ 27 dB below
(XPD ≥ 27 dB with SEG=19). Reading TOTAL is the correct choice for gain and F/B analyses.

```python
# Basic pattern read in Python
gains = {}
with open("simulation.out") as f:
    for line in f:
        parts = line.split()
        try:
            theta, phi = float(parts[0]), float(parts[1])
            if abs(theta - 90.0) < 0.1:
                gains[round(phi)] = float(parts[4])   # TOTAL column
        except (ValueError, IndexError):
            pass

gain_forward = gains.get(0, gains.get(360))   # phi=0° = director direction (+X)
gain_back    = gains.get(180)                 # phi=180° = reflector direction
fb_ratio     = gain_forward - gain_back       # F/B in dB
```

### 6.5. Model validation

To confirm the diamond model is correct before running the sweep:

1. Simulate the driven element alone (no parasites). The input impedance should be
   **~100 Ω resistive** (full-wave square loop → 100–125 Ω; the 45° orientation does not
   change this value).
2. Check the polarization: VERTC should sit ≥ 25 dB below HORIZ at phi=0°. If the
   difference is smaller, the feedpoint is too far from the vertex → raise SEG.
3. Add the reflector. Gain should climb ~5 dBi relative to the isotropic dipole and F/B
   should be ≥ 10 dB.
4. Verify that the pattern peak points towards the directors (phi=0° in the model, towards +X).
5. **Note on gain:** the diamond orientation yields ~0.2 dBi less than the square
   orientation with side feed, because of the different projection of the current in the
   radiation plane. This is a real physical effect, not a model artefact.

---

*73 from EA4IPW — OpenQuad v1.0*
