# OpenQuad — Antena Cubical Quad modular y plegable

**Por EA4IPW — Caso práctico: construcción de un quad de 5 elementos para 435 MHz**

<p align="center">
  <img src="../web/diagram.jpeg" width="420" alt="Diagrama del diseño"/>
</p>

---

## 1. Qué es este diseño

Este proyecto documenta un **diseño de antena Cubical Quad modular y plegable** pensado para fabricarse con piezas impresas en 3D, varillas de fibra de vidrio o madera como spreaders y un boom de PVC, madera o aluminio.

Las características principales del diseño son:

- **Modular:** cada elemento (reflector, driven, directores) se monta sobre un *bloque* independiente que se desliza y se fija al boom. Puedes construir la antena con 2, 3, 5 , 6, 7 .. elementos usando el mismo hardware.
- **Plegable:** los spreaders pivotan sobre el bloque, de modo que la antena puede recogerse para transporte o almacenamiento y desplegarse en segundos para operar.
- **Escalable por banda:** el diseño paramétrico en OpenSCAD ([src/all_in_one.scad](../src/all_in_one.scad)) permite ajustar el diámetro del boom y de los spreaders y regenerar la pieza para otros tamaños de boom y spreader.

- **Ajustable:** los loops se sujetan con abrazaderas impresas ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) que permiten recortar y volver a fijar el cable durante el tuning.

Esta guía documenta el proceso práctico de construcción y ajuste paso a paso. Los fundamentos teóricos (origen de las fórmulas 1005/1030/975, efecto del velocity factor, rendimiento esperado, referencias bibliográficas) se tratan en un documento separado:

> 📘 **[TEORIA.es.md](TEORIA.es.md) — Fundamentos teóricos y referencias**

Las fórmulas son válidas para cualquier frecuencia; como ejemplo práctico detallado se documenta una construcción real para la banda de 70 cm (435 MHz) con cable de instalación PVC de 0.5 mm².

<p align="center">
  <img src="images/pics/70cm_open.jpeg" width="420" alt="Antena desplegada (5 elementos, 435 MHz)"/>
  <img src="images/pics/70cm_folded.jpeg" width="420" alt="Antena plegada para transporte"/>
</p>

---

## 2. Dimensiones para la construcción de referencia (435 MHz, Vf = 0.91)

Las siguientes dimensiones corresponden a la construcción real documentada en esta guía, usando cable PVC de 0.5 mm² con velocity factor medido de 0.91.

> Si construyes para otra frecuencia o con otro tipo de cable, consulta las fórmulas generales y el procedimiento para medir el Vf en [TEORIA.es.md § 2–3](TEORIA.es.md), o usa la [🧮 calculadora online](https://openquad-calc.ea4ipw.es) para obtener las dimensiones directamente.

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

**Longitud total del boom según configuración:**

| Configuración | Boom (mm) | Boom (in) |
|---|---|---|
| 2 elem (R + DE) | 137.9 | 5.43 |
| 3 elem (R + DE + D1) | 241.4 | 9.50 |
| 4 elem (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 elem (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 elem (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 elem (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. Materiales

Resumen de lo que necesitas para construir la antena. Las secciones siguientes detallan alternativas, dimensionado y justificaciones.

| Material | Especificación recomendada | Cantidad | Subsección |
|---|---|---|---|
| Cable de cobre (elementos) | PVC 0.5 mm² (VHF/UHF); 1–2 mm Ø desnudo o aislado (HF) | Según perímetros (§2) | [3.1](#31-cable-para-los-elementos) |
| Boom | Tubo de aluminio, PVC o madera (cuadrado o circular) | 1, longitud según configuración (§2) | [3.2](#32-boom) |
| Spreaders | Varilla no conductora (fibra de vidrio, haya o PVC), 4–8 mm Ø en VHF/UHF | 4 por elemento | [3.3](#33-spreaders) |
| Tornillos Allen M3 × 12 mm | Hex socket cap (M3×8/M3×10 para spreaders más finos) | 4 por elemento | [3.4](#34-tornillería-y-retención) |
| Tuercas M3 | Hexagonales estándar | 4 por elemento | [3.4](#34-tornillería-y-retención) |
| Goma elástica | Cualquiera que abrace el bloque plegado | 1 por elemento | [3.4](#34-tornillería-y-retención) |
| Coaxial + conector | Según tu equipo (típicamente RG-58/RG-316 en UHF) | 1 | — |
| Termorretráctil | Varios diámetros para aislar soldaduras del feedpoint y empalmes | Unos cm | — |
| Ferritas snap-on mix 43 (opcional, ajuste) | Fair-Rite 0443164251/0443167251 según Ø del coaxial | 5–6 | [4.2](#42-choke-balun-opcional-pero-recomendado-para-la-medida) |

### 3.1. Cable para los elementos

Cualquier cable de cobre con o sin aislamiento sirve. Para cable aislado (PVC, polietileno), recuerda aplicar la corrección de Vf (ver [TEORIA.es.md § 2](TEORIA.es.md)).

En VHF/UHF, secciones de 0.5 mm² a 1.5 mm² funcionan bien. El cable más fino es más manejable; el más grueso mantiene mejor la forma, mi recomendación es el de 0.5mm². A 435 MHz el skin depth es de solo 3 µm, así que toda la corriente fluye por la superficie del conductor. La diferencia de pérdidas entre 0.5 mm² y 1.5 mm² es de ~0.025 dB — completamente despreciable. El ancho de banda se reduce ~8% con el cable más fino, lo que tampoco es significativo en la práctica.

En HF, donde los elementos son mucho más grandes, se usa típicamente cable de cobre de 1–2 mm de diámetro (desnudo o aislado), o incluso cable multifilar para reducir peso.

Para potencias de hasta 50W no hay ningún problema con cable fino. El límite práctico lo ponen las soldaduras y el aislamiento (el PVC se ablanda a ~70°C), no el conductor.

Al unir tramos o cerrar un loop, pela unos 10 mm de cada extremo, únelos en paralelo (trenzando o con un empalme Western Union), suelda con aporte generoso y protege la unión con termorretráctil.

<p align="center">
  <img src="images/pics/10mm_extra_soldering.jpg" width="300" alt="10 mm de cable pelado antes de soldar"/>
  <img src="images/pics/soldering_edges.jpg" width="300" alt="Empalme de los dos extremos antes de la soldadura"/>
</p>
<p align="center">
  <img src="images/pics/soldered_edges.jpg" width="300" alt="Empalme soldado"/>
  <img src="images/pics/thermoretractile.jpg" width="300" alt="Termorretráctil aplicado sobre la soldadura"/>
</p>

### 3.2. Boom

El aluminio es ideal: ligero, rígido y fácil de trabajar. Un tubo cuadrado o circular de sección apropiada al tamaño de la antena es suficiente. Para UHF un tubo de PVC también sirve perfectamente.

**¿Afecta un boom metálico a la antena?** En un quad, a diferencia de un Yagi, el boom es perpendicular al plano de los loops y los elementos están separados del boom por los spreaders. El efecto es mínimo o inexistente. **No se necesita corrección de boom** como en un Yagi.

Un boom de madera funciona igual pero es más pesado y absorbe humedad. Su efecto dieléctrico (εr ≈ 2) podría desplazar la frecuencia ~0.1% — irrelevante en la práctica.

Si el boom es circular en vez de cuadrado, no hay diferencia eléctrica. La única consideración es mecánica: asegurar que los hubs de los spreaders queden fijados en la misma orientación angular (ver sección 3.5).

<p align="center">
  <img src="images/pics/reflector_assembly_closed_boom.jpg" width="420" alt="Elemento montado sobre boom de PVC"/>
</p>

### 3.3. Spreaders

Varillas de fibra de vidrio, haya, o PVC. Deben ser de material no conductor. El diámetro apropiado depende de la banda: en VHF/UHF, varillas de 4–8 mm son suficientes

<p align="center">
  <img src="images/pics/element_preparation.jpg" width="420" alt="Hubs impresos y varillas de spreader cortadas a medida"/>
</p>

### 3.4. Tornillería y retención

Cada elemento necesita una pequeña cantidad de tornillería estándar para cerrar las abrazaderas sobre los spreaders y mantener el bloque print-in-place plegado durante el transporte:

- **Tornillos Allen (hex socket cap) M3 × 12 mm — 4 por elemento.** Uno por cada abrazadera de spreader; aprietan las dos mitades de la abrazadera alrededor de la varilla. La longitud de 12 mm está dimensionada para un **spreader de 8 mm** — spreaders más finos (4–6 mm) usan un cuerpo de abrazadera más delgado y pueden necesitar un tornillo más corto (M3×8 o M3×10); comprueba la profundidad del canal del tornillo en la pieza renderizada antes de comprar. El alojamiento de la tuerca y la holgura del tornillo están dimensionados para M3 en [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad).
- **Tuercas M3 — 4 por elemento.** Se asientan en el hueco hexagonal de cada abrazadera antes de apretar el tornillo.
- **Goma elástica — 1 por elemento.** Envuelve el bloque `all_in_one` plegado para mantener las cuatro abrazaderas cerradas contra el collar del boom durante transporte y almacenamiento.

<p align="center">
  <img src="images/pics/element_assembly_screws.jpg" width="420" alt="Bloques montados con tornillería M3"/>
</p>

### 3.5. Alineación de los elementos

Todos los loops cuadrados deben estar **alineados en la misma orientación rotacional** sobre el boom. Si se rota un elemento respecto a los demás, el acoplamiento entre elementos se degrada porque los segmentos de corriente dejan de ser paralelos.

- **Unos pocos grados de error:** efecto despreciable.
- **45° de rotación:** acoplamiento seriamente degradado, pérdida de ganancia y F/B.

Con boom cuadrado la alineación es natural. Con boom circular, asegura la orientación con un tornillo prisionero, un pin pasante, o una gota de pegamento.

<p align="center">
  <img src="images/pics/reflector_assembly_open.jpg" width="320" alt="Elemento desplegado (spreaders abiertos en X)"/>
  <img src="images/pics/reflector_assembly_closed.jpg" width="320" alt="Elemento plegado (spreaders cerrados)"/>
</p>

---

## 4. Ajuste paso a paso

### 4.1. Herramientas necesarias

- Analizador de antenas (NanoVNA, LiteVNA, o similar)
- Cable coaxial corto con conector para el VNA
- Soldador y estaño
- Regla milimetrada o calibre digital
- Alicates de corte fino

<p align="center">
  <img src="images/pics/nanovna_swr.jpg" width="420" alt="NanoVNA mostrando carta de Smith y SWR de la antena"/>
</p>

### 4.2. Choke balun (opcional pero recomendado para la medida)

Un choke balun en el feedpoint mejora la fiabilidad de las medidas al impedir que la trenza del coaxial radie y altere los resultados. Sin choke, tocar o mover el cable del VNA puede cambiar las lecturas.

**Para HF:** un choke bobinado clásico funciona bien: 6–10 vueltas de coaxial sobre un toroide de ferrita (FT-140-43 o similar).

**Para VHF/UHF:** NO uses un choke bobinado — a frecuencias altas la capacitancia entre espiras crea resonancias parásitas. En su lugar, usa **ferritas snap-on (clamp-on)** de mix 43 ensartadas en línea sobre el coaxial justo detrás del feedpoint. 5–6 unidades proporcionan impedancia suficiente.

Referencia de ferritas snap-on válidas para VHF/UHF: Fair-Rite 0443164251 (cable ≤6.6 mm), Fair-Rite 0443167251 (cable ≤9.85 mm), o Fair-Rite 0443164151 (cable ≤12.7 mm), todas en material mix 43. Disponibles en Mouser, DigiKey, o distribuidores similares.

Las snap-on se abren y cierran con los dedos, no requieren herramientas, y son completamente reutilizables.

**Nota:** Muchas antenas comerciales de tipo quad no llevan choke y funcionan perfectamente. El quad tiene una geometría intrínsecamente bien equilibrada en el feedpoint. El choke es principalmente para obtener medidas fiables durante el ajuste, no un requisito para el uso normal.

<p align="center">
  <img src="images/pics/driven_element_solder.jpg" width="320" alt="Detalle de la soldadura del driven"/>
  <img src="images/pics/driven_element.jpeg" width="320" alt="Driven element con coaxial y sellado"/>
</p>

### 4.3. Procedimiento de ajuste

#### Paso 1 — Construir y calibrar el Vf

Todo cable real tiene Vf < 1. El cobre desnudo al aire está alrededor de 0.97 y 0.99, los cables aislados bajan a 0.90–0.97 según el material. El procedimiento recomendado es partir de un valor aproximado y calibrar midiendo:

1. Calcula las dimensiones de todos los elementos con la [🧮 calculadora online](https://openquad-calc.ea4ipw.es) usando como Vf de partida el valor típico de tu cable (0.99 cobre desnudo, ≈0.91 PVC fino, ≈0.95 polietileno, ≈0.97 teflón; tabla completa en [TEORIA.es.md § 2.2](TEORIA.es.md)). La fórmula subyacente es `perímetro = k × λ × Vf`, con `λ = 299,792.458 / f(MHz)` mm y `k_driven ≈ 1.022` (ver [TEORIA.es.md § 1](TEORIA.es.md)).
2. Monta la antena completa con esas dimensiones.
3. Mide la frecuencia resonante del conjunto con el VNA.
4. Introduce la frecuencia medida en la [🧮 calculadora](https://openquad-calc.ea4ipw.es) para obtener el Vf real y las dimensiones corregidas.
5. Acorta cada loop a la nueva medida — las abrazaderas de hilo ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) permiten este ajuste sin rehacer la soldadura.

> Ver [TEORIA.es.md § 2.4](TEORIA.es.md) para más detalles.

**No intentes ajustar el driven aislado a la frecuencia objetivo y luego añadir el reflector esperando que se mantenga.** El acoplamiento siempre desplaza la frecuencia; por eso medimos con la antena completa ya montada.

#### Paso 2 — Añadir los directores, uno a uno

1. Monta el Director 1 a 0.15λ delante del driven. Su perímetro debe ser ~3% menor que el driven.
2. Mide. La frecuencia puede subir o bajar ligeramente dependiendo del acoplamiento.
3. Si el SWR es aceptable, procede al siguiente director.
4. Repite para cada director adicional. Cada uno debe ser un 3% más corto que el anterior.

**Problema común: SWR sube bruscamente al añadir un director.** La causa más frecuente es que el director es demasiado largo (demasiado cerca de la frecuencia de resonancia del driven). Cuando un parásito resuena a la misma frecuencia que el driven, absorbe máxima energía y el SWR se dispara. **Solución:** verifica que el director es realmente un 3% más corto que el driven y recórtalo si es necesario.

#### Paso 3 — Ajuste final

Después de montar todos los elementos, puede ser necesario un retoque fino del driven element para centrar la frecuencia. Los directores raramente necesitan retoque si se cortaron correctamente.

**Tip:** En el VNA, usa la vista de SWR vs frecuencia (no solo la carta de Smith) para ver claramente dónde está el mínimo y el ancho de banda.

<p align="center">
  <img src="images/pics/wire_clam_screw.jpg" width="320" alt="Abrazadera de hilo — lado del tornillo Allen"/>
  <img src="images/pics/wire_clam_nut.jpg" width="320" alt="Abrazadera de hilo — lado de la tuerca"/>
</p>

---

## 5. Problemas frecuentes y soluciones

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

**Solución:** asegura bien los cables en los spreaders antes de las medidas definitivas, ajustando la tensión para que que el cable se mantenga estirado.

### Las medidas del VNA cambian al tocar el cable

**Causa:** corriente de modo común en la trenza exterior del coaxial. El cable del VNA se comporta como parte de la antena.

**Solución:** añade ferritas snap-on (mix 43) en el feedpoint. Si no tienes ferritas, al menos mantén la misma disposición del cable entre medidas.

### El SWR es bueno pero el F/B es pobre

**Causa probable:** el reflector no está bien ajustado. El SWR y el F/B se optimizan a diferentes longitudes del reflector.

**Solución:** prueba a alargar o acortar el reflector 1–2%. Alternativamente, usa un stub cortocircuitado en el reflector para ajustarlo sin cambiar su longitud física.

---

## 6. Resultado de la construcción de referencia

La antena documentada como ejemplo en esta guía (5 elementos, 435 MHz, cable PVC de 0.5 mm², Vf medido de 0.91) alcanzó los siguientes resultados medidos:

- **SWR:** 1.1 en el punto de mínimo (432 MHz), <1.6 a 435 MHz
- **F/B medido:** ~6 unidades S de diferencia (S9 frontal, S3 trasero) ≈ 30–36 dB
- **Impedancia en resonancia:** próxima a 50 Ω
- **Ancho de banda útil (SWR < 2):** ~430–440 MHz

> Para comparar con los valores teóricos esperados en otras configuraciones (2–7 elementos) y la equivalencia con Yagi, ver [TEORIA.es.md § 4](TEORIA.es.md).

<p align="center">
  <img src="images/pics/70cm_open_2.jpeg" width="520" alt="Vista 3/4 de la antena de 5 elementos para 435 MHz construida"/>
</p>

---

## 7. Piezas pre-construidas

CI publica un conjunto pre-renderizado de STL para los tamaños de boom y spreader más comunes en cada release. Cada combinación se distribuye como un único zip que contiene las tres piezas imprimibles (`all_in_one`, `driven_element`, `regular_wire_clamp`) más las vistas previas en PNG. Descarga la combinación que coincida con tu hardware y empieza a imprimir — no hace falta OpenSCAD.

Si ninguna de las combinaciones pre-renderizadas coincide con tu hardware, consulta el [§ 7.4](#74-construir-un-tamaño-personalizado) más abajo para renderizar la tuya.

### 7.1. Bloque todo-en-uno (collar del boom + 4 abrazaderas)

<p align="center">
  <img src="images/pics/aio_open.jpg" width="320" alt="Bloque all-in-one con las abrazaderas abiertas"/>
  <img src="images/pics/aio_closed.jpg" width="320" alt="Bloque all-in-one con las abrazaderas cerradas contra el collar del boom"/>
</p>

Forma del boom × dimensión del boom en filas, diámetro del spreader en columnas.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Redondo 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Redondo 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Redondo 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **Cuadrado 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Cuadrado 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Cuadrado 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. Abrazaderas de spreader

Estas dos piezas dependen únicamente del diámetro del spreader (la forma y dimensión del boom no importan), por lo que solo hay tres variantes de cada una.

| Spreader | Elemento excitado | Abrazadera de hilo (parásito) |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. Descargas

Cada enlace es un zip con los tres STL más las vistas previas PNG para esa combinación. Siempre apunta a la **última release**.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Redondo 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **Redondo 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **Redondo 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **Cuadrado 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **Cuadrado 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **Cuadrado 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. Construir un tamaño personalizado

Si ninguna de las combinaciones pre-renderizadas coincide con tu hardware (o quieres experimentar con otros diámetros), puedes renderizar las piezas tú mismo. Hay tres parámetros que normalmente tocarás, todos en el archivo [src/all_in_one.scad](../src/all_in_one.scad):

- `boom_is_round` — `true` para tubo redondo, `false` para cuadrado.
- `boom_dia` (redondo) **o** `boom_side` (cuadrado) — dimensión exterior del boom en mm.
- `spreaders_dia` — diámetro exterior de tu varilla spreader en mm.

El elemento excitado y la abrazadera de hilo regular ([src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)) solo dependen de `spreaders_dia` y de `driven_element` (`true` / `false`).

> ⚠️ **Pre-verifica visualmente el todo-en-uno antes de laminar — especialmente los pivotes.** Esta pieza es print-in-place: las cuatro abrazaderas se imprimen ya unidas al collar central mediante cilindros de pivote finos, con pequeñas esferas de retención (lock-detent) que mantienen cada abrazadera abierta (para imprimir) o plegada (para transporte). Tamaños inusuales de boom o spreader pueden desplazar la geometría lo suficiente como para fusionar los pivotes sólidos (la abrazadera no pivota) o abrirlos demasiado (la retención no engancha). Renderiza siempre el modelo con **F6** en OpenSCAD, haz zoom en uno de los pivotes y confirma:
>
> - El cilindro del pivote tiene un anillo claro de holgura a su alrededor dentro del agujero — sin paredes fusionadas.
> - Las esferas de la retención son visibles como elementos distintos, no fusionadas con el material circundante.
> - El cuerpo de la abrazadera mantiene una separación continua con las placas del marco del pivote.
>
> Si algo parece fusionado o de espesor cero, los valores a ajustar son `print_gap` y `pivot_clearance` (en la sección *Hidden* cerca del inicio de [src/all_in_one.scad](../src/all_in_one.scad)).

**Opción A — GUI de OpenSCAD**

1. Instala OpenSCAD (descarga una versión **nightly 2026.x** reciente desde <https://openscad.org/downloads.html> — la versión estable 2021.01 no incluye el backend manifold que se usa aquí).
2. Abre [src/all_in_one.scad](../src/all_in_one.scad). El panel Customizer de la derecha solo expone los cuatro parámetros de boom/spreader anteriores (el resto de los parámetros del modelo están ocultos a propósito).
3. Edita los valores, pulsa **F5** para una vista previa rápida y luego **F6** (el icono del reloj) para renderizar la geometría completa.
4. Inspecciona (especialmente los pivotes — ver aviso arriba) y luego **Archivo → Exportar → Exportar como STL…**.
5. Repite con [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) para `driven_element=true` y `driven_element=false`.

**Opción B — CLI / Makefile**

El repositorio incluye un [Makefile](../Makefile) que envuelve la CLI de OpenSCAD. Requiere `openscad` en tu `PATH` (o pasar `OPENSCAD=/ruta/a/openscad`).

La forma más simple: edita los valores por defecto de `boom_…` / `spreaders_dia` al principio de [src/all_in_one.scad](../src/all_in_one.scad), luego:

```bash
make            # construye build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl
make renders    # también genera vistas previas PNG de 800×800
```

O llama a OpenSCAD directamente con sobrecargas `-D`, dejando los archivos fuente intactos:

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

Ejecuta `make help` para ver todos los targets disponibles (`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`).

---

*73 de EA4IPW — OpenQuad v1.0*
