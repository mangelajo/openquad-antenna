#!/usr/bin/env python3
"""
nec2_spacing_analysis.py — Análisis NEC2 del efecto del espaciado en una Cubical Quad.

Requiere: nec2c en el PATH, Python ≥ 3.9, matplotlib, numpy.
Uso: python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5
"""

import argparse
import csv
import math
import os
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False

# ──────────────────────────────────────────────────────────────────────────────
# Constantes físicas y de diseño
# ──────────────────────────────────────────────────────────────────────────────
C_MM_MHZ  = 299_792.458          # velocidad de la luz en mm·MHz
C_FT_MHZ  = 983.5714             # velocidad de la luz en pies·MHz
K_DRIVEN  = 1.022                # factor geométrico de resonancia del driven
K_REFL_NOM = 1.047               # reflector nominal
K_DIR1    = 0.991                # primer director
DIRECTOR_RATIO = 0.97            # reducción progresiva de k para cada director adicional
WIRE_RADIUS_M = 0.0005           # radio del conductor en metros (1 mm de diámetro)
SEGMENTS_PER_SIDE = 19           # segmentos por lado; más segmentos → feed más cerca del vértice
                                  # SEG=19 → XPD ≥ 27 dB; SEG=99 → XPD ≥ 38 dB

# Configuraciones de espaciado predefinidas
SPACINGS = {
    "openquad": {
        "label": "OpenQuad (ARRL/Orr — máx. ganancia)",
        "r_de":  0.200,
        "dir":   0.150,
        "color": "#00b4d8",
    },
    "yt1vp": {
        "label": "Clásico/YT1VP (W6SAI — compromiso F/B)",
        "r_de":  (730 * 0.25) / C_FT_MHZ,   # ≈ 0.1855 λ
        "dir":   (600 * 0.25) / C_FT_MHZ,   # ≈ 0.1525 λ
        "color": "#ff6b6b",
    },
}


# ──────────────────────────────────────────────────────────────────────────────
# Geometría NEC2
# ──────────────────────────────────────────────────────────────────────────────
def director_k(index: int) -> float:
    """k-factor para el director de orden `index` (0-based)."""
    return K_DIR1 * (DIRECTOR_RATIO ** index)


def element_ks(num_directors: int) -> list[float]:
    """Lista ordenada de k-factors: [reflector, driven, dir1, dir2, …]."""
    return [K_REFL_NOM, K_DRIVEN] + [director_k(i) for i in range(num_directors)]


def boom_positions_m(k_refl: float, r_de_frac: float, dir_frac: float,
                     freq_mhz: float, num_directors: int) -> list[float]:
    """Posiciones en metros a lo largo del boom (eje X). Reflector en x=0."""
    lam_m = (C_MM_MHZ / freq_mhz) * 1e-3
    pos = [0.0, r_de_frac * lam_m]
    for _ in range(num_directors):
        pos.append(pos[-1] + dir_frac * lam_m)
    return pos


def write_nec_file(path: Path, freq_mhz: float, k_refl: float,
                   num_directors: int, r_de_frac: float, dir_frac: float) -> tuple[int, int]:
    """
    Escribe el fichero NEC2 para una quad en orientación DIAMANTE (45°),
    que es la geometría real de la MOQUAD (brazos spreader en N/S/E/W).

    Cada loop es un cuadrado girado 45°. Vértices en el plano YZ:
        S (0, -r)  ← feedpoint: H-pol natural
        E (+r,  0)
        N (0, +r)
        W (-r,  0)
    donde r = lado × √2/2 (radio centro→vértice).

    Conductores horarios: W1:S→E, W2:E→N, W3:N→W, W4:W→S
    Feed: último segmento de W4 (W→S), el más próximo al vértice S.
    XPD ≥ 27 dB con SEG=19, ≥ 38 dB con SEG=99.

    Devuelve (feed_tag, feed_seg).
    """
    ks    = element_ks(num_directors)
    ks[0] = k_refl
    pos   = boom_positions_m(k_refl, r_de_frac, dir_frac, freq_mhz, num_directors)
    lam_m = (C_MM_MHZ / freq_mhz) * 1e-3
    SQRT2_OVER_2 = math.sqrt(2) / 2

    lines = [
        f"CM Cubical Quad diamond {2+num_directors} el @ {freq_mhz} MHz",
        f"CM k_refl={k_refl:.4f}  R-DE={r_de_frac:.4f}lam  Dir={dir_frac:.4f}lam",
        f"CM Feed: last seg of W->S (driven W4), H-pol, SEG={SEGMENTS_PER_SIDE}",
        "CE",
    ]
    tag = 0
    feed_tag = feed_seg = None

    for i, k in enumerate(ks):
        side_m = k * lam_m / 4
        r      = side_m * SQRT2_OVER_2    # radio centro→vértice
        x      = pos[i]

        S = ( 0.,  -r)   # bottom — feedpoint
        E = (+r,   0.)   # right
        N = ( 0.,  +r)   # top
        W = (-r,   0.)   # left

        # W1:S→E  W2:E→N  W3:N→W  W4:W→S
        wires = [(S, E), (E, N), (N, W), (W, S)]

        for j, ((y1, z1), (y2, z2)) in enumerate(wires):
            tag += 1
            if i == 1 and j == 3:        # W4 del driven: W→S, feed en último seg
                feed_tag = tag
                feed_seg = SEGMENTS_PER_SIDE
            lines.append(
                f"GW {tag} {SEGMENTS_PER_SIDE} "
                f"{x:.6f} {y1:.6f} {z1:.6f} "
                f"{x:.6f} {y2:.6f} {z2:.6f} "
                f"{WIRE_RADIUS_M:.6f}"
            )

    lines += [
        "GE 0",
        "EK",                                    # Extended Thin Wire Kernel
        f"EX 0 {feed_tag} {feed_seg} 0 1 0",    # excitación de tensión unitaria
        f"FR 0 1 0 0 {freq_mhz} 0",             # frecuencia
        "RP 0 1 361 1000 90 0 1 1",             # patrón azimutal completo
        "EN",
    ]
    path.write_text("\n".join(lines) + "\n")
    return feed_tag, feed_seg


def run_nec2(nec_path: Path) -> Path:
    """Ejecuta nec2c y devuelve la ruta del fichero .out."""
    out_path = nec_path.with_suffix(".out")
    result = subprocess.run(
        ["nec2c", "-i", str(nec_path), "-o", str(out_path)],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        print(f"ERROR nec2c: {result.stderr[:400]}", file=sys.stderr)
        raise RuntimeError("nec2c falló")
    return out_path


def parse_azimuth_pattern(out_path: Path) -> dict[int, float]:
    """
    Lee el fichero .out de NEC2 y devuelve {phi_grados: ganancia_total_dBi}.
    La columna 5 (índice 4, 0-based) es la ganancia TOTAL en dBi.
    """
    gains: dict[int, float] = {}
    with out_path.open() as f:
        for line in f:
            parts = line.split()
            if len(parts) < 5:
                continue
            try:
                theta = float(parts[0])
                phi   = float(parts[1])
                if abs(theta - 90.0) < 0.15:
                    gains[round(phi)] = float(parts[4])
            except (ValueError, IndexError):
                pass
    return gains


def fwd_back(gains: dict[int, float]) -> tuple[float, float]:
    """Extrae ganancia adelante (phi=0) y atrás (phi=180)."""
    fwd  = gains.get(0, gains.get(360))
    back = gains.get(180)
    if fwd is None or back is None:
        raise ValueError("Patrón incompleto: faltan phi=0° o phi=180°")
    return fwd, back


def parse_feedpoint_impedance(out_path: Path, feed_tag: int,
                              segments_per_side: int) -> tuple[float, float] | None:
    """
    Extrae la impedancia de entrada Z_in = R + jX del feedpoint.

    Requiere que el fichero NEC2 se haya generado con la carta `PT -1` para que nec2c
    imprima la tabla de corrientes de todos los segmentos. En esa tabla, la línea del
    segmento de feed tiene el formato:

        TAG  ABS_SEG  V_re  V_im  I_re  I_im  R  X  |I|  phase  Pwr

    nec2c calcula directamente R y X como columnas 6 y 7 (0-based: 6, 7), por lo que
    no es necesario recalcular Z = V/I manualmente.

    Devuelve (R, X) en Ohms, o None si no se encuentra el segmento de feed.
    """
    abs_seg = (feed_tag - 1) * segments_per_side + segments_per_side   # último seg del wire
    with out_path.open() as f:
        for line in f:
            parts = line.split()
            if len(parts) < 8:
                continue
            try:
                if int(parts[0]) == feed_tag and int(parts[1]) == abs_seg:
                    R = float(parts[6])
                    X = float(parts[7])
                    return R, X
            except (ValueError, IndexError):
                pass
    return None


def swr_from_z(R: float, X: float, z0: float = 50.0) -> float:
    """SWR respecto a impedancia de línea z0 (por defecto 50 Ω)."""
    gamma_num = complex(R - z0, X)
    gamma_den = complex(R + z0, X)
    gamma = abs(gamma_num / gamma_den)
    if gamma >= 1.0:
        return 99.0
    return (1 + gamma) / (1 - gamma)


def impedance_sweep(freq_target: float, num_directors: int,
                    r_de_frac: float, dir_frac: float,
                    k_refl: float,
                    freq_range: tuple[float, float, float] = (420.0, 450.0, 1.0),
                    workdir: Path | None = None) -> list[tuple[float, float, float, float]]:
    """
    Barrido de frecuencia (manteniendo k_refl fijo) para ver cómo varía Z_in vs. f.
    Genera un único fichero NEC con carta FR multi-punto + PT -1 + XQ (sin patrón).

    Devuelve lista de (freq_MHz, R, X, SWR_50).
    """
    if workdir is None:
        workdir = Path(tempfile.mkdtemp(prefix="quad_imp_"))

    f_start, f_end, f_step = freq_range
    n_freqs = int((f_end - f_start) / f_step) + 1

    # Necesitamos generar un fichero con FR sweep + PT -1 + XQ (no RP)
    ks    = element_ks(num_directors)
    ks[0] = k_refl
    pos   = boom_positions_m(k_refl, r_de_frac, dir_frac, freq_target, num_directors)
    lam_m = (C_MM_MHZ / freq_target) * 1e-3
    SQRT2_OVER_2 = math.sqrt(2) / 2

    lines = [
        f"CM Impedance sweep — k_refl={k_refl:.3f}",
        f"CM f={f_start}-{f_end} MHz step {f_step} MHz",
        "CE",
    ]
    tag = 0
    feed_tag = None

    for i, k in enumerate(ks):
        side_m = k * lam_m / 4
        r      = side_m * SQRT2_OVER_2
        x      = pos[i]
        S = (0., -r); E = (+r, 0.); N = (0., +r); W = (-r, 0.)
        wires = [(S, E), (E, N), (N, W), (W, S)]
        for j, ((y1, z1), (y2, z2)) in enumerate(wires):
            tag += 1
            if i == 1 and j == 3:
                feed_tag = tag
            lines.append(
                f"GW {tag} {SEGMENTS_PER_SIDE} "
                f"{x:.6f} {y1:.6f} {z1:.6f} "
                f"{x:.6f} {y2:.6f} {z2:.6f} "
                f"{WIRE_RADIUS_M:.6f}"
            )

    lines += [
        "GE 0",
        "EK",
        f"EX 0 {feed_tag} {SEGMENTS_PER_SIDE} 0 1 0",
        f"FR 0 {n_freqs} 0 0 {f_start} {f_step}",
        "PT -1",     # imprime tabla de corrientes de todos los segmentos
        "XQ",        # ejecuta sin patrón de radiación (mucho más rápido)
        "EN",
    ]

    nec_path = workdir / f"impsweep_k{int(k_refl*1000)}.nec"
    nec_path.write_text("\n".join(lines) + "\n")
    out_path = run_nec2(nec_path)

    # Parsear resultados: la tabla de corrientes aparece una vez por cada frecuencia.
    # Leemos el fichero bloque por bloque.
    abs_seg = (feed_tag - 1) * SEGMENTS_PER_SIDE + SEGMENTS_PER_SIDE
    results: list[tuple[float, float, float, float]] = []
    current_freq: float | None = None
    with out_path.open() as f:
        for line in f:
            u = line.upper()
            if "FREQUENCY" in u and "MHZ" in u and "-" not in line:
                for tok in line.split():
                    try:
                        v = float(tok)
                        if f_start - 1 <= v <= f_end + 1:
                            current_freq = v
                            break
                    except ValueError:
                        pass
            parts = line.split()
            if current_freq is not None and len(parts) >= 8:
                try:
                    if int(parts[0]) == feed_tag and int(parts[1]) == abs_seg:
                        R = float(parts[6])
                        X = float(parts[7])
                        swr = swr_from_z(R, X)
                        results.append((current_freq, R, X, swr))
                        current_freq = None    # evitar doble lectura
                except (ValueError, IndexError):
                    pass
    return results


def reflector_tuning_sweep(freq: float, num_directors: int,
                           r_de_frac: float, dir_frac: float,
                           k_refl_values: list[float],
                           workdir: Path | None = None
                           ) -> list[dict]:
    """
    Barrido de k_refl a frecuencia fija: para cada valor, calcula ganancia, F/B y Z_in.
    Devuelve lista de dicts con claves: k_refl, perim_mm, gain, fb, R, X, swr.
    Útil para generar la tabla de §1.7 de TEORIA.es.md.
    """
    if workdir is None:
        workdir = Path(tempfile.mkdtemp(prefix="quad_reftune_"))

    results = []
    for k_refl in k_refl_values:
        # 1) Patrón de radiación para ganancia y F/B
        nec  = workdir / f"gain_k{int(k_refl*10000)}.nec"
        write_nec_file(nec, freq, k_refl, num_directors, r_de_frac, dir_frac)
        out  = run_nec2(nec)
        gains = parse_azimuth_pattern(out)
        try:
            fwd, back = fwd_back(gains)
            gain = fwd
            fb   = fwd - back
        except ValueError:
            gain = fb = None

        # 2) Impedancia a la frecuencia de trabajo (fichero separado con PT -1)
        imp = impedance_sweep(freq, num_directors, r_de_frac, dir_frac, k_refl,
                               freq_range=(freq, freq, 1.0), workdir=workdir)
        R, X, swr = (imp[0][1], imp[0][2], imp[0][3]) if imp else (None, None, None)

        results.append({
            "k_refl": k_refl,
            "perim_mm": k_refl * (C_MM_MHZ / freq),
            "gain": gain,
            "fb": fb,
            "R": R, "X": X, "swr": swr,
        })
    return results


# ──────────────────────────────────────────────────────────────────────────────
# Sweep principal
# ──────────────────────────────────────────────────────────────────────────────
def sweep(freq_mhz: float, num_directors: int,
          r_de_frac: float, dir_frac: float,
          k_refl_range: tuple[float, float, float] = (1.022, 1.120, 0.002),
          workdir: Path | None = None) -> list[tuple[float, float, float]]:
    """
    Barre k_refl en el rango dado. Devuelve lista de (k_refl, gain_dBi, fb_dB).
    """
    if workdir is None:
        workdir = Path(tempfile.mkdtemp(prefix="quad_nec_"))

    k_start, k_end, k_step = k_refl_range
    rows = []
    k = k_start
    while k <= k_end + k_step / 2:
        k_round = round(k, 4)
        uid  = f"k{int(k_round*10000):05d}_r{int(r_de_frac*10000):05d}"
        nec  = workdir / f"{uid}.nec"
        write_nec_file(nec, freq_mhz, k_round, num_directors, r_de_frac, dir_frac)
        out  = run_nec2(nec)
        gains = parse_azimuth_pattern(out)
        try:
            fwd, back = fwd_back(gains)
            rows.append((k_round, fwd, fwd - back))
        except ValueError as e:
            print(f"  Advertencia k={k_round:.4f}: {e}", file=sys.stderr)
        k += k_step
    return rows


# ──────────────────────────────────────────────────────────────────────────────
# Salida
# ──────────────────────────────────────────────────────────────────────────────
def print_table(label: str, rows: list[tuple[float, float, float]]) -> None:
    best_fb   = max(rows, key=lambda r: r[2])
    best_gain = max(rows, key=lambda r: r[1])
    print(f"\n{'─'*58}")
    print(f"  {label}")
    print(f"{'─'*58}")
    print(f"  {'k_refl':>8}  {'Ganancia (dBi)':>14}  {'F/B (dB)':>10}")
    for kr, gain, fb in rows:
        marks = []
        if kr == best_gain[0]: marks.append("← max gain")
        if kr == best_fb[0]:   marks.append("← max F/B")
        print(f"  {kr:.3f}       {gain:+8.2f}        {fb:8.1f}   {'  '.join(marks)}")
    print()
    print(f"  Mejor ganancia:  {best_gain[1]:+.2f} dBi ({best_gain[1]-2.15:+.2f} dBd)"
          f"  F/B={best_gain[2]:.1f} dB  (k={best_gain[0]:.3f})")
    print(f"  Mejor F/B:       {best_fb[1]:+.2f} dBi ({best_fb[1]-2.15:+.2f} dBd)"
          f"  F/B={best_fb[2]:.1f} dB  (k={best_fb[0]:.3f})")


def save_csv(path: str, results: dict[str, list[tuple[float, float, float]]]) -> None:
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["config", "k_refl", "gain_dBi", "fb_dB"])
        for name, rows in results.items():
            for kr, gain, fb in rows:
                w.writerow([name, kr, round(gain, 3), round(fb, 2)])
    print(f"\nResultados guardados en {path}")


def save_reflector_tuning_csv(path: str, results: list[dict]) -> None:
    """Guarda resultados de reflector_tuning_sweep en CSV."""
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["k_refl", "perim_mm", "gain_dBi", "fb_dB",
                    "R_ohm", "X_ohm", "swr_50"])
        for r in results:
            w.writerow([r["k_refl"], round(r["perim_mm"], 1),
                        round(r["gain"], 2) if r["gain"] is not None else "",
                        round(r["fb"], 1)   if r["fb"]   is not None else "",
                        round(r["R"], 2)    if r["R"]    is not None else "",
                        round(r["X"], 2)    if r["X"]    is not None else "",
                        round(r["swr"], 3)  if r["swr"]  is not None else ""])
    print(f"\nDatos guardados en {path}")


def save_impedance_sweep_csv(path: str,
                             all_rows: dict[float, list[tuple]]) -> None:
    """Guarda barrido de impedancia vs frecuencia."""
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["k_refl", "freq_mhz", "R_ohm", "X_ohm", "swr_50"])
        for k_refl, rows in all_rows.items():
            for (freq, R, X, swr) in rows:
                w.writerow([k_refl, freq, round(R, 2),
                            round(X, 2), round(swr, 3)])
    print(f"\nDatos guardados en {path}")


def plot_results(results: dict[str, list[tuple[float, float, float]]],
                 freq_mhz: float, out_png: str = "quad_spacing_analysis.png") -> None:
    if not HAS_MATPLOTLIB:
        print("matplotlib no disponible; se omite la gráfica.", file=sys.stderr)
        return

    BG, AX, TX, GR = "#0f1117", "#1e2130", "#e0e0e0", "#303550"
    fig = plt.figure(figsize=(13, 9))
    fig.patch.set_facecolor(BG)
    gs  = gridspec.GridSpec(2, 2, figure=fig, hspace=0.38, wspace=0.32)

    def style(ax, title):
        ax.set_facecolor(AX)
        for sp in ax.spines.values(): sp.set_color(GR)
        ax.tick_params(colors=TX, labelsize=9)
        ax.xaxis.label.set_color(TX); ax.yaxis.label.set_color(TX)
        ax.set_title(title, color=TX, fontsize=11, fontweight="bold", pad=8)
        ax.grid(True, color=GR, alpha=0.5, linewidth=0.5)

    axes = [fig.add_subplot(gs[r, c]) for r in range(2) for c in range(2)]

    for name, rows in results.items():
        cfg   = SPACINGS.get(name, {"label": name, "color": "#aaaaaa"})
        color = cfg["color"]
        label = cfg["label"]
        ks    = [r[0] for r in rows]
        gains = [r[1] for r in rows]
        fbs   = [r[2] for r in rows]

        # Plot 1: ganancia vs k
        axes[0].plot(ks, gains, color=color, lw=2, label=label)
        # Plot 2: F/B vs k
        axes[1].plot(ks, fbs,   color=color, lw=2, label=label)
        # Plot 3: trade-off curve
        axes[2].plot(fbs, gains, color=color, lw=2, label=label)

    # Plot 4: diferencia (solo si hay exactamente 2 configs con la misma rejilla de k)
    names = list(results.keys())
    if len(names) == 2:
        r1, r2 = results[names[0]], results[names[1]]
        if len(r1) == len(r2):
            delta_gain = [b[1]-a[1] for a,b in zip(r1,r2)]
            delta_fb   = [b[2]-a[2] for a,b in zip(r1,r2)]
            ks = [r[0] for r in r1]
            axes[3].plot(ks, delta_fb,   color="#f4c430", lw=2, label="Δ F/B (B−A)")
            axes[3].plot(ks, delta_gain, color="#9ecb6e", lw=2, ls="--", label="Δ Ganancia (B−A)")
            axes[3].axhline(0, color="#555", lw=0.8)
            axes[3].fill_between(ks, delta_fb, 0,
                                 where=[d>0 for d in delta_fb], alpha=0.15, color="#f4c430")

    for ax, title, xlabel, ylabel in zip(
        axes,
        ["Ganancia vs k_reflector", "F/B vs k_reflector",
         "Trade-off Ganancia ↔ F/B", f"Diferencia {names[1]} − {names[0]}" if len(names)==2 else "Δ"],
        ["k_refl", "k_refl", "F/B (dB)", "k_refl"],
        ["Ganancia (dBi)", "F/B (dB)", "Ganancia (dBi)", "Δ (dB)"],
    ):
        style(ax, title)
        ax.set_xlabel(xlabel); ax.set_ylabel(ylabel)
        ax.legend(fontsize=8, facecolor=AX, edgecolor=GR, labelcolor=TX)

    fig.suptitle(
        f"Cubical Quad — Efecto del espaciado sobre ganancia y F/B\n"
        f"{sum(len(v) for v in results.values())} simulaciones NEC2 @ {freq_mhz} MHz",
        color=TX, fontsize=12, fontweight="bold", y=0.98,
    )
    plt.savefig(out_png, dpi=150, bbox_inches="tight", facecolor=BG)
    print(f"Gráfica guardada en {out_png}")


# ──────────────────────────────────────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────────────────────────────────────
def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--freq",       type=float, default=435.0, help="Frecuencia en MHz (default: 435)")
    ap.add_argument("--elements",   type=int,   default=5,     help="Número total de elementos (default: 5)")
    ap.add_argument("--spacing-r-de", type=float, default=None,
                    help="Fracción de λ para R→DE (si se da, analiza solo esta config)")
    ap.add_argument("--spacing-dir",  type=float, default=None,
                    help="Fracción de λ entre directores (si se da, analiza solo esta config)")
    ap.add_argument("--k-start",    type=float, default=1.022, help="k_refl inicio del sweep")
    ap.add_argument("--k-end",      type=float, default=1.120, help="k_refl fin del sweep")
    ap.add_argument("--k-step",     type=float, default=0.002, help="Paso del sweep en k_refl")
    ap.add_argument("--csv",        type=str,   default=None,  help="Guardar resultados en CSV")
    ap.add_argument("--png",        type=str,   default="quad_spacing_analysis.png",
                    help="Nombre del fichero PNG de salida")
    ap.add_argument("--workdir",    type=str,   default=None,
                    help="Directorio temporal para ficheros NEC2 (default: tempdir)")
    ap.add_argument("--reflector-tuning", action="store_true",
                    help="Analiza el compromiso ganancia/F/B + impedancia variando el k del "
                         "reflector (para sección §1.7 de TEORIA). Fija el espaciado a OpenQuad.")
    ap.add_argument("--impedance-sweep", action="store_true",
                    help="Barrido de impedancia vs frecuencia para varios k_refl. "
                         "Genera tabla de Z_in y SWR (para sección §1.7 de TEORIA).")
    ap.add_argument("--full-data-dump", type=str, default=None,
                    help="Directorio donde volcar CSVs completos de todos los análisis "
                         "(para alimentar tools/nec2_plot_gallery.py).")
    args = ap.parse_args()

    num_directors = args.elements - 2
    if num_directors < 0:
        ap.error("--elements debe ser ≥ 2 (reflector + driven)")

    workdir = Path(args.workdir) if args.workdir else None

    # ── Modo --full-data-dump: volcar todos los CSV para la galería ──
    if args.full_data_dump:
        out_dir = Path(args.full_data_dump)
        out_dir.mkdir(parents=True, exist_ok=True)
        # nec2c has a hard-coded 80-char limit on the input/output filename.
        # macOS tempdirs (/var/folders/.../T/...) already eat ~60 chars, which
        # leaves no room for the per-run .nec/.out files. Use the dump dir as
        # the workdir (relative path, short) when the caller hasn't set one.
        if workdir is None:
            workdir = out_dir
        print(f"\nVolcando todos los análisis en {out_dir}/")

        # 1) Spacing sweep — ambas configs
        spacing_results: dict[str, list[tuple[float, float, float]]] = {}
        for name, cfg in SPACINGS.items():
            print(f"  Spacing sweep: {cfg['label']}")
            rows = sweep(freq_mhz=args.freq, num_directors=num_directors,
                         r_de_frac=cfg["r_de"], dir_frac=cfg["dir"],
                         k_refl_range=(args.k_start, args.k_end, args.k_step),
                         workdir=workdir)
            spacing_results[name] = rows
        save_csv(str(out_dir / "spacing_sweep.csv"), spacing_results)

        # 2) Reflector tuning detallado (paso 0.002 entre 1.020 y 1.120)
        print("  Reflector tuning sweep (detallado)...")
        k_values = [round(1.020 + 0.002 * i, 4) for i in range(51)]
        tune_results = reflector_tuning_sweep(
            freq=args.freq, num_directors=num_directors,
            r_de_frac=SPACINGS["openquad"]["r_de"],
            dir_frac=SPACINGS["openquad"]["dir"],
            k_refl_values=k_values, workdir=workdir,
        )
        save_reflector_tuning_csv(str(out_dir / "reflector_tuning.csv"),
                                  tune_results)

        # 3) Impedance sweep para 4 valores representativos de k_refl
        print("  Impedance sweep vs frecuencia...")
        imp_data: dict[float, list[tuple[float, float, float, float]]] = {}
        for k_refl in [1.047, 1.068, 1.090, 1.110]:
            rows_imp = impedance_sweep(
                freq_target=args.freq, num_directors=num_directors,
                r_de_frac=SPACINGS["openquad"]["r_de"],
                dir_frac=SPACINGS["openquad"]["dir"],
                k_refl=k_refl,
                freq_range=(args.freq - 20, args.freq + 20, 0.5),
                workdir=workdir,
            )
            imp_data[k_refl] = rows_imp
        save_impedance_sweep_csv(str(out_dir / "impedance_sweep.csv"), imp_data)

        # 4) Patrón de radiación completo para k_refl nominal y optimizados
        print("  Patrones de radiación full...")
        patterns: dict[float, dict[int, float]] = {}
        pat_dir = workdir if workdir else Path(tempfile.mkdtemp(prefix="quad_pat_"))
        for k_refl in [1.047, 1.068, 1.110]:
            nec = pat_dir / f"pattern_k{int(k_refl*1000)}.nec"
            write_nec_file(nec, args.freq, k_refl, num_directors,
                           SPACINGS["openquad"]["r_de"],
                           SPACINGS["openquad"]["dir"])
            out = run_nec2(nec)
            patterns[k_refl] = parse_azimuth_pattern(out)

        with open(out_dir / "patterns.csv", "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["k_refl", "phi_deg", "gain_dBi"])
            for k_refl, gains in patterns.items():
                for phi in sorted(gains.keys()):
                    w.writerow([k_refl, phi, round(gains[phi], 2)])
        print(f"  Patrones guardados en {out_dir}/patterns.csv")

        print(f"\n✓ Volcado completo. Ejecuta: "
              f"python3 tools/nec2_plot_gallery.py {out_dir}")
        return

    # ── Modos especiales: análisis de reflector (§1.7 de TEORIA) ──
    if args.reflector_tuning:
        print(f"\nAnálisis de ajuste del reflector — {args.elements} elementos @ {args.freq} MHz")
        print(f"Espaciado fijo: OpenQuad (R→DE=0.200λ, Dir=0.150λ)")
        k_values = [1.047, 1.068, 1.090, 1.110]
        results = reflector_tuning_sweep(
            freq=args.freq,
            num_directors=num_directors,
            r_de_frac=SPACINGS["openquad"]["r_de"],
            dir_frac=SPACINGS["openquad"]["dir"],
            k_refl_values=k_values,
            workdir=workdir,
        )
        print(f"\n  {'k_refl':>7}  {'Perím(mm)':>9}  {'Gain(dBi)':>10}  {'F/B(dB)':>8}  "
              f"{'R(Ω)':>7}  {'X(Ω)':>8}  {'SWR@50':>7}")
        print(f"  {'-'*75}")
        for r in results:
            print(f"  {r['k_refl']:>7.3f}  {r['perim_mm']:>8.0f}   "
                  f"{r['gain']:>+9.2f}  {r['fb']:>8.1f}  "
                  f"{r['R']:>7.1f}  {r['X']:>+8.1f}  {r['swr']:>7.2f}")
        print("\n  Recomendaciones:")
        print("    k=1.068: máxima ganancia, F/B moderado (uso DX)")
        print("    k=1.090: compromiso equilibrado")
        print("    k=1.110: máximo F/B, ganancia casi idéntica (EME/satélite)")
        return

    if args.impedance_sweep:
        print(f"\nBarrido de impedancia vs frecuencia @ k_refl nominal")
        for k_refl in [1.047, 1.090]:
            print(f"\n  k_refl = {k_refl}")
            rows = impedance_sweep(
                freq_target=args.freq,
                num_directors=num_directors,
                r_de_frac=SPACINGS["openquad"]["r_de"],
                dir_frac=SPACINGS["openquad"]["dir"],
                k_refl=k_refl,
                freq_range=(args.freq - 15, args.freq + 15, 1.0),
                workdir=workdir,
            )
            print(f"  {'f(MHz)':>8}  {'R(Ω)':>7}  {'X(Ω)':>8}  {'SWR@50':>7}")
            for f, R, X, swr in rows:
                mark = "  ← f_target" if abs(f - args.freq) < 0.1 else ""
                print(f"  {f:>8.1f}  {R:>7.1f}  {X:>+8.1f}  {swr:>7.2f}{mark}")
        return

    # Configuraciones a analizar
    if args.spacing_r_de is not None:
        configs_to_run = {
            "custom": {
                "label": f"Custom ({args.spacing_r_de:.4f}λ / {args.spacing_dir:.4f}λ)",
                "r_de":  args.spacing_r_de,
                "dir":   args.spacing_dir or 0.150,
                "color": "#aaaaaa",
            }
        }
    else:
        configs_to_run = SPACINGS

    print(f"\nAnálisis NEC2 — Cubical Quad {args.elements} elementos @ {args.freq} MHz")
    print(f"Sweep k_refl: {args.k_start:.3f} … {args.k_end:.3f}  (paso {args.k_step:.3f})")

    all_results: dict[str, list[tuple[float, float, float]]] = {}
    for name, cfg in configs_to_run.items():
        print(f"\n  Simulando: {cfg['label']}")
        print(f"    R→DE = {cfg['r_de']:.4f}λ   Dir = {cfg['dir']:.4f}λ")
        rows = sweep(
            freq_mhz=args.freq,
            num_directors=num_directors,
            r_de_frac=cfg["r_de"],
            dir_frac=cfg["dir"],
            k_refl_range=(args.k_start, args.k_end, args.k_step),
            workdir=workdir,
        )
        all_results[name] = rows
        print_table(cfg["label"], rows)

    if len(all_results) == 2:
        names = list(all_results.keys())
        rows_a = all_results[names[0]]
        rows_b = all_results[names[1]]
        # Comparación en k nominal (1.047)
        nom = 1.047
        a_nom = next((r for r in rows_a if abs(r[0]-nom) < 0.002), None)
        b_nom = next((r for r in rows_b if abs(r[0]-nom) < 0.002), None)
        best_a = max(rows_a, key=lambda r: r[2])
        best_b = max(rows_b, key=lambda r: r[2])
        print(f"\n{'═'*58}")
        print(f"  COMPARACIÓN FINAL")
        print(f"{'═'*58}")
        if a_nom and b_nom:
            print(f"\n  k_refl nominal ({nom}):")
            print(f"    {names[0]:12s}  Gain={a_nom[1]:+.2f} dBi  F/B={a_nom[2]:.1f} dB")
            print(f"    {names[1]:12s}  Gain={b_nom[1]:+.2f} dBi  F/B={b_nom[2]:.1f} dB")
            print(f"    Δ Ganancia = {b_nom[1]-a_nom[1]:+.2f} dB   Δ F/B = {b_nom[2]-a_nom[2]:+.1f} dB")
        print(f"\n  Máximo F/B optimizando k_refl:")
        print(f"    {names[0]:12s}  Gain={best_a[1]:+.2f} dBi  F/B={best_a[2]:.1f} dB  (k={best_a[0]:.3f})")
        print(f"    {names[1]:12s}  Gain={best_b[1]:+.2f} dBi  F/B={best_b[2]:.1f} dB  (k={best_b[0]:.3f})")
        print(f"    Δ Ganancia = {best_b[1]-best_a[1]:+.2f} dB   Δ F/B = {best_b[2]-best_a[2]:+.1f} dB")

    if args.csv:
        save_csv(args.csv, all_results)

    plot_results(all_results, args.freq, out_png=args.png)


if __name__ == "__main__":
    main()
