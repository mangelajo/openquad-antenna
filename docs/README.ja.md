# OpenQuad — モジュラー式・折り畳み式 Cubical Quad アンテナ

**著者：EA4IPW — ケーススタディ：435 MHz 用 5 エレメントクワッドの製作**

<p align="center">
  <img src="../web/diagram.jpeg" width="420" alt="設計図"/>
</p>

---

## 1. この設計の概要

本プロジェクトは、**モジュラー式・折り畳み式の Cubical Quad アンテナ**の設計を文書化したものです。3D プリント部品、スプレッダーとしてのグラスファイバーまたは木製ロッド、そして PVC・木材・アルミ製ブームで製作することを想定しています。

主な設計上の特徴は次のとおりです。

- **モジュラー式：** 各エレメント（リフレクター、ドリブン、ディレクター）は独立した*ブロック*に取り付けられ、ブームにスライドして固定します。同じハードウェアで 2、3、5、6、7 … エレメントのアンテナを製作できます。
- **折り畳み式：** スプレッダーはブロック上でピボット（回転）するので、アンテナを運搬・収納のために折り畳み、運用時は数秒で展開できます。
- **バンドに合わせてスケーラブル：** OpenSCAD によるパラメトリック設計（[src/all_in_one.scad](../src/all_in_one.scad)）により、ブームとスプレッダーの直径を調整し、別サイズのブームやスプレッダー用にパーツを再生成できます。

- **調整可能：** ループは 3D プリント製のクランプ（[stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)）で固定され、チューニング中にケーブルを切り詰めて再固定できます。

本ガイドでは、製作と調整の実践的な手順を段階的に文書化します。理論的な背景（1005/1030/975 の公式の由来、Velocity Factor の影響、期待される性能、参考文献）は別ドキュメントで扱います。

> 📘 **[TEORIA.ja.md](TEORIA.ja.md) — 理論的背景と参考文献**

公式はどの周波数でも有効ですが、実践的な詳細例として、PVC 絶縁 0.5 mm² ケーブルを用いた 70 cm バンド（435 MHz）向けの実機製作を文書化しています。

<p align="center">
  <img src="images/pics/70cm_open.jpeg" width="420" alt="展開したアンテナ（5 エレメント、435 MHz）"/>
  <img src="images/pics/70cm_folded.jpeg" width="420" alt="運搬のために折り畳んだアンテナ"/>
</p>

---

## 2. リファレンス製作の寸法（435 MHz、Vf = 0.91）

以下の寸法は、本ガイドで文書化した実機製作に対応するもので、0.5 mm² の PVC ケーブル（実測 Velocity Factor 0.91）を使用しています。

> 別の周波数や別の種類のケーブルで製作する場合は、一般公式と Vf の測定手順を [TEORIA.ja.md § 2–3](TEORIA.ja.md) で参照するか、[🧮 オンライン計算機](https://openquad-calc.ea4ipw.es) を使って直接寸法を得ることもできます。

**エレメント：**

| エレメント | 周長 (mm) | 周長 (in) | 辺 (mm) | 辺 (in) | スプレッダー (mm) | スプレッダー (in) |
|---|---|---|---|---|---|---|
| リフレクター | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| ドリブン | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| ディレクター 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| ディレクター 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| ディレクター 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| ディレクター 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| ディレクター 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**間隔：**

| 区間 | 距離 (mm) | 距離 (in) |
|---|---|---|
| リフレクター → ドリブン | 137.9 | 5.43 |
| ドリブン → ディレクター 1 | 103.4 | 4.07 |
| ディレクター → ディレクター | 103.4 | 4.07 |

**構成ごとのブーム全長：**

| 構成 | ブーム (mm) | ブーム (in) |
|---|---|---|
| 2 エレメント (R + DE) | 137.9 | 5.43 |
| 3 エレメント (R + DE + D1) | 241.4 | 9.50 |
| 4 エレメント (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 エレメント (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 エレメント (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 エレメント (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. 材料

アンテナを製作するのに必要なものの概要です。以降の節では代替案、寸法決定、根拠を詳しく説明します。

| 材料 | 推奨仕様 | 数量 | サブセクション |
|---|---|---|---|
| 銅導線（エレメント） | PVC 0.5 mm²（VHF/UHF）；1〜2 mm Ø 裸線または絶縁（HF） | 周長に応じて（§2） | [3.1](#31-エレメント用ケーブル) |
| ブーム | アルミ・PVC・木製のチューブ（角または丸） | 1 本、構成により長さが変わる（§2） | [3.2](#32-ブーム) |
| スプレッダー | 非導電性ロッド（グラスファイバー・ブナ材・PVC）、VHF/UHF では 4〜8 mm Ø | エレメントあたり 4 本 | [3.3](#33-スプレッダー) |
| M3 × 12 mm 六角穴付きボルト | Hex socket cap（細いスプレッダー用に M3×8/M3×10） | エレメントあたり 4 本 | [3.4](#34-締結部品と保持) |
| M3 ナット | 標準六角 | エレメントあたり 4 個 | [3.4](#34-締結部品と保持) |
| ゴムバンド | 折りたたんだブロックを巻けるもの | エレメントあたり 1 本 | [3.4](#34-締結部品と保持) |
| 同軸ケーブル + コネクター | 使用機器に合わせる（UHF では一般に RG-58/RG-316） | 1 | — |
| 熱収縮チューブ | 給電点のはんだ付けや接続部の絶縁用、各種径 | 数 cm | — |
| スナップオンフェライト mix 43（任意、調整用） | 同軸径に応じて Fair-Rite 0443164251/0443167251 | 5〜6 | [4.2](#42-チョークバラン測定時には任意だが推奨) |

### 3.1. エレメント用ケーブル

絶縁の有無にかかわらず、銅導線であれば何でも使えます。絶縁ケーブル（PVC、ポリエチレン）を使う場合は Vf 補正を忘れずに適用してください（[TEORIA.ja.md § 2](TEORIA.ja.md) を参照）。

VHF/UHF では 0.5 mm² から 1.5 mm² の断面積が適しています。細い方が取り回しやすく、太い方が形状を保ちやすいですが、推奨は 0.5 mm² です。435 MHz における表皮深さはわずか 3 µm で、すべての電流は導体表面を流れます。0.5 mm² と 1.5 mm² の損失差は約 0.025 dB で、完全に無視できます。細いケーブルでは帯域幅が約 8% 減少しますが、実用上は意味のある差ではありません。

HF ではエレメントがはるかに大きくなるため、典型的には直径 1〜2 mm の銅導線（裸銅線または絶縁付き）や、軽量化のために撚り線が使われます。

50 W までの電力であれば、細いケーブルでも全く問題ありません。実用上の限界は導体ではなく、はんだ付け部と絶縁（PVC は約 70°C で軟化します）にあります。

複数の電線を接続したりループを閉じたりする場合は、両端から約 10 mm の被覆を剥き、平行に重ねて（撚り合わせるか、ウェスタンユニオン接続で）、たっぷりのはんだで溶接し、熱収縮チューブで保護してください。

<p align="center">
  <img src="images/pics/10mm_extra_soldering.jpg" width="300" alt="はんだ付け前の被覆を剥いだ 10 mm の導線"/>
  <img src="images/pics/soldering_edges.jpg" width="300" alt="はんだ付け前に両端を合わせた状態"/>
</p>
<p align="center">
  <img src="images/pics/soldered_edges.jpg" width="300" alt="はんだ付け済みの接続部"/>
  <img src="images/pics/thermoretractile.jpg" width="300" alt="接続部に被せた熱収縮チューブ"/>
</p>

### 3.2. ブーム

アルミニウムが理想的です。軽く、剛性があり、加工も容易です。アンテナのサイズに適した断面の角パイプまたは丸パイプで十分です。UHF であれば PVC パイプでも問題なく使えます。

**金属製ブームはアンテナに影響するか？** クワッドでは、Yagi とは異なり、ブームはループの面に対して垂直であり、エレメントはスプレッダーによってブームから離されています。影響はごくわずか、あるいは皆無です。Yagi のように**ブーム補正は不要**です。

木製ブームも同様に機能しますが、重く吸湿します。その誘電効果（εr ≈ 2）は周波数を約 0.1% ずらす可能性がありますが、実用上は問題になりません。

ブームが角ではなく丸である場合、電気的な差はありません。唯一の考慮点は機械的なもので、スプレッダーのハブが同じ回転方向で固定されるようにすることです（セクション 3.5 参照）。

<p align="center">
  <img src="images/pics/reflector_assembly_closed_boom.jpg" width="420" alt="PVC ブームに取り付けたエレメント"/>
</p>

### 3.3. スプレッダー

グラスファイバー、ブナ材、または PVC のロッドを使用します。非導電性の素材である必要があります。適切な直径はバンドによって異なり、VHF/UHF では 4〜8 mm のロッドで十分です。

<p align="center">
  <img src="images/pics/element_preparation.jpg" width="420" alt="3D プリントしたハブと、長さに切ったスプレッダーロッド"/>
</p>

### 3.4. 締結部品と保持

各エレメントには、スプレッダーにクランプを閉じるため、および print-in-place ブロックを折りたたんだ状態で輸送するために、少量の標準締結部品が必要です：

- **M3 × 12 mm 六角穴付きボルト — 1 エレメントあたり 4 本。** スプレッダークランプ 1 個につき 1 本で、クランプの 2 つの半分をスプレッダーロッドの周りで締め付けます。12 mm の長さは **8 mm スプレッダー**用の寸法です。より細いスプレッダー（4〜6 mm）ではクランプ本体が薄くなるため、より短いボルト（M3×8 または M3×10）が必要になる場合があります。購入前にレンダリング済みの部品でボルト通路の深さを確認してください。ナット座とボルトのクリアランスは [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) で M3 用に寸法設計されています。
- **M3 ナット — 1 エレメントあたり 4 個。** ボルトを締め付ける前に、各クランプの六角ポケットにはめ込みます。
- **ゴムバンド — 1 エレメントあたり 1 本。** 折りたたんだ `all_in_one` ブロックに巻きつけ、輸送および保管中に 4 つのクランプをブームカラーに閉じた状態で保持します。

<p align="center">
  <img src="images/pics/element_assembly_screws.jpg" width="420" alt="M3 ハードウェアで組み立てたブロック"/>
</p>

### 3.5. エレメントの整列

すべての正方形ループは、ブーム上で**同じ回転方向に整列**させる必要があります。あるエレメントが他に対して回転していると、電流セグメントが平行でなくなるため、エレメント間の結合が劣化します。

- **数度程度の誤差：** 影響は無視できます。
- **45° の回転：** 結合が著しく劣化し、利得と F/B 比が低下します。

角ブームでは整列は自然に得られます。丸ブームの場合は、止めねじ、貫通ピン、または少量の接着剤で向きを確保してください。

<p align="center">
  <img src="images/pics/reflector_assembly_open.jpg" width="320" alt="展開したエレメント（スプレッダーが X 形に開いた状態）"/>
  <img src="images/pics/reflector_assembly_closed.jpg" width="320" alt="折りたたんだエレメント（スプレッダーを閉じた状態）"/>
</p>

---

## 4. 段階的な調整手順

### 4.1. 必要な工具

- アンテナアナライザ（NanoVNA、LiteVNA またはそれに準ずるもの）
- VNA 用コネクタ付きの短い同軸ケーブル
- はんだごてとはんだ
- ミリメートル目盛りの定規またはデジタルノギス
- 細刃のニッパー

<p align="center">
  <img src="images/pics/nanovna_swr.jpg" width="420" alt="アンテナのスミスチャートと SWR を表示している NanoVNA"/>
</p>

### 4.2. チョークバラン（測定時には任意だが推奨）

給電点にチョークバランを入れると、同軸のシールド編組が放射して測定結果を乱すのを防ぎ、測定の信頼性が向上します。チョークがないと、VNA のケーブルに触れたり動かしたりするだけで読み値が変わることがあります。

**HF 用：** クラシックな巻線型チョークがよく機能します。フェライトトロイド（FT-140-43 など）に同軸を 6〜10 回巻きます。

**VHF/UHF 用：** 巻線型チョークは使用しないでください。高周波では巻線間の容量により寄生共振が発生します。その代わりに、給電点のすぐ後ろで同軸上に**スナップオン（クランプオン）フェライト**（mix 43）を連ねて通します。5〜6 個で十分なインピーダンスが得られます。

VHF/UHF に有効なスナップオンフェライトの例：Fair-Rite 0443164251（ケーブル径 ≤6.6 mm）、Fair-Rite 0443167251（ケーブル径 ≤9.85 mm）、または Fair-Rite 0443164151（ケーブル径 ≤12.7 mm）。いずれも mix 43 素材です。Mouser、DigiKey などの販売代理店で入手できます。

スナップオンは指で開閉でき、工具は不要で、完全に再利用可能です。

**注意：** 多くの市販のクワッド型アンテナはチョークを持たず、それで問題なく動作しています。クワッドは給電点で本質的にバランスの取れたジオメトリを持ちます。チョークは主に調整中の信頼できる測定のためのものであり、通常の運用における必須条件ではありません。

<p align="center">
  <img src="images/pics/driven_element_solder.jpg" width="320" alt="ドリブンエレメントのはんだ付け部の拡大"/>
  <img src="images/pics/driven_element.jpeg" width="320" alt="同軸ケーブルを接続し防水処理したドリブンエレメント"/>
</p>

### 4.3. 調整手順

#### ステップ 1 — 組み立てて Vf を較正する

実際の電線には必ず Vf < 1 があります。空気中の裸銅線は 0.97〜0.99 程度、絶縁付きケーブルは誘電体により 0.90〜0.97 まで下がります。推奨手順は、おおよその値から始めて測定により較正することです：

1. [🧮 オンライン計算機](https://openquad-calc.ea4ipw.es) を使い、あなたのケーブルの典型的な Vf を出発値として、すべてのエレメントの寸法を計算します（裸銅線 0.99、薄い PVC ≈0.91、ポリエチレン ≈0.95、テフロン ≈0.97。詳細な表は [TEORIA.ja.md § 2.2](TEORIA.ja.md)）。基礎となる式は `周長 = k × λ × Vf`、ここで `λ = 299,792.458 / f(MHz)` mm、`k_driven ≈ 1.022` です（[TEORIA.ja.md § 1](TEORIA.ja.md) 参照）。
2. その寸法でアンテナ全体を組み立てます。
3. VNA で組み立てたアンテナの共振周波数を測定します。
4. 測定した周波数を [🧮 計算機](https://openquad-calc.ea4ipw.es) に入力し、実際の Vf と補正後の寸法を得ます。
5. 各ループを新しい寸法に合わせて短くします — ワイヤークランプ（[stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)）により、はんだ付けをやり直さずに調整できます。

> 詳細は [TEORIA.ja.md § 2.4](TEORIA.ja.md) を参照してください。

**ドリブン単体で目標周波数に合わせ、その後リフレクターを追加して周波数が維持されると期待してはいけません。** 結合は常に周波数をずらします。だからこそ、アンテナ全体を組み立てた状態で測定します。

#### ステップ 2 — ディレクターを 1 つずつ追加する

1. ドリブンの前方 0.15λ の位置にディレクター 1 を取り付けます。その周長はドリブンより約 3% 短くします。
2. 測定します。結合の状態により周波数はわずかに上下します。
3. SWR が許容範囲なら、次のディレクターに進みます。
4. 追加の各ディレクターについて繰り返します。各ディレクターは前のものより 3% 短くします。

**よくある問題：ディレクターを追加した途端に SWR が急上昇する。** 最も多い原因は、ディレクターが長すぎる（ドリブンの共振周波数に近すぎる）ことです。寄生素子がドリブンと同じ周波数で共振すると最大のエネルギーを吸収し、SWR が跳ね上がります。**対策：** ディレクターが実際にドリブンより 3% 短いことを確認し、必要に応じて切り詰めます。

#### ステップ 3 — 最終調整

すべてのエレメントを取り付けたあと、周波数を中心に合わせるためにドリブンエレメントの微調整が必要になることがあります。ディレクターは正しくカットされていれば、ほとんど手直しを必要としません。

**ヒント：** VNA では、スミスチャートだけでなく「SWR vs 周波数」表示を使うと、最小点と帯域幅の位置が明確にわかります。

<p align="center">
  <img src="images/pics/wire_clam_screw.jpg" width="320" alt="ワイヤークランプ — 六角穴付きボルト側"/>
  <img src="images/pics/wire_clam_nut.jpg" width="320" alt="ワイヤークランプ — ナット側"/>
</p>

---

## 5. よくある問題と対処法

### 共振周波数が予想よりかなり低い

**考えられる原因：** 絶縁ケーブルの Vf を考慮していない。PVC ケーブルは Vf = 0.91〜0.95 となることがあり、エレメントを電気的に長くします。

**対策：** 手順のステップ 1 に従って Vf を実測し、寸法を再計算します。

### ディレクターを追加すると SWR が大幅に上がる

**考えられる原因：** ディレクターがドリブンと同じ長さ、あるいはごく近い長さにカットされている。寄生素子がドリブンと同じ周波数で共振すると最大のエネルギーを吸収します。

**対策：** ディレクターがドリブンより 3% 短いことを確認し、必要なら切り詰めます。

### リフレクターを追加すると周波数が下がる

**原因：** リフレクターとドリブンの間の誘導性の相互結合です。これは正常な動作であり、誤りではありません。

**対策：** ドリブンをプリコンペンセート（目標より少し高い周波数に単独で調整）するか、ドリブンとリフレクターを組み合わせた状態で調整します。

### アンテナを触ると周波数がずれる

**原因：** VHF/UHF では、コーナーが 1〜2 mm ずれるだけでも周波数が容易に変化します。

**対策：** 最終測定の前にスプレッダー上のケーブルをしっかり固定し、ケーブルがピンと張った状態になるようテンションを調整してください。

### VNA ケーブルに触れると測定値が変わる

**原因：** 同軸外側シールドのコモンモード電流。VNA のケーブルがアンテナの一部として振る舞っています。

**対策：** 給電点にスナップオンフェライト（mix 43）を追加します。フェライトが手元にない場合は、少なくとも測定間でケーブルの取り回しを変えないようにします。

### SWR は良好だが F/B 比が悪い

**考えられる原因：** リフレクターの調整が不適切。SWR と F/B 比は、リフレクターの異なる長さで最適化されます。

**対策：** リフレクターを 1〜2% 伸ばすか縮めて試します。あるいは、リフレクターに短絡スタブを付けて、物理的な長さを変えずに調整することもできます。

---

## 6. リファレンス製作の結果

本ガイドで例として文書化したアンテナ（5 エレメント、435 MHz、0.5 mm² PVC ケーブル、実測 Vf = 0.91）は、以下の測定結果を得ました。

- **SWR：** 最小点（432 MHz）で 1.1、435 MHz で <1.6
- **実測 F/B 比：** S メーターで約 6 単位の差（前方 S9、後方 S3）≈ 30〜36 dB
- **共振時インピーダンス：** 50 Ω に近い値
- **実用帯域幅（SWR < 2）：** 約 430〜440 MHz

> 他の構成（2〜7 エレメント）での理論値や Yagi との等価性と比較するには、[TEORIA.ja.md § 4](TEORIA.ja.md) を参照してください。

<p align="center">
  <img src="images/pics/70cm_open_2.jpeg" width="520" alt="完成した 435 MHz 用 5 エレメントアンテナの 3/4 ビュー"/>
</p>

---

## 7. 事前ビルド済みパーツ

リリースごとに、CI が最も一般的なブームとスプレッダーサイズの STL を事前レンダリングして公開します。各組み合わせは、3 つの印刷可能パーツ（`all_in_one`, `driven_element`, `regular_wire_clamp`）と PNG プレビューを含む単一の zip として配布されます。お使いのハードウェアに合う組み合わせをダウンロードして、すぐに印刷を開始できます — OpenSCAD は不要です。

事前レンダリングされた組み合わせがどれもハードウェアに合わない場合は、下の [§ 7.4](#74-カスタム-サイズをビルドする) を参照して自分でレンダリングしてください。

### 7.1. オールインワン ブロック（ブーム カラー + 4 つのクランプ）

<p align="center">
  <img src="images/pics/aio_open.jpg" width="320" alt="クランプを開いた状態のオールインワンブロック"/>
  <img src="images/pics/aio_closed.jpg" width="320" alt="クランプをブームカラーに閉じたオールインワンブロック"/>
</p>

行：ブーム形状 × ブーム寸法、列：スプレッダー径。

| ブーム \ スプレッダー | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **丸 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **丸 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **丸 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **角 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **角 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **角 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. スプレッダー クランプ

この 2 つのパーツはスプレッダー径のみに依存します（ブームの形状や寸法は関係ありません）。各 3 種類のバリエーションのみです。

| スプレッダー | 励振エレメント | ワイヤクランプ（寄生） |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. ダウンロード

各リンクは、その組み合わせの 3 つの STL と PNG プレビューを含む zip です。常に **最新のリリース** を取得します。

| ブーム \ スプレッダー | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **丸 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **丸 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **丸 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **角 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **角 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **角 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. カスタム サイズをビルドする

事前レンダリング済みの組み合わせがどれもハードウェアに合わない（または他の直径を試したい）場合は、自分でパーツをレンダリングできます。通常変更する 3 つのパラメータはすべて [src/all_in_one.scad](../src/all_in_one.scad) ファイルにあります：

- `boom_is_round` — 丸パイプの場合 `true`、角パイプの場合 `false`。
- `boom_dia`（丸）**または** `boom_side`（角）— ブームの外寸（mm）。
- `spreaders_dia` — スプレッダー ロッドの外径（mm）。

励振エレメントと通常のワイヤクランプ（[src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)）は `spreaders_dia` と `driven_element`（`true` / `false`）のみに依存します。

> ⚠️ **スライスする前にオールインワンを視覚的にプリチェックしてください — 特にピボット部分。** このパーツはプリント・イン・プレース方式です：4 つのクランプは中央のカラーに細いピボット シリンダで取り付けられた状態で印刷され、小さなロック検出球が各クランプを開いた状態（印刷用）または折りたたんだ状態（運搬用）に保ちます。通常と異なるブームやスプレッダー サイズはジオメトリを変動させ、ピボットが融合してしまう（クランプが回転しない）またはクリアランスが大きすぎる（ロック検出が掛からない）ことがあります。OpenSCAD で **F6** を押してモデルをレンダリングし、ピボットの 1 つにズームインして以下を確認してください：
>
> - ピボット シリンダがその穴の中で明確なクリアランス リングを持っている — 融合した壁がない。
> - ロック検出球が独立した特徴として見える — 周囲の材料に融合していない。
> - クランプ本体がピボット フレーム プレートに対して連続したギャップを保っている。
>
> 何かが融合または厚さゼロに見える場合、調整する値は `print_gap` と `pivot_clearance` です（[src/all_in_one.scad](../src/all_in_one.scad) 上部の *Hidden* セクション内）。

**オプション A — OpenSCAD GUI**

1. OpenSCAD をインストールします（<https://openscad.org/downloads.html> から最新の **2026.x ナイトリー** をダウンロード — 古い安定版 2021.01 には、ここで使用される manifold バックエンドがありません）。
2. [src/all_in_one.scad](../src/all_in_one.scad) を開きます。右側のカスタマイザ パネルには、上記の 4 つのブーム/スプレッダー パラメータのみが表示されます（モデルの他のパラメータは意図的に非表示にしています）。
3. 値を編集し、**F5** で簡易プレビュー、続いて **F6**（時計アイコン）でフルジオメトリをレンダリングします。
4. 検査（特にピボット — 上記の警告を参照）し、**ファイル → エクスポート → STL としてエクスポート…**。
5. [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) で `driven_element=true` と `driven_element=false` について繰り返します。

**オプション B — CLI / Makefile**

リポジトリには OpenSCAD CLI をラップした [Makefile](../Makefile) が含まれています。`openscad` が `PATH` に必要です（または `OPENSCAD=/path/to/openscad` を渡してください）。

最も簡単な方法：[src/all_in_one.scad](../src/all_in_one.scad) 上部の `boom_…` / `spreaders_dia` のデフォルト値を編集し、次のように実行します：

```bash
make            # build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl をビルド
make renders    # 800×800 PNG プレビューも生成
```

または、ソース ファイルを変更せずに `-D` オーバーライドで OpenSCAD を直接呼び出します：

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

`make help` を実行して、利用可能なすべてのターゲット（`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`）を表示します。

---

*73 from EA4IPW — OpenQuad v1.0*
