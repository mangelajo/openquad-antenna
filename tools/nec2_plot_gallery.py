#!/usr/bin/env python3
"""
nec2_plot_gallery.py — Galería multi-idioma de gráficas técnicas del análisis NEC2.

Consume los CSVs producidos por `nec2_spacing_analysis.py --full-data-dump DIR`
y produce 4 gráficas por idioma en subdirectorios <out>/<lang>/:
    02_pareto_decision.png    — Curva gain↔F/B con zonas de uso
    03_polar_pattern.png      — Patrón polar H-pol, 3 k_refl
    06_swr_bandwidth.png      — SWR@50Ω vs frecuencia, 4 k_refl
    08_design_summary.png     — Tarjetas resumen de las 4 configuraciones

Uso:
    python3 tools/nec2_plot_gallery.py tools/data/
    python3 tools/nec2_plot_gallery.py tools/data/ --out-dir docs/images/gallery/
    python3 tools/nec2_plot_gallery.py tools/data/ --lang en     # un solo idioma
    python3 tools/nec2_plot_gallery.py tools/data/ --lang all    # default: los 6
"""

import argparse
import csv
import sys
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.font_manager as fm
import matplotlib.gridspec as gridspec
import matplotlib.pyplot as plt
import numpy as np


# ──────────────────────────────────────────────────────────────────────────────
# Paleta de colores (mismo estilo que la calculadora web)
# ──────────────────────────────────────────────────────────────────────────────
PALETTE = {
    "bg":       "#0f1117",
    "ax":       "#1e2130",
    "text":     "#e0e0e0",
    "muted":    "#8a92a8",
    "grid":     "#303550",
    "openquad": "#00b4d8",
    "yt1vp":    "#ff6b6b",
    "accent1":  "#f4c430",
    "accent2":  "#9ecb6e",
    "accent3":  "#c77dff",
    "accent4":  "#ff9500",
    "warning":  "#ff3366",
}


# ──────────────────────────────────────────────────────────────────────────────
# Strings por idioma. Todo el texto que aparece en las gráficas se define aquí.
# ──────────────────────────────────────────────────────────────────────────────
STRINGS: dict[str, dict[str, str]] = {
    "es": {
        "pareto.title":          "Compromiso ganancia ↔ F/B — selección del punto de operación",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "Ganancia (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — Cómo escoger el punto de operación",
        "pareto.zone.bad":       "Mal ajustado",
        "pareto.zone.dx":        "DX / alcance",
        "pareto.zone.balanced":  "Equilibrado",
        "pareto.zone.eme":       "EME / satélite",
        "pareto.tag.nominal":    "nominal",
        "pareto.tag.maxgain":    "max Gain",
        "pareto.tag.balanced":   "equilibrado",
        "pareto.tag.maxfb":      "max F/B",
        "polar.suptitle":        "MOQUAD — Patrón polar de radiación (H-pol, plano horizontal)",
        "polar.label.nominal":   "k=1.047 (nominal, F/B~7 dB)",
        "polar.label.maxgain":   "k=1.068 (max gain, F/B~12 dB)",
        "polar.label.maxfb":     "k=1.110 (max F/B ~38 dB)",
        "polar.dir.front":       "Directores",
        "polar.dir.back":        "Reflector",
        "swr.title":             "SWR@50Ω vs frecuencia — ancho de banda operativo",
        "swr.xlabel":            "Frecuencia (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — SWR vs frecuencia para distintos k_reflector",
        "swr.freq_target":       "f objetivo",
        "summary.suptitle":      "MOQUAD — Tarjetas de configuración (5 el., 435 MHz, geometría diamante)",
        "summary.card.nominal":  "Nominal\n(punto de partida)",
        "summary.card.maxgain":  "Max Gain\nDX / alcance",
        "summary.card.balanced": "Compromiso\nEquilibrado",
        "summary.card.maxfb":    "Max F/B\nEME / sat",
        "summary.perim":         "Perímetro",
        "summary.gain":          "Ganancia",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
    "en": {
        "pareto.title":          "Gain ↔ F/B tradeoff — choosing the operating point",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "Gain (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — How to choose the operating point",
        "pareto.zone.bad":       "Misadjusted",
        "pareto.zone.dx":        "DX / long range",
        "pareto.zone.balanced":  "Balanced",
        "pareto.zone.eme":       "EME / satellite",
        "pareto.tag.nominal":    "nominal",
        "pareto.tag.maxgain":    "max gain",
        "pareto.tag.balanced":   "balanced",
        "pareto.tag.maxfb":      "max F/B",
        "polar.suptitle":        "MOQUAD — Polar radiation pattern (H-pol, horizontal plane)",
        "polar.label.nominal":   "k=1.047 (nominal, F/B~7 dB)",
        "polar.label.maxgain":   "k=1.068 (max gain, F/B~12 dB)",
        "polar.label.maxfb":     "k=1.110 (max F/B ~38 dB)",
        "polar.dir.front":       "Directors",
        "polar.dir.back":        "Reflector",
        "swr.title":             "SWR@50Ω vs frequency — operating bandwidth",
        "swr.xlabel":            "Frequency (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — SWR vs frequency for different k_reflector",
        "swr.freq_target":       "target f",
        "summary.suptitle":      "MOQUAD — Configuration cards (5 el., 435 MHz, diamond geometry)",
        "summary.card.nominal":  "Nominal\n(starting point)",
        "summary.card.maxgain":  "Max Gain\nDX / long range",
        "summary.card.balanced": "Compromise\nBalanced",
        "summary.card.maxfb":    "Max F/B\nEME / sat",
        "summary.perim":         "Perimeter",
        "summary.gain":          "Gain",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
    "it": {
        "pareto.title":          "Compromesso guadagno ↔ F/B — scelta del punto operativo",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "Guadagno (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — Come scegliere il punto operativo",
        "pareto.zone.bad":       "Mal regolato",
        "pareto.zone.dx":        "DX / lunga distanza",
        "pareto.zone.balanced":  "Equilibrato",
        "pareto.zone.eme":       "EME / satellite",
        "pareto.tag.nominal":    "nominale",
        "pareto.tag.maxgain":    "max gain",
        "pareto.tag.balanced":   "equilibrato",
        "pareto.tag.maxfb":      "max F/B",
        "polar.suptitle":        "MOQUAD — Diagramma polare di radiazione (H-pol, piano orizzontale)",
        "polar.label.nominal":   "k=1.047 (nominale, F/B~7 dB)",
        "polar.label.maxgain":   "k=1.068 (max gain, F/B~12 dB)",
        "polar.label.maxfb":     "k=1.110 (max F/B ~38 dB)",
        "polar.dir.front":       "Direttori",
        "polar.dir.back":        "Riflettore",
        "swr.title":             "SWR@50Ω vs frequenza — banda operativa",
        "swr.xlabel":            "Frequenza (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — SWR vs frequenza per diversi k_reflector",
        "swr.freq_target":       "f obiettivo",
        "summary.suptitle":      "MOQUAD — Schede di configurazione (5 el., 435 MHz, geometria diamante)",
        "summary.card.nominal":  "Nominale\n(punto di partenza)",
        "summary.card.maxgain":  "Max Gain\nDX / lunga distanza",
        "summary.card.balanced": "Compromesso\nEquilibrato",
        "summary.card.maxfb":    "Max F/B\nEME / sat",
        "summary.perim":         "Perimetro",
        "summary.gain":          "Guadagno",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
    "pt": {
        "pareto.title":          "Compromisso ganho ↔ F/B — escolha do ponto de operação",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "Ganho (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — Como escolher o ponto de operação",
        "pareto.zone.bad":       "Mal ajustado",
        "pareto.zone.dx":        "DX / longo alcance",
        "pareto.zone.balanced":  "Equilibrado",
        "pareto.zone.eme":       "EME / satélite",
        "pareto.tag.nominal":    "nominal",
        "pareto.tag.maxgain":    "max ganho",
        "pareto.tag.balanced":   "equilibrado",
        "pareto.tag.maxfb":      "max F/B",
        "polar.suptitle":        "MOQUAD — Diagrama polar de radiação (H-pol, plano horizontal)",
        "polar.label.nominal":   "k=1.047 (nominal, F/B~7 dB)",
        "polar.label.maxgain":   "k=1.068 (max ganho, F/B~12 dB)",
        "polar.label.maxfb":     "k=1.110 (max F/B ~38 dB)",
        "polar.dir.front":       "Diretores",
        "polar.dir.back":        "Refletor",
        "swr.title":             "SWR@50Ω vs frequência — largura de banda operacional",
        "swr.xlabel":            "Frequência (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — SWR vs frequência para diferentes k_reflector",
        "swr.freq_target":       "f alvo",
        "summary.suptitle":      "MOQUAD — Cartões de configuração (5 el., 435 MHz, geometria diamante)",
        "summary.card.nominal":  "Nominal\n(ponto de partida)",
        "summary.card.maxgain":  "Max Ganho\nDX / longo alcance",
        "summary.card.balanced": "Compromisso\nEquilibrado",
        "summary.card.maxfb":    "Max F/B\nEME / sat",
        "summary.perim":         "Perímetro",
        "summary.gain":          "Ganho",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
    "ja": {
        "pareto.title":          "利得 ↔ F/B のトレードオフ — 動作点の選択",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "利得 (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — 動作点の選び方",
        "pareto.zone.bad":       "調整不良",
        "pareto.zone.dx":        "DX / 長距離",
        "pareto.zone.balanced":  "バランス",
        "pareto.zone.eme":       "EME / 衛星",
        "pareto.tag.nominal":    "公称",
        "pareto.tag.maxgain":    "最大利得",
        "pareto.tag.balanced":   "バランス",
        "pareto.tag.maxfb":      "最大 F/B",
        "polar.suptitle":        "MOQUAD — 放射パターン極座標（水平偏波、水平面）",
        "polar.label.nominal":   "k=1.047（公称、F/B~7 dB）",
        "polar.label.maxgain":   "k=1.068（最大利得、F/B~12 dB）",
        "polar.label.maxfb":     "k=1.110（最大 F/B ~38 dB）",
        "polar.dir.front":       "ディレクタ方向",
        "polar.dir.back":        "リフレクタ方向",
        "swr.title":             "SWR@50Ω 対周波数 — 動作帯域",
        "swr.xlabel":            "周波数 (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — k_reflector を変えたときの SWR 対周波数",
        "swr.freq_target":       "目標 f",
        "summary.suptitle":      "MOQUAD — 設定カード（5 エレメント、435 MHz、菱形ジオメトリ）",
        "summary.card.nominal":  "公称\n（出発点）",
        "summary.card.maxgain":  "最大利得\nDX / 長距離",
        "summary.card.balanced": "妥協点\nバランス",
        "summary.card.maxfb":    "最大 F/B\nEME / 衛星",
        "summary.perim":         "周囲長",
        "summary.gain":          "利得",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
    "zh": {
        "pareto.title":          "增益 ↔ F/B 折中 — 选择工作点",
        "pareto.xlabel":         "F/B (dB)",
        "pareto.ylabel":         "增益 (dBi)",
        "pareto.cbar":           "k_reflector",
        "pareto.suptitle":       "MOQUAD — 如何选择工作点",
        "pareto.zone.bad":       "调整不良",
        "pareto.zone.dx":        "DX / 远距离",
        "pareto.zone.balanced":  "平衡",
        "pareto.zone.eme":       "EME / 卫星",
        "pareto.tag.nominal":    "标称",
        "pareto.tag.maxgain":    "最大增益",
        "pareto.tag.balanced":   "平衡",
        "pareto.tag.maxfb":      "最大 F/B",
        "polar.suptitle":        "MOQUAD — 极坐标辐射方向图（水平极化，水平面）",
        "polar.label.nominal":   "k=1.047（标称，F/B~7 dB）",
        "polar.label.maxgain":   "k=1.068（最大增益，F/B~12 dB）",
        "polar.label.maxfb":     "k=1.110（最大 F/B ~38 dB）",
        "polar.dir.front":       "引向器方向",
        "polar.dir.back":        "反射器方向",
        "swr.title":             "SWR@50Ω vs 频率 — 工作带宽",
        "swr.xlabel":            "频率 (MHz)",
        "swr.ylabel":            "SWR",
        "swr.suptitle":          "MOQUAD — 不同 k_reflector 下的 SWR vs 频率",
        "swr.freq_target":       "目标 f",
        "summary.suptitle":      "MOQUAD — 配置卡片（5 元件，435 MHz，菱形几何）",
        "summary.card.nominal":  "标称\n（起点）",
        "summary.card.maxgain":  "最大增益\nDX / 远距离",
        "summary.card.balanced": "折中\n平衡",
        "summary.card.maxfb":    "最大 F/B\nEME / 卫星",
        "summary.perim":         "周长",
        "summary.gain":          "增益",
        "summary.fb":            "F/B",
        "summary.swr":           "SWR @ 50Ω",
    },
}
ALL_LANGS = list(STRINGS.keys())


def pick_cjk_font() -> str | None:
    """Return the name of an installed CJK-capable font, or None."""
    candidates = [
        "Hiragino Sans GB", "Hiragino Sans", "PingFang SC", "PingFang HK",
        "Heiti TC", "STHeiti", "Arial Unicode MS",
        "Noto Sans CJK JP", "Noto Sans CJK SC",
    ]
    available = {f.name for f in fm.fontManager.ttflist}
    for c in candidates:
        if c in available:
            return c
    return None


def apply_font_for_lang(lang: str) -> None:
    """Select a font that covers the glyphs needed for `lang`."""
    if lang in ("ja", "zh"):
        cjk = pick_cjk_font()
        if cjk:
            matplotlib.rcParams["font.family"] = cjk
        else:
            print(f"  ⚠ No CJK font found for {lang}; glyphs may render as boxes.",
                  file=sys.stderr)
    else:
        # DejaVu handles accents and most Latin scripts well.
        matplotlib.rcParams["font.family"] = "DejaVu Sans"


# ──────────────────────────────────────────────────────────────────────────────
# Helpers visuales
# ──────────────────────────────────────────────────────────────────────────────
def style_axes(ax, title: str = "", xlabel: str = "", ylabel: str = "") -> None:
    ax.set_facecolor(PALETTE["ax"])
    for spine in ax.spines.values():
        spine.set_color(PALETTE["grid"])
        spine.set_linewidth(0.8)
    ax.tick_params(colors=PALETTE["text"], labelsize=9)
    ax.grid(True, color=PALETTE["grid"], alpha=0.5, linewidth=0.5)
    if title:
        ax.set_title(title, color=PALETTE["text"], fontsize=12,
                     fontweight="bold", pad=10)
    if xlabel:
        ax.set_xlabel(xlabel, color=PALETTE["text"], fontsize=10)
    if ylabel:
        ax.set_ylabel(ylabel, color=PALETTE["text"], fontsize=10)


def save_figure(fig, out_path: Path) -> None:
    fig.savefig(out_path, dpi=150, bbox_inches="tight",
                facecolor=PALETTE["bg"], edgecolor="none")
    print(f"  → {out_path}")
    plt.close(fig)


# ──────────────────────────────────────────────────────────────────────────────
# Lectura de CSVs
# ──────────────────────────────────────────────────────────────────────────────
def read_spacing_sweep(path: Path):
    out = defaultdict(list)
    with open(path) as f:
        for row in csv.DictReader(f):
            out[row["config"]].append((
                float(row["k_refl"]), float(row["gain_dBi"]), float(row["fb_dB"]),
            ))
    for k in out:
        out[k].sort()
    return dict(out)


def read_reflector_tuning(path: Path):
    rows = []
    with open(path) as f:
        for row in csv.DictReader(f):
            rows.append({
                "k_refl":   float(row["k_refl"]),
                "perim_mm": float(row["perim_mm"]),
                "gain":     float(row["gain_dBi"]) if row["gain_dBi"] else None,
                "fb":       float(row["fb_dB"])    if row["fb_dB"]    else None,
                "R":        float(row["R_ohm"])    if row["R_ohm"]    else None,
                "X":        float(row["X_ohm"])    if row["X_ohm"]    else None,
                "swr":      float(row["swr_50"])   if row["swr_50"]   else None,
            })
    return rows


def read_impedance_sweep(path: Path):
    out = defaultdict(list)
    with open(path) as f:
        for row in csv.DictReader(f):
            out[float(row["k_refl"])].append((
                float(row["freq_mhz"]), float(row["R_ohm"]),
                float(row["X_ohm"]),    float(row["swr_50"]),
            ))
    for k in out:
        out[k].sort()
    return dict(out)


def read_patterns(path: Path):
    out = defaultdict(dict)
    with open(path) as f:
        for row in csv.DictReader(f):
            out[float(row["k_refl"])][float(row["phi_deg"])] = float(row["gain_dBi"])
    return dict(out)


# ──────────────────────────────────────────────────────────────────────────────
# Gráfica 02 — Curva Pareto de decisión
# ──────────────────────────────────────────────────────────────────────────────
def plot_02_pareto_decision(tune, out_dir: Path, S: dict[str, str]) -> None:
    fig, ax = plt.subplots(figsize=(11, 7))
    fig.patch.set_facecolor(PALETTE["bg"])
    style_axes(ax, S["pareto.title"], S["pareto.xlabel"], S["pareto.ylabel"])

    rows = [r for r in sorted(tune, key=lambda r: r["k_refl"])
            if r["gain"] is not None and r["fb"] is not None]
    ks    = [r["k_refl"] for r in rows]
    gains = [r["gain"]   for r in rows]
    fbs   = [r["fb"]     for r in rows]

    ax.plot(fbs, gains, color=PALETTE["muted"], lw=1.2, alpha=0.5, zorder=2)
    sc = ax.scatter(fbs, gains, c=ks, cmap="plasma", s=25, zorder=3,
                    edgecolors=PALETTE["ax"], linewidths=0.5)
    cbar = fig.colorbar(sc, ax=ax, pad=0.02)
    cbar.set_label(S["pareto.cbar"], color=PALETTE["text"])
    cbar.ax.yaxis.set_tick_params(color=PALETTE["text"], labelcolor=PALETTE["text"])
    for sp in cbar.ax.spines.values():
        sp.set_color(PALETTE["grid"])

    ylim = ax.get_ylim()
    zones = [
        (0,  10, PALETTE["warning"],  S["pareto.zone.bad"]),
        (10, 20, PALETTE["accent4"],  S["pareto.zone.dx"]),
        (20, 30, PALETTE["accent2"],  S["pareto.zone.balanced"]),
        (30, 50, PALETTE["openquad"], S["pareto.zone.eme"]),
    ]
    for f1, f2, col, label in zones:
        ax.axvspan(f1, f2, alpha=0.07, color=col)
        ax.text((f1 + f2) / 2, ylim[1] - 0.05 * (ylim[1] - ylim[0]),
                label, ha="center", va="top", color=col,
                fontsize=9, fontweight="bold")

    markers = [
        (1.047, S["pareto.tag.nominal"]),
        (1.068, S["pareto.tag.maxgain"]),
        (1.090, S["pareto.tag.balanced"]),
        (1.110, S["pareto.tag.maxfb"]),
    ]
    for k_target, tag in markers:
        row = min(rows, key=lambda r: abs(r["k_refl"] - k_target))
        ax.plot(row["fb"], row["gain"], "o", ms=10,
                mfc=PALETTE["accent3"], mec="white", mew=1.5, zorder=5)
        ax.annotate(f"k={row['k_refl']:.3f}\n{tag}",
                    xy=(row["fb"], row["gain"]),
                    xytext=(15, 10), textcoords="offset points",
                    fontsize=9, color=PALETTE["text"],
                    arrowprops=dict(arrowstyle="-", color=PALETTE["muted"], lw=0.8))

    fig.suptitle(S["pareto.suptitle"], color=PALETTE["text"],
                 fontsize=13, fontweight="bold", y=0.97)
    save_figure(fig, out_dir / "02_pareto_decision.png")


# ──────────────────────────────────────────────────────────────────────────────
# Gráfica 03 — Patrón polar overlay
# ──────────────────────────────────────────────────────────────────────────────
def plot_03_polar_pattern(patterns, out_dir: Path, S: dict[str, str]) -> None:
    fig = plt.figure(figsize=(11, 11))
    fig.patch.set_facecolor(PALETTE["bg"])
    ax = fig.add_subplot(111, projection="polar")
    ax.set_facecolor(PALETTE["ax"])

    colors = [PALETTE["openquad"], PALETTE["accent2"], PALETTE["yt1vp"]]
    labels = [S["polar.label.nominal"], S["polar.label.maxgain"], S["polar.label.maxfb"]]

    for (k_refl, gains), color, label in zip(sorted(patterns.items()), colors, labels):
        phis = sorted(gains.keys())
        theta = np.radians(phis)
        r = np.array([gains[p] for p in phis])
        r_clipped = np.maximum(r, -30)
        ax.plot(theta, r_clipped, color=color, lw=2.2, label=label)
        ax.fill(theta, r_clipped, color=color, alpha=0.08)

    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.set_rlim(-30, 12)
    ax.set_rticks([-30, -20, -10, 0, 10])
    ax.set_rlabel_position(135)
    ax.tick_params(colors=PALETTE["text"], labelsize=9)
    ax.grid(color=PALETTE["grid"], alpha=0.5, linewidth=0.5)
    for spine in ax.spines.values():
        spine.set_color(PALETTE["grid"])

    ax.annotate(S["polar.dir.front"], xy=(np.radians(0), 11.5),
                ha="center", color=PALETTE["muted"], fontsize=10, fontweight="bold")
    ax.annotate(S["polar.dir.back"], xy=(np.radians(180), 11.5),
                ha="center", color=PALETTE["muted"], fontsize=10, fontweight="bold")
    for angle in (90, 270):
        ax.annotate(f"{angle}°", xy=(np.radians(angle), 11.5),
                    ha="center", color=PALETTE["muted"], fontsize=9)

    ax.legend(loc="upper right", bbox_to_anchor=(1.25, 1.10),
              fontsize=9, facecolor=PALETTE["ax"],
              edgecolor=PALETTE["grid"], labelcolor=PALETTE["text"])

    fig.suptitle(S["polar.suptitle"], color=PALETTE["text"],
                 fontsize=13, fontweight="bold", y=0.95)
    save_figure(fig, out_dir / "03_polar_pattern.png")


# ──────────────────────────────────────────────────────────────────────────────
# Gráfica 06 — SWR vs frecuencia
# ──────────────────────────────────────────────────────────────────────────────
def plot_06_swr_bandwidth(impedance_data, freq_target: float,
                          out_dir: Path, S: dict[str, str]) -> None:
    fig, ax = plt.subplots(figsize=(12, 7))
    fig.patch.set_facecolor(PALETTE["bg"])
    style_axes(ax, S["swr.title"], S["swr.xlabel"], S["swr.ylabel"])

    colors = [PALETTE["openquad"], PALETTE["accent2"],
              PALETTE["accent4"], PALETTE["yt1vp"]]
    for (k_refl, rows), color in zip(sorted(impedance_data.items()), colors):
        freqs = [r[0] for r in rows]
        swrs  = [min(r[3], 5) for r in rows]
        ax.plot(freqs, swrs, color=color, lw=2, label=f"k_refl = {k_refl:.3f}")

    ax.axhline(1.0, color=PALETTE["accent2"], lw=0.6, ls=":", alpha=0.6)
    ax.axhline(1.5, color=PALETTE["accent1"], lw=0.8, ls="--", alpha=0.7)
    ax.axhline(2.0, color=PALETTE["warning"], lw=0.8, ls="--", alpha=0.7)
    ax.text(ax.get_xlim()[1], 1.52, " SWR 1.5:1", color=PALETTE["accent1"],
            fontsize=8, va="bottom")
    ax.text(ax.get_xlim()[1], 2.02, " SWR 2:1", color=PALETTE["warning"],
            fontsize=8, va="bottom")

    ax.axvline(freq_target, color=PALETTE["muted"], lw=0.8, ls=":", alpha=0.6)
    ax.annotate(f"{S['swr.freq_target']}\n{freq_target:.0f} MHz",
                xy=(freq_target, ax.get_ylim()[1] * 0.95),
                ha="center", color=PALETTE["muted"], fontsize=9)

    ax.set_ylim(1, 5)
    ax.legend(fontsize=9, facecolor=PALETTE["ax"],
              edgecolor=PALETTE["grid"], labelcolor=PALETTE["text"])

    fig.suptitle(S["swr.suptitle"], color=PALETTE["text"],
                 fontsize=12, fontweight="bold", y=0.97)
    save_figure(fig, out_dir / "06_swr_bandwidth.png")


# ──────────────────────────────────────────────────────────────────────────────
# Gráfica 08 — Tarjetas resumen de diseño
# ──────────────────────────────────────────────────────────────────────────────
def plot_08_design_summary(tune, patterns, out_dir: Path, S: dict[str, str]) -> None:
    fig = plt.figure(figsize=(14, 10))
    fig.patch.set_facecolor(PALETTE["bg"])
    gs = gridspec.GridSpec(2, 4, figure=fig, wspace=0.25, hspace=0.1,
                           height_ratios=[2, 1])

    targets = [
        (1.047, S["summary.card.nominal"],  PALETTE["muted"]),
        (1.068, S["summary.card.maxgain"],  PALETTE["accent4"]),
        (1.090, S["summary.card.balanced"], PALETTE["accent2"]),
        (1.110, S["summary.card.maxfb"],    PALETTE["openquad"]),
    ]

    for col, (k_target, label, color) in enumerate(targets):
        row = min(tune, key=lambda r: abs(r["k_refl"] - k_target))

        ax_polar = fig.add_subplot(gs[0, col], projection="polar")
        ax_polar.set_facecolor(PALETTE["ax"])

        nearest = min(patterns.keys(), key=lambda k: abs(k - k_target))
        gains = patterns[nearest]
        phis = sorted(gains.keys())
        theta = np.radians(phis)
        r = np.maximum([gains[p] for p in phis], -30)
        ax_polar.plot(theta, r, color=color, lw=2.2)
        ax_polar.fill(theta, r, color=color, alpha=0.2)
        ax_polar.set_theta_zero_location("N")
        ax_polar.set_theta_direction(-1)
        ax_polar.set_rlim(-30, 12)
        ax_polar.set_rticks([-20, -10, 0, 10])
        ax_polar.tick_params(colors=PALETTE["text"], labelsize=7)
        ax_polar.grid(color=PALETTE["grid"], alpha=0.5, linewidth=0.4)
        for spine in ax_polar.spines.values():
            spine.set_color(PALETTE["grid"])
        ax_polar.set_title(label, color=color, fontsize=11,
                           fontweight="bold", pad=10)

        ax_txt = fig.add_subplot(gs[1, col])
        ax_txt.set_facecolor(PALETTE["bg"])
        ax_txt.set_xticks([])
        ax_txt.set_yticks([])
        for sp in ax_txt.spines.values():
            sp.set_visible(False)

        perim = row["perim_mm"]
        gain  = row["gain"] if row["gain"] is not None else 0.0
        fb    = row["fb"]   if row["fb"]   is not None else 0.0
        R     = row["R"]    if row["R"]    is not None else 0.0
        X     = row["X"]    if row["X"]    is not None else 0.0
        swr   = row["swr"]  if row["swr"]  is not None else 0.0

        sign = "−" if X < 0 else "+"
        text = (
            f"$\\bf{{k_{{refl}} = {row['k_refl']:.3f}}}$\n"
            f"{S['summary.perim']}: {perim:.0f} mm\n\n"
            f"{S['summary.gain']}: {gain:+.2f} dBi\n"
            f"{S['summary.fb']}: {fb:.1f} dB\n\n"
            f"Z = {R:.0f} {sign} j{abs(X):.0f} Ω\n"
            f"{S['summary.swr']}: {swr:.2f}"
        )
        ax_txt.text(0.5, 0.95, text, transform=ax_txt.transAxes,
                    color=PALETTE["text"], fontsize=10,
                    ha="center", va="top",
                    bbox=dict(boxstyle="round,pad=0.8",
                              facecolor=PALETTE["ax"],
                              edgecolor=color, lw=1.5))

    fig.suptitle(S["summary.suptitle"], color=PALETTE["text"],
                 fontsize=13, fontweight="bold", y=0.97)
    save_figure(fig, out_dir / "08_design_summary.png")


# ──────────────────────────────────────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────────────────────────────────────
def render_for_lang(lang: str, data: dict, out_base: Path, freq_target: float) -> None:
    apply_font_for_lang(lang)
    S = STRINGS[lang]
    out_dir = out_base / lang
    out_dir.mkdir(parents=True, exist_ok=True)
    print(f"\n[{lang}] → {out_dir}/")
    plot_02_pareto_decision(data["tune"],      out_dir, S)
    plot_03_polar_pattern  (data["patterns"],  out_dir, S)
    plot_06_swr_bandwidth  (data["imp"], freq_target, out_dir, S)
    plot_08_design_summary (data["tune"], data["patterns"], out_dir, S)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("data_dir", type=str,
                    help="Directorio con los CSVs generados por --full-data-dump")
    ap.add_argument("--out-dir", type=str, default=None,
                    help="Directorio base de salida (default: data_dir/gallery)")
    ap.add_argument("--lang", type=str, default="all",
                    help=f"Idioma o 'all' (default). Opciones: {', '.join(ALL_LANGS)}, all")
    ap.add_argument("--freq-target", type=float, default=435.0,
                    help="Frecuencia objetivo para anotaciones (default: 435)")
    args = ap.parse_args()

    data_dir = Path(args.data_dir)
    out_base = Path(args.out_dir) if args.out_dir else data_dir / "gallery"
    out_base.mkdir(parents=True, exist_ok=True)

    if args.lang == "all":
        langs = ALL_LANGS
    elif args.lang in STRINGS:
        langs = [args.lang]
    else:
        ap.error(f"--lang debe ser uno de {ALL_LANGS} o 'all'")

    print(f"\nLeyendo CSVs de {data_dir}/")
    data = {
        "spacing":  read_spacing_sweep   (data_dir / "spacing_sweep.csv"),
        "tune":     read_reflector_tuning(data_dir / "reflector_tuning.csv"),
        "imp":      read_impedance_sweep (data_dir / "impedance_sweep.csv"),
        "patterns": read_patterns        (data_dir / "patterns.csv"),
    }

    print(f"\nGenerando galería en {out_base}/ para idiomas: {', '.join(langs)}")
    for lang in langs:
        render_for_lang(lang, data, out_base, args.freq_target)

    total = len(langs) * 4
    print(f"\n✓ {total} gráficas generadas ({len(langs)} idiomas × 4 gráficas).")


if __name__ == "__main__":
    main()
