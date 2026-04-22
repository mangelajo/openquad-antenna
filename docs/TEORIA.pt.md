# Fundamentos teóricos da antena Cubical Quad

**Por EA4IPW — Complemento teórico ao guia OpenQuad**

Este documento reúne os fundamentos teóricos, fórmulas e referências que sustentam o design de uma antena Cubical Quad. O caso prático de construção está documentado em [README.pt.md](README.pt.md).

A cubical quad é uma antena de elementos parasitas (como um Yagi) em que cada elemento é um loop quadrado de um comprimento de onda completo. Face a um Yagi equivalente, oferece ~2 dB mais de ganho para o mesmo número de elementos, melhor rácio front-to-back, e uma impedância de feedpoint mais próxima de 50 Ω.

As fórmulas e procedimentos deste guia são válidos para qualquer frequência.

---

## 1. As fórmulas e de onde vêm

### 1.1. A constante base: da velocidade da luz ao valor mágico "1005"

Esta constante aparece publicada na bibliografia de antenas desde os anos 1960 (ver referências no final), mas vejamos de onde vem.

O comprimento de onda no vácuo é:

    λ = c / f

Onde c = 299,792,458 m/s. Expresso em pés:

    λ (pés) = 983.57 / f(MHz)

Um loop quadrado de um comprimento de onda não ressoa exatamente em λ teórica. Os efeitos da corrente a circular pelas esquinas e a curvatura do campo fazem com que precise de ser ligeiramente mais longo (~2.2%) para ressoar. Isto dá a constante empírica clássica:

    983.57 × 1.021 ≈ 1005

**Nota:** Ao contrário de um dipolo, que se *encurta* ~5% em relação ao teórico (de 492 para 468) pelo "end effect" nas suas extremidades abertas, um loop fechado precisa de ser *mais longo* porque não tem extremidades abertas.

### 1.2. Fórmulas para cada elemento

As fórmulas dão o **perímetro total do loop**:

| Elemento | Perímetro (pés) | Perímetro (mm) | Origem |
|---|---|---|---|
| Driven element | 1005 / f | 1005 / f × 304.8 | Ressonância em f |
| Refletor | 1030 / f | 1030 / f × 304.8 | ~2.5% mais longo → indutivo |
| Diretor 1 | 975 / f | 975 / f × 304.8 | ~3% mais curto → capacitivo |
| Diretor N+1 | Diretor_N × 0.97 | Diretor_N × 0.97 | Série dos 3% |

Onde f está em MHz.

**Dimensões derivadas:**

- Comprimento de um lado do quadrado: `lado = perímetro / 4`
- Comprimento do braço spreader (do centro até à esquina): `spreader = lado × √2 / 2 = lado × 0.7071`

### 1.3. De onde saem as constantes 1030 e 975

Não são arbitrárias. Partem da constante base do driven element (1005):

| Constante | Cálculo | Função |
|---|---|---|
| 1005 | 984 × 1.021 | Loop ressonante na frequência de trabalho |
| 1030 | 1005 × 1.025 | Refletor: 2.5% mais longo → ressoa abaixo → indutivo |
| 975 | 1005 × 0.970 | Diretor: 3% mais curto → ressoa acima → capacitivo |

O refletor indutivo e o diretor capacitivo produzem a fase necessária para que a antena irradie numa só direção (do refletor para os diretores).

### 1.4. Espaçamentos entre elementos

| Troço | Distância |
|---|---|
| Refletor → Driven | 0.20λ |
| Driven → Diretor 1 | 0.15λ |
| Diretor → Diretor | 0.15λ |

Onde λ é o comprimento de onda em espaço livre:

    λ (mm) = 300,000 / f(MHz)
    λ (polegadas) = 11,811 / f(MHz)
    λ (pés) = 984 / f(MHz)

**Importante:** Os espaçamentos dependem do comprimento de onda no espaço livre, NÃO do velocity factor do cabo. O boom mede sempre o mesmo independentemente do tipo de cabo que uses para os elementos.

### 1.5. Escolha do espaçamento refletor→driven: compromisso ganho vs F/B

A bibliografia mostra alguma dispersão quanto ao espaçamento ótimo entre o refletor e o
driven. As duas referências mais comuns são:

| Fonte | R→Driven | Diretores | Objetivo de desenho |
|---|---|---|---|
| ARRL Antenna Book / Orr & Cowan | **0.200 λ** | 0.150 λ | Ganho máximo |
| W6SAI / calculadoras clássicas (ex. YT1VP) | **0.186 λ** | 0.153 λ | Compromisso ganho/F/B |

O valor 0.186 λ das calculadoras clássicas vem da constante histórica `730 ft·MHz`
expressa em unidades imperiais:

    spacing_pés = 730 / f(MHz) × 0.25  →  spacing/λ = 730×0.25 / 983.57 ≈ 0.1855 λ

#### Resultado da simulação NEC2 (5 elementos, 435 MHz)

Foi feito um varrimento de k_refletor com `nec2c` para ambas as configurações de espaçamento.
O modelo replica a geometria real da MOQUAD: **loops rodados 45° (orientação em diamante)**,
com feed no vértice inferior (vértice S) para polarização horizontal. Os resultados mostram
que a diferença de ganho entre os dois espaçamentos é **desprezável** (< 0.05 dBi), enquanto
o F/B máximo atingível varia:

| Configuração | k_refl ótimo | Ganho de pico | F/B máximo |
|---|---|---|---|
| OpenQuad 0.200 λ | 1.110 | 10.10 dBi (7.95 dBd) | **37.8 dB** |
| YT1VP  0.186 λ | 1.108 | 10.12 dBi (7.97 dBd) | **42.3 dB** |

Com o k_refl nominal (1.047) ambas as configurações dão praticamente o mesmo resultado:
~10.1 dBi e ~7.2 dB de F/B. A diferença de F/B só surge quando o refletor é ajustado em
direção ao ponto de cancelamento máximo (refletor mais longo → maior desfasamento indutivo).

**Conclusão prática:** para uma construção típica em que o comprimento do refletor é
ajustado por um stub ou cortando o loop, o espaçamento mais curto das calculadoras clássicas
oferece **~4.5 dB mais de F/B** no ponto ótimo com o mesmo ganho. Se o objetivo principal é
o F/B (rejeição de interferências, EME, concursos de direção fixa), usa 0.186 λ; se o
objetivo é o ganho máximo com F/B suficiente, usa 0.200 λ.

O script NEC2 que gera esta análise encontra-se em `tools/nec2_spacing_analysis.py`
(ver §6 deste documento).

> **Referências:** ver §5 — Cebik W4RNL *Cubical Quad Notes* vol. 1, cap. 3
> (https://antenna2.github.io/cebik/content/bookant.html); ARRL Antenna Book cap. 12;
> Tom Rauch W8JI — "Cubical Quad Antenna" (https://www.w8ji.com/quad_cubical_quad.htm);
> W6SAI *All About Cubical Quad Antennas*, pp. 44–52.

### 1.6. Afinação fina do refletor: o compromisso ganho ↔ F/B

Os valores nominais da calculadora (k_refletor = 1.047, ou seja 2.5% mais longo que o driven)
são um ponto de partida razoável, mas **não o ótimo**. Em qualquer array parasítico existe
um compromisso fundamental: o refletor pode ser sintonizado para **ganho máximo em frente**
ou para **cancelamento traseiro máximo (F/B)**, mas os dois ótimos não coincidem.

#### Resultado do varrimento NEC2 (5 elementos, 435 MHz, geometria em diamante)

| k_refl | Perímetro refletor | Ganho em frente | Ganho atrás | F/B |
|---|---|---|---|---|
| 1.047 (nominal) | 722 mm | 9.94 dBi | +2.54 dBi | 7.4 dB |
| 1.068 (max gain) | 736 mm | **10.28 dBi** | −1.92 dBi | 12.2 dB |
| 1.090 (compromisso) | 751 mm | 10.16 dBi | −9.74 dBi | 19.9 dB |
| 1.110 (max F/B) | 765 mm | 9.91 dBi | **−28.2 dBi** | **38.1 dB** |

Observação chave: **o ganho em frente quase não muda** (intervalo de 0.37 dB em todo o
varrimento), enquanto o ganho atrás cai **30 dB** ao passar do refletor nominal para o
otimizado para F/B. O F/B não se ganha aumentando a radiação frontal, mas sim cancelando a
traseira.

#### Desmistificação: "dBi de ganho" é o pico do diagrama

`dBi` mede o ganho na direção de **radiação máxima** (pico do diagrama), não uma média nem
o ganho numa direção fixa. Numa quad bem orientada esse pico coincide com a direção dos
diretores (phi=0°), mas se o array estiver mal ajustado o pico pode desviar-se para os lados.
Nesta análise reportamos sempre o ganho a phi=0° (em frente), que coincide com o pico em
todas as configurações do sweep.

#### A ressonância do feedpoint desloca-se — mas para CIMA

Um equívoco comum: "se alongo o refletor, baixo a frequência de ressonância". Num array
parasítico a realidade é o contrário:

| k_refl | Z a 435 MHz | f_res do feedpoint (X=0) | SWR @ 50Ω @ 435 MHz |
|---|---|---|---|
| 1.047 | 45 − j39 Ω | 444 MHz (+9) | 2.24 |
| 1.068 | 60 − j33 Ω | 445 MHz (+10) | 1.86 |
| 1.090 | 75 − j37 Ω | 446 MHz (+11) | 2.04 |
| 1.110 | 84 − j45 Ω | 447 MHz (+12) | 2.33 |

O driven não muda — por si só ressoa sempre perto de 435 MHz. O que muda é o **acoplamento
mútuo** entre refletor e driven. A matriz de impedâncias é:

    Z_in = Z_11 − Z_12² / Z_22

onde Z_11 é a auto-impedância do driven, Z_22 a do refletor e Z_12 a mútua. Ao alongar o
refletor, Z_22 fica mais indutivo, o que modifica o termo Z_12²/Z_22 de tal forma que a
reactância que se soma ao driven é **capacitiva**. Isto desloca a frequência onde X=0 para
cima, não para baixo.

Na prática, a 435 MHz o feedpoint fica sempre com reactância capacitiva moderada
(X ≈ −35 a −45 Ω), manejável com um gamma match, L-match, ou hairpin.

#### Procedimento de ajuste iterativo

Para aproveitar o compromisso e levar a antena ao ponto ótimo:

1. **Constrói** refletor, driven e diretores com as dimensões nominais da calculadora
   (k_refl = 1.047), adicionando 15–20 mm a mais ao perímetro do refletor como margem de
   ajuste.

2. **Mede** o F/B apontando para um beacon conhecido, ou mede a impedância e a ressonância
   com um VNA.

3. **Alonga o refletor em passos de ~5 mm** (adicionando fio ou com um stub ajustável),
   anotando o F/B após cada passo. O F/B vai subir progressivamente.

4. **Para** quando o F/B começar a baixar ou ficar instável — passaste o ponto ótimo.
   Recua meio passo.

5. **Reajusta o matching** (gamma/L/hairpin) depois de fixar o comprimento do refletor,
   porque a reactância do feedpoint terá mudado em relação ao ponto inicial.

> **Nota operativa:** o refletor ajusta-se SEMPRE alongando-o a partir do valor nominal. Por
> isso é mais sensato construir com margem extra e cortar se passares do ponto, do que
> ficares curto e teres de acrescentar fio.

#### Compromissos típicos recomendados

- **Aplicações de longo alcance / DX**: k_refl ≈ 1.068 (736 mm @ 435 MHz) — maximiza o
  ganho, F/B razoável de ~12 dB.
- **Receção de beacon com interferências traseiras / rejeição de intermodulação**: k_refl ≈
  1.090 (751 mm) — perdes 0.1 dB de ganho, ganhas 7.7 dB de F/B.
- **EME, satélite, concursos com direção fixa**: k_refl ≈ 1.108 (764 mm) — F/B máximo de
  38 dB, ganho quase idêntico ao nominal.

Estes valores são para 5 elementos. Para 2 ou 3 elementos as diferenças são mais marcadas
e o compromisso é mais duro — ver Cebik, *Cubical Quad Notes* Vol. 1 cap. 3 para a análise
completa.

---

## 2. O Velocity Factor (Vf): porque é que importa e como calculá-lo

### 2.1. O que é o Vf

As fórmulas da secção anterior assumem **cobre nu em espaço livre** (Vf = 1.0). Se usares cabo com isolamento (PVC, polietileno, teflão), a onda viaja mais lentamente pelo condutor, o que reduz o comprimento físico necessário para ressoar na mesma frequência.

O isolamento aumenta a capacitância distribuída ao longo do condutor, abrandando a propagação. Isto significa que precisas de **menos cabo** para completar um comprimento de onda elétrico.

### 2.2. Valores típicos de Vf

| Tipo de cabo | Vf aproximado |
|---|---|
| Cobre nu | 1.00 |
| Isolamento PTFE/Teflão | 0.97–0.98 |
| Isolamento polietileno | 0.95–0.96 |
| Isolamento PVC fino | 0.91–0.95 |
| Isolamento PVC grosso (cabo de instalação 450/750V) | 0.90–0.93 |

**Atenção:** Estes são valores orientativos. O Vf real depende da espessura do isolamento em relação ao diâmetro do condutor. Um cabo de instalação doméstica (H07V-K, UNE-EN 50525) de 1.5 mm² tem uma bainha PVC proporcionalmente mais grossa que o mesmo cabo em 6 mm², e portanto um Vf mais baixo.

### 2.3. Fórmulas corrigidas com Vf

Multiplica cada constante pelo Vf:

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (polegadas)
    Driven = (1005 × Vf) / f(MHz)              (pés)

O mesmo para as constantes 1030 (refletor) e 975 (diretor 1).

### 2.4. Como medir o Vf do teu cabo

O método mais direto é empírico:

1. Calcula o perímetro do driven element usando as fórmulas para cobre nu (Vf = 1.0).
2. Constrói o loop.
3. Constrói também o refletor.
4. Mede a sua ressonância utilizando o NanoVNA
5. Calcula o teu Vf real: **Vf = f_ressonancia_medida / f_objetivo**

Por exemplo: se calculaste para 435 MHz mas o loop ressoa a 400 MHz, o teu Vf é 400/435 = 0.92.

Na minha experiência, calcular o Vf apenas com o elemento diretor não vai funcionar,
precisas de ter o refletor, cuja instalação desvia a frequência para baixo.

Isto funciona porque um Vf menor que 1 significa que o conjunto é eletricamente "demasiado longo" e ressoa mais abaixo do que seria esperado.

---

## 3. Cálculo de dimensões para qualquer frequência

Para uma frequência central f (em MHz) e um velocity factor Vf:

**Perímetros (mm):**

    Refletor    = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Diretor 1   = (975 × Vf) / f × 304.8
    Diretor 2   = Diretor 1 × 0.97
    Diretor 3   = Diretor 2 × 0.97
    ...e assim sucessivamente

**Perímetros (polegadas):**

    Refletor    = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Diretor 1   = (975 × Vf) / f × 12
    Diretor 2   = Diretor 1 × 0.97
    ...

**Espaçamentos (mm):** (independentes do Vf)

    Refletor → Driven:    300,000 / f × 0.20
    Driven → Diretor:     300,000 / f × 0.15
    Diretor → Diretor:    300,000 / f × 0.15

**Espaçamentos (polegadas):**

    Refletor → Driven:    11,811 / f × 0.20
    Driven → Diretor:     11,811 / f × 0.15
    Diretor → Diretor:    11,811 / f × 0.15

---

## 4. Desempenho teórico esperado

### 4.1. Ganho e F/B por configuração

| Elementos | Ganho aprox. (dBd) | Ganho aprox. (dBi) | Rácio F/B |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

Valores em dBd (sobre dipolo) e dBi (sobre isotrópica). dBi = dBd + 2.15.

A partir de 4–5 elementos os rendimentos são decrescentes (~0.5 dB por diretor adicional). Para a maioria das aplicações, 3–5 elementos é o ponto ótimo entre ganho, complexidade e facilidade de ajuste.

### 4.2. Equivalência com Yagi

Como referência geral, um quad de N elementos rende aproximadamente como um Yagi de N+2 elementos com boom de comprimento semelhante.

### 4.3. Verificação prática do F/B

Sintoniza um repetidor ou baliza conhecido, aponta a antena para a fonte, anota a leitura do S-meter, roda 180° e compara. Cada unidade S de diferença equivale a ~6 dB segundo a norma IARU Region 1 R.1 (1981), embora a calibração dos S-meters em equipamentos comerciais possa variar significativamente, especialmente abaixo de S3 onde muitos recetores só dão 2–3 dB por unidade S.

---

## 5. Referências

### Livros e documentos técnicos

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" — Volumes 1, 2 e 3.** A referência definitiva sobre design de quads. Disponível em: https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** O livro clássico que popularizou o quad entre radioamadores.
- **ARRL Antenna Book — Chapter 12: Quad Arrays.** Fonte das fórmulas 1005/1030/975.

### Artigos online

- **L. B. Cebik (W4RNL) — "Cubical Quad Notes" (3 volumes).** A referência definitiva sobre
  design de quads. Todos os volumes disponíveis em PDF em:
  https://antenna2.github.io/cebik/content/bookant.html
- **L. B. Cebik (W4RNL) — "2-Element Quads as a Function of Wire Diameter"** — Metodologia
  de otimização NEC que fixa o driven em ressonância e ajusta o refletor para F/B máximo.
  Documenta o compromisso ganho↔F/B com dados NEC-4.
  https://antenna2.github.io/cebik/content/quad/q2l1.html
- **L. B. Cebik (W4RNL) — "The Quad vs. Yagi Question"** — Análise comparativa com
  varrimentos paramétricos. Confirma que quads de 2 elementos não superam ~20 dB de F/B
  sem diretores. https://antenna2.github.io/cebik/content/quad/qyc.html
- **Tom Rauch (W8JI) — "Cubical Quad Antenna"** — Análise técnica rigorosa com dados NEC.
  Citação direta sobre o compromisso ganho/F/B: *"if we optimize F/B ratio we can expect
  lower gain from any parasitic array"*. https://www.w8ji.com/quad_cubical_quad.htm
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Efeito
  do Vf em loops com cabo PVC. https://q82.uk/1005overf
- **Electronics Notes — "Yagi Feed Impedance & Matching"** — Explica o efeito do acoplamento
  mútuo sobre a impedância do feedpoint: *"altering the element spacing has a greater effect
  on the impedance than it does the gain"*. https://www.electronics-notes.com/articles/antennas-propagation/yagi-uda-antenna-aerial/feed-impedance-matching.php
- **Wikipedia — "Yagi–Uda antenna" (secção Mutual impedance)** — Formulação matemática do
  acoplamento Z_ij entre driven e parasitas. Chave para entender porque alongar o refletor
  DESLOCA a frequência de ressonância do feedpoint (para cima, não para baixo).
  https://en.wikipedia.org/wiki/Yagi%E2%80%93Uda_antenna
- **KD2BD (John Magliacane) — "Thoughts on Perfect Impedance Matching of a Yagi"** —
  Matching de feedpoints com reactância não nula. Útil depois de otimizar o refletor para
  F/B, quando Z_in deixa de ser 50 Ω. https://www.qsl.net/kd2bd/impedance_matching.html
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Guias de construção

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Calculadoras online

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm
  Usa espaçamento R→DE ≈ 0.186 λ (constante `730 ft·MHz`) e entre diretores ≈ 0.153 λ
  (constante `600 ft·MHz`). Ver §1.5 para a comparação com o valor 0.200 λ usado por OpenQuad.
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Livros recomendados (papel)

- **James L. Lawson (W2PV) — "Yagi Antenna Design"** (ARRL, 1986, ISBN 0-87259-041-0).
  Referência clássica sobre otimização computacional de arrays parasíticos. A metodologia
  de varrimento paramétrico (variar k_refl mantendo o driven fixo) usada por OpenQuad vem
  diretamente desta obra.
- **William I. Orr (W6SAI) — "All About Cubical Quad Antennas"** (Radio Publications, 1959
  e edições posteriores). Origem histórica das constantes empíricas `730/f` e `600/f` para
  espaçamentos; clássico absoluto do mundo quad.
- **David B. Leeson — "Physical Design of Yagi Antennas"** (ARRL, 1992, ISBN 0-87259-381-9).
  Complementa Lawson com o design mecânico e métodos de matching. Cebik recomenda-o como
  *companion book* para entender arrays parasíticos em profundidade.
- **ARRL Antenna Book** (edição atual, ARRL). O capítulo dedicado às quads agrupa as
  fórmulas clássicas 1005/1030/975 e a gama de espaçamentos 0.14–0.25 λ.

### Normas citadas

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definição do S-meter. 1 unidade S = 6 dB, S9 em VHF = −93 dBm (5 µV em 50 Ω).

---

## 6. Análise NEC2 do espaçamento entre elementos

### 6.1. Ferramenta necessária

As análises deste documento foram feitas com **nec2c**, implementação livre de NEC-2
(Numerical Electromagnetics Code). Instalação em Debian/Ubuntu:

```bash
sudo apt-get install nec2c
```

Em macOS com Homebrew:

```bash
brew install nec2c
```

### 6.2. Script de análise: `tools/nec2_spacing_analysis.py`

O script gera os ficheiros de entrada NEC2, executa as simulações e produz gráficos
comparativos. Suporta três modos de análise:

```bash
# MODO 1 — Varrimento de k_refl para as duas configurações de espaçamento (análise §1.5)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5

# MODO 2 — Análise do ajuste do refletor: ganho + F/B + Z_in (dados §1.6)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --reflector-tuning

# MODO 3 — Varrimento de impedância vs frequência (Z_in, SWR, ressonância do feedpoint)
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --impedance-sweep

# Apenas uma configuração personalizada
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 \
        --spacing-r-de 0.200 --spacing-dir 0.150

# Guardar resultados em CSV
python3 tools/nec2_spacing_analysis.py --freq 435 --elements 5 --csv resultados.csv
```

O modo `--reflector-tuning` reproduz a tabela de §1.6 (k=1.047, 1.068, 1.090, 1.110 com
ganho, F/B, R, X e SWR). Usa a carta `PT -1` de NEC2 para ler a corrente do segmento de
feed e calcular Z_in = R + jX diretamente.

O modo `--impedance-sweep` faz um varrimento de ±15 MHz em torno da frequência alvo,
mostrando como a ressonância elétrica do feedpoint (onde X=0) se desloca para cima à
medida que se alonga o refletor — o fenómeno documentado em §1.6.

### 6.3. Como funciona o modelo NEC2 para uma quad

A MOQUAD monta os loops **rodados 45° (orientação em diamante)**, com os braços spreader
virados a N/S/E/W e o fio a unir as suas pontas. O modelo NEC2 reflete esta geometria real.

Cada loop é modelado como **4 condutores retilíneos formando um diamante** no plano YZ.
O boom corre ao longo do eixo X. Os quatro vértices estão nas posições cardinais:

```
              N (0, +r)
             / \
            /   \
W (-r, 0) ●       ● E (+r, 0)
            \   /
             \ /
              S (0, -r)  ← feedpoint do driven
         +z
         |
    ─────●───── +y    r = lado × √2 / 2  (raio = distância centro→vértice)
```

O feedpoint fica no **vértice S (inferior)**, que é o ponto de alimentação natural para
**polarização horizontal**. A razão:

- A partir de S, os condutores W→S e S→E chegam/saem a ±45°.
- As componentes horizontais (±Y) **somam-se** em S → corrente líquida horizontal.
- As componentes verticais (±Z) **cancelam-se** em S → sem contaminação V-pol.

O feed é implementado no **último segmento do condutor W→S** (o mais próximo do vértice S).
Quantos mais segmentos por lado, mais perto do vértice fica o gap e melhor o XPD. Com SEG=19
o gap fica a ~4 mm do vértice e o XPD ≥ 27 dB. Com SEG=99 o XPD ultrapassa 38 dB.

Condutores em ordem horária (vistos de frente, +X):

```
W1:  S → E   (condutor inferior-direito)   ← direção (+y, +z)/√2
W2:  E → N   (condutor superior-direito)   ← direção (-y, +z)/√2
W3:  N → W   (condutor superior-esquerdo)  ← direção (-y, -z)/√2
W4:  W → S   (condutor inferior-esquerdo)  ← direção (+y, -z)/√2  ← FEED aqui
```

Formato da carta GW de NEC2:

```
GW  tag  nseg  x1  y1  z1  x2  y2  z2  raio
```

Exemplo para o driven em x=0.1378 m, lado s=0.1760 m (r=0.1244 m), raio=0.0005 m, SEG=19:

```
GW  5  19  0.1378   0.0000  -0.1244  0.1378  +0.1244   0.0000  0.0005   ← W1: S→E
GW  6  19  0.1378  +0.1244   0.0000  0.1378   0.0000  +0.1244  0.0005   ← W2: E→N
GW  7  19  0.1378   0.0000  +0.1244  0.1378  -0.1244   0.0000  0.0005   ← W3: N→W
GW  8  19  0.1378  -0.1244   0.0000  0.1378   0.0000  -0.1244  0.0005   ← W4: W→S (FEED)
```

A excitação é aplicada ao **último segmento** do condutor W4 (W→S), o mais próximo do
vértice S:

```
EX  0  8  19  0  1  0     ← tag=8 (W4 do driven), seg=19 (último), tensão unitária
```

O diagrama de radiação horizontal obtém-se com:

```
RP  0  1  361  1000  90  0  1  1       ← theta=90°, phi=0..360°, passo 1°
```

### 6.4. Interpretação das colunas do ficheiro .out

A secção `RADIATION PATTERNS` do ficheiro de saída tem este formato:

```
  THETA    PHI    VERTC    HORIZ    TOTAL    AXIAL   TILT  SENSE  ...
 DEGREES  DEGREES   DB       DB       DB     RATIO  DEGREES
```

- **VERTC** (col 3): ganho de polarização vertical (dBi)
- **HORIZ** (col 4): ganho de polarização horizontal (dBi)
- **TOTAL** (col 5): ganho total (dBi) — **a coluna principal**

Para a MOQUAD em diamante com feed em S, HORIZ ≈ TOTAL e VERTC fica ≥ 27 dB abaixo
(XPD ≥ 27 dB com SEG=19). Ler TOTAL para as análises de ganho e F/B é correto.

```python
# Leitura básica do diagrama em Python
gains = {}
with open("simulacao.out") as f:
    for line in f:
        parts = line.split()
        try:
            theta, phi = float(parts[0]), float(parts[1])
            if abs(theta - 90.0) < 0.1:
                gains[round(phi)] = float(parts[4])   # coluna TOTAL
        except (ValueError, IndexError):
            pass

gain_forward = gains.get(0, gains.get(360))   # phi=0° = direção dos diretores (+X)
gain_back    = gains.get(180)                  # phi=180° = direção do refletor
fb_ratio     = gain_forward - gain_back        # F/B em dB
```

### 6.5. Validação do modelo

Para validar que o modelo em diamante está correto antes de fazer o sweep:

1. Simula apenas o driven element (sem parasitas). A impedância de entrada deve ser
   **~100 Ω resistiva** (loop quadrado de onda inteira → 100–125 Ω; a orientação 45° não
   altera este valor).
2. Verifica a polarização: VERTC deve ficar ≥ 25 dB abaixo de HORIZ em phi=0°. Se a
   diferença for menor, o feedpoint está demasiado longe do vértice → aumentar SEG.
3. Adiciona o refletor. O ganho deve subir ~5 dBi relativamente ao dipolo isotrópico e o
   F/B deve ser ≥ 10 dB.
4. Verifica que o pico de ganho aponta para os diretores (phi=0° no modelo, para +X).
5. **Nota sobre o ganho:** a orientação em diamante dá ~0.2 dBi menos que a orientação
   quadrada com side-feed, pela diferente projeção da corrente no plano de radiação. É um
   efeito físico real, não um artefacto do modelo.

---

*73 de EA4IPW — OpenQuad v1.0*
