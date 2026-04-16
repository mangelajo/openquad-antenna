# OpenQuad — Modular and foldable Cubical Quad antenna

**By EA4IPW — Reference build: a 5-element quad for 435 MHz**

---

## 1. What this design is

This project documents a **modular and foldable Cubical Quad antenna design** intended to be built with 3D-printed parts, fiberglass rods as spreaders, and an aluminum boom.

The main features of the design are:

- **Modular:** each element (reflector, driven, directors) is mounted on an independent *block* that slides onto and clamps to the boom. You can build the antenna with 2, 3, 5, 6, 7 .. elements using the same hardware.
- **Foldable:** the spreaders pivot on the block, so the antenna can be collapsed for transport or storage and deployed in seconds for operation.
- **Scalable per band:** the parametric OpenSCAD design ([src/all_in_one.scad](../src/all_in_one.scad)) lets you adjust the boom and spreader diameters and regenerate the part for other boom and spreader sizes.

- **Adjustable:** the loops are held with printed clamps ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) that allow you to trim and re-clamp the wire during tuning.

This guide documents the practical construction and tuning process step by step. The theoretical foundations (origin of the 1005/1030/975 formulas, effect of velocity factor, expected performance, bibliographic references) are covered in a separate document:

> 📘 **[TEORIA.en.md](TEORIA.en.md) — Theoretical foundations and references**

The formulas are valid for any frequency; as a detailed practical example, a real build for the 70 cm band (435 MHz) with 0.5 mm² PVC installation wire is documented.

---

## 2. Dimensions for the reference build (435 MHz, Vf = 0.91)

The following dimensions correspond to the real build documented in this guide, using 0.5 mm² PVC wire with a measured velocity factor of 0.91.

> If you build for another frequency or with a different type of wire, see the general formulas and the procedure for measuring Vf in [TEORIA.en.md § 2–3](TEORIA.en.md).

**Elements:**

| Element | Perimeter (mm) | Perimeter (in) | Side (mm) | Side (in) | Spreader (mm) | Spreader (in) |
|---|---|---|---|---|---|---|
| Reflector | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| Driven | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| Director 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| Director 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| Director 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| Director 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| Director 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**Spacings:**

| Segment | Distance (mm) | Distance (in) |
|---|---|---|
| Reflector → Driven | 137.9 | 5.43 |
| Driven → Director 1 | 103.4 | 4.07 |
| Director → Director | 103.4 | 4.07 |

**Total boom length by configuration:**

| Configuration | Boom (mm) | Boom (in) |
|---|---|---|
| 2 elem (R + DE) | 137.9 | 5.43 |
| 3 elem (R + DE + D1) | 241.4 | 9.50 |
| 4 elem (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 elem (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 elem (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 elem (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. Materials

### 3.1. Wire for the elements

Any copper wire, with or without insulation, works. For insulated wire (PVC, polyethylene), remember to apply the Vf correction (see [TEORIA.en.md § 2](TEORIA.en.md)).

At VHF/UHF, sections from 0.5 mm² to 1.5 mm² work well. Thinner wire is easier to handle; thicker wire holds its shape better. My recommendation is 0.5 mm². At 435 MHz the skin depth is only 3 µm, so all the current flows along the surface of the conductor. The loss difference between 0.5 mm² and 1.5 mm² is ~0.025 dB — completely negligible. Bandwidth is reduced by ~8% with thinner wire, which is not significant in practice either.

At HF, where the elements are much larger, copper wire of 1–2 mm diameter (bare or insulated) is typically used, or even stranded wire to reduce weight.

For powers up to 50W there is no problem with thin wire. The practical limit is set by the solder joints and the insulation (PVC softens at ~70°C), not by the conductor.

### 3.2. Boom

Aluminum is ideal: light, stiff and easy to work with. A square or circular tube of a cross-section appropriate to the size of the antenna is sufficient. For UHF, a PVC tube also works perfectly.

**Does a metal boom affect the antenna?** In a quad, unlike a Yagi, the boom is perpendicular to the plane of the loops and the elements are separated from the boom by the spreaders. The effect is minimal or non-existent. **No boom correction is needed** as in a Yagi.

A wooden boom works the same but is heavier and absorbs moisture. Its dielectric effect (εr ≈ 2) could shift the frequency by ~0.1% — irrelevant in practice.

If the boom is circular instead of square, there is no electrical difference. The only consideration is mechanical: making sure the spreader hubs are fixed in the same angular orientation (see section 3.4).

### 3.3. Spreaders

Fiberglass, beech or PVC rods. They must be made of a non-conductive material. The appropriate diameter depends on the band: at VHF/UHF, 4–8 mm rods are sufficient.

### 3.4. Element alignment

All the square loops must be **aligned in the same rotational orientation** on the boom. If one element is rotated with respect to the others, the coupling between elements degrades because the current segments are no longer parallel.

- **A few degrees of error:** negligible effect.
- **45° rotation:** seriously degraded coupling, loss of gain and F/B.

With a square boom, alignment is natural. With a circular boom, ensure orientation with a set screw, a through pin, or a drop of glue.

---

## 4. Step-by-step tuning

### 4.1. Tools needed

- Antenna analyzer (NanoVNA, LiteVNA, or similar)
- Short coaxial cable with connector for the VNA
- Soldering iron and solder
- Millimeter ruler or digital caliper
- Fine cutting pliers

### 4.2. Choke balun (optional but recommended for measurement)

A choke balun at the feedpoint improves the reliability of the measurements by preventing the coax braid from radiating and altering the results. Without a choke, touching or moving the VNA cable can change the readings.

**For HF:** a classic wound choke works well: 6–10 turns of coax on a ferrite toroid (FT-140-43 or similar).

**For VHF/UHF:** do NOT use a wound choke — at high frequencies the capacitance between turns creates parasitic resonances. Instead, use **snap-on (clamp-on) ferrites** of mix 43 threaded in line on the coax just behind the feedpoint. 5–6 units provide enough impedance.

Reference for snap-on ferrites valid for VHF/UHF: Fair-Rite 0443164251 (cable ≤6.6 mm), Fair-Rite 0443167251 (cable ≤9.85 mm), or Fair-Rite 0443164151 (cable ≤12.7 mm), all in mix 43 material. Available from Mouser, DigiKey, or similar distributors.

The snap-ons open and close with your fingers, require no tools, and are completely reusable.

**Note:** Many commercial quad-type antennas have no choke and work perfectly. The quad has an intrinsically well-balanced geometry at the feedpoint. The choke is mainly for obtaining reliable measurements during tuning, not a requirement for normal use.

### 4.3. Tuning procedure

#### Step 1 — Determine the Vf of your wire

If you use bare copper, skip to step 2 (Vf = 1.0).

If you use insulated wire:

1. Calculate the perimeter of the driven element with Vf = 1.0: `perimeter = 1005 / f(MHz) × 304.8 mm`.
2. Build the loop and the reflector and measure its resonance with the VNA.
3. Calculate your real Vf: `Vf = f_measured / f_target`.
4. Recalculate all dimensions with this Vf.

> See [TEORIA.en.md § 2.4](TEORIA.en.md) for more details.

**Do not try to tune the driven in isolation to the target frequency and then add the reflector expecting it to stay put.** Coupling always shifts the frequency. There are two valid approaches:

#### Step 2 — Add the directors, one by one

1. Mount Director 1 at 0.15λ in front of the driven. Its perimeter should be ~3% shorter than the driven.
2. Measure. The frequency may rise or fall slightly depending on the coupling.
3. If the SWR is acceptable, proceed to the next director.
4. Repeat for each additional director. Each one should be 3% shorter than the previous.

**Common problem: SWR rises sharply when adding a director.** The most frequent cause is that the director is too long (too close to the resonance frequency of the driven). When a parasitic resonates at the same frequency as the driven, it absorbs maximum energy and the SWR shoots up. **Solution:** verify that the director really is 3% shorter than the driven and trim it if necessary.

#### Step 3 — Final tuning

After mounting all the elements, a fine touch-up of the driven element may be needed to center the frequency. The directors rarely need a touch-up if they were cut correctly.

**Tip:** On the VNA, use the SWR vs. frequency view (not just the Smith chart) to clearly see where the minimum and the bandwidth are.

---

## 5. Common problems and solutions

### The resonance frequency is much lower than expected

**Probable cause:** the Vf of the insulated wire has not been taken into account. A PVC wire can have Vf = 0.91–0.95, which electrically lengthens the elements.

**Solution:** measure the Vf empirically (step 1 of the procedure) and recalculate the dimensions.

### The SWR rises a lot when adding a director

**Probable cause:** the director is cut to the same length as the driven, or very close to it. When a parasitic resonates at the same frequency as the driven, it absorbs maximum energy.

**Solution:** verify that the director is 3% shorter than the driven. Trim it if necessary.

### The frequency drops when adding the reflector

**Cause:** inductive mutual coupling between reflector and driven. This is normal behavior, not an error.

**Solution:** precompensate the driven (tune it alone to a frequency higher than the target) or tune with driven + reflector mounted together.

### The frequency shifts when handling the antenna

**Cause:** at VHF/UHF, 1–2 mm of displacement at a corner easily changes the frequency.

**Solution:** secure the wires well on the spreaders before the definitive measurements, adjusting the tension so that the wire stays taut.

### The VNA measurements change when touching the cable

**Cause:** common-mode current on the outer braid of the coax. The VNA cable behaves as part of the antenna.

**Solution:** add snap-on ferrites (mix 43) at the feedpoint. If you do not have ferrites, at least keep the same cable layout between measurements.

### The SWR is good but the F/B is poor

**Probable cause:** the reflector is not well tuned. SWR and F/B are optimized at different reflector lengths.

**Solution:** try lengthening or shortening the reflector by 1–2%. Alternatively, use a shorted stub on the reflector to tune it without changing its physical length.

---

## 6. Result of the reference build

The antenna documented as an example in this guide (5 elements, 435 MHz, 0.5 mm² PVC wire, measured Vf of 0.91) achieved the following measured results:

- **SWR:** 1.1 at the minimum point (432 MHz), <1.6 at 435 MHz
- **Measured F/B:** ~6 S units of difference (S9 forward, S3 rearward) ≈ 30–36 dB
- **Impedance at resonance:** close to 50 Ω
- **Useful bandwidth (SWR < 2):** ~430–440 MHz

> To compare with the theoretical values expected in other configurations (2–7 elements) and the equivalence with Yagi, see [TEORIA.en.md § 4](TEORIA.en.md).

---

## 7. Pre-built parts

CI publishes a pre-rendered set of STLs for the most common boom and spreader sizes on every release. Each combination ships as a single zip containing the three printable parts (`all_in_one`, `driven_element`, `regular_wire_clamp`) plus PNG previews. Download the combination that matches your hardware and start printing — no OpenSCAD needed.

If none of the pre-rendered combinations matches your hardware, see [§ 7.4](#74-build-a-custom-size) below to render your own.

### 7.1. All-in-one block (boom collar + 4 clamps)

Boom shape × boom dimension as rows, spreader diameter as columns.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Round 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Round 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Round 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **Square 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Square 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Square 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. Spreader clamps

These two parts depend only on the spreader diameter (the boom shape and dimension don't matter), so there are only three variants of each.

| Spreader | Driven element | Wire clamp (parasitic) |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. Downloads

Each link is a zip with the three STLs plus PNG previews for that combination. Always pulls from the **latest release**.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Round 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **Round 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **Round 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **Square 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **Square 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **Square 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. Build a custom size

If none of the pre-rendered combinations matches your hardware (or you want to experiment with other diameters), you can render the parts yourself. There are three knobs that you'll normally touch, all on the [src/all_in_one.scad](../src/all_in_one.scad) file:

- `boom_is_round` — `true` for round tubing, `false` for square.
- `boom_dia` (round) **or** `boom_side` (square) — the boom's outer dimension in mm.
- `spreaders_dia` — outer diameter of your spreader rod in mm.

The driven element and regular wire clamp ([src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)) only depend on `spreaders_dia` and on `driven_element` (`true` / `false`).

> ⚠️ **Pre-check the all-in-one visually before slicing — especially the pivots.** This part is print-in-place: the four clamps are printed already attached to the central collar by thin pivot cylinders, with small lock-detent spheres that hold each clamp open (for printing) or folded (for transport). Unusual boom or spreader sizes can shift the geometry enough to fuse the pivots solid (clamp won't pivot) or open them up too much (lock detent won't catch). Always render the model with **F6** in OpenSCAD, then zoom into one of the pivots and confirm:
>
> - The pivot cylinder has a clear ring of clearance around it inside its hole — no fused walls.
> - The lock-detent spheres are visible as distinct features, not merged into the surrounding material.
> - The clamp body keeps a continuous gap to the pivot frame plates.
>
> If anything looks fused or zero-thickness, the values to nudge are `print_gap` and `pivot_clearance` (in the *Hidden* section near the top of [src/all_in_one.scad](../src/all_in_one.scad)).

**Option A — OpenSCAD GUI**

1. Install OpenSCAD (download a recent **2026.x nightly** from <https://openscad.org/downloads.html> — the older stable 2021.01 release is missing the manifold backend used here).
2. Open [src/all_in_one.scad](../src/all_in_one.scad). The Customizer panel on the right exposes only the four boom/spreader knobs above (the rest of the model's parameters are intentionally hidden).
3. Edit the values, press **F5** for a quick preview, then **F6** (the clock icon) to render the full geometry.
4. Inspect (especially the pivots — see warning above), then **File → Export → Export as STL…**.
5. Repeat with [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) for `driven_element=true` and `driven_element=false`.

**Option B — CLI / Makefile**

The repo ships a [Makefile](../Makefile) that wraps the OpenSCAD CLI. Requires `openscad` on your `PATH` (or pass `OPENSCAD=/path/to/openscad`).

The simplest way: edit the `boom_…` / `spreaders_dia` defaults at the top of [src/all_in_one.scad](../src/all_in_one.scad), then:

```bash
make            # builds build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl
make renders    # also generates 800×800 PNG previews
```

Or call OpenSCAD directly with `-D` overrides, leaving the source files untouched:

```bash
openscad --backend=manifold -o my_block.stl \
  -D 'boom_is_round=true' -D 'boom_dia=22.0' -D 'spreaders_dia=5.0' \
  src/all_in_one.scad

openscad --backend=manifold -o driven.stl \
  -D 'driven_element=true' -D 'spreaders_dia=5.0' \
  src/antenna_spreader_clamp.scad

openscad --backend=manifold -o wire_clamp.stl \
  -D 'driven_element=false' -D 'spreaders_dia=5.0' \
  src/antenna_spreader_clamp.scad
```

Run `make help` to see all the available targets (`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`).

---

*73 from EA4IPW — OpenQuad v1.0*
