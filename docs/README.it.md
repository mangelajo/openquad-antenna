# OpenQuad — Antenna Cubical Quad modulare e pieghevole

**Di EA4IPW — Caso pratico: costruzione di una quad di 5 elementi per 435 MHz**

---

## 1. Cos'è questo progetto

Questo progetto documenta un **design di antenna Cubical Quad modulare e pieghevole** pensato per essere realizzato con parti stampate in 3D, aste di fibra di vetro o legno come spreader e un boom in PVC, legno o alluminio.

Le caratteristiche principali del progetto sono:

- **Modulare:** ogni elemento (riflettore, driven, direttori) si monta su un *blocco* indipendente che scorre e si fissa al boom. Puoi costruire l'antenna con 2, 3, 5, 6, 7 .. elementi usando lo stesso hardware.
- **Pieghevole:** gli spreader ruotano sul blocco, in modo che l'antenna possa essere richiusa per il trasporto o lo stoccaggio e dispiegata in pochi secondi per operare.
- **Scalabile per banda:** il design parametrico in OpenSCAD ([src/all_in_one.scad](../src/all_in_one.scad)) permette di regolare il diametro del boom e degli spreader e rigenerare il pezzo per altre dimensioni di boom e spreader.

- **Regolabile:** i loop sono fissati con morsetti stampati ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) che permettono di tagliare e fissare nuovamente il cavo durante il tuning.

Questa guida documenta il processo pratico di costruzione e regolazione passo passo. I fondamenti teorici (origine delle formule 1005/1030/975, effetto del velocity factor, prestazioni attese, riferimenti bibliografici) sono trattati in un documento separato:

> 📘 **[TEORIA.it.md](TEORIA.it.md) — Fondamenti teorici e riferimenti**

Le formule sono valide per qualsiasi frequenza; come esempio pratico dettagliato è documentata una costruzione reale per la banda dei 70 cm (435 MHz) con cavo da installazione PVC da 0.5 mm².

---

## 2. Dimensioni per la costruzione di riferimento (435 MHz, Vf = 0.91)

Le seguenti dimensioni corrispondono alla costruzione reale documentata in questa guida, utilizzando cavo PVC da 0.5 mm² con velocity factor misurato di 0.91.

> Se costruisci per un'altra frequenza o con un altro tipo di cavo, consulta le formule generali e la procedura per misurare il Vf in [TEORIA.it.md § 2–3](TEORIA.it.md), oppure usa il [🧮 calcolatore online](https://openquad-calc.ea4ipw.es) per ottenere direttamente le dimensioni.

**Elementi:**

| Elemento | Perimetro (mm) | Perimetro (in) | Lato (mm) | Lato (in) | Spreader (mm) | Spreader (in) |
|---|---|---|---|---|---|---|
| Riflettore | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| Driven | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| Direttore 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| Direttore 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| Direttore 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| Direttore 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| Direttore 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**Spaziature:**

| Tratto | Distanza (mm) | Distanza (in) |
|---|---|---|
| Riflettore → Driven | 137.9 | 5.43 |
| Driven → Direttore 1 | 103.4 | 4.07 |
| Direttore → Direttore | 103.4 | 4.07 |

**Lunghezza totale del boom a seconda della configurazione:**

| Configurazione | Boom (mm) | Boom (in) |
|---|---|---|
| 2 elem (R + DE) | 137.9 | 5.43 |
| 3 elem (R + DE + D1) | 241.4 | 9.50 |
| 4 elem (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 elem (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 elem (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 elem (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. Materiali

Riepilogo di ciò che serve per costruire l'antenna. Le sezioni seguenti dettagliano alternative, dimensionamento e motivazioni.

| Materiale | Specifica consigliata | Quantità | Sottosezione |
|---|---|---|---|
| Cavo di rame (elementi) | PVC 0.5 mm² (VHF/UHF); 1–2 mm Ø nudo o isolato (HF) | Secondo i perimetri (§2) | [3.1](#31-cavo-per-gli-elementi) |
| Boom | Tubo di alluminio, PVC o legno (quadrato o circolare) | 1, lunghezza a seconda della configurazione (§2) | [3.2](#32-boom) |
| Spreader | Asta non conduttrice (fibra di vetro, faggio o PVC), 4–8 mm Ø in VHF/UHF | 4 per elemento | [3.3](#33-spreader) |
| Viti a brugola M3 × 12 mm | Hex socket cap (M3×8/M3×10 per spreader più sottili) | 4 per elemento | [3.4](#34-viteria-e-ritenzione) |
| Dadi M3 | Esagonali standard | 4 per elemento | [3.4](#34-viteria-e-ritenzione) |
| Elastico | Uno qualsiasi che abbracci il blocco ripiegato | 1 per elemento | [3.4](#34-viteria-e-ritenzione) |
| Coassiale + connettore | Secondo il tuo apparato (tipicamente RG-58/RG-316 in UHF) | 1 | — |
| Termorestringente | Vari diametri per isolare saldature del feedpoint e giunzioni | Pochi cm | — |
| Ferriti snap-on mix 43 (opzionale, regolazione) | Fair-Rite 0443164251/0443167251 a seconda del Ø del coassiale | 5–6 | [4.2](#42-choke-balun-opzionale-ma-raccomandato-per-la-misura) |

### 3.1. Cavo per gli elementi

Qualsiasi cavo di rame con o senza isolamento va bene. Per cavo isolato (PVC, polietilene), ricorda di applicare la correzione del Vf (vedi [TEORIA.it.md § 2](TEORIA.it.md)).

In VHF/UHF, sezioni da 0.5 mm² a 1.5 mm² funzionano bene. Il cavo più fine è più maneggevole; quello più grosso mantiene meglio la forma, la mia raccomandazione è quello da 0.5mm². A 435 MHz lo skin depth è di soli 3 µm, quindi tutta la corrente scorre sulla superficie del conduttore. La differenza di perdite tra 0.5 mm² e 1.5 mm² è di ~0.025 dB — completamente trascurabile. La larghezza di banda si riduce di ~8% con il cavo più fine, il che non è nemmeno significativo nella pratica.

In HF, dove gli elementi sono molto più grandi, si usa tipicamente cavo di rame da 1–2 mm di diametro (nudo o isolato), o addirittura cavo multifilare per ridurre il peso.

Per potenze fino a 50W non c'è alcun problema con cavo sottile. Il limite pratico è dato dalle saldature e dall'isolamento (il PVC si ammorbidisce a ~70°C), non dal conduttore.

### 3.2. Boom

L'alluminio è ideale: leggero, rigido e facile da lavorare. Un tubo quadrato o circolare di sezione adeguata alle dimensioni dell'antenna è sufficiente. Per UHF anche un tubo di PVC va perfettamente bene.

**Un boom metallico influisce sull'antenna?** In una quad, a differenza di una Yagi, il boom è perpendicolare al piano dei loop e gli elementi sono distanziati dal boom dagli spreader. L'effetto è minimo o inesistente. **Non è necessaria alcuna correzione del boom** come in una Yagi.

Un boom di legno funziona ugualmente ma è più pesante e assorbe umidità. Il suo effetto dielettrico (εr ≈ 2) potrebbe spostare la frequenza di ~0.1% — irrilevante nella pratica.

Se il boom è circolare invece che quadrato, non c'è differenza elettrica. L'unica considerazione è meccanica: assicurarsi che gli hub degli spreader rimangano fissati nella stessa orientazione angolare (vedi sezione 3.5).

### 3.3. Spreader

Aste di fibra di vetro, faggio, o PVC. Devono essere di materiale non conduttore. Il diametro appropriato dipende dalla banda: in VHF/UHF, aste da 4–8 mm sono sufficienti.

### 3.4. Viteria e ritenzione

Ogni elemento richiede una piccola quantità di viteria standard per chiudere le clamp sugli spreader e tenere il blocco print-in-place ripiegato durante il trasporto:

- **Viti a brugola (hex socket cap) M3 × 12 mm — 4 per elemento.** Una per ogni clamp di spreader; stringono le due metà della clamp attorno all'asta. La lunghezza di 12 mm è dimensionata per uno **spreader da 8 mm** — spreader più sottili (4–6 mm) usano un corpo clamp più fine e possono richiedere una vite più corta (M3×8 o M3×10); verifica la profondità del canale della vite sul pezzo renderizzato prima di acquistare. La sede del dado e la tolleranza della vite sono dimensionate per M3 in [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad).
- **Dadi M3 — 4 per elemento.** Si alloggiano nella tasca esagonale di ogni clamp prima di serrare la vite.
- **Elastico — 1 per elemento.** Avvolge il blocco `all_in_one` ripiegato per tenere le quattro clamp chiuse contro il collare del boom durante trasporto e stoccaggio.

### 3.5. Allineamento degli elementi

Tutti i loop quadrati devono essere **allineati nella stessa orientazione rotazionale** sul boom. Se un elemento viene ruotato rispetto agli altri, l'accoppiamento tra gli elementi degrada perché i segmenti di corrente cessano di essere paralleli.

- **Pochi gradi di errore:** effetto trascurabile.
- **45° di rotazione:** accoppiamento seriamente degradato, perdita di guadagno e F/B.

Con boom quadrato l'allineamento è naturale. Con boom circolare, assicura l'orientazione con un grano (vite senza testa), una spina passante, o una goccia di colla.

---

## 4. Regolazione passo passo

### 4.1. Strumenti necessari

- Analizzatore di antenne (NanoVNA, LiteVNA, o simile)
- Cavo coassiale corto con connettore per il VNA
- Saldatore e stagno
- Righello millimetrato o calibro digitale
- Tronchesine di precisione

### 4.2. Choke balun (opzionale ma raccomandato per la misura)

Un choke balun al feedpoint migliora l'affidabilità delle misure impedendo che la calza del coassiale irradi e alteri i risultati. Senza choke, toccare o muovere il cavo del VNA può cambiare le letture.

**Per HF:** un choke avvolto classico funziona bene: 6–10 spire di coassiale su un toroide di ferrite (FT-140-43 o simile).

**Per VHF/UHF:** NON usare un choke avvolto — alle frequenze alte la capacità tra le spire crea risonanze parassite. Al suo posto, usa **ferriti snap-on (clamp-on)** di mix 43 infilate in linea sul coassiale appena dietro il feedpoint. 5–6 unità forniscono impedenza sufficiente.

Riferimento di ferriti snap-on adatte per VHF/UHF: Fair-Rite 0443164251 (cavo ≤6.6 mm), Fair-Rite 0443167251 (cavo ≤9.85 mm), o Fair-Rite 0443164151 (cavo ≤12.7 mm), tutte in materiale mix 43. Disponibili su Mouser, DigiKey, o distributori simili.

Le snap-on si aprono e chiudono con le dita, non richiedono attrezzi, e sono completamente riutilizzabili.

**Nota:** Molte antenne commerciali di tipo quad non hanno choke e funzionano perfettamente. La quad ha una geometria intrinsecamente ben bilanciata al feedpoint. Il choke serve principalmente per ottenere misure affidabili durante la regolazione, non è un requisito per l'uso normale.

### 4.3. Procedura di regolazione

#### Passo 1 — Costruire e calibrare il Vf

Ogni cavo reale ha Vf < 1. Il rame nudo in aria si aggira tra 0.97 e 0.99; i cavi con isolamento scendono a 0.90–0.97 a seconda del dielettrico. La procedura consigliata è partire da un valore approssimato e calibrare misurando:

1. Calcola le dimensioni di tutti gli elementi con il [🧮 calcolatore online](https://openquad-calc.ea4ipw.es), usando come Vf di partenza il valore tipico del tuo cavo (0.99 rame nudo, ≈0.91 PVC sottile, ≈0.95 polietilene, ≈0.97 teflon; tabella completa in [TEORIA.it.md § 2.2](TEORIA.it.md)). La formula sottostante è `perimetro = k × λ × Vf`, con `λ = 299,792.458 / f(MHz)` mm e `k_driven ≈ 1.022` (vedi [TEORIA.it.md § 1](TEORIA.it.md)).
2. Monta l'antenna completa con quelle dimensioni.
3. Misura la frequenza di risonanza dell'insieme con il VNA.
4. Inserisci la frequenza misurata nel [🧮 calcolatore](https://openquad-calc.ea4ipw.es) per ottenere il Vf reale e le dimensioni corrette.
5. Accorcia ogni loop alla nuova misura — i morsetti per il filo ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) permettono questa regolazione senza rifare la saldatura.

> Vedi [TEORIA.it.md § 2.4](TEORIA.it.md) per maggiori dettagli.

**Non tentare di regolare il driven isolato alla frequenza obiettivo e poi aggiungere il riflettore sperando che si mantenga.** L'accoppiamento sposta sempre la frequenza; per questo misuriamo con l'antenna completa già montata.

#### Passo 2 — Aggiungere i direttori, uno a uno

1. Monta il Direttore 1 a 0.15λ davanti al driven. Il suo perimetro deve essere ~3% più piccolo del driven.
2. Misura. La frequenza può salire o scendere leggermente a seconda dell'accoppiamento.
3. Se l'SWR è accettabile, procedi al direttore successivo.
4. Ripeti per ogni direttore aggiuntivo. Ognuno deve essere un 3% più corto del precedente.

**Problema comune: l'SWR sale bruscamente aggiungendo un direttore.** La causa più frequente è che il direttore è troppo lungo (troppo vicino alla frequenza di risonanza del driven). Quando un parassita risuona alla stessa frequenza del driven, assorbe la massima energia e l'SWR va alle stelle. **Soluzione:** verifica che il direttore sia realmente un 3% più corto del driven e accorcialo se necessario.

#### Passo 3 — Regolazione finale

Dopo aver montato tutti gli elementi, può essere necessario un ritocco fine del driven element per centrare la frequenza. I direttori raramente necessitano di ritocchi se sono stati tagliati correttamente.

**Tip:** Sul VNA, usa la vista di SWR vs frequenza (non solo la carta di Smith) per vedere chiaramente dov'è il minimo e la larghezza di banda.

---

## 5. Problemi frequenti e soluzioni

### La frequenza di risonanza è molto al di sotto del previsto

**Causa probabile:** non è stato tenuto conto del Vf del cavo isolato. Un cavo PVC può avere Vf = 0.91–0.95, il che allunga elettricamente gli elementi.

**Soluzione:** misura il Vf empiricamente (passo 1 della procedura) e ricalcola le dimensioni.

### L'SWR sale molto aggiungendo un direttore

**Causa probabile:** il direttore è tagliato alla stessa lunghezza del driven, o molto vicina. Quando un parassita risuona alla stessa frequenza del driven, assorbe la massima energia.

**Soluzione:** verifica che il direttore sia un 3% più corto del driven. Accorcialo se necessario.

### La frequenza scende aggiungendo il riflettore

**Causa:** accoppiamento mutuo induttivo tra riflettore e driven. È comportamento normale, non un errore.

**Soluzione:** precompensa il driven (regolandolo da solo a una frequenza più alta di quella obiettivo) oppure regola con driven + riflettore montati insieme.

### La frequenza si sposta maneggiando l'antenna

**Causa:** in VHF/UHF, 1–2 mm di spostamento in un angolo cambiano facilmente la frequenza.

**Soluzione:** fissa bene i cavi sugli spreader prima delle misure definitive, regolando la tensione in modo che il cavo rimanga teso.

### Le misure del VNA cambiano toccando il cavo

**Causa:** corrente di modo comune sulla calza esterna del coassiale. Il cavo del VNA si comporta come parte dell'antenna.

**Soluzione:** aggiungi ferriti snap-on (mix 43) al feedpoint. Se non hai ferriti, almeno mantieni la stessa disposizione del cavo tra le misure.

### L'SWR è buono ma il F/B è scarso

**Causa probabile:** il riflettore non è ben regolato. L'SWR e il F/B si ottimizzano a lunghezze diverse del riflettore.

**Soluzione:** prova ad allungare o accorciare il riflettore dell'1–2%. In alternativa, usa uno stub cortocircuitato sul riflettore per regolarlo senza cambiarne la lunghezza fisica.

---

## 6. Risultato della costruzione di riferimento

L'antenna documentata come esempio in questa guida (5 elementi, 435 MHz, cavo PVC da 0.5 mm², Vf misurato di 0.91) ha raggiunto i seguenti risultati misurati:

- **SWR:** 1.1 nel punto di minimo (432 MHz), <1.6 a 435 MHz
- **F/B misurato:** ~6 unità S di differenza (S9 frontale, S3 posteriore) ≈ 30–36 dB
- **Impedenza in risonanza:** prossima a 50 Ω
- **Larghezza di banda utile (SWR < 2):** ~430–440 MHz

> Per confrontare con i valori teorici attesi in altre configurazioni (2–7 elementi) e l'equivalenza con Yagi, vedi [TEORIA.it.md § 4](TEORIA.it.md).

---

## 7. Parti pre-costruite

Il CI pubblica un set pre-renderizzato di STL per le dimensioni di boom e spreader più comuni a ogni release. Ogni combinazione è distribuita come un singolo zip contenente le tre parti stampabili (`all_in_one`, `driven_element`, `regular_wire_clamp`) più le anteprime PNG. Scarica la combinazione che corrisponde al tuo hardware e inizia a stampare — non serve OpenSCAD.

Se nessuna delle combinazioni pre-renderizzate corrisponde al tuo hardware, consulta il [§ 7.4](#74-costruire-una-dimensione-personalizzata) qui sotto per renderizzare la tua.

### 7.1. Blocco tutto-in-uno (collare del boom + 4 morsetti)

Forma del boom × dimensione del boom come righe, diametro dello spreader come colonne.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Tondo 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Tondo 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Tondo 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrato 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrato 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrato 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. Morsetti dello spreader

Queste due parti dipendono solo dal diametro dello spreader (la forma e la dimensione del boom non contano), quindi ci sono solo tre varianti di ciascuna.

| Spreader | Elemento eccitato | Morsetto del filo (parassita) |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. Download

Ogni link è un zip con i tre STL più le anteprime PNG per quella combinazione. Punta sempre all'**ultima release**.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Tondo 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **Tondo 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **Tondo 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **Quadrato 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **Quadrato 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **Quadrato 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. Costruire una dimensione personalizzata

Se nessuna delle combinazioni pre-renderizzate corrisponde al tuo hardware (o vuoi sperimentare con altri diametri), puoi renderizzare le parti da solo. Ci sono tre parametri che normalmente toccherai, tutti nel file [src/all_in_one.scad](../src/all_in_one.scad):

- `boom_is_round` — `true` per tubo tondo, `false` per quadrato.
- `boom_dia` (tondo) **o** `boom_side` (quadrato) — dimensione esterna del boom in mm.
- `spreaders_dia` — diametro esterno della tua bacchetta spreader in mm.

L'elemento eccitato e il morsetto del filo regolare ([src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)) dipendono solo da `spreaders_dia` e da `driven_element` (`true` / `false`).

> ⚠️ **Verifica visivamente il tutto-in-uno prima dello slicing — soprattutto i pivot.** Questa parte è print-in-place: i quattro morsetti vengono stampati già attaccati al collare centrale tramite cilindri di pivot sottili, con piccole sfere lock-detent che tengono ogni morsetto aperto (per la stampa) o piegato (per il trasporto). Dimensioni insolite di boom o spreader possono spostare la geometria abbastanza da fondere i pivot in solido (il morsetto non ruota) o aprirli troppo (il lock-detent non si aggancia). Renderizza sempre il modello con **F6** in OpenSCAD, poi zooma su uno dei pivot e conferma:
>
> - Il cilindro del pivot ha un anello chiaro di gioco intorno dentro al suo foro — nessuna parete fusa.
> - Le sfere del lock-detent sono visibili come elementi distinti, non fuse con il materiale circostante.
> - Il corpo del morsetto mantiene un gap continuo verso le piastre del telaio del pivot.
>
> Se qualcosa sembra fuso o a spessore zero, i valori da regolare sono `print_gap` e `pivot_clearance` (nella sezione *Hidden* vicino all'inizio di [src/all_in_one.scad](../src/all_in_one.scad)).

**Opzione A — GUI di OpenSCAD**

1. Installa OpenSCAD (scarica una versione **nightly 2026.x** recente da <https://openscad.org/downloads.html> — la versione stabile 2021.01 non include il backend manifold usato qui).
2. Apri [src/all_in_one.scad](../src/all_in_one.scad). Il pannello Customizer sulla destra mostra solo i quattro parametri di boom/spreader sopra elencati (il resto dei parametri del modello è intenzionalmente nascosto).
3. Modifica i valori, premi **F5** per un'anteprima veloce, poi **F6** (l'icona dell'orologio) per renderizzare la geometria completa.
4. Ispeziona (soprattutto i pivot — vedi avviso sopra), poi **File → Esporta → Esporta come STL…**.
5. Ripeti con [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) per `driven_element=true` e `driven_element=false`.

**Opzione B — CLI / Makefile**

Il repository include un [Makefile](../Makefile) che racchiude la CLI di OpenSCAD. Richiede `openscad` nel tuo `PATH` (oppure passa `OPENSCAD=/percorso/a/openscad`).

Il modo più semplice: modifica i valori predefiniti di `boom_…` / `spreaders_dia` all'inizio di [src/all_in_one.scad](../src/all_in_one.scad), poi:

```bash
make            # costruisce build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl
make renders    # genera anche anteprime PNG 800×800
```

Oppure chiama OpenSCAD direttamente con override `-D`, lasciando i file sorgente intatti:

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

Esegui `make help` per vedere tutti i target disponibili (`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`).

---

*73 da EA4IPW — OpenQuad v1.0*
