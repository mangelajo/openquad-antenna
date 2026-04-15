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

- **Cebik's articles on quads** (indexed by G0UIH): https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Explanation of the Vf effect on loops with PVC wire: https://q82.uk/1005overf
- **W8JI — Cubical Quad** — Rigorous technical analysis: https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Construction guides

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Online calculators

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm (no Vf correction)
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Cited standards

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definition of the S-meter. 1 S unit = 6 dB, S9 at VHF = −93 dBm (5 µV into 50 Ω).

---

*73 from EA4IPW — OpenQuad v1.0*
