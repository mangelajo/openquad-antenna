# OpenQuad — Antenna Cubical Quad modulare e pieghevole

**Di EA4IPW — Caso pratico: costruzione di una quad di 5 elementi per 435 MHz**

---

## 1. Cos'è questo progetto

Questo progetto documenta un **design di antenna Cubical Quad modulare e pieghevole** pensato per essere realizzato con parti stampate in 3D, aste di fibra di vetro come spreader e un boom di alluminio.

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

> Se costruisci per un'altra frequenza o con un altro tipo di cavo, consulta le formule generali e la procedura per misurare il Vf in [TEORIA.it.md § 2–3](TEORIA.it.md).

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

### 3.1. Cavo per gli elementi

Qualsiasi cavo di rame con o senza isolamento va bene. Per cavo isolato (PVC, polietilene), ricorda di applicare la correzione del Vf (vedi [TEORIA.it.md § 2](TEORIA.it.md)).

In VHF/UHF, sezioni da 0.5 mm² a 1.5 mm² funzionano bene. Il cavo più fine è più maneggevole; quello più grosso mantiene meglio la forma, la mia raccomandazione è quello da 0.5mm². A 435 MHz lo skin depth è di soli 3 µm, quindi tutta la corrente scorre sulla superficie del conduttore. La differenza di perdite tra 0.5 mm² e 1.5 mm² è di ~0.025 dB — completamente trascurabile. La larghezza di banda si riduce di ~8% con il cavo più fine, il che non è nemmeno significativo nella pratica.

In HF, dove gli elementi sono molto più grandi, si usa tipicamente cavo di rame da 1–2 mm di diametro (nudo o isolato), o addirittura cavo multifilare per ridurre il peso.

Per potenze fino a 50W non c'è alcun problema con cavo sottile. Il limite pratico è dato dalle saldature e dall'isolamento (il PVC si ammorbidisce a ~70°C), non dal conduttore.

### 3.2. Boom

L'alluminio è ideale: leggero, rigido e facile da lavorare. Un tubo quadrato o circolare di sezione adeguata alle dimensioni dell'antenna è sufficiente. Per UHF anche un tubo di PVC va perfettamente bene.

**Un boom metallico influisce sull'antenna?** In una quad, a differenza di una Yagi, il boom è perpendicolare al piano dei loop e gli elementi sono distanziati dal boom dagli spreader. L'effetto è minimo o inesistente. **Non è necessaria alcuna correzione del boom** come in una Yagi.

Un boom di legno funziona ugualmente ma è più pesante e assorbe umidità. Il suo effetto dielettrico (εr ≈ 2) potrebbe spostare la frequenza di ~0.1% — irrilevante nella pratica.

Se il boom è circolare invece che quadrato, non c'è differenza elettrica. L'unica considerazione è meccanica: assicurarsi che gli hub degli spreader rimangano fissati nella stessa orientazione angolare (vedi sezione 3.4).

### 3.3. Spreader

Aste di fibra di vetro, faggio, o PVC. Devono essere di materiale non conduttore. Il diametro appropriato dipende dalla banda: in VHF/UHF, aste da 4–8 mm sono sufficienti.

### 3.4. Allineamento degli elementi

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

#### Passo 1 — Determinare il Vf del tuo cavo

Se usi rame nudo, salta al passo 2 (Vf = 1.0).

Se usi cavo con isolamento:

1. Calcola il perimetro del driven element con Vf = 1.0: `perimetro = 1005 / f(MHz) × 304.8 mm`.
2. Costruisci il loop e il riflettore e misura la sua risonanza con il VNA.
3. Calcola il tuo Vf reale: `Vf = f_misurata / f_obiettivo`.
4. Ricalcola tutte le dimensioni con questo Vf.

> Vedi [TEORIA.it.md § 2.4](TEORIA.it.md) per maggiori dettagli.

**Non tentare di regolare il driven isolato alla frequenza obiettivo e poi aggiungere il riflettore sperando che si mantenga.** L'accoppiamento sposta sempre la frequenza. Ci sono due approcci validi:

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

*73 da EA4IPW — OpenQuad v1.0*
