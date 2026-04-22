// OpenQuad calculator — DOM / i18n layer.
// Pure computation lives in calc.js and is unit-tested separately.

import {
  MM_PER_INCH,
  C_MM_MHZ,
  DBD_TO_DBI,
  SPACING_MODES,
  buildElements,
  buildSpacings,
  performanceFor,
  recommendRodDiameter,
  recalibrateVf,
} from './calc.js';

const REPO_BASE = "https://github.com/mangelajo/openquad-antenna/blob/main/docs/";
const docUrl = (name, lang) => REPO_BASE + name + "." + lang + ".md";
const GITHUB_URL = "https://github.com/mangelajo/openquad-antenna";

// Per-language doc URLs (used inside translation strings below).
const T_es = docUrl("TEORIA", "es"), R_es = docUrl("README", "es");
const T_en = docUrl("TEORIA", "en"), R_en = docUrl("README", "en");
const T_it = docUrl("TEORIA", "it"), R_it = docUrl("README", "it");
const T_pt = docUrl("TEORIA", "pt"), R_pt = docUrl("README", "pt");
const T_ja = docUrl("TEORIA", "ja"), R_ja = docUrl("README", "ja");
const T_zh = docUrl("TEORIA", "zh"), R_zh = docUrl("README", "zh");

// Per-language deep links to the tuning section (§4 of each README).
const TUNE_ANCHORS = {
  es: "4-ajuste-paso-a-paso",
  en: "4-step-by-step-tuning",
  it: "4-regolazione-passo-passo",
  pt: "4-ajuste-passo-a-passo",
  ja: "4-段階的な調整手順",
  zh: "4-逐步调谐",
};
const tuneUrl = (lang) => docUrl("README", lang) + "#" + TUNE_ANCHORS[lang];
const TUNE_es = tuneUrl("es"), TUNE_en = tuneUrl("en"), TUNE_it = tuneUrl("it");
const TUNE_pt = tuneUrl("pt"), TUNE_ja = tuneUrl("ja"), TUNE_zh = tuneUrl("zh");

const LANGS = {
  es: {
    locale: "es-ES",
    "lang.label": "Idioma",
    "unit.label": "Unidades",
    "page.title": "OpenQuad — Calculadora Cubical Quad",
    "page.h1": "OpenQuad — Calculadora Cubical Quad",
    "page.intro": "Calculadora paramétrica para antena cubical quad modular (EA4IPW). Genera las dimensiones para tu frecuencia, mide la resonancia con reflector + driven montados, y obtén el Vf real y el corte/ajuste necesario en cada elemento.",
    "page.formulas-hint": `Fórmulas y procedimiento: ver <a href="${T_es}">TEORIA.es.md</a> y <a href="${R_es}">README.es.md</a>.`,
    "page.diagram-alt": "Diagrama de la antena cubical quad",
    "sec1.title": "1. Parámetros iniciales",
    "sec1.freq": "Frecuencia objetivo (MHz)",
    "sec1.vf-initial": "Vf inicial (cable)",
    "sec1.num-directors": "Nº de directores",
    "sec1.boom-dim": "Diámetro/lado del boom (mm)",
    "sec1.spacing-mode": "Modo de espaciado",
    "sec1.spacing-maxgain": "Máx. ganancia  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Máx. F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `Afecta solo al largo del boom — ver <a href="${T_es}#16-elección-del-espaciado-reflectordrivencompromiso-ganancia-vs-fb">TEORIA §1.6</a>.`,
    "sec1.hint": "Por defecto Vf = 0.99 (cobre desnudo al aire; el vacío teórico sería 1.00). El procedimiento recomendado es construir con este valor, medir, y recalcular abajo. Si ya conoces el Vf real de tu cable (ej. 0.91 para PVC fino), introdúcelo directamente.",
    "sec2.title-prefix": "2. Dimensiones iniciales (Vf =",
    "stat.elements": "Elementos totales",
    "stat.gain": "Ganancia teórica",
    "stat.fb": "Ratio F/B",
    "stat.fb-sub": "delante / atrás",
    "stat.yagi": "Equiv. Yagi",
    "stat.yagi-sub": "aprox. mismo rendimiento",
    "stat.yagi-value": "~{n} elementos",
    "stat.boom": "Boom total",
    "stat.boom-empty": "solo reflector + driven",
    "stat.wavelength": "Longitud de onda (λ)",
    "stat.wavelength-sub": "en espacio libre",
    "stat.rod-dia": "Ø varilla recomendado",
    "stat.rod-dia-sub": "máx. spreader {val} {unit}",
    "stat.need-elements": "se necesitan ≥2 elementos",
    "stat.extrapolated": " (extrapolado)",
    "sec2.stats-hint": `Valores teóricos orientativos según <a href="${T_es}">TEORIA § 4</a>. A partir de 4–5 elementos los rendimientos son decrecientes (~0.5 dB por director adicional). dBi = dBd + 2.15.`,
    "col.element": "Elemento",
    "col.perim": "Perímetro ({unit})",
    "col.side": "Lado ({unit})",
    "col.spreader": "Spreader ({unit})",
    "col.rod": "Varilla recomendada ({unit})",
    "sec2.legend": "<strong>Lado</strong> = perímetro / 4. <strong>Spreader</strong> = lado × √2 / 2 (centro a esquina). <strong>Varilla</strong> = spreader − offset del hub − 15 mm (media abrazadera de extremo); la punta queda centrada en la abrazadera, permitiendo ±15 mm de ajuste de Vf sin recortar.",
    "sec3.title": "3. Calibración del Velocity Factor (solo necesario para cables aislados)",
    "sec3.intro": `Construye el conjunto con las dimensiones de arriba, mide la frecuencia de resonancia con el VNA (procedimiento detallado en <a href="${TUNE_es}">§4 Ajuste paso a paso</a>) e introdúcela aquí:`,
    "sec3.freq-measured": "Frecuencia medida (MHz)",
    "sec3.placeholder": "ej. 400.0",
    "sec3.vf-calculated": "Vf calculado",
    "sec3.hint": `<code>Vf = f_medida / f_objetivo</code>. Un Vf &lt; 1 significa que los elementos están eléctricamente "demasiado largos" y resuenan por debajo de la frecuencia objetivo.`,
    "sec4.title": "4. Dimensiones recalculadas y ajustes",
    "sec4.status-empty": "Introduce la frecuencia medida arriba para ver los ajustes.",
    "sec4.status-filled": "Vf real = <strong>{vf}</strong> (medida {measured} MHz vs objetivo {target} MHz, Vf inicial {initial}).",
    "col.p-initial": "P. inicial ({unit})",
    "col.p-new": "P. nuevo ({unit})",
    "col.delta": "Δ perímetro ({unit})",
    "col.action": "Acción",
    "sec4.legend": `Δ negativo = <span class="cut">recortar</span> cable. Δ positivo = <span class="add">añadir</span> cable (poco práctico, mejor empezar de nuevo más largo). Las longitudes son del cable total del loop (perímetro completo).`,
    "action.cut": "Recortar {val} {unit} de cable",
    "action.add": "Añadir {val} {unit} de cable",
    "action.none": "Sin cambio",
    "sec5.title": "5. Espaciados entre elementos",
    "sec5.hint": "Independientes del Vf — el boom siempre mide lo mismo para una frecuencia dada.",
    "col.section": "Tramo",
    "col.distance": "Distancia ({unit})",
    "col.accumulated": "Acumulado ({unit})",
    "el.reflector": "Reflector",
    "el.driven": "Driven",
    "el.director": "Director {n}",
    "sp.r-de": "Reflector → Driven",
    "sp.de-d1": "Driven → Director 1",
    "sp.d-d": "Director {i} → Director {j}",
    "footer": `73 de EA4IPW — OpenQuad · <a href="${GITHUB_URL}">Código en GitHub</a>`,
  },
  en: {
    locale: "en-US",
    "lang.label": "Language",
    "unit.label": "Units",
    "page.title": "OpenQuad — Cubical Quad Calculator",
    "page.h1": "OpenQuad — Cubical Quad Calculator",
    "page.intro": "Parametric calculator for a modular cubical quad antenna (EA4IPW). Generates the dimensions for your frequency, lets you measure resonance with reflector + driven mounted, and gives the real Vf and the required cut/adjustment for each element.",
    "page.formulas-hint": `Formulas and procedure: see <a href="${T_en}">TEORIA.en.md</a> and <a href="${R_en}">README.en.md</a>.`,
    "page.diagram-alt": "Cubical quad antenna diagram",
    "sec1.title": "1. Initial parameters",
    "sec1.freq": "Target frequency (MHz)",
    "sec1.vf-initial": "Initial Vf (wire)",
    "sec1.num-directors": "Number of directors",
    "sec1.boom-dim": "Boom diameter/side (mm)",
    "sec1.spacing-mode": "Spacing mode",
    "sec1.spacing-maxgain": "Max gain  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Max F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `Affects boom length only — see <a href="${T_en}#16-choice-of-reflector-driven-spacing-gain-vs-fb-tradeoff">TEORIA §1.6</a>.`,
    "sec1.hint": "Default Vf = 1.0 (bare copper, maximum length). The recommended procedure is to build with Vf = 1.0, measure, and recalculate below. If you already know the real Vf of your wire (e.g. 0.91 for thin PVC), enter it directly.",
    "sec2.title-prefix": "2. Initial dimensions (Vf =",
    "stat.elements": "Total elements",
    "stat.gain": "Theoretical gain",
    "stat.fb": "F/B ratio",
    "stat.fb-sub": "front / back",
    "stat.yagi": "Yagi equiv.",
    "stat.yagi-sub": "approx. same performance",
    "stat.yagi-value": "~{n} elements",
    "stat.boom": "Total boom",
    "stat.boom-empty": "reflector + driven only",
    "stat.wavelength": "Wavelength (λ)",
    "stat.wavelength-sub": "in free space",
    "stat.rod-dia": "Recommended rod Ø",
    "stat.rod-dia-sub": "max. spreader {val} {unit}",
    "stat.need-elements": "need ≥2 elements",
    "stat.extrapolated": " (extrapolated)",
    "sec2.stats-hint": `Approximate theoretical values per <a href="${T_en}">TEORIA § 4</a>. From 4–5 elements returns diminish (~0.5 dB per extra director). dBi = dBd + 2.15.`,
    "col.element": "Element",
    "col.perim": "Perimeter ({unit})",
    "col.side": "Side ({unit})",
    "col.spreader": "Spreader ({unit})",
    "col.rod": "Recommended rod ({unit})",
    "sec2.legend": "<strong>Side</strong> = perimeter / 4. <strong>Spreader</strong> = side × √2 / 2 (center to corner). <strong>Rod</strong> = spreader − hub offset − 15 mm (half of tip-clamp body); the rod tip sits near the centre of the tip clamp, giving ±15 mm of Vf slide without retrimming.",
    "sec3.title": "3. Velocity Factor calibration (only needed for insulated wire)",
    "sec3.intro": `Build the antenna with the dimensions above, measure the resonance frequency with the VNA (detailed procedure at <a href="${TUNE_en}">§4 Step-by-step tuning</a>), and enter it here:`,
    "sec3.freq-measured": "Measured frequency (MHz)",
    "sec3.placeholder": "e.g. 400.0",
    "sec3.vf-calculated": "Calculated Vf",
    "sec3.hint": `<code>Vf = f_measured / f_target</code>. Vf &lt; 1 means the elements are electrically "too long" and resonate below the target frequency.`,
    "sec4.title": "4. Recalculated dimensions and adjustments",
    "sec4.status-empty": "Enter the measured frequency above to see the adjustments.",
    "sec4.status-filled": "Real Vf = <strong>{vf}</strong> (measured {measured} MHz vs target {target} MHz, initial Vf {initial}).",
    "col.p-initial": "Initial P. ({unit})",
    "col.p-new": "New P. ({unit})",
    "col.delta": "Δ perimeter ({unit})",
    "col.action": "Action",
    "sec4.legend": `Δ negative = <span class="cut">trim</span> wire. Δ positive = <span class="add">add</span> wire (impractical, better to start over longer). Lengths refer to the total loop wire (full perimeter).`,
    "action.cut": "Trim {val} {unit} of wire",
    "action.add": "Add {val} {unit} of wire",
    "action.none": "No change",
    "sec5.title": "5. Spacing between elements",
    "sec5.hint": "Independent of Vf — the boom is always the same for a given frequency.",
    "col.section": "Section",
    "col.distance": "Distance ({unit})",
    "col.accumulated": "Accumulated ({unit})",
    "el.reflector": "Reflector",
    "el.driven": "Driven",
    "el.director": "Director {n}",
    "sp.r-de": "Reflector → Driven",
    "sp.de-d1": "Driven → Director 1",
    "sp.d-d": "Director {i} → Director {j}",
    "footer": `73 from EA4IPW — OpenQuad · <a href="${GITHUB_URL}">Code on GitHub</a>`,
  },
  it: {
    locale: "it-IT",
    "lang.label": "Lingua",
    "unit.label": "Unità",
    "page.title": "OpenQuad — Calcolatore Cubical Quad",
    "page.h1": "OpenQuad — Calcolatore Cubical Quad",
    "page.intro": "Calcolatore parametrico per antenna cubical quad modulare (EA4IPW). Genera le dimensioni per la tua frequenza, misura la risonanza con riflettore + driven montati, e fornisce il Vf reale e il taglio/regolazione necessaria per ogni elemento.",
    "page.formulas-hint": `Formule e procedura: vedi <a href="${T_it}">TEORIA.it.md</a> e <a href="${R_it}">README.it.md</a>.`,
    "page.diagram-alt": "Diagramma dell'antenna cubical quad",
    "sec1.title": "1. Parametri iniziali",
    "sec1.freq": "Frequenza target (MHz)",
    "sec1.vf-initial": "Vf iniziale (cavo)",
    "sec1.num-directors": "N° di direttori",
    "sec1.boom-dim": "Diametro/lato del boom (mm)",
    "sec1.spacing-mode": "Modalità spaziatura",
    "sec1.spacing-maxgain": "Max gain  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Max F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `Incide solo sulla lunghezza del boom — vedi <a href="${T_it}">TEORIA §1.6</a>.`,
    "sec1.hint": "Default Vf = 1.0 (rame nudo, lunghezza massima). La procedura consigliata è costruire con Vf = 1.0, misurare e ricalcolare sotto. Se conosci già il Vf reale del tuo cavo (es. 0.91 per PVC sottile), inseriscilo direttamente.",
    "sec2.title-prefix": "2. Dimensioni iniziali (Vf =",
    "stat.elements": "Elementi totali",
    "stat.gain": "Guadagno teorico",
    "stat.fb": "Rapporto F/B",
    "stat.fb-sub": "avanti / indietro",
    "stat.yagi": "Equiv. Yagi",
    "stat.yagi-sub": "circa stesse prestazioni",
    "stat.yagi-value": "~{n} elementi",
    "stat.boom": "Boom totale",
    "stat.boom-empty": "solo riflettore + driven",
    "stat.wavelength": "Lunghezza d'onda (λ)",
    "stat.wavelength-sub": "nello spazio libero",
    "stat.rod-dia": "Ø asta consigliato",
    "stat.rod-dia-sub": "max. spreader {val} {unit}",
    "stat.need-elements": "servono ≥2 elementi",
    "stat.extrapolated": " (estrapolato)",
    "sec2.stats-hint": `Valori teorici indicativi secondo <a href="${T_it}">TEORIA § 4</a>. Da 4–5 elementi i rendimenti diminuiscono (~0.5 dB per direttore aggiuntivo). dBi = dBd + 2.15.`,
    "col.element": "Elemento",
    "col.perim": "Perimetro ({unit})",
    "col.side": "Lato ({unit})",
    "col.spreader": "Spreader ({unit})",
    "col.rod": "Asta consigliata ({unit})",
    "sec2.legend": "<strong>Lato</strong> = perimetro / 4. <strong>Spreader</strong> = lato × √2 / 2 (centro-angolo). <strong>Asta</strong> = spreader − offset dell'hub − 15 mm (metà morsetto di estremità); la punta dell'asta resta al centro del morsetto, permettendo ±15 mm di regolazione del Vf senza ritagliare.",
    "sec3.title": "3. Calibrazione del Velocity Factor (solo per cavi isolati)",
    "sec3.intro": `Costruisci l'antenna con le dimensioni sopra, misura la frequenza di risonanza con il VNA (procedura dettagliata in <a href="${TUNE_it}">§4 Regolazione passo passo</a>) e inseriscila qui:`,
    "sec3.freq-measured": "Frequenza misurata (MHz)",
    "sec3.placeholder": "es. 400.0",
    "sec3.vf-calculated": "Vf calcolato",
    "sec3.hint": `<code>Vf = f_misurata / f_target</code>. Un Vf &lt; 1 significa che gli elementi sono elettricamente "troppo lunghi" e risuonano sotto la frequenza target.`,
    "sec4.title": "4. Dimensioni ricalcolate e regolazioni",
    "sec4.status-empty": "Inserisci la frequenza misurata sopra per vedere le regolazioni.",
    "sec4.status-filled": "Vf reale = <strong>{vf}</strong> (misurata {measured} MHz vs target {target} MHz, Vf iniziale {initial}).",
    "col.p-initial": "P. iniziale ({unit})",
    "col.p-new": "P. nuovo ({unit})",
    "col.delta": "Δ perimetro ({unit})",
    "col.action": "Azione",
    "sec4.legend": `Δ negativo = <span class="cut">tagliare</span> cavo. Δ positivo = <span class="add">aggiungere</span> cavo (poco pratico, meglio ripartire più lungo). Le lunghezze sono del cavo totale del loop (perimetro completo).`,
    "action.cut": "Tagliare {val} {unit} di cavo",
    "action.add": "Aggiungere {val} {unit} di cavo",
    "action.none": "Nessuna modifica",
    "sec5.title": "5. Spaziature tra elementi",
    "sec5.hint": "Indipendenti dal Vf — il boom ha sempre la stessa lunghezza per una data frequenza.",
    "col.section": "Tratto",
    "col.distance": "Distanza ({unit})",
    "col.accumulated": "Accumulato ({unit})",
    "el.reflector": "Riflettore",
    "el.driven": "Driven",
    "el.director": "Direttore {n}",
    "sp.r-de": "Riflettore → Driven",
    "sp.de-d1": "Driven → Direttore 1",
    "sp.d-d": "Direttore {i} → Direttore {j}",
    "footer": `73 da EA4IPW — OpenQuad · <a href="${GITHUB_URL}">Codice su GitHub</a>`,
  },
  pt: {
    locale: "pt-PT",
    "lang.label": "Idioma",
    "unit.label": "Unidades",
    "page.title": "OpenQuad — Calculadora Cubical Quad",
    "page.h1": "OpenQuad — Calculadora Cubical Quad",
    "page.intro": "Calculadora paramétrica para antena cubical quad modular (EA4IPW). Gera as dimensões para a tua frequência, mede a ressonância com refletor + driven montados, e obtém o Vf real e o corte/ajuste necessário em cada elemento.",
    "page.formulas-hint": `Fórmulas e procedimento: ver <a href="${T_pt}">TEORIA.pt.md</a> e <a href="${R_pt}">README.pt.md</a>.`,
    "page.diagram-alt": "Diagrama da antena cubical quad",
    "sec1.title": "1. Parâmetros iniciais",
    "sec1.freq": "Frequência alvo (MHz)",
    "sec1.vf-initial": "Vf inicial (cabo)",
    "sec1.num-directors": "Nº de diretores",
    "sec1.boom-dim": "Diâmetro/lado do boom (mm)",
    "sec1.spacing-mode": "Modo de espaçamento",
    "sec1.spacing-maxgain": "Máx. ganância  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Máx. F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `Afeta apenas o comprimento do boom — ver <a href="${T_pt}">TEORIA §1.6</a>.`,
    "sec1.hint": "Por omissão Vf = 1.0 (cobre nu, comprimento máximo). O procedimento recomendado é construir com Vf = 1.0, medir, e recalcular abaixo. Se já conheces o Vf real do teu cabo (ex. 0.91 para PVC fino), introduz-o diretamente.",
    "sec2.title-prefix": "2. Dimensões iniciais (Vf =",
    "stat.elements": "Elementos totais",
    "stat.gain": "Ganho teórico",
    "stat.fb": "Rácio F/B",
    "stat.fb-sub": "frente / trás",
    "stat.yagi": "Equiv. Yagi",
    "stat.yagi-sub": "aprox. mesmo desempenho",
    "stat.yagi-value": "~{n} elementos",
    "stat.boom": "Boom total",
    "stat.boom-empty": "só refletor + driven",
    "stat.wavelength": "Comprimento de onda (λ)",
    "stat.wavelength-sub": "no espaço livre",
    "stat.rod-dia": "Ø vareta recomendado",
    "stat.rod-dia-sub": "máx. spreader {val} {unit}",
    "stat.need-elements": "necessários ≥2 elementos",
    "stat.extrapolated": " (extrapolado)",
    "sec2.stats-hint": `Valores teóricos orientativos segundo <a href="${T_pt}">TEORIA § 4</a>. A partir de 4–5 elementos os rendimentos decrescem (~0.5 dB por diretor adicional). dBi = dBd + 2.15.`,
    "col.element": "Elemento",
    "col.perim": "Perímetro ({unit})",
    "col.side": "Lado ({unit})",
    "col.spreader": "Spreader ({unit})",
    "col.rod": "Vareta recomendada ({unit})",
    "sec2.legend": "<strong>Lado</strong> = perímetro / 4. <strong>Spreader</strong> = lado × √2 / 2 (centro ao canto). <strong>Vareta</strong> = spreader − offset do hub − 15 mm (metade da braçadeira da ponta); a ponta da vareta fica no centro da braçadeira, permitindo ±15 mm de ajuste de Vf sem cortar.",
    "sec3.title": "3. Calibração do Velocity Factor (apenas para cabos isolados)",
    "sec3.intro": `Constrói a antena com as dimensões acima, mede a frequência de ressonância com o VNA (procedimento detalhado em <a href="${TUNE_pt}">§4 Ajuste passo a passo</a>) e introdu-la aqui:`,
    "sec3.freq-measured": "Frequência medida (MHz)",
    "sec3.placeholder": "ex. 400.0",
    "sec3.vf-calculated": "Vf calculado",
    "sec3.hint": `<code>Vf = f_medida / f_alvo</code>. Um Vf &lt; 1 significa que os elementos estão eletricamente "demasiado longos" e ressoam abaixo da frequência alvo.`,
    "sec4.title": "4. Dimensões recalculadas e ajustes",
    "sec4.status-empty": "Introduz a frequência medida acima para ver os ajustes.",
    "sec4.status-filled": "Vf real = <strong>{vf}</strong> (medida {measured} MHz vs alvo {target} MHz, Vf inicial {initial}).",
    "col.p-initial": "P. inicial ({unit})",
    "col.p-new": "P. novo ({unit})",
    "col.delta": "Δ perímetro ({unit})",
    "col.action": "Ação",
    "sec4.legend": `Δ negativo = <span class="cut">cortar</span> cabo. Δ positivo = <span class="add">adicionar</span> cabo (pouco prático, melhor recomeçar mais comprido). Os comprimentos são do cabo total do loop (perímetro completo).`,
    "action.cut": "Cortar {val} {unit} de cabo",
    "action.add": "Adicionar {val} {unit} de cabo",
    "action.none": "Sem alteração",
    "sec5.title": "5. Espaçamentos entre elementos",
    "sec5.hint": "Independentes do Vf — o boom tem sempre o mesmo tamanho para uma dada frequência.",
    "col.section": "Troço",
    "col.distance": "Distância ({unit})",
    "col.accumulated": "Acumulado ({unit})",
    "el.reflector": "Refletor",
    "el.driven": "Driven",
    "el.director": "Diretor {n}",
    "sp.r-de": "Refletor → Driven",
    "sp.de-d1": "Driven → Diretor 1",
    "sp.d-d": "Diretor {i} → Diretor {j}",
    "footer": `73 de EA4IPW — OpenQuad · <a href="${GITHUB_URL}">Código no GitHub</a>`,
  },
  ja: {
    locale: "ja-JP",
    "lang.label": "言語",
    "unit.label": "単位",
    "page.title": "OpenQuad — キュービカルクワッド計算機",
    "page.h1": "OpenQuad — キュービカルクワッド計算機",
    "page.intro": "モジュラー式キュービカルクワッドアンテナ（EA4IPW）のパラメトリック計算機。希望周波数の寸法を生成し、リフレクターとドリブンを組み立てた状態で共振を測定して、実際の Vf と各エレメントに必要な切断・調整量を算出します。",
    "page.formulas-hint": `式と手順: <a href="${T_ja}">TEORIA.ja.md</a> および <a href="${R_ja}">README.ja.md</a> を参照。`,
    "page.diagram-alt": "キュービカルクワッドアンテナの図",
    "sec1.title": "1. 初期パラメータ",
    "sec1.freq": "目標周波数 (MHz)",
    "sec1.vf-initial": "初期 Vf（ケーブル）",
    "sec1.num-directors": "ディレクター数",
    "sec1.boom-dim": "ブーム直径／辺長 (mm)",
    "sec1.spacing-mode": "Spacing mode",
    "sec1.spacing-maxgain": "Max gain  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Max F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `See <a href="${T_en}">TEORIA §1.6</a>.`,
    "sec1.hint": "デフォルトは Vf = 1.0（裸銅線、最大長）。推奨手順は Vf = 1.0 で製作し、測定後に下で再計算することです。ケーブルの実 Vf がすでに分かっている場合（例: 薄い PVC で 0.91）、直接入力してください。",
    "sec2.title-prefix": "2. 初期寸法 (Vf =",
    "stat.elements": "総エレメント数",
    "stat.gain": "理論利得",
    "stat.fb": "F/B 比",
    "stat.fb-sub": "前方 / 後方",
    "stat.yagi": "Yagi 等価",
    "stat.yagi-sub": "ほぼ同性能",
    "stat.yagi-value": "~{n} エレメント",
    "stat.boom": "ブーム全長",
    "stat.boom-empty": "リフレクター + ドリブンのみ",
    "stat.wavelength": "波長 (λ)",
    "stat.wavelength-sub": "自由空間",
    "stat.rod-dia": "推奨ロッド径",
    "stat.rod-dia-sub": "最大スプレッダー {val} {unit}",
    "stat.need-elements": "≥2 エレメント必要",
    "stat.extrapolated": "（外挿）",
    "sec2.stats-hint": `<a href="${T_ja}">TEORIA § 4</a> による参考理論値。4–5 エレメントを超えると利得増加は逓減（ディレクター追加あたり ~0.5 dB）。dBi = dBd + 2.15。`,
    "col.element": "エレメント",
    "col.perim": "周長 ({unit})",
    "col.side": "辺 ({unit})",
    "col.spreader": "スプレッダー ({unit})",
    "col.rod": "推奨ロッド ({unit})",
    "sec2.legend": "<strong>辺</strong> = 周長 / 4。<strong>スプレッダー</strong> = 辺 × √2 / 2（中心から角まで）。<strong>ロッド</strong> = スプレッダー − ハブオフセット − 15 mm（先端クランプの半分）。ロッド先端がクランプの中央付近に来るので、切らずに ±15 mm の Vf 調整が可能です。",
    "sec3.title": "3. Velocity Factor の校正（絶縁ケーブルのみ）",
    "sec3.intro": `上記の寸法でアンテナを組み立て、VNA で共振周波数を測定し（詳細な手順は <a href="${TUNE_ja}">§4 段階的な調整手順</a>）、ここに入力してください：`,
    "sec3.freq-measured": "測定周波数 (MHz)",
    "sec3.placeholder": "例: 400.0",
    "sec3.vf-calculated": "計算された Vf",
    "sec3.hint": `<code>Vf = f_測定 / f_目標</code>。Vf &lt; 1 はエレメントが電気的に「長すぎ」、目標周波数より低く共振することを意味します。`,
    "sec4.title": "4. 再計算寸法と調整",
    "sec4.status-empty": "上に測定周波数を入力すると調整値が表示されます。",
    "sec4.status-filled": "実 Vf = <strong>{vf}</strong>（測定 {measured} MHz、目標 {target} MHz、初期 Vf {initial}）。",
    "col.p-initial": "初期周長 ({unit})",
    "col.p-new": "新周長 ({unit})",
    "col.delta": "Δ 周長 ({unit})",
    "col.action": "操作",
    "sec4.legend": `Δ が負 = ケーブルを<span class="cut">切断</span>。Δ が正 = ケーブルを<span class="add">追加</span>（実用的でないため、長めから作り直す方が良い）。長さはループ全体（周長）です。`,
    "action.cut": "ケーブルを {val} {unit} 切る",
    "action.add": "ケーブルを {val} {unit} 足す",
    "action.none": "変更なし",
    "sec5.title": "5. エレメント間隔",
    "sec5.hint": "Vf に依存しない — ブーム長は与えられた周波数で常に同じです。",
    "col.section": "区間",
    "col.distance": "距離 ({unit})",
    "col.accumulated": "累積 ({unit})",
    "el.reflector": "リフレクター",
    "el.driven": "ドリブン",
    "el.director": "ディレクター {n}",
    "sp.r-de": "リフレクター → ドリブン",
    "sp.de-d1": "ドリブン → ディレクター 1",
    "sp.d-d": "ディレクター {i} → ディレクター {j}",
    "footer": `73 from EA4IPW — OpenQuad · <a href="${GITHUB_URL}">GitHub のコード</a>`,
  },
  zh: {
    locale: "zh-CN",
    "lang.label": "语言",
    "unit.label": "单位",
    "page.title": "OpenQuad — 立方四方天线计算器",
    "page.h1": "OpenQuad — 立方四方天线计算器",
    "page.intro": "模块化立方四方天线（EA4IPW）的参数化计算器。生成所需频率的尺寸，安装反射器和驱动元后测量谐振，得出实际 Vf 和每个元件所需的剪切/调整量。",
    "page.formulas-hint": `公式与步骤：参见 <a href="${T_zh}">TEORIA.zh.md</a> 和 <a href="${R_zh}">README.zh.md</a>。`,
    "page.diagram-alt": "立方四方天线示意图",
    "sec1.title": "1. 初始参数",
    "sec1.freq": "目标频率 (MHz)",
    "sec1.vf-initial": "初始 Vf（导线）",
    "sec1.num-directors": "引向器数量",
    "sec1.boom-dim": "主梁直径/边长 (mm)",
    "sec1.spacing-mode": "Spacing mode",
    "sec1.spacing-maxgain": "Max gain  (0.200 λ — ARRL/Orr)",
    "sec1.spacing-maxfb":   "Max F/B  (0.186 λ — W6SAI/YT1VP, +4.5 dB F/B)",
    "sec1.spacing-hint": `See <a href="${T_en}">TEORIA §1.6</a>.`,
    "sec1.hint": "默认 Vf = 1.0（裸铜，最大长度）。推荐流程是用 Vf = 1.0 制作，测量后在下方重新计算。如果已知导线的实际 Vf（如薄 PVC 为 0.91），可直接输入。",
    "sec2.title-prefix": "2. 初始尺寸 (Vf =",
    "stat.elements": "总元件数",
    "stat.gain": "理论增益",
    "stat.fb": "前后比 F/B",
    "stat.fb-sub": "前 / 后",
    "stat.yagi": "等效八木",
    "stat.yagi-sub": "性能大致相同",
    "stat.yagi-value": "~{n} 元件",
    "stat.boom": "总主梁",
    "stat.boom-empty": "仅反射器 + 驱动元",
    "stat.wavelength": "波长 (λ)",
    "stat.wavelength-sub": "自由空间",
    "stat.rod-dia": "推荐杆直径",
    "stat.rod-dia-sub": "最大撑杆 {val} {unit}",
    "stat.need-elements": "需要 ≥2 个元件",
    "stat.extrapolated": "（外推）",
    "sec2.stats-hint": `参考理论值见 <a href="${T_zh}">TEORIA § 4</a>。从 4–5 个元件开始收益递减（每增加一个引向器约 0.5 dB）。dBi = dBd + 2.15。`,
    "col.element": "元件",
    "col.perim": "周长 ({unit})",
    "col.side": "边长 ({unit})",
    "col.spreader": "撑杆 ({unit})",
    "col.rod": "推荐杆 ({unit})",
    "sec2.legend": "<strong>边长</strong> = 周长 / 4。<strong>撑杆</strong> = 边长 × √2 / 2（中心到角）。<strong>杆</strong> = 撑杆 − 集线器偏移 − 15 mm（端部夹具的一半）；杆尖位于夹具中央附近，可在不切割的情况下进行 ±15 mm 的 Vf 调整。",
    "sec3.title": "3. Velocity Factor 校准（仅绝缘导线需要）",
    "sec3.intro": `用上方尺寸制作天线，使用 VNA 测量谐振频率（详细步骤见 <a href="${TUNE_zh}">§4 逐步调谐</a>），并在此输入：`,
    "sec3.freq-measured": "测量频率 (MHz)",
    "sec3.placeholder": "如 400.0",
    "sec3.vf-calculated": "计算的 Vf",
    "sec3.hint": `<code>Vf = f_测量 / f_目标</code>。Vf &lt; 1 表示元件电气上"过长"，谐振低于目标频率。`,
    "sec4.title": "4. 重新计算的尺寸和调整",
    "sec4.status-empty": "在上方输入测量频率以查看调整值。",
    "sec4.status-filled": "实际 Vf = <strong>{vf}</strong>（测量 {measured} MHz vs 目标 {target} MHz，初始 Vf {initial}）。",
    "col.p-initial": "初始周长 ({unit})",
    "col.p-new": "新周长 ({unit})",
    "col.delta": "Δ 周长 ({unit})",
    "col.action": "操作",
    "sec4.legend": `Δ 为负 = <span class="cut">剪短</span>导线。Δ 为正 = <span class="add">加长</span>导线（不实用，最好重新制作更长的）。长度是整个回路（完整周长）的导线长度。`,
    "action.cut": "剪掉 {val} {unit} 导线",
    "action.add": "加上 {val} {unit} 导线",
    "action.none": "无需更改",
    "sec5.title": "5. 元件间距",
    "sec5.hint": "与 Vf 无关 — 给定频率下主梁长度始终相同。",
    "col.section": "段",
    "col.distance": "距离 ({unit})",
    "col.accumulated": "累计 ({unit})",
    "el.reflector": "反射器",
    "el.driven": "驱动元",
    "el.director": "引向器 {n}",
    "sp.r-de": "反射器 → 驱动元",
    "sp.de-d1": "驱动元 → 引向器 1",
    "sp.d-d": "引向器 {i} → 引向器 {j}",
    "footer": `73 来自 EA4IPW — OpenQuad · <a href="${GITHUB_URL}">GitHub 代码</a>`,
  },
};

let currentLang = "es";
let currentUnit = "mm"; // "mm" or "in"

// English defaults to inches; all other languages to millimetres.
const LANG_UNIT_DEFAULT = { en: "in" };

function detectLang() {
  const stored = localStorage.getItem("openquad-lang");
  if (stored && LANGS[stored]) return stored;
  const nav = (navigator.language || "es").toLowerCase();
  for (const code of Object.keys(LANGS)) {
    if (nav.startsWith(code)) return code;
  }
  return "es";
}

function detectUnit(lang) {
  const stored = localStorage.getItem("openquad-unit");
  if (stored === "mm" || stored === "in") return stored;
  return LANG_UNIT_DEFAULT[lang] || "mm";
}

function unitFactor() { return currentUnit === "in" ? 1 / MM_PER_INCH : 1; }
function unitDecimals() { return currentUnit === "in" ? 2 : 1; }
function toUnit(mm) { return mm * unitFactor(); }
function fmtUnit(mm) { return fmt(toUnit(mm), unitDecimals()); }

function t(key, params) {
  let s = LANGS[currentLang][key];
  if (s === undefined) s = LANGS.es[key] || key;
  if (params) {
    for (const [k, v] of Object.entries(params)) {
      s = s.replaceAll("{" + k + "}", String(v));
    }
  }
  return s;
}

function translateAll() {
  const params = { unit: currentUnit };
  document.querySelectorAll("[data-i18n]").forEach(el => {
    const key = el.getAttribute("data-i18n");
    const val = t(key, params);
    if (el.tagName === "LABEL" && el.querySelector("input, select, span")) {
      // Replace only the leading text node, preserve nested input/select/span.
      const first = el.firstChild;
      if (first && first.nodeType === Node.TEXT_NODE) {
        first.nodeValue = val + " ";
      } else {
        el.insertBefore(document.createTextNode(val + " "), el.firstChild);
      }
    } else {
      el.textContent = val;
    }
  });
  document.querySelectorAll("[data-i18n-html]").forEach(el => {
    el.innerHTML = t(el.getAttribute("data-i18n-html"), params);
  });
  document.querySelectorAll("[data-i18n-placeholder]").forEach(el => {
    el.placeholder = t(el.getAttribute("data-i18n-placeholder"), params);
  });
  document.querySelectorAll("[data-i18n-alt]").forEach(el => {
    el.alt = t(el.getAttribute("data-i18n-alt"), params);
  });
}

function applyLang(lang) {
  currentLang = lang;
  localStorage.setItem("openquad-lang", lang);
  document.documentElement.lang = lang;
  translateAll();
  recompute();
}

function applyUnit(unit) {
  currentUnit = unit;
  localStorage.setItem("openquad-unit", unit);
  translateAll();
  recompute();
}

function $(id) { return document.getElementById(id); }

function fmt(n, decimals = 1) {
  if (!isFinite(n)) return "—";
  return n.toLocaleString(LANGS[currentLang].locale, {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

function elementName(index) {
  if (index === 0) return t("el.reflector");
  if (index === 1) return t("el.driven");
  return t("el.director", { n: index - 1 });
}

function spacingName(spacing) {
  if (spacing.type === "r-de") return t("sp.r-de");
  if (spacing.type === "de-d1") return t("sp.de-d1");
  return t("sp.d-d", { i: spacing.i, j: spacing.j });
}

function renderInitialTable(elements) {
  const tbody = $("initial-dimensions").querySelector("tbody");
  tbody.innerHTML = elements.map(e => `
    <tr>
      <td>${elementName(e.index)}</td>
      <td>${fmtUnit(e.perimeter)}</td>
      <td>${fmtUnit(e.side)}</td>
      <td>${fmtUnit(e.spreader)}</td>
      <td>${fmtUnit(e.rod)}</td>
    </tr>
  `).join("");
}

function renderSpacingsTable(spacings) {
  const tbody = $("spacings").querySelector("tbody");
  tbody.innerHTML = spacings.map(s => `
    <tr>
      <td>${spacingName(s)}</td>
      <td>${fmtUnit(s.distance)}</td>
      <td>${fmtUnit(s.accumulated)}</td>
    </tr>
  `).join("");
}

function renderStats(freq, numDirectors, spacings, elements) {
  const total = 2 + numDirectors;
  const lambdaMm = C_MM_MHZ / freq;
  const boomMm = spacings.length ? spacings[spacings.length - 1].accumulated : 0;
  const perf = performanceFor(total);

  $("stat-elements").textContent = String(total);
  const parts = ["R", "DE"];
  for (let i = 1; i <= numDirectors; i++) parts.push("D" + i);
  $("stat-elements-sub").textContent = parts.join(" + ");

  $("stat-wavelength").textContent = fmtUnit(lambdaMm) + " " + currentUnit;
  $("stat-boom").textContent = boomMm > 0 ? fmtUnit(boomMm) + " " + currentUnit : "—";
  $("stat-boom-sub").textContent = boomMm > 0
    ? (boomMm / lambdaMm).toFixed(2) + " λ"
    : t("stat.boom-empty");

  if (perf) {
    const dbi = perf.gainDbd + DBD_TO_DBI;
    const tilde = perf.extrapolated ? "≥" : "~";
    $("stat-gain").textContent = tilde + perf.gainDbd.toFixed(1) + " dBd";
    $("stat-gain-sub").textContent = tilde + dbi.toFixed(1) + " dBi"
      + (perf.extrapolated ? t("stat.extrapolated") : "");
    $("stat-fb").textContent = perf.fbMin + "–" + perf.fbMax + " dB";
    $("stat-yagi").textContent = t("stat.yagi-value", { n: total + 2 });
  } else {
    $("stat-gain").textContent = "—";
    $("stat-gain-sub").textContent = t("stat.need-elements");
    $("stat-fb").textContent = "—";
    $("stat-yagi").textContent = "—";
  }

  const maxSpreader = elements.length ? Math.max(...elements.map(e => e.spreader)) : 0;
  const rodDia = recommendRodDiameter(maxSpreader);
  if (rodDia) {
    $("stat-rod-dia").textContent = rodDia.toFixed(2) + " mm";
    $("stat-rod-dia-sub").textContent = t("stat.rod-dia-sub", { val: fmtUnit(maxSpreader), unit: currentUnit });
  } else {
    $("stat-rod-dia").textContent = "—";
    $("stat-rod-dia-sub").textContent = "—";
  }
}

function renderAdjustTable(initial, adjusted) {
  const tbody = $("adjusted-dimensions").querySelector("tbody");
  if (!adjusted) { tbody.innerHTML = ""; return; }
  tbody.innerHTML = initial.map((e0, i) => {
    const e1 = adjusted[i];
    const dPerim = e1.perimeter - e0.perimeter;
    const tol = 0.5;
    let cls, action;
    if (dPerim < -tol) {
      cls = "cut";
      action = t("action.cut", { val: fmtUnit(Math.abs(dPerim)), unit: currentUnit });
    } else if (dPerim > tol) {
      cls = "add";
      action = t("action.add", { val: fmtUnit(dPerim), unit: currentUnit });
    } else {
      cls = "ok";
      action = t("action.none");
    }
    const dSign = dPerim >= 0 ? "+" : "";
    return `
      <tr>
        <td>${elementName(e0.index)}</td>
        <td>${fmtUnit(e0.perimeter)}</td>
        <td>${fmtUnit(e1.perimeter)}</td>
        <td class="${cls}">${dSign}${fmtUnit(dPerim)}</td>
        <td class="${cls}">${action}</td>
      </tr>
    `;
  }).join("");
}

function recompute() {
  const freq = parseFloat($("freq").value);
  const vfInitial = parseFloat($("vf-initial").value);
  const numDirectors = parseInt($("num-directors").value, 10);
  const freqMeasured = parseFloat($("freq-measured").value);
  const boomDim = parseFloat($("boom-dim").value);
  const spacingMode = $("spacing-mode").value;

  if (!isFinite(freq) || freq <= 0 || !isFinite(vfInitial) || vfInitial <= 0
      || !isFinite(numDirectors) || numDirectors < 0
      || !isFinite(boomDim) || boomDim <= 0) {
    return;
  }

  $("vf-initial-display").textContent = vfInitial.toFixed(2);

  const initial = buildElements(freq, vfInitial, numDirectors, boomDim);
  renderInitialTable(initial);

  const spacings = buildSpacings(freq, numDirectors, spacingMode);
  renderSpacingsTable(spacings);
  renderStats(freq, numDirectors, spacings, initial);

  const status = $("adjust-status");
  let adjusted = null;
  if (isFinite(freqMeasured) && freqMeasured > 0) {
    const vfNew = recalibrateVf(vfInitial, freq, freqMeasured);
    $("vf-calculated").textContent = vfNew.toFixed(3);
    adjusted = buildElements(freq, vfNew, numDirectors, boomDim);
    status.innerHTML = t("sec4.status-filled", {
      vf: vfNew.toFixed(3),
      measured: fmt(freqMeasured),
      target: fmt(freq),
      initial: vfInitial.toFixed(2),
    });
  } else {
    $("vf-calculated").textContent = "—";
    status.textContent = t("sec4.status-empty");
  }
  renderAdjustTable(initial, adjusted);
}

["freq", "vf-initial", "num-directors", "freq-measured", "boom-dim"].forEach(id => {
  $(id).addEventListener("input", recompute);
});
$("spacing-mode").addEventListener("change", recompute);

const langSelect = $("lang-select");
langSelect.addEventListener("change", e => applyLang(e.target.value));

const unitSelect = $("unit-select");
unitSelect.addEventListener("change", e => applyUnit(e.target.value));

const initialLang = detectLang();
const initialUnit = detectUnit(initialLang);
currentUnit = initialUnit;
langSelect.value = initialLang;
unitSelect.value = initialUnit;
applyLang(initialLang);
