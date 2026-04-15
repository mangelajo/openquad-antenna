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

- **Artigos de Cebik sobre quads** (indexados por G0UIH): https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — Explicação do efeito do Vf em loops com cabo PVC: https://q82.uk/1005overf
- **W8JI — Cubical Quad** — Análise técnica rigorosa: https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas — Wire Quads:** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna:** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### Guias de construção

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX):** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX):** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna":** https://www.computer7.com/building-a-quad-antenna/

### Calculadoras online

- **YT1VP Cubical Quad Calculator:** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm (não tem correção de Vf)
- **CSGNetwork Cubical Quad Calculator:** http://www.csgnetwork.com/antennae5q2calc.html

### Normas citadas

- **IARU Region 1 Technical Recommendation R.1 (1981):** Definição do S-meter. 1 unidade S = 6 dB, S9 em VHF = −93 dBm (5 µV em 50 Ω).

---

*73 de EA4IPW — OpenQuad v1.0*
