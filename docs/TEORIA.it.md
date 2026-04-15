# Fondamenti teorici dell'antenna Cubical Quad

**Di EA4IPW — Complemento teorico alla guida OpenQuad**

Questo documento raccoglie i fondamenti teorici, le formule e i riferimenti che sostengono il design di un'antenna Cubical Quad. Il caso pratico di costruzione è documentato in [README.it.md](README.it.md).

La cubical quad è un'antenna a elementi parassiti (come una Yagi) dove ogni elemento è un loop quadrato di una lunghezza d'onda completa. Rispetto a una Yagi equivalente, offre ~2 dB in più di guadagno per lo stesso numero di elementi, un miglior rapporto front-to-back, e un'impedenza di feedpoint più vicina a 50 Ω.

Le formule e le procedure di questa guida sono valide per qualsiasi frequenza.

---

## 1. Le formule e da dove vengono

### 1.1. La costante base: dalla velocità della luce al valore magico "1005"

Questa costante appare pubblicata nella bibliografia delle antenne dagli anni 1960 (vedi riferimenti alla fine), ma vediamo da dove viene.

La lunghezza d'onda nel vuoto è:

    λ = c / f

Dove c = 299,792,458 m/s. Espressa in piedi:

    λ (piedi) = 983.57 / f(MHz)

Un loop quadrato di una lunghezza d'onda non risuona esattamente a λ teorica. Gli effetti della corrente che circola negli angoli e la curvatura del campo fanno sì che debba essere leggermente più lungo (~2.2%) per risuonare. Questo dà la costante empirica classica:

    983.57 × 1.021 ≈ 1005

**Nota:** A differenza di un dipolo, che si *accorcia* del ~5% rispetto al teorico (da 492 a 468) a causa dell'"end effect" alle sue estremità aperte, un loop chiuso ha bisogno di essere *più lungo* perché non ha estremità aperte.

### 1.2. Formule per ogni elemento

Le formule danno il **perimetro totale del loop**:

| Elemento | Perimetro (piedi) | Perimetro (mm) | Origine |
|---|---|---|---|
| Driven element | 1005 / f | 1005 / f × 304.8 | Risonanza a f |
| Riflettore | 1030 / f | 1030 / f × 304.8 | ~2.5% più lungo → induttivo |
| Direttore 1 | 975 / f | 975 / f × 304.8 | ~3% più corto → capacitivo |
| Direttore N+1 | Direttore_N × 0.97 | Direttore_N × 0.97 | Serie del 3% |

Dove f è in MHz.

**Dimensioni derivate:**

- Lunghezza di un lato del quadrato: `lato = perimetro / 4`
- Lunghezza del braccio spreader (dal centro all'angolo): `spreader = lato × √2 / 2 = lato × 0.7071`

### 1.3. Da dove escono le costanti 1030 e 975

Non sono arbitrarie. Partono dalla costante base del driven element (1005):

| Costante | Calcolo | Funzione |
|---|---|---|
| 1005 | 984 × 1.021 | Loop risonante alla frequenza di lavoro |
| 1030 | 1005 × 1.025 | Riflettore: 2.5% più lungo → risuona al di sotto → induttivo |
| 975 | 1005 × 0.970 | Direttore: 3% più corto → risuona al di sopra → capacitivo |

Il riflettore induttivo e il direttore capacitivo producono la fase necessaria perché l'antenna irradi in una sola direzione (dal riflettore verso i direttori).

### 1.4. Spaziature tra gli elementi

| Tratto | Distanza |
|---|---|
| Riflettore → Driven | 0.20λ |
| Driven → Direttore 1 | 0.15λ |
| Direttore → Direttore | 0.15λ |

Dove λ è la lunghezza d'onda nello spazio libero:

    λ (mm) = 300,000 / f(MHz)
    λ (pollici) = 11,811 / f(MHz)
    λ (piedi) = 984 / f(MHz)

**Importante:** Le spaziature dipendono dalla lunghezza d'onda nello spazio libero, NON dal velocity factor del cavo. Il boom misura sempre lo stesso indipendentemente dal tipo di cavo che usi per gli elementi.

---

## 2. Il Velocity Factor (Vf): perché conta e come calcolarlo

### 2.1. Cos'è il Vf

Le formule della sezione precedente assumono **rame nudo nello spazio libero** (Vf = 1.0). Se usi cavo con isolamento (PVC, polietilene, teflon), l'onda viaggia più lentamente attraverso il conduttore, il che riduce la lunghezza fisica necessaria per risuonare alla stessa frequenza.

L'isolamento aumenta la capacità distribuita lungo il conduttore, rallentando la propagazione. Questo significa che hai bisogno di **meno cavo** per completare una lunghezza d'onda elettrica.

### 2.2. Valori tipici di Vf

| Tipo di cavo | Vf approssimativo |
|---|---|
| Rame nudo | 1.00 |
| Isolante PTFE/Teflon | 0.97–0.98 |
| Isolante polietilene | 0.95–0.96 |
| Isolante PVC sottile | 0.91–0.95 |
| Isolante PVC spesso (cavo da installazione 450/750V) | 0.90–0.93 |

**Attenzione:** Questi sono valori orientativi. Il Vf reale dipende dallo spessore dell'isolante rispetto al diametro del conduttore. Un cavo da installazione domestica (H07V-K, UNE-EN 50525) da 1.5 mm² ha una guaina PVC proporzionalmente più spessa rispetto allo stesso cavo da 6 mm², e quindi un Vf più basso.

### 2.3. Formule corrette con Vf

Moltiplica ogni costante per il Vf:

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (pollici)
    Driven = (1005 × Vf) / f(MHz)              (piedi)

Lo stesso per le costanti 1030 (riflettore) e 975 (direttore 1).

### 2.4. Come misurare il Vf del tuo cavo

Il metodo più diretto è empirico:

1. Calcola il perimetro del driven element usando le formule per rame nudo (Vf = 1.0).
2. Costruisci il loop.
3. Costruisci anche il riflettore.
4. Misura la sua risonanza utilizzando il NanoVNA.
5. Calcola il tuo Vf reale: **Vf = f_risonanza_misurata / f_obiettivo**

Per esempio: se hai calcolato per 435 MHz ma il loop risuona a 400 MHz, il tuo Vf è 400/435 = 0.92.

Nella mia esperienza, calcolare il Vf solo con l'elemento direttore non funzionerà,
è necessario avere il riflettore, la cui installazione sposta la frequenza verso il basso.

Questo funziona perché un Vf minore di 1 significa che l'insieme è elettricamente "troppo lungo" e risuona più in basso del previsto.

---

## 3. Calcolo delle dimensioni per qualsiasi frequenza

Per una frequenza centrale f (in MHz) e un velocity factor Vf:

**Perimetri (mm):**

    Riflettore  = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Direttore 1 = (975 × Vf) / f × 304.8
    Direttore 2 = Direttore 1 × 0.97
    Direttore 3 = Direttore 2 × 0.97
    ...e così via

**Perimetri (pollici):**

    Riflettore  = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Direttore 1 = (975 × Vf) / f × 12
    Direttore 2 = Direttore 1 × 0.97
    ...

**Spaziature (mm):** (indipendenti dal Vf)

    Riflettore → Driven:  300,000 / f × 0.20
    Driven → Direttore:   300,000 / f × 0.15
    Direttore → Direttore: 300,000 / f × 0.15

**Spaziature (pollici):**

    Riflettore → Driven:  11,811 / f × 0.20
    Driven → Direttore:   11,811 / f × 0.15
    Direttore → Direttore: 11,811 / f × 0.15

---

## 4. Prestazioni teoriche attese

### 4.1. Guadagno e F/B per configurazione

| Elementi | Guadagno appross. (dBd) | Guadagno appross. (dBi) | Rapporto F/B |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

Valori in dBd (rispetto al dipolo) e dBi (rispetto all'isotropica). dBi = dBd + 2.15.

A partire da 4–5 elementi i rendimenti sono decrescenti (~0.5 dB per direttore aggiuntivo). Per la maggior parte delle applicazioni, 3–5 elementi è il punto ottimale tra guadagno, complessità e facilità di regolazione.

### 4.2. Equivalenza con Yagi

Come riferimento generale, una quad di N elementi rende approssimativamente come una Yagi di N+2 elementi con boom di lunghezza simile.

### 4.3. Verifica pratica del F/B

Sintonizza un ripetitore o una baliza conosciuta, punta l'antenna verso la sorgente, annota la lettura dell'S-meter, ruota di 180° e confronta. Ogni unità S di differenza equivale a ~6 dB secondo la norma IARU Region 1 R.1 (1981), anche se la calibrazione degli S-meter negli apparati commerciali può variare significativamente, specialmente al di sotto di S3 dove molti ricevitori forniscono solo 2–3 dB per unità S.

---

## 5. Riferimenti

### Libri e documenti tecnici

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" — Volumi 1, 2 e 3.** Il riferimento definitivo sul design delle quad. Disponibile su: https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** Il libro classico che ha reso popolare la quad tra i radioamatori.
- **ARRL Antenna Book — Chapter 12: Quad Arrays.** Fonte delle formule 1005/1030/975.

### Articoli online

- **Articoli di Cebik sulle quad** (indicizzati da G0UIH): https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Spiegazione dell'effetto del Vf sui loop con cavo PVC: https://q82.uk/1005overf
- **W8JI — Cubical Quad** — Analisi tecnica rigorosa: https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Guide di costruzione

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Calcolatori online

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm (non ha correzione di Vf)
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Norme citate

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definizione dell'S-meter. 1 unità S = 6 dB, S9 in VHF = −93 dBm (5 µV in 50 Ω).

---

*73 da EA4IPW — OpenQuad v1.0*
