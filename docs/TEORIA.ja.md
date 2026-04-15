# Cubical Quad アンテナの理論的背景

**著者：EA4IPW — OpenQuad ガイドの理論的補足**

本ドキュメントでは、Cubical Quad アンテナの設計を支える理論的背景、公式、および参考文献をまとめます。製作の実例については [README.ja.md](README.ja.md) を参照してください。

Cubical Quad は、各エレメントが 1 波長分の正方形ループで構成される、寄生素子型アンテナ（Yagi と同様）です。同じエレメント数の Yagi に対して約 2 dB 高い利得、良好な front-to-back 比、そして 50 Ω により近い給電点インピーダンスを提供します。

本ガイドの公式と手順はどの周波数でも有効です。

---

## 1. 公式とその由来

### 1.1. 基本定数：光速から「1005」という魔法の値まで

この定数は 1960 年代以降のアンテナ関連文献に掲載されていますが（末尾の参考文献を参照）、その由来を見てみましょう。

真空中の波長は以下で与えられます。

    λ = c / f

ここで c = 299,792,458 m/s です。フィート単位では次のようになります。

    λ (pies) = 983.57 / f(MHz)

1 波長の正方形ループは、厳密に理論上の λ では共振しません。コーナーを流れる電流の影響と電界の曲がりのため、共振させるには少し長く（約 2.2%）する必要があります。これが古典的な経験定数を与えます。

    983.57 × 1.021 ≈ 1005

**注：** ダイポールは開放端での「end effect」により理論値から約 5% *短く*なる（492 から 468 へ）のに対し、閉じたループは開放端を持たないため、逆に*より長く*する必要があります。

### 1.2. 各エレメントの公式

公式は**ループの全周長**を与えます。

| エレメント | 周長 (pies) | 周長 (mm) | 由来 |
|---|---|---|---|
| ドリブンエレメント | 1005 / f | 1005 / f × 304.8 | f で共振 |
| リフレクター | 1030 / f | 1030 / f × 304.8 | 約 2.5% 長い → 誘導性 |
| ディレクター 1 | 975 / f | 975 / f × 304.8 | 約 3% 短い → 容量性 |
| ディレクター N+1 | Director_N × 0.97 | Director_N × 0.97 | 3% 系列 |

ここで f は MHz 単位です。

**派生寸法：**

- 正方形の 1 辺の長さ：`辺 = 周長 / 4`
- スプレッダー腕の長さ（中心からコーナーまで）：`spreader = 辺 × √2 / 2 = 辺 × 0.7071`

### 1.3. 定数 1030 と 975 の由来

これらは恣意的なものではありません。ドリブンエレメントの基本定数（1005）を出発点とします。

| 定数 | 計算 | 機能 |
|---|---|---|
| 1005 | 984 × 1.021 | 動作周波数で共振するループ |
| 1030 | 1005 × 1.025 | リフレクター：2.5% 長い → 下方で共振 → 誘導性 |
| 975 | 1005 × 0.970 | ディレクター：3% 短い → 上方で共振 → 容量性 |

誘導性リフレクターと容量性ディレクターは、アンテナを単一方向（リフレクターからディレクター方向）に放射させるために必要な位相を生み出します。

### 1.4. エレメント間の間隔

| 区間 | 距離 |
|---|---|
| リフレクター → ドリブン | 0.20λ |
| ドリブン → ディレクター 1 | 0.15λ |
| ディレクター → ディレクター | 0.15λ |

ここで λ は自由空間での波長です。

    λ (mm) = 300,000 / f(MHz)
    λ (pulgadas) = 11,811 / f(MHz)
    λ (pies) = 984 / f(MHz)

**重要：** 間隔は自由空間での波長に依存し、ケーブルの Velocity Factor には依存しません。エレメントにどのような種類のケーブルを使っても、ブームの長さは常に同じです。

---

## 2. Velocity Factor (Vf)：なぜ重要で、どう計算するか

### 2.1. Vf とは何か

前節の公式は**自由空間中の裸銅線**（Vf = 1.0）を仮定しています。絶縁付きケーブル（PVC、ポリエチレン、テフロン）を使うと、波が導体内をより遅く伝わるため、同じ周波数で共振するのに必要な物理的な長さは短くなります。

絶縁は導体に沿った分布容量を増やし、伝搬を遅くします。つまり、1 波長の電気的な長さを完成させるのに**必要なケーブルの長さは短く**なります。

### 2.2. Vf の典型的な値

| ケーブルの種類 | おおよその Vf |
|---|---|
| 裸銅線 | 1.00 |
| PTFE/テフロン絶縁 | 0.97–0.98 |
| ポリエチレン絶縁 | 0.95–0.96 |
| 薄い PVC 絶縁 | 0.91–0.95 |
| 厚い PVC 絶縁（450/750V 設置ケーブル） | 0.90–0.93 |

**注意：** これらは目安の値です。実際の Vf は、導体直径に対する絶縁の厚さに依存します。家庭用の配線ケーブル（H07V-K、UNE-EN 50525）の 1.5 mm² は、同じ 6 mm² ケーブルよりも比例的に厚い PVC 被覆を持っており、そのため Vf はより低くなります。

### 2.3. Vf による補正後の公式

各定数に Vf を掛けます。

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (pulgadas)
    Driven = (1005 × Vf) / f(MHz)              (pies)

リフレクター用 1030 とディレクター 1 用 975 についても同様です。

### 2.4. ケーブルの Vf を測定する方法

最も直接的な方法は実験的なものです。

1. 裸銅線用の公式（Vf = 1.0）でドリブンエレメントの周長を計算します。
2. ループを製作します。
3. リフレクターも製作します。
4. NanoVNA を使って共振周波数を測定します。
5. 実際の Vf を計算します：**Vf = f_共振_実測 / f_目標**

たとえば、435 MHz を狙って計算したのにループが 400 MHz で共振した場合、Vf = 400/435 = 0.92 となります。

私の経験上、ディレクターエレメント単独で Vf を計算することはうまくいきません。リフレクターが必要で、その設置が周波数を下方にシフトさせます。

これが機能するのは、Vf が 1 より小さいということは、全体が電気的に「長すぎる」ことを意味し、予想よりも下方で共振するためです。

---

## 3. 任意の周波数における寸法の計算

中心周波数 f（MHz）と Velocity Factor Vf について：

**周長 (mm)：**

    Reflector   = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Director 1  = (975 × Vf) / f × 304.8
    Director 2  = Director 1 × 0.97
    Director 3  = Director 2 × 0.97
    ...以下同様

**周長 (pulgadas)：**

    Reflector   = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Director 1  = (975 × Vf) / f × 12
    Director 2  = Director 1 × 0.97
    ...

**間隔 (mm)：**（Vf に依存しません）

    Reflector → Driven:   300,000 / f × 0.20
    Driven → Director:    300,000 / f × 0.15
    Director → Director:  300,000 / f × 0.15

**間隔 (pulgadas)：**

    Reflector → Driven:   11,811 / f × 0.20
    Driven → Director:    11,811 / f × 0.15
    Director → Director:  11,811 / f × 0.15

---

## 4. 期待される理論性能

### 4.1. 構成別の利得と F/B 比

| エレメント数 | 概算利得 (dBd) | 概算利得 (dBi) | F/B 比 |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

値は dBd（ダイポール基準）および dBi（等方性基準）です。dBi = dBd + 2.15。

4〜5 エレメントを超えると収穫逓減となり、ディレクター 1 本追加あたり約 0.5 dB しか増えません。ほとんどの用途では、利得、複雑さ、調整の容易さの間で 3〜5 エレメントが最適点です。

### 4.2. Yagi との等価性

一般的な目安として、N エレメントのクワッドは同程度のブーム長を持つ N+2 エレメントの Yagi とほぼ同等の性能を発揮します。

### 4.3. F/B 比の実地検証

既知のレピーターまたはビーコンに同調し、アンテナを音源に向け、S メーターの読み値を記録してから 180° 回して比較します。IARU Region 1 R.1（1981）の規格によれば、S メーター 1 単位の差は約 6 dB に相当しますが、商用機の S メーター較正はかなりばらつく場合があり、特に S3 以下では多くの受信機で S 単位あたり 2〜3 dB しか差がないことがあります。

---

## 5. 参考文献

### 書籍と技術文書

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" — Volumes 1, 2, 3.** クワッド設計に関する決定版の参考文献。次で入手可能：https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** ハムの間でクワッドを広めた古典的な書籍。
- **ARRL Antenna Book — Chapter 12: Quad Arrays.** 1005/1030/975 公式の出典。

### オンライン記事

- **Cebik のクワッドに関する記事**（G0UIH によるインデックス）：https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** — PVC ケーブルのループにおける Vf 影響の解説：https://q82.uk/1005overf
- **W8JI — Cubical Quad** — 厳密な技術的分析：https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas — Wire Quads：** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes — Cubical Quad Antenna：** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### 製作ガイド

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX)：** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX)：** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna"：** https://www.computer7.com/building-a-quad-antenna/

### オンライン計算機

- **YT1VP Cubical Quad Calculator：** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm （Vf 補正なし）
- **CSGNetwork Cubical Quad Calculator：** http://www.csgnetwork.com/antennae5q2calc.html

### 引用規格

- **IARU Region 1 Technical Recommendation R.1 (1981)：** S メーターの定義。1 S 単位 = 6 dB、VHF での S9 = −93 dBm（50 Ω で 5 µV）。

---

*73 from EA4IPW — OpenQuad v1.0*
