# OpenQuad — Antena Cubical Quad modular e dobrável

**Por EA4IPW — Caso prático: construção de um quad de 5 elementos para 435 MHz**

---

## 1. O que é este design

Este projeto documenta um **design de antena Cubical Quad modular e dobrável** pensado para ser fabricado com peças impressas em 3D, varetas de fibra de vidro como spreaders e um boom de alumínio.

As características principais do design são:

- **Modular:** cada elemento (refletor, driven, diretores) é montado sobre um *bloco* independente que desliza e se fixa ao boom. Podes construir a antena com 2, 3, 5, 6, 7 .. elementos usando o mesmo hardware.
- **Dobrável:** os spreaders pivotam sobre o bloco, de modo que a antena pode ser recolhida para transporte ou armazenamento e desdobrada em segundos para operar.
- **Escalável por banda:** o design paramétrico em OpenSCAD ([src/all_in_one.scad](../src/all_in_one.scad)) permite ajustar o diâmetro do boom e dos spreaders e regenerar a peça para outros tamanhos de boom e spreader.

- **Ajustável:** os loops são fixados com abraçadeiras impressas ([stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)) que permitem cortar e voltar a fixar o cabo durante o tuning.

Este guia documenta o processo prático de construção e ajuste passo a passo. Os fundamentos teóricos (origem das fórmulas 1005/1030/975, efeito do velocity factor, desempenho esperado, referências bibliográficas) são tratados num documento separado:

> 📘 **[TEORIA.pt.md](TEORIA.pt.md) — Fundamentos teóricos e referências**

As fórmulas são válidas para qualquer frequência; como exemplo prático detalhado documenta-se uma construção real para a banda de 70 cm (435 MHz) com cabo de instalação PVC de 0.5 mm².

---

## 2. Dimensões para a construção de referência (435 MHz, Vf = 0.91)

As seguintes dimensões correspondem à construção real documentada neste guia, usando cabo PVC de 0.5 mm² com velocity factor medido de 0.91.

> Se construíres para outra frequência ou com outro tipo de cabo, consulta as fórmulas gerais e o procedimento para medir o Vf em [TEORIA.pt.md § 2–3](TEORIA.pt.md).

**Elementos:**

| Elemento | Perímetro (mm) | Perímetro (in) | Lado (mm) | Lado (in) | Spreader (mm) | Spreader (in) |
|---|---|---|---|---|---|---|
| Refletor | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| Driven | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| Diretor 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| Diretor 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| Diretor 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| Diretor 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| Diretor 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**Espaçamentos:**

| Troço | Distância (mm) | Distância (in) |
|---|---|---|
| Refletor → Driven | 137.9 | 5.43 |
| Driven → Diretor 1 | 103.4 | 4.07 |
| Diretor → Diretor | 103.4 | 4.07 |

**Comprimento total do boom conforme configuração:**

| Configuração | Boom (mm) | Boom (in) |
|---|---|---|
| 2 elem (R + DE) | 137.9 | 5.43 |
| 3 elem (R + DE + D1) | 241.4 | 9.50 |
| 4 elem (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 elem (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 elem (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 elem (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. Materiais

### 3.1. Cabo para os elementos

Qualquer cabo de cobre com ou sem isolamento serve. Para cabo isolado (PVC, polietileno), lembra-te de aplicar a correção de Vf (ver [TEORIA.pt.md § 2](TEORIA.pt.md)).

Em VHF/UHF, secções de 0.5 mm² a 1.5 mm² funcionam bem. O cabo mais fino é mais fácil de manusear; o mais grosso mantém melhor a forma, a minha recomendação é o de 0.5mm². A 435 MHz o skin depth é de apenas 3 µm, pelo que toda a corrente flui pela superfície do condutor. A diferença de perdas entre 0.5 mm² e 1.5 mm² é de ~0.025 dB — completamente desprezável. A largura de banda reduz-se ~8% com o cabo mais fino, o que também não é significativo na prática.

Em HF, onde os elementos são muito maiores, usa-se tipicamente cabo de cobre de 1–2 mm de diâmetro (nu ou isolado), ou mesmo cabo multifilar para reduzir peso.

Para potências até 50W não há qualquer problema com cabo fino. O limite prático é imposto pelas soldaduras e pelo isolamento (o PVC amolece a ~70°C), não pelo condutor.

### 3.2. Boom

O alumínio é ideal: leve, rígido e fácil de trabalhar. Um tubo quadrado ou circular de secção apropriada ao tamanho da antena é suficiente. Para UHF um tubo de PVC também serve perfeitamente.

**Um boom metálico afeta a antena?** Num quad, ao contrário de um Yagi, o boom é perpendicular ao plano dos loops e os elementos estão separados do boom pelos spreaders. O efeito é mínimo ou inexistente. **Não é necessária correção de boom** como num Yagi.

Um boom de madeira funciona igualmente mas é mais pesado e absorve humidade. O seu efeito dielétrico (εr ≈ 2) poderia deslocar a frequência ~0.1% — irrelevante na prática.

Se o boom for circular em vez de quadrado, não há diferença elétrica. A única consideração é mecânica: garantir que os hubs dos spreaders fiquem fixados na mesma orientação angular (ver secção 3.5).

### 3.3. Spreaders

Varetas de fibra de vidro, faia, ou PVC. Devem ser de material não condutor. O diâmetro apropriado depende da banda: em VHF/UHF, varetas de 4–8 mm são suficientes

### 3.4. Parafusaria e retenção

Cada elemento necessita de uma pequena quantidade de parafusaria padrão para fechar as abraçadeiras sobre os spreaders e manter o bloco print-in-place dobrado durante o transporte:

- **Parafusos Allen (hex socket cap) M3 × 12 mm — 4 por elemento.** Um por cada abraçadeira de spreader; apertam as duas metades da abraçadeira em torno da vareta. O comprimento de 12 mm está dimensionado para um **spreader de 8 mm** — spreaders mais finos (4–6 mm) usam um corpo de abraçadeira mais fino e podem precisar de um parafuso mais curto (M3×8 ou M3×10); verifica a profundidade do canal do parafuso na peça renderizada antes de comprar. O alojamento da porca e a folga do parafuso estão dimensionados para M3 em [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad).
- **Porcas M3 — 4 por elemento.** Assentam no bolso hexagonal de cada abraçadeira antes de apertar o parafuso.
- **Elástico de borracha — 1 por elemento.** Envolve o bloco `all_in_one` dobrado para manter as quatro abraçadeiras fechadas contra o colar do boom durante transporte e armazenamento.

### 3.5. Alinhamento dos elementos

Todos os loops quadrados devem estar **alinhados na mesma orientação rotacional** sobre o boom. Se um elemento for rodado em relação aos demais, o acoplamento entre elementos degrada-se porque os segmentos de corrente deixam de ser paralelos.

- **Alguns graus de erro:** efeito desprezável.
- **45° de rotação:** acoplamento seriamente degradado, perda de ganho e F/B.

Com boom quadrado o alinhamento é natural. Com boom circular, garante a orientação com um parafuso sem cabeça, um pino passante, ou uma gota de cola.

---

## 4. Ajuste passo a passo

### 4.1. Ferramentas necessárias

- Analisador de antenas (NanoVNA, LiteVNA, ou similar)
- Cabo coaxial curto com conector para o VNA
- Ferro de soldar e estanho
- Régua milimetrada ou paquímetro digital
- Alicates de corte fino

### 4.2. Choke balun (opcional mas recomendado para a medição)

Um choke balun no feedpoint melhora a fiabilidade das medições ao impedir que a malha do coaxial irradie e altere os resultados. Sem choke, tocar ou mover o cabo do VNA pode alterar as leituras.

**Para HF:** um choke bobinado clássico funciona bem: 6–10 voltas de coaxial sobre um toroide de ferrite (FT-140-43 ou similar).

**Para VHF/UHF:** NÃO uses um choke bobinado — em frequências altas a capacitância entre espiras cria ressonâncias parasitas. Em vez disso, usa **ferrites snap-on (clamp-on)** de mix 43 enfiadas em linha sobre o coaxial mesmo atrás do feedpoint. 5–6 unidades fornecem impedância suficiente.

Referência de ferrites snap-on válidas para VHF/UHF: Fair-Rite 0443164251 (cabo ≤6.6 mm), Fair-Rite 0443167251 (cabo ≤9.85 mm), ou Fair-Rite 0443164151 (cabo ≤12.7 mm), todas em material mix 43. Disponíveis na Mouser, DigiKey, ou distribuidores similares.

As snap-on abrem-se e fecham-se com os dedos, não requerem ferramentas, e são completamente reutilizáveis.

**Nota:** Muitas antenas comerciais do tipo quad não têm choke e funcionam perfeitamente. O quad tem uma geometria intrinsecamente bem equilibrada no feedpoint. O choke serve principalmente para obter medições fiáveis durante o ajuste, não é um requisito para uso normal.

### 4.3. Procedimento de ajuste

#### Passo 1 — Determinar o Vf do teu cabo

Se usares cobre nu, salta para o passo 2 (Vf = 1.0).

Se usares cabo com isolamento:

1. Calcula o perímetro do driven element com Vf = 1.0: `perímetro = 1005 / f(MHz) × 304.8 mm`.
2. Constrói o loop e o refletor e mede a sua ressonância com o VNA.
3. Calcula o teu Vf real: `Vf = f_medida / f_objetivo`.
4. Recalcula todas as dimensões com este Vf.

> Ver [TEORIA.pt.md § 2.4](TEORIA.pt.md) para mais detalhes.

**Não tentes ajustar o driven isolado à frequência objetivo e depois acrescentar o refletor esperando que se mantenha.** O acoplamento desloca sempre a frequência. Há duas abordagens válidas:

#### Passo 2 — Acrescentar os diretores, um a um

1. Monta o Diretor 1 a 0.15λ em frente ao driven. O seu perímetro deve ser ~3% menor que o driven.
2. Mede. A frequência pode subir ou descer ligeiramente dependendo do acoplamento.
3. Se o SWR for aceitável, avança para o diretor seguinte.
4. Repete para cada diretor adicional. Cada um deve ser 3% mais curto que o anterior.

**Problema comum: SWR sobe bruscamente ao acrescentar um diretor.** A causa mais frequente é que o diretor está demasiado longo (demasiado perto da frequência de ressonância do driven). Quando um parasita ressoa à mesma frequência que o driven, absorve energia máxima e o SWR dispara. **Solução:** verifica que o diretor é realmente 3% mais curto que o driven e corta-o se necessário.

#### Passo 3 — Ajuste final

Depois de montar todos os elementos, pode ser necessário um retoque fino do driven element para centrar a frequência. Os diretores raramente precisam de retoque se foram cortados corretamente.

**Dica:** No VNA, usa a vista de SWR vs frequência (não apenas a carta de Smith) para ver claramente onde está o mínimo e a largura de banda.

---

## 5. Problemas frequentes e soluções

### A frequência de ressonância está muito abaixo do esperado

**Causa provável:** não foi tido em conta o Vf do cabo isolado. Um cabo PVC pode ter Vf = 0.91–0.95, o que alonga eletricamente os elementos.

**Solução:** mede o Vf empiricamente (passo 1 do procedimento) e recalcula as dimensões.

### O SWR sobe muito ao acrescentar um diretor

**Causa provável:** o diretor está cortado com o mesmo comprimento que o driven, ou muito perto. Quando um parasita ressoa na mesma frequência que o driven, absorve energia máxima.

**Solução:** verifica que o diretor é 3% mais curto que o driven. Corta-o se necessário.

### A frequência baixa ao acrescentar o refletor

**Causa:** acoplamento mútuo indutivo entre refletor e driven. É comportamento normal, não um erro.

**Solução:** pré-compensar o driven (ajustá-lo sozinho a uma frequência mais alta do que a objetivo) ou ajustar com driven + refletor montados em conjunto.

### A frequência desloca-se ao manipular a antena

**Causa:** em VHF/UHF, 1–2 mm de deslocamento numa esquina alteram a frequência facilmente.

**Solução:** fixa bem os cabos nos spreaders antes das medições definitivas, ajustando a tensão para que o cabo se mantenha esticado.

### As medições do VNA mudam ao tocar no cabo

**Causa:** corrente de modo comum na malha exterior do coaxial. O cabo do VNA comporta-se como parte da antena.

**Solução:** adiciona ferrites snap-on (mix 43) no feedpoint. Se não tiveres ferrites, pelo menos mantém a mesma disposição do cabo entre medições.

### O SWR é bom mas o F/B é fraco

**Causa provável:** o refletor não está bem ajustado. O SWR e o F/B otimizam-se com comprimentos diferentes do refletor.

**Solução:** experimenta alongar ou encurtar o refletor 1–2%. Em alternativa, usa um stub em curto-circuito no refletor para o ajustar sem alterar o seu comprimento físico.

---

## 6. Resultado da construção de referência

A antena documentada como exemplo neste guia (5 elementos, 435 MHz, cabo PVC de 0.5 mm², Vf medido de 0.91) atingiu os seguintes resultados medidos:

- **SWR:** 1.1 no ponto de mínimo (432 MHz), <1.6 a 435 MHz
- **F/B medido:** ~6 unidades S de diferença (S9 frontal, S3 traseiro) ≈ 30–36 dB
- **Impedância em ressonância:** próxima de 50 Ω
- **Largura de banda útil (SWR < 2):** ~430–440 MHz

> Para comparar com os valores teóricos esperados noutras configurações (2–7 elementos) e a equivalência com Yagi, ver [TEORIA.pt.md § 4](TEORIA.pt.md).

---

## 7. Peças pré-construídas

O CI publica um conjunto pré-renderizado de STL para os tamanhos de boom e spreader mais comuns a cada release. Cada combinação é distribuída como um único zip contendo as três peças imprimíveis (`all_in_one`, `driven_element`, `regular_wire_clamp`) mais as pré-visualizações PNG. Descarrega a combinação que corresponde ao teu hardware e começa a imprimir — sem OpenSCAD.

Se nenhuma das combinações pré-renderizadas corresponder ao teu hardware, consulta o [§ 7.4](#74-construir-um-tamanho-personalizado) abaixo para renderizar a tua própria.

### 7.1. Bloco tudo-em-um (colar do boom + 4 braçadeiras)

Forma do boom × dimensão do boom nas linhas, diâmetro do spreader nas colunas.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Redondo 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Redondo 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Redondo 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrado 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrado 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **Quadrado 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. Braçadeiras do spreader

Estas duas peças dependem apenas do diâmetro do spreader (a forma e a dimensão do boom não importam), portanto só existem três variantes de cada uma.

| Spreader | Elemento excitado | Braçadeira do fio (parasita) |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. Downloads

Cada link é um zip com os três STL mais as pré-visualizações PNG para essa combinação. Aponta sempre para a **última release**.

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **Redondo 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **Redondo 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **Redondo 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **Quadrado 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **Quadrado 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **Quadrado 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. Construir um tamanho personalizado

Se nenhuma das combinações pré-renderizadas corresponder ao teu hardware (ou se quiseres experimentar outros diâmetros), podes renderizar as peças tu mesmo. Há três parâmetros que normalmente irás tocar, todos no ficheiro [src/all_in_one.scad](../src/all_in_one.scad):

- `boom_is_round` — `true` para tubo redondo, `false` para quadrado.
- `boom_dia` (redondo) **ou** `boom_side` (quadrado) — dimensão exterior do boom em mm.
- `spreaders_dia` — diâmetro exterior da tua vareta spreader em mm.

O elemento excitado e a braçadeira de fio regular ([src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)) dependem apenas de `spreaders_dia` e de `driven_element` (`true` / `false`).

> ⚠️ **Pré-verifica visualmente o tudo-em-um antes do slicing — especialmente os pivôs.** Esta peça é print-in-place: as quatro braçadeiras são impressas já ligadas ao colar central por cilindros de pivô finos, com pequenas esferas lock-detent que mantêm cada braçadeira aberta (para imprimir) ou dobrada (para transporte). Tamanhos invulgares de boom ou spreader podem deslocar a geometria o suficiente para fundir os pivôs sólidos (a braçadeira não pivota) ou abri-los demasiado (o lock-detent não engancha). Renderiza sempre o modelo com **F6** no OpenSCAD, faz zoom num dos pivôs e confirma:
>
> - O cilindro do pivô tem um anel claro de folga à sua volta dentro do furo — sem paredes fundidas.
> - As esferas do lock-detent são visíveis como elementos distintos, não fundidas com o material circundante.
> - O corpo da braçadeira mantém uma separação contínua com as placas da estrutura do pivô.
>
> Se algo parecer fundido ou com espessura zero, os valores a ajustar são `print_gap` e `pivot_clearance` (na secção *Hidden* perto do início de [src/all_in_one.scad](../src/all_in_one.scad)).

**Opção A — GUI do OpenSCAD**

1. Instala o OpenSCAD (descarrega uma versão **nightly 2026.x** recente em <https://openscad.org/downloads.html> — a versão estável 2021.01 não tem o backend manifold usado aqui).
2. Abre [src/all_in_one.scad](../src/all_in_one.scad). O painel Customizer à direita expõe apenas os quatro parâmetros de boom/spreader acima (o resto dos parâmetros do modelo está intencionalmente oculto).
3. Edita os valores, pressiona **F5** para uma pré-visualização rápida e depois **F6** (o ícone do relógio) para renderizar a geometria completa.
4. Inspeciona (especialmente os pivôs — ver aviso acima) e depois **Ficheiro → Exportar → Exportar como STL…**.
5. Repete com [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) para `driven_element=true` e `driven_element=false`.

**Opção B — CLI / Makefile**

O repositório inclui um [Makefile](../Makefile) que encapsula a CLI do OpenSCAD. Requer `openscad` no teu `PATH` (ou passar `OPENSCAD=/caminho/para/openscad`).

A forma mais simples: edita os valores predefinidos de `boom_…` / `spreaders_dia` no topo de [src/all_in_one.scad](../src/all_in_one.scad), depois:

```bash
make            # constrói build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl
make renders    # também gera pré-visualizações PNG de 800×800
```

Ou chama o OpenSCAD diretamente com sobreposições `-D`, deixando os ficheiros fonte intactos:

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

Executa `make help` para veres todos os targets disponíveis (`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`).

---

*73 de EA4IPW — OpenQuad v1.0*
