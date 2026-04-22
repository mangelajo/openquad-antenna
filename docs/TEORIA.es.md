# Fundamentos teóricos de la antena Cubical Quad

**Por EA4IPW — Complemento teórico a la guía OpenQuad**

Este documento recoge los fundamentos teóricos, fórmulas y referencias que sustentan el diseño de una antena Cubical Quad. El caso práctico de construcción se documenta en [README.es.md](README.es.md).

La cubical quad es una antena de elementos parasíticos (como un Yagi) donde cada elemento es un loop cuadrado de una longitud de onda completa. Frente a un Yagi equivalente, ofrece ~2 dB más de ganancia para el mismo número de elementos, mejor ratio front-to-back, y una impedancia de feedpoint más cercana a 50 Ω.

Las fórmulas y procedimientos de esta guía son válidos para cualquier frecuencia.

---

## 1. Las fórmulas y de dónde vienen

### 1.1. La longitud de onda y el factor geométrico del loop

La longitud de onda en el vacío es:

    λ = c / f

Donde **c = 299,792,458 m/s** (por definición del SI). Expresada directamente en mm con f en MHz:

    λ (mm) = 299,792.458 / f(MHz)

Un loop cuadrado no resuena exactamente en un perímetro de 1λ. La curva de impedancia del loop (evolución de la parte reactiva con la frecuencia) cruza por cero cuando el perímetro es **~2.2% más largo** que λ. Llamamos **k** a este factor geométrico de resonancia:

    k_driven ≈ 1.022

**Nota:** A diferencia de un dipolo, que se *acorta* ~5% respecto al teórico (factor ≈ 0.95) por el "end effect" en sus extremos abiertos, un loop cerrado necesita ser *más largo* porque no tiene extremos abiertos y la geometría de las esquinas introduce reactancia inductiva a λ exacta.

### 1.2. Fórmulas para cada elemento

Las fórmulas dan el **perímetro total del loop**, en mm, partiendo de λ = c/f:

| Elemento | Factor k | Perímetro |
|---|---|---|
| Driven | k_d ≈ 1.022 | k_d × λ × Vf |
| Reflector | k_d × 1.025 ≈ 1.047 | k_d × 1.025 × λ × Vf |
| Director 1 | k_d × 0.970 ≈ 0.991 | k_d × 0.970 × λ × Vf |
| Director N+1 | × 0.97 sobre el anterior | Director_N × 0.97 |

Donde:
- **λ (mm) = 299,792.458 / f(MHz)** — longitud de onda en el vacío
- **Vf** — velocity factor del conductor (ver §2; ≈ 0.99 para cobre desnudo en aire)

**Ejemplo (f = 435 MHz, cobre desnudo, Vf = 0.99):**

    λ        = 299,792.458 / 435          = 689.18 mm
    Driven   = 1.022 × 689.18 × 0.99      = 697.3 mm
    Reflector= 1.047 × 689.18 × 0.99      = 714.5 mm
    Director1= 0.991 × 689.18 × 0.99      = 676.2 mm

**Dimensiones derivadas:**

- Longitud de un lado del cuadrado: `lado = perímetro / 4`
- Longitud del brazo spreader (del centro a la esquina): `spreader = lado × √2 / 2 ≈ lado × 0.7071`

### 1.3. Por qué el reflector es más largo y el director más corto

Los factores relativos respecto al driven no son arbitrarios:

| Elemento | Factor vs. driven | Por qué |
|---|---|---|
| Driven | 1.000 | Loop resonante a la frecuencia de trabajo |
| Reflector | 1.025 (+2.5%) | Resuena por debajo → impedancia **inductiva** |
| Director | 0.970 (−3%) | Resuena por encima → impedancia **capacitiva** |

El reflector inductivo y el director capacitivo producen la fase necesaria para que la antena radie en una sola dirección (del reflector hacia los directores). En términos absolutos, sobre k_driven ≈ 1.022:

    k_reflector = 1.022 × 1.025 = 1.047
    k_director  = 1.022 × 0.970 = 0.991

### 1.4. Equivalencia con la constante histórica "1005/f"

La bibliografía clásica (ARRL Antenna Book, Orr, Cebik) expresa el driven como:

    Perímetro (pies) = 1005 / f(MHz)

Esto equivale a `k_driven × λ` en unidades inglesas, con la suposición implícita **Vf = 1**:

    1005 / 983.57 = 1.0218 ≈ k_driven

En el modelo que usamos aquí, esa constante empírica se descompone en su factor geométrico (k ≈ 1.022) y el Vf del conductor, que siempre es ligeramente < 1 en aire real. La calculadora online usa esta forma explícita.

### 1.5. Espaciados entre elementos

| Tramo | Distancia |
|---|---|
| Reflector → Driven | 0.20 × λ |
| Driven → Director 1 | 0.15 × λ |
| Director → Director | 0.15 × λ |

Donde λ = 299,792.458 / f(MHz) es la longitud de onda en el vacío.

**Importante:** Los espaciados dependen de la longitud de onda en el espacio libre, NO del velocity factor del cable. El boom siempre mide lo mismo independientemente del tipo de cable que uses para los elementos.

### 1.6. Elección del espaciado reflector→driven: compromiso ganancia vs F/B

Existe cierta dispersión en la bibliografía respecto al espaciado óptimo entre el reflector y el
driven. Las dos referencias más habituales son:

| Fuente | R→Driven | Directores | Objetivo de diseño |
|---|---|---|---|
| ARRL Antenna Book / Orr & Cowan | **0.200 λ** | 0.150 λ | Máxima ganancia |
| W6SAI / calculadoras clásicas (e.g. YT1VP) | **0.186 λ** | 0.153 λ | Compromiso ganancia/F/B |

El valor 0.186 λ de las calculadoras clásicas procede de la constante histórica `730 ft·MHz`
expresada en unidades imperiales:

    spacing_pies = 730 / f(MHz) × 0.25  →  spacing/λ = 730×0.25 / 983.57 ≈ 0.1855 λ

#### Resultado de la simulación NEC2 (5 elementos, 435 MHz)

Se realizó un barrido de k_reflector con `nec2c` para ambas configuraciones de espaciado.
El modelo replica la geometría real de la MOQUAD: **loops en orientación diamante (45°)**,
con feed en el vértice inferior (S-corner) para polarización horizontal.
Los resultados muestran que la diferencia de ganancia entre ambos espaciados es
**despreciable** (< 0.05 dBi), mientras que el F/B máximo alcanzable sí varía:

| Configuración | k_refl óptimo | Ganancia pico | F/B máximo |
|---|---|---|---|
| OpenQuad 0.200 λ | 1.110 | 10.10 dBi (7.95 dBd) | **37.8 dB** |
| YT1VP  0.186 λ | 1.108 | 10.12 dBi (7.97 dBd) | **42.3 dB** |

Con el k_refl nominal (1.047) ambas configuraciones dan prácticamente el mismo resultado:
~10.1 dBi y ~7.2 dB de F/B. La diferencia de F/B sólo emerge cuando el reflector se ajusta
hacia el punto de cancelación máxima (reflector más largo → mayor desfase inductivo).

**Conclusión práctica:** para una construcción típica en la que se ajusta la longitud del
reflector mediante el stub o recortando el loop, el espaciado más corto de las calculadoras
clásicas ofrece **~4.5 dB más de F/B** en el punto óptimo con la misma ganancia. Si el objetivo
prioritario es el F/B (rechazo de interferencias, EME, contests de dirección fija), usa 0.186 λ;
si el objetivo es la máxima ganancia con F/B suficiente, usa 0.200 λ.

El script NEC2 que genera este análisis se encuentra en `tools/nec2_spacing_analysis.py`
(ver sección §6 de este documento).

> **Referencias:** ver §5 — Cebik W4RNL *Cubical Quad Notes* vol. 1, cap. 3
> (https://antenna2.github.io/cebik/content/bookant.html); ARRL Antenna Book cap. 12;
> Tom Rauch W8JI — "Cubical Quad Antenna" (https://www.w8ji.com/quad_cubical_quad.htm);
> W6SAI *All About Cubical Quad Antennas*, págs. 44–52.

### 1.7. Ajuste fino del reflector: el compromiso ganancia ↔ F/B

Los valores nominales de la calculadora (k_reflector = 1.047, es decir 2.5% más largo que el
driven) son un punto de partida razonable, pero **no el óptimo**. En cualquier array parasítico
existe un compromiso fundamental: el reflector se puede sintonizar para **máxima ganancia
adelante** o para **máxima cancelación trasera (F/B)**, pero los dos óptimos no coinciden.

#### Resultado del barrido NEC2 (5 elementos, 435 MHz, geometría diamante)

| k_refl | Perímetro reflector | Ganancia adelante | Ganancia atrás | F/B |
|---|---|---|---|---|
| 1.047 (nominal) | 722 mm | 9.94 dBi | +2.54 dBi | 7.4 dB |
| 1.068 (max gain) | 736 mm | **10.28 dBi** | −1.92 dBi | 12.2 dB |
| 1.090 (compromise) | 751 mm | 10.16 dBi | −9.74 dBi | 19.9 dB |
| 1.110 (max F/B) | 765 mm | 9.91 dBi | **−28.2 dBi** | **38.1 dB** |

Observación clave: **la ganancia adelante apenas cambia** (rango de 0.37 dB en todo el barrido),
mientras que la ganancia atrás se desploma **30 dB** al pasar del reflector nominal al optimizado
para F/B. El F/B no se gana aumentando la radiación frontal, sino cancelando la trasera.

#### Desmitificación: "dBi de ganancia" es el pico del patrón

`dBi` mide la ganancia en la dirección de **máxima radiación** (pico del patrón), no una media
ni la ganancia en una dirección fija. En una quad bien orientada ese pico coincide con la
dirección de los directores (phi=0°), pero si el array está mal ajustado el pico puede desviarse
hacia los lados. En este análisis siempre informamos ganancia en phi=0° (adelante), que coincide
con el pico en todas las configuraciones del sweep.

#### La resonancia del feedpoint se desplaza — pero hacia ARRIBA

Un malentendido habitual: "si alargo el reflector, bajo la frecuencia de resonancia". La
realidad es la contraria en un array parasítico:

| k_refl | Z a 435 MHz | f_res del feedpoint (X=0) | SWR @ 50Ω @ 435 MHz |
|---|---|---|---|
| 1.047 | 45 − j39 Ω | 444 MHz (+9) | 2.24 |
| 1.068 | 60 − j33 Ω | 445 MHz (+10) | 1.86 |
| 1.090 | 75 − j37 Ω | 446 MHz (+11) | 2.04 |
| 1.110 | 84 − j45 Ω | 447 MHz (+12) | 2.33 |

El driven no cambia — siempre resuena cerca de 435 MHz por sí solo. Lo que cambia es el
**acoplamiento mutuo** entre reflector y driven. La matriz de impedancias es:

    Z_in = Z_11 − Z_12² / Z_22

donde Z_11 es la impedancia propia del driven, Z_22 la del reflector, y Z_12 la mutua. Al alargar
el reflector, Z_22 se vuelve más inductiva, lo que modifica el término Z_12²/Z_22 de forma que
la reactancia que se suma al driven es **capacitiva**. Esto desplaza la frecuencia donde X=0
hacia arriba, no hacia abajo.

En la práctica, a 435 MHz el feedpoint siempre queda con reactancia capacitiva moderada
(X ≈ −35 a −45 Ω), manejable con un gamma match, L-match, o un hairpin.

#### Procedimiento de ajuste iterativo

Para aprovechar el compromiso y llevar la antena al punto óptimo:

1. **Construir** reflector, driven y directores con las dimensiones nominales de la calculadora
   (k_refl = 1.047), añadiendo 15–20 mm extra al perímetro del reflector como margen de ajuste.

2. **Medir** el F/B apuntando a una baliza conocida, o midiendo con VNA la impedancia y la
   resonancia.

3. **Alargar el reflector en pasos de ~5 mm** (añadiendo cable o con un stub ajustable),
   anotando F/B tras cada paso. El F/B subirá progresivamente.

4. **Detenerse** cuando F/B empiece a bajar o se vuelva inestable — has pasado el punto óptimo.
   Retrocede medio paso.

5. **Reajustar el matching** (gamma/L/hairpin) tras fijar la longitud del reflector, porque la
   reactancia del feedpoint habrá cambiado respecto al punto inicial.

> **Nota operativa:** el reflector SIEMPRE se ajusta alargándolo desde el valor nominal. Por eso
> es más sensato construir con margen extra y recortar si te pasas, que quedarte corto y tener
> que añadir cable.

#### Compromisos típicos recomendados

- **Aplicaciones de largo alcance / DX**: k_refl ≈ 1.068 (736 mm @ 435 MHz) — maximiza ganancia,
  F/B razonable de ~12 dB.
- **Recepción de baliza con interferencias traseras / rechazo de intermodulación**: k_refl ≈ 1.090
  (751 mm) — pierdes 0.1 dB de ganancia, ganas 7.7 dB de F/B.
- **EME, satélite, contests con dirección fija**: k_refl ≈ 1.108 (764 mm) — máximo F/B de 38 dB,
  ganancia casi idéntica al nominal.

Estos valores son para 5 elementos. Para 2 o 3 elementos las diferencias son más marcadas y el
compromiso es más duro — ver Cebik, *Cubical Quad Notes* Vol. 1 cap. 3 para el análisis completo.

---

## 2. El Velocity Factor (Vf): por qué importa y cómo calcularlo

### 2.1. Qué es el Vf

El Velocity Factor (Vf) es la relación entre la velocidad de propagación de la onda por el conductor y la velocidad de la luz en el vacío:

    Vf = v_conductor / c

Un Vf = 1 corresponde al vacío perfecto (por definición). El **aire** tiene permitividad relativa εr ≈ 1.0006 y por tanto el Vf puro en aire es prácticamente 1. Sin embargo, en antenas reales se añaden pequeños efectos — grosor finito del conductor, pérdidas, acoplamiento con el entorno cercano (soportes, mástil, suelo, objetos metálicos próximos) — que reducen el Vf efectivo de un hilo de **cobre desnudo al aire** hasta el rango **≈ 0.97–0.99**. El valor exacto depende del diámetro del hilo, la altura sobre el suelo y las obstrucciones cercanas; en condiciones limpias (antena elevada, lejos de objetos) tiende a 0.99, mientras que instalaciones más comprometidas caen hacia 0.97.

El aislamiento (PVC, polietileno, teflón) aumenta la capacitancia distribuida a lo largo del conductor, ralentizando significativamente la propagación. Esto reduce el Vf y hace que necesites **menos cable** para completar una longitud de onda eléctrica.

### 2.2. Valores típicos de Vf

| Tipo de cable | Vf aproximado |
|---|---|
| Vacío (referencia teórica) | 1.00 |
| Cobre desnudo al aire | 0.97–0.99 |
| Aislamiento PTFE/Teflón | 0.97–0.98 |
| Aislamiento polietileno | 0.95–0.96 |
| Aislamiento PVC fino | 0.91–0.95 |
| Aislamiento PVC grueso (cable de instalación 450/750V) | 0.90–0.93 |

**Atención:** Estos son valores orientativos. El Vf real depende del grosor del aislamiento relativo al diámetro del conductor. Un cable de instalación doméstica (H07V-K, UNE-EN 50525) de 1.5 mm² tiene un forro PVC proporcionalmente más grueso que el mismo cable en 6 mm², y por tanto un Vf más bajo.

### 2.3. Aplicación del Vf en las fórmulas

El Vf multiplica el resultado geométrico del apartado 1.2:

    Perímetro (mm) = k × λ × Vf

Donde:
- **λ (mm) = 299,792.458 / f(MHz)** — longitud de onda en el vacío
- **k** — factor geométrico del elemento (driven = 1.022, reflector = 1.047, director 1 = 0.991)
- **Vf** — velocity factor del conductor

Como el Vf de un cable real es siempre < 1, el perímetro físico queda más corto que el geométrico ideal — el Vf está compensando la capacitancia distribuida que hace que la onda viaje más lenta por el conductor.

### 2.4. Cómo medir el Vf de tu cable

El método más directo es empírico:

1. Calcula las dimensiones con Vf = 0.99 (cobre desnudo en aire) como punto de partida.
2. Construye la antena completa (reflector + driven como mínimo, idealmente todos los elementos).
3. Mide la frecuencia de resonancia con el NanoVNA.
4. Calcula tu Vf real: **Vf_nuevo = Vf_inicial × f_medida / f_objetivo**

Por ejemplo: si partiste de Vf = 0.99 y construiste para 435 MHz, pero el conjunto resuena a 400 MHz, tu Vf real es 0.99 × 400/435 = 0.91.

En mi experiencia, calcular el Vf con un elemento aislado no funciona bien, necesitas al menos reflector + driven para que el acoplamiento entre ellos estabilice la resonancia en su valor típico de antena completa.

Esto funciona porque un Vf menor que 1 significa que el conjunto es eléctricamente "demasiado largo" y resuena más abajo de lo esperado; la diferencia de frecuencia medida/objetivo da exactamente ese factor de corrección.

---

## 3. Cálculo de dimensiones para cualquier frecuencia

Para una frecuencia central f (en MHz) y un velocity factor Vf, primero calcula la longitud de onda:

    λ (mm) = 299,792.458 / f(MHz)

**Perímetros (mm):**

    Driven      = 1.022 × λ × Vf
    Reflector   = 1.047 × λ × Vf       (= 1.025 × Driven)
    Director 1  = 0.991 × λ × Vf       (= 0.970 × Driven)
    Director 2  = 0.97 × Director 1
    Director 3  = 0.97 × Director 2
    ...y así sucesivamente

**Espaciados (mm):** (independientes del Vf — el boom siempre mide lo mismo para una frecuencia dada)

    Reflector → Driven:   0.20 × λ
    Driven → Director:    0.15 × λ
    Director → Director:  0.15 × λ

**Lado del cuadrado y brazo spreader:**

    lado     = perímetro / 4
    spreader = lado × √2 / 2 ≈ lado × 0.7071

---

## 4. Rendimiento teórico esperado

### 4.1. Ganancia y F/B por configuración

| Elementos | Ganancia aprox. (dBd) | Ganancia aprox. (dBi) | Ratio F/B |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

Valores en dBd (sobre dipolo) y dBi (sobre isotrópica). dBi = dBd + 2.15.

A partir de 4–5 elementos los rendimientos son decrecientes (~0.5 dB por director adicional). Para la mayoría de aplicaciones, 3–5 elementos es el punto óptimo entre ganancia, complejidad y facilidad de ajuste.

### 4.2. Equivalencia con Yagi

Como referencia general, un quad de N elementos rinde aproximadamente como un Yagi de N+2 elementos con boom de longitud similar.

### 4.3. Verificación práctica del F/B

Sintoniza un repetidor o baliza conocida, apunta la antena hacia la fuente, anota la lectura del S-meter, gira 180° y compara. Cada unidad S de diferencia equivale a ~6 dB según la norma IARU Region 1 R.1 (1981), aunque la calibración de los S-meters en equipos comerciales puede variar significativamente, especialmente por debajo de S3 donde muchos receptores solo dan 2–3 dB por unidad S.

---

## 5. Referencias

### Libros y documentos técnicos

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" — Volúmenes 1, 2 y 3.** La referencia definitiva sobre diseño de quads. Disponible en: https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** El libro clásico que popularizó el quad entre radioaficionados.
- **ARRL Antenna Book — Chapter 12: Quad Arrays.** Fuente de las fórmulas 1005/1030/975.

### Artículos online

- **L. B. Cebik (W4RNL) — "Cubical Quad Notes" (3 volúmenes).** La referencia definitiva sobre
  diseño de quads. Todos los volúmenes disponibles en PDF en:
  https://antenna2.github.io/cebik/content/bookant.html
- **L. B. Cebik (W4RNL) — "2-Element Quads as a Function of Wire Diameter"** — Metodología
  de optimización NEC que fija el driven en resonancia y ajusta reflector para máximo F/B.
  Documenta el compromiso ganancia↔F/B con datos NEC-4. https://antenna2.github.io/cebik/content/quad/q2l1.html
- **L. B. Cebik (W4RNL) — "The Quad vs. Yagi Question"** — Análisis comparativo con sweeps
  paramétricos. Confirma que los quads de 2 elementos no superan ~20 dB de F/B sin directores.
  https://antenna2.github.io/cebik/content/quad/qyc.html
- **Tom Rauch (W8JI) — "Cubical Quad Antenna"** — Análisis técnico riguroso con datos NEC.
  Cita directa sobre el compromiso ganancia/F/B: *"if we optimize F/B ratio we can expect lower
  gain from any parasitic array"*. https://www.w8ji.com/quad_cubical_quad.htm
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Efecto del
  Vf en loops con cable PVC. https://q82.uk/1005overf
- **Electronics Notes — "Yagi Feed Impedance & Matching"** — Explica el efecto del acoplamiento
  mutuo sobre la impedancia del feedpoint: *"altering the element spacing has a greater effect
  on the impedance than it does the gain"*. https://www.electronics-notes.com/articles/antennas-propagation/yagi-uda-antenna-aerial/feed-impedance-matching.php
- **Wikipedia — "Yagi–Uda antenna" (sección Mutual impedance)** — Formulación matemática del
  acoplamiento Z_ij entre driven y parásitos. Clave para entender por qué alargar el reflector
  DESPLAZA la frecuencia de resonancia del feedpoint (hacia arriba, no hacia abajo).
  https://en.wikipedia.org/wiki/Yagi%E2%80%93Uda_antenna
- **KD2BD (John Magliacane) — "Thoughts on Perfect Impedance Matching of a Yagi"** — Matching
  de feedpoints con reactancia no nula. Útil tras optimizar el reflector para F/B, cuando Z_in
  deja de ser 50 Ω. https://www.qsl.net/kd2bd/impedance_matching.html
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Guías de construcción

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Calculadores online

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm
  Usa espaciado R→DE ≈ 0.186 λ (constante `730 ft·MHz`) y directores ≈ 0.153 λ (constante
  `600 ft·MHz`). Ver §1.6 para la comparación con el valor 0.200 λ usado por OpenQuad.
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Libros recomendados (papel)

- **James L. Lawson (W2PV) — "Yagi Antenna Design"** (ARRL, 1986, ISBN 0-87259-041-0).
  Referencia clásica sobre optimización computacional de arrays parasíticos. La metodología
  de barrido paramétrico (variar k_refl manteniendo driven fijo) que usa OpenQuad viene
  directamente de esta obra.
- **William I. Orr (W6SAI) — "All About Cubical Quad Antennas"** (Radio Publications, 1959
  y ediciones posteriores). Origen histórico de las constantes empíricas `730/f` y `600/f`
  para espaciados; clásico absoluto del mundo quad.
- **David B. Leeson — "Physical Design of Yagi Antennas"** (ARRL, 1992, ISBN 0-87259-381-9).
  Complementa a Lawson con el diseño mecánico y métodos de matching. Cebik lo recomienda como
  *companion book* para entender arrays parasíticos en profundidad.
- **ARRL Antenna Book** (edición actual, ARRL). El capítulo dedicado a quads recoge las
  fórmulas clásicas 1005/1030/975 y el rango de espaciados 0.14–0.25 λ.

### Normas citadas

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definición del S-meter. 1 unidad S = 6 dB, S9 en VHF = −93 dBm (5 µV en 50 Ω).

---

*73 de EA4IPW — OpenQuad v1.0*
