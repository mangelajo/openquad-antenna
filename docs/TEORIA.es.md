# Fundamentos teóricos de la antena Cubical Quad

**Por EA4IPW — Complemento teórico a la guía OpenQuad**

Este documento recoge los fundamentos teóricos, fórmulas y referencias que sustentan el diseño de una antena Cubical Quad. El caso práctico de construcción se documenta en [README.es.md](README.es.md).

La cubical quad es una antena de elementos parasíticos (como un Yagi) donde cada elemento es un loop cuadrado de una longitud de onda completa. Frente a un Yagi equivalente, ofrece ~2 dB más de ganancia para el mismo número de elementos, mejor ratio front-to-back, y una impedancia de feedpoint más cercana a 50 Ω.

Las fórmulas y procedimientos de esta guía son válidos para cualquier frecuencia.

---

## 1. Las fórmulas y de dónde vienen

### 1.1. La constante base: de la velocidad de la luz al valor mágico "1005"

Esta constante aparece publicada en la bibliografía de antenas desde los años 1960 (ver referencias al final), pero vemos de dónde viene.

La longitud de onda en el vacío es:

    λ = c / f

Donde c = 299,792,458 m/s. Expresado en pies:

    λ (pies) = 983.57 / f(MHz)

Un loop cuadrado de una longitud de onda no resuena exactamente en λ teórica. Los efectos de la corriente circulando por las esquinas y la curvatura del campo hacen que necesite ser ligeramente más largo (~2.2%) para resonar. Esto da la constante empírica clásica:

    983.57 × 1.021 ≈ 1005

**Nota:** A diferencia de un dipolo, que se *acorta* ~5% respecto al teórico (de 492 a 468) por el "end effect" en sus extremos abiertos, un loop cerrado necesita ser *más largo* porque no tiene extremos abiertos.

### 1.2. Fórmulas para cada elemento

Las fórmulas dan el **perímetro total del loop**:

| Elemento | Perímetro (pies) | Perímetro (mm) | Origen |
|---|---|---|---|
| Driven element | 1005 / f | 1005 / f × 304.8 | Resonancia a f |
| Reflector | 1030 / f | 1030 / f × 304.8 | ~2.5% más largo → inductivo |
| Director 1 | 975 / f | 975 / f × 304.8 | ~3% más corto → capacitivo |
| Director N+1 | Director_N × 0.97 | Director_N × 0.97 | Serie del 3% |

Donde f está en MHz.

**Dimensiones derivadas:**

- Longitud de un lado del cuadrado: `lado = perímetro / 4`
- Longitud del brazo spreader (del centro a la esquina): `spreader = lado × √2 / 2 = lado × 0.7071`

### 1.3. De dónde salen las constantes 1030 y 975

No son arbitrarias. Parten de la constante base del driven element (1005):

| Constante | Cálculo | Función |
|---|---|---|
| 1005 | 984 × 1.021 | Loop resonante a la frecuencia de trabajo |
| 1030 | 1005 × 1.025 | Reflector: 2.5% más largo → resuena por debajo → inductivo |
| 975 | 1005 × 0.970 | Director: 3% más corto → resuena por encima → capacitivo |

El reflector inductivo y el director capacitivo producen la fase necesaria para que la antena radie en una sola dirección (del reflector hacia los directores).

### 1.4. Espaciados entre elementos

| Tramo | Distancia |
|---|---|
| Reflector → Driven | 0.20λ |
| Driven → Director 1 | 0.15λ |
| Director → Director | 0.15λ |

Donde λ es la longitud de onda en espacio libre:

    λ (mm) = 300,000 / f(MHz)
    λ (pulgadas) = 11,811 / f(MHz)
    λ (pies) = 984 / f(MHz)

**Importante:** Los espaciados dependen de la longitud de onda en el espacio libre, NO del velocity factor del cable. El boom siempre mide lo mismo independientemente del tipo de cable que uses para los elementos.

---

## 2. El Velocity Factor (Vf): por qué importa y cómo calcularlo

### 2.1. Qué es el Vf

Las fórmulas del apartado anterior asumen **cobre desnudo en espacio libre** (Vf = 1.0). Si usas cable con aislamiento (PVC, polietileno, teflón), la onda viaja más lenta por el conductor, lo que reduce la longitud física necesaria para resonar a la misma frecuencia.

El aislamiento aumenta la capacitancia distribuida a lo largo del conductor, ralentizando la propagación. Esto significa que necesitas **menos cable** para completar una longitud de onda eléctrica.

### 2.2. Valores típicos de Vf

| Tipo de cable | Vf aproximado |
|---|---|
| Cobre desnudo | 1.00 |
| Aislamiento PTFE/Teflón | 0.97–0.98 |
| Aislamiento polietileno | 0.95–0.96 |
| Aislamiento PVC fino | 0.91–0.95 |
| Aislamiento PVC grueso (cable de instalación 450/750V) | 0.90–0.93 |

**Atención:** Estos son valores orientativos. El Vf real depende del grosor del aislamiento relativo al diámetro del conductor. Un cable de instalación doméstica (H07V-K, UNE-EN 50525) de 1.5 mm² tiene un forro PVC proporcionalmente más grueso que el mismo cable en 6 mm², y por tanto un Vf más bajo.

### 2.3. Fórmulas corregidas con Vf

Multiplica cada constante por el Vf:

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (pulgadas)
    Driven = (1005 × Vf) / f(MHz)              (pies)

Lo mismo para las constantes 1030 (reflector) y 975 (director 1).

### 2.4. Cómo medir el Vf de tu cable

El método más directo es empírico:

1. Calcula el perímetro del driven element usando las fórmulas para cobre desnudo (Vf = 1.0).
2. Construye el loop.
3. Construye también el reflector.
4. Mide su resonancia utilizando el NanoVNA
5. Calcula tu Vf real: **Vf = f_resonancia_medida / f_objetivo**

Por ejemplo: si calculaste para 435 MHz pero el loop resuena a 400 MHz, tu Vf es 400/435 = 0.92.

En mi experiencia, calcular el Vf con únicamente el elemento director no funcionará,
necesitas tener el reflector, cuya instalación desvía la frecuencia hacia abajo.

Esto funciona porque un Vf menor que 1 significa que el conjunto es eléctricamente "demasiado largo" y resuena más abajo de lo esperado.

---

## 3. Cálculo de dimensiones para cualquier frecuencia

Para una frecuencia central f (en MHz) y un velocity factor Vf:

**Perímetros (mm):**

    Reflector   = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Director 1  = (975 × Vf) / f × 304.8
    Director 2  = Director 1 × 0.97
    Director 3  = Director 2 × 0.97
    ...y así sucesivamente

**Perímetros (pulgadas):**

    Reflector   = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Director 1  = (975 × Vf) / f × 12
    Director 2  = Director 1 × 0.97
    ...

**Espaciados (mm):** (independientes del Vf)

    Reflector → Driven:   300,000 / f × 0.20
    Driven → Director:    300,000 / f × 0.15
    Director → Director:  300,000 / f × 0.15

**Espaciados (pulgadas):**

    Reflector → Driven:   11,811 / f × 0.20
    Driven → Director:    11,811 / f × 0.15
    Director → Director:  11,811 / f × 0.15

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

- **Artículos de Cebik sobre quads** (indexados por G0UIH): https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Explicación del efecto del Vf en loops con cable PVC: https://q82.uk/1005overf
- **W8JI — Cubical Quad** — Análisis técnico riguroso: https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Guías de construcción

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Calculadores online

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm (no tiene corrección de Vf)
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Normas citadas

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definición del S-meter. 1 unidad S = 6 dB, S9 en VHF = −93 dBm (5 µV en 50 Ω).

---

*73 de EA4IPW — OpenQuad v1.0*
