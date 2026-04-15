# MOQUAD — Guía práctica para construir y ajustar una antena Cubical Quad modular

**Por EA4IPW — Basada en la construcción real de un quad de 5 elementos para 435 MHz**

---

## 1. Introducción

Esta guía documenta el proceso de diseño, construcción y ajuste paso a paso de una antena cubical quad. Está pensada para radioaficionados que quieran construir su propia antena con materiales accesibles y ajustarla con un analizador de antenas tipo NanoVNA.

La cubical quad es una antena de elementos parasíticos (como un Yagi) donde cada elemento es un loop cuadrado de una longitud de onda completa. Frente a un Yagi equivalente, ofrece ~2 dB más de ganancia para el mismo número de elementos, mejor ratio front-to-back, y una impedancia de feedpoint más cercana a 50 Ω.

Las fórmulas y procedimientos de esta guía son válidos para cualquier frecuencia. Se incluye como ejemplo práctico detallado una construcción real para la banda de 70 cm (435 MHz).

---

## 2. Las fórmulas y de dónde vienen

### 2.1. La constante base: de la velocidad de la luz a "1005"

La longitud de onda en el vacío es:

    λ = c / f

Donde c = 299,792,458 m/s. Expresado en pies:

    λ (pies) = 983.57 / f(MHz)

Un loop cuadrado de una longitud de onda no resuena exactamente en λ teórica. Los efectos de la corriente circulando por las esquinas y la curvatura del campo hacen que necesite ser ligeramente más largo (~2.2%) para resonar. Esto da la constante empírica clásica:

    983.57 × 1.021 ≈ 1005

Esta constante aparece publicada en la bibliografía de antenas desde los años 1960 (ver Referencias).

**Nota:** A diferencia de un dipolo, que se *acorta* ~5% respecto al teórico (de 492 a 468) por el "end effect" en sus extremos abiertos, un loop cerrado necesita ser *más largo* porque no tiene extremos abiertos.

### 2.2. Fórmulas para cada elemento

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

### 2.3. De dónde salen las constantes 1030 y 975

No son arbitrarias. Parten de la constante base del driven element (1005):

| Constante | Cálculo | Función |
|---|---|---|
| 1005 | 984 × 1.021 | Loop resonante a la frecuencia de trabajo |
| 1030 | 1005 × 1.025 | Reflector: 2.5% más largo → resuena por debajo → inductivo |
| 975 | 1005 × 0.970 | Director: 3% más corto → resuena por encima → capacitivo |

El reflector inductivo y el director capacitivo producen la fase necesaria para que la antena radie en una sola dirección (del reflector hacia los directores).

### 2.4. Espaciados entre elementos

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

## 3. El Velocity Factor (Vf): por qué importa y cómo calcularlo

### 3.1. Qué es el Vf

Las fórmulas del apartado anterior asumen **cobre desnudo en espacio libre** (Vf = 1.0). Si usas cable con aislamiento (PVC, polietileno, teflón), la onda viaja más lenta por el conductor, lo que reduce la longitud física necesaria para resonar a la misma frecuencia.

El aislamiento aumenta la capacitancia distribuida a lo largo del conductor, ralentizando la propagación. Esto significa que necesitas **menos cable** para completar una longitud de onda eléctrica.

### 3.2. Valores típicos de Vf

| Tipo de cable | Vf aproximado |
|---|---|
| Cobre desnudo | 1.00 |
| Aislamiento PTFE/Teflón | 0.97–0.98 |
| Aislamiento polietileno | 0.95–0.96 |
| Aislamiento PVC fino | 0.93–0.95 |
| Aislamiento PVC grueso (cable de instalación 450/750V) | 0.90–0.93 |

**Atención:** Estos son valores orientativos. El Vf real depende del grosor del aislamiento relativo al diámetro del conductor. Un cable de instalación doméstica (H07V-K, UNE-EN 50525) de 1.5 mm² tiene un forro PVC proporcionalmente más grueso que el mismo cable en 6 mm², y por tanto un Vf más bajo.

### 3.3. Fórmulas corregidas con Vf

Multiplica cada constante por el Vf:

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (pulgadas)
    Driven = (1005 × Vf) / f(MHz)              (pies)

Lo mismo para las constantes 1030 (reflector) y 975 (director 1).

### 3.4. Cómo medir el Vf de tu cable

El método más directo es empírico:

1. Calcula el perímetro del driven element usando las fórmulas para cobre desnudo (Vf = 1.0).
2. Construye el loop y mide su resonancia con un VNA.
3. Calcula tu Vf real: **Vf = f_resonancia_medida / f_objetivo**

Por ejemplo: si calculaste para 435 MHz pero el loop resuena a 400 MHz, tu Vf es 400/435 = 0.92.

Esto funciona porque un Vf menor que 1 significa que el loop es eléctricamente "demasiado largo" y resuena más abajo de lo esperado.

**Método alternativo con VNA (más preciso):**

1. Corta un trozo recto de cable de longitud conocida.
2. Conéctalo al VNA por un extremo, dejando el otro abierto.
3. Busca la frecuencia donde muestra resonancia de cuarto de onda.
4. Calcula: Vf = (4 × longitud_física × f_resonancia) / c

Una vez que conoces el Vf, úsalo para recalcular todos los elementos y corta con un 3–5% de margen adicional para el ajuste fino.

### 3.5. Cuánto importa el Vf en la práctica

El impacto del Vf crece con la frecuencia. Para visualizarlo:

| Banda | f (MHz) | Perímetro driven Vf=1.0 | Perímetro driven Vf=0.91 | Diferencia |
|---|---|---|---|---|
| 20 m | 14.2 | 21,579 mm | 19,637 mm | 1,942 mm |
| 10 m | 28.5 | 10,752 mm | 9,784 mm | 968 mm |
| 6 m | 50.1 | 6,116 mm | 5,565 mm | 551 mm |
| 2 m | 145 | 2,113 mm | 1,923 mm | 190 mm |
| 70 cm | 435 | 704 mm | 641 mm | 63 mm |

En HF, la diferencia es de metros y es fácil de absorber recortando cable. En VHF/UHF, aunque la diferencia absoluta es menor, es proporcionalmente más significativa y puede desplazar la resonancia decenas de MHz si se ignora.

---

## 4. Cómo calcular las dimensiones para cualquier frecuencia

### 4.1. Fórmula general

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

### 4.2. Ejemplo resuelto: 435 MHz con cable PVC (Vf = 0.91)

Las siguientes dimensiones corresponden a la construcción real documentada en esta guía.

**Elementos:**

| Elemento | Perímetro (mm) | Perímetro (in) | Lado (mm) | Lado (in) | Spreader (mm) | Spreader (in) |
|---|---|---|---|---|---|---|
| Reflector | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| Driven | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| Director 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| Director 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| Director 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| Director 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| Director 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**Espaciados:**

| Tramo | Distancia (mm) | Distancia (in) |
|---|---|---|
| Reflector → Driven | 137.9 | 5.43 |
| Driven → Director 1 | 103.4 | 4.07 |
| Director → Director | 103.4 | 4.07 |

**Longitud total del boom:**

| Configuración | Boom (mm) | Boom (in) |
|---|---|---|
| 2 elem (R + DE) | 137.9 | 5.43 |
| 3 elem (R + DE + D1) | 241.4 | 9.50 |
| 4 elem (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 elem (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 elem (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 elem (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 5. Materiales

### 5.1. Cable para los elementos

Cualquier cable de cobre con o sin aislamiento sirve. Para cable aislado (PVC, polietileno), recuerda aplicar la corrección de Vf.

En VHF/UHF, secciones de 0.5 mm² a 1.5 mm² funcionan bien. El cable más fino es más manejable; el más grueso mantiene mejor la forma. A 435 MHz el skin depth es de solo 3 µm, así que toda la corriente fluye por la superficie del conductor. La diferencia de pérdidas entre 0.5 mm² y 1.5 mm² es de ~0.025 dB — completamente despreciable. El ancho de banda se reduce ~8% con el cable más fino, lo que tampoco es significativo en la práctica.

En HF, donde los elementos son mucho más grandes, se usa típicamente cable de cobre de 1–2 mm de diámetro (desnudo o aislado), o incluso cable multifilar para reducir peso.

Para potencias de hasta 50W no hay ningún problema con cable fino. El límite práctico lo ponen las soldaduras y el aislamiento (el PVC se ablanda a ~70°C), no el conductor.

### 5.2. Boom

El aluminio es ideal: ligero, rígido y fácil de trabajar. Un tubo cuadrado o circular de sección apropiada al tamaño de la antena es suficiente.

**¿Afecta un boom metálico a la antena?** En un quad, a diferencia de un Yagi, el boom es perpendicular al plano de los loops y los elementos están separados del boom por los spreaders. El efecto es mínimo o inexistente. **No se necesita corrección de boom** como en un Yagi.

Un boom de madera funciona igual pero es más pesado y absorbe humedad. Su efecto dieléctrico (εr ≈ 2) podría desplazar la frecuencia ~0.1% — irrelevante en la práctica.

Si el boom es circular en vez de cuadrado, no hay diferencia eléctrica. La única consideración es mecánica: asegurar que los hubs de los spreaders queden fijados en la misma orientación angular (ver sección 5.4).

### 5.3. Spreaders

Varillas de fibra de vidrio, bambú, o PVC. Deben ser de material no conductor. El diámetro apropiado depende de la banda: en VHF/UHF, varillas de 4–5 mm son suficientes; en HF, se necesitan cañas de bambú, tubos de fibra de vidrio, o barras de mayor sección.

### 5.4. Alineación de los elementos

Todos los loops cuadrados deben estar **alineados en la misma orientación rotacional** sobre el boom. Si se rota un elemento respecto a los demás, el acoplamiento entre elementos se degrada porque los segmentos de corriente dejan de ser paralelos.

- **Unos pocos grados de error:** efecto despreciable.
- **45° de rotación:** acoplamiento seriamente degradado, pérdida de ganancia y F/B.
- **90° de rotación:** equivalente a 0° por simetría del cuadrado, pero la polarización sería cruzada si el feedpoint no rota con el elemento.

Con boom cuadrado la alineación es natural. Con boom circular, asegura la orientación con un tornillo prisionero, un pin pasante, o un flat en el tubo.

---

## 6. Ajuste paso a paso

### 6.1. Herramientas necesarias

- Analizador de antenas (NanoVNA, LiteVNA, o similar)
- Cable coaxial corto con conector para el VNA
- Soldador y estaño
- Regla milimetrada o calibre digital
- Alicates de corte fino

### 6.2. Choke balun (opcional pero recomendado para la medida)

Un choke balun en el feedpoint mejora la fiabilidad de las medidas al impedir que la trenza del coaxial radie y altere los resultados. Sin choke, tocar o mover el cable del VNA puede cambiar las lecturas.

**Para HF:** un choke bobinado clásico funciona bien: 6–10 vueltas de coaxial sobre un toroide de ferrita (FT-140-43 o similar).

**Para VHF/UHF:** NO uses un choke bobinado — a frecuencias altas la capacitancia entre espiras crea resonancias parásitas. En su lugar, usa **ferritas snap-on (clamp-on)** de mix 43 ensartadas en línea sobre el coaxial justo detrás del feedpoint. 5–6 unidades proporcionan impedancia suficiente.

Referencia de ferritas snap-on válidas para VHF/UHF: Fair-Rite 0443164251 (cable ≤6.6 mm), Fair-Rite 0443167251 (cable ≤9.85 mm), o Fair-Rite 0443164151 (cable ≤12.7 mm), todas en material mix 43. Disponibles en Mouser, DigiKey, o distribuidores similares.

Las snap-on se abren y cierran con los dedos, no requieren herramientas, y son completamente reutilizables.

**Nota:** Muchas antenas comerciales de tipo quad no llevan choke y funcionan perfectamente. El quad tiene una geometría intrínsecamente bien equilibrada en el feedpoint. El choke es principalmente para obtener medidas fiables durante el ajuste, no un requisito para el uso normal.

### 6.3. Procedimiento de ajuste

#### Paso 1 — Determinar el Vf de tu cable

Si usas cobre desnudo, salta al paso 2 (Vf = 1.0).

Si usas cable con aislamiento:

1. Calcula el perímetro del driven element con Vf = 1.0: `perímetro = 1005 / f(MHz) × 304.8 mm`.
2. Construye el loop y mide su resonancia con el VNA.
3. Calcula tu Vf real: `Vf = f_medida / f_objetivo`.
4. Recalcula todas las dimensiones con este Vf.

#### Paso 2 — Driven element solo

1. Corta el driven con un 3–5% de margen (más largo de lo calculado).
2. Monta el loop en los spreaders y conecta el coaxial al feedpoint (centro del lado inferior para polarización horizontal, centro de un lado lateral para polarización vertical).
3. Mide con el VNA: busca el mínimo de SWR.
4. Recorta simétricamente (misma cantidad de cada lado del feedpoint) hasta centrar la resonancia en tu frecuencia objetivo.

**Nota:** Un driven aislado tiene ~100–120 Ω de impedancia, así que el SWR mínimo será alto (~2:1 sobre 50 Ω). Esto es normal y esperado.

#### Paso 3 — Añadir el reflector

1. Monta el reflector a la distancia calculada (0.20λ) detrás del driven.
2. **La resonancia bajará** (típicamente 1–2% de la frecuencia). Esto es completamente normal: el acoplamiento mutuo desplaza la resonancia hacia abajo.
3. La impedancia del driven bajará a 50–80 Ω y el SWR debería mejorar significativamente.
4. Si la resonancia ha bajado demasiado, recorta el driven (no el reflector) unos pocos mm para subirla.

**No intentes ajustar el driven aislado a la frecuencia objetivo y luego añadir el reflector esperando que se mantenga.** El acoplamiento siempre desplaza la frecuencia. Hay dos enfoques válidos:

- **Precompensar:** ajustar el driven solo a una frecuencia ligeramente superior a la objetivo, sabiendo que el reflector la bajará.
- **Ajustar con todo montado:** montar driven + reflector juntos desde el inicio y recortar el driven hasta centrar la resonancia. Este es el enfoque más práctico.

#### Paso 4 — Añadir los directores, uno a uno

1. Monta el Director 1 a 0.15λ delante del driven. Su perímetro debe ser ~3% menor que el driven.
2. Mide. La frecuencia puede subir o bajar ligeramente dependiendo del acoplamiento.
3. Si el SWR es aceptable, procede al siguiente director.
4. Repite para cada director adicional. Cada uno debe ser un 3% más corto que el anterior.

**Problema común: SWR sube bruscamente al añadir un director.** La causa más frecuente es que el director es demasiado largo (demasiado cerca de la frecuencia de resonancia del driven). Cuando un parásito resuena a la misma frecuencia que el driven, absorbe máxima energía y el SWR se dispara. **Solución:** verifica que el director es realmente un 3% más corto que el driven y recórtalo si es necesario.

#### Paso 5 — Ajuste final

Después de montar todos los elementos, puede ser necesario un retoque fino del driven element para centrar la frecuencia. Los directores raramente necesitan retoque si se cortaron correctamente.

**Tip:** En el VNA, usa la vista de SWR vs frecuencia (no solo la carta de Smith) para ver claramente dónde está el mínimo y el ancho de banda.

---

## 7. Rendimiento esperado

### 7.1. Ganancia y F/B por configuración

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

### 7.2. Equivalencia con Yagi

Como referencia general, un quad de N elementos rinde aproximadamente como un Yagi de N+2 elementos con boom de longitud similar.

### 7.3. Verificación práctica del F/B

Sintoniza un repetidor o baliza conocida, apunta la antena hacia la fuente, anota la lectura del S-meter, gira 180° y compara. Cada unidad S de diferencia equivale a ~6 dB según la norma IARU Region 1 R.1 (1981), aunque la calibración de los S-meters en equipos comerciales puede variar significativamente, especialmente por debajo de S3 donde muchos receptores solo dan 2–3 dB por unidad S.

---

## 8. Problemas frecuentes y soluciones

### La frecuencia de resonancia está muy por debajo de lo esperado

**Causa probable:** no se ha tenido en cuenta el Vf del cable aislado. Un cable PVC puede tener Vf = 0.91–0.95, lo que alarga eléctricamente los elementos.

**Solución:** mide el Vf empíricamente (paso 1 del procedimiento) y recalcula las dimensiones.

### El SWR sube mucho al añadir un director

**Causa probable:** el director está cortado a la misma longitud que el driven, o muy cerca. Cuando un parásito resuena en la misma frecuencia que el driven, absorbe máxima energía.

**Solución:** verifica que el director es un 3% más corto que el driven. Recórtalo si es necesario.

### La frecuencia baja al añadir el reflector

**Causa:** acoplamiento mutuo inductivo entre reflector y driven. Es comportamiento normal, no un error.

**Solución:** precompensar el driven (ajustarlo solo a una frecuencia más alta de la objetivo) o ajustar con driven + reflector montados conjuntamente.

### La frecuencia se desplaza al manipular la antena

**Causa:** en VHF/UHF, 1–2 mm de desplazamiento en una esquina cambian la frecuencia fácilmente.

**Solución:** asegura bien los cables en los spreaders antes de las medidas definitivas. Usa muescas, bridas o hilo de nylon.

### Las medidas del VNA cambian al tocar el cable

**Causa:** corriente de modo común en la trenza exterior del coaxial. El cable del VNA se comporta como parte de la antena.

**Solución:** añade ferritas snap-on (mix 43) en el feedpoint. Si no tienes ferritas, al menos mantén la misma disposición del cable entre medidas.

### El SWR es bueno pero el F/B es pobre

**Causa probable:** el reflector no está bien ajustado. El SWR y el F/B se optimizan a diferentes longitudes del reflector.

**Solución:** prueba a alargar o acortar el reflector 1–2%. Alternativamente, usa un stub cortocircuitado en el reflector para ajustarlo sin cambiar su longitud física.

---

## 9. Resultado de la construcción de referencia

La antena documentada como ejemplo en esta guía (5 elementos, 435 MHz, cable PVC de 0.5 mm², Vf medido de 0.91) alcanzó los siguientes resultados medidos:

- **SWR:** 1.32 en el punto de mínimo (432 MHz), <1.6 a 435 MHz
- **F/B medido:** ~6 unidades S de diferencia (S9 frontal, S3 trasero) ≈ 30–36 dB
- **Impedancia en resonancia:** próxima a 50 Ω
- **Ancho de banda útil (SWR < 2):** ~430–440 MHz

---

## 10. Referencias

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

*73 de EA4IPW — MOQUAD v1.0*