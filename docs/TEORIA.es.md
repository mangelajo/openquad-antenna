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
