# OpenQuad —— 模块化可折叠 Cubical Quad（立方四方天线）

**作者 EA4IPW —— 实例：为 435 MHz 构建 5 单元 quad 天线**

<p align="center">
  <img src="../web/diagram.jpeg" width="420" alt="设计示意图"/>
</p>

---

## 1. 本设计是什么

本项目记录了一种**模块化可折叠 Cubical Quad 天线设计**，其构想是使用 3D 打印件、玻璃纤维或木棒作为撑杆，以及 PVC、木材或铝合金主梁来制作。

本设计的主要特点如下：

- **模块化：** 每个元件（反射器、驱动元、引向器）都安装在独立的*模块*上，该模块可在主梁上滑动并固定。你可以使用相同的硬件构建 2、3、5、6、7…… 单元的天线。
- **可折叠：** 撑杆可围绕模块枢转，因此天线可折拢用于运输或存放，并能在几秒钟内展开投入使用。
- **按频段可扩展：** 基于 OpenSCAD 的参数化设计（[src/all_in_one.scad](../src/all_in_one.scad)）允许调整主梁与撑杆的直径，并为其他主梁与撑杆尺寸重新生成零件。

- **可调：** 环形单元由 3D 打印夹子（[stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)）固定，可在调谐过程中修剪并重新固定导线。

本指南记录了实际建造与调谐的逐步过程。理论基础（1005/1030/975 公式的来源、velocity factor 的影响、预期性能、参考文献）在另一份文档中论述：

> 📘 **[TEORIA.zh.md](TEORIA.zh.md) —— 理论基础与参考文献**

这些公式对任何频率都适用；作为详细的实例，本文记录了针对 70 cm 频段（435 MHz）、使用 0.5 mm² PVC 安装导线的真实制作过程。

<p align="center">
  <img src="images/pics/70cm_open.jpeg" width="420" alt="展开的天线（5 单元，435 MHz）"/>
  <img src="images/pics/70cm_folded.jpeg" width="420" alt="折叠后便于运输的天线"/>
</p>

---

## 2. 参考构建的尺寸（435 MHz，Vf = 0.91）

下列尺寸对应本指南所记录的真实构建，使用 0.5 mm² PVC 导线，实测 velocity factor 为 0.91。

> 如果你为其他频率或其他类型的导线构建，请参阅通用公式以及 Vf 的测量方法，详见 [TEORIA.zh.md § 2–3](TEORIA.zh.md)，或直接使用 [🧮 在线计算器](https://openquad-calc.ea4ipw.es) 获取尺寸。

**元件：**

| 元件 | 周长 (mm) | 周长 (in) | 边长 (mm) | 边长 (in) | 撑杆 (mm) | 撑杆 (in) |
|---|---|---|---|---|---|---|
| 反射器 | 656.8 | 25.86 | 164.2 | 6.46 | 116.1 | 4.57 |
| 驱动元 | 640.8 | 25.23 | 160.2 | 6.31 | 113.3 | 4.46 |
| 引向器 1 | 621.7 | 24.47 | 155.4 | 6.12 | 109.9 | 4.33 |
| 引向器 2 | 603.0 | 23.74 | 150.8 | 5.93 | 106.6 | 4.20 |
| 引向器 3 | 584.9 | 23.03 | 146.2 | 5.76 | 103.4 | 4.07 |
| 引向器 4 | 567.4 | 22.34 | 141.8 | 5.58 | 100.3 | 3.95 |
| 引向器 5 | 550.4 | 21.67 | 137.6 | 5.42 | 97.3 | 3.83 |

**间距：**

| 区段 | 距离 (mm) | 距离 (in) |
|---|---|---|
| 反射器 → 驱动元 | 137.9 | 5.43 |
| 驱动元 → 引向器 1 | 103.4 | 4.07 |
| 引向器 → 引向器 | 103.4 | 4.07 |

**不同配置下主梁的总长度：**

| 配置 | 主梁 (mm) | 主梁 (in) |
|---|---|---|
| 2 单元 (R + DE) | 137.9 | 5.43 |
| 3 单元 (R + DE + D1) | 241.4 | 9.50 |
| 4 单元 (R + DE + D1 + D2) | 344.8 | 13.57 |
| 5 单元 (R + DE + D1–D3) | 448.3 | 17.65 |
| 6 单元 (R + DE + D1–D4) | 551.7 | 21.72 |
| 7 单元 (R + DE + D1–D5) | 655.2 | 25.80 |

---

## 3. 材料

以下是制作天线所需物品的概览。后续小节会详细说明替代方案、尺寸选择与理由。

| 材料 | 推荐规格 | 数量 | 小节 |
|---|---|---|---|
| 铜导线（元件） | PVC 0.5 mm²（VHF/UHF）；1–2 mm Ø 裸线或带绝缘（HF） | 按周长（§2） | [3.1](#31-元件使用的导线) |
| 主梁 | 铝、PVC 或木制管材（方形或圆形） | 1 根，长度依配置而定（§2） | [3.2](#32-主梁) |
| 撑杆 | 非导电棒（玻璃纤维、山毛榉或 PVC），VHF/UHF 为 4–8 mm Ø | 每元件 4 根 | [3.3](#33-撑杆) |
| M3 × 12 mm 内六角圆柱头螺钉 | Hex socket cap（更细撑杆用 M3×8/M3×10） | 每元件 4 颗 | [3.4](#34-紧固件与固定) |
| M3 螺母 | 标准六角 | 每元件 4 颗 | [3.4](#34-紧固件与固定) |
| 橡皮筋 | 任一可缠绕折叠组件者 | 每元件 1 条 | [3.4](#34-紧固件与固定) |
| 同轴电缆 + 连接器 | 视设备而定（UHF 通常使用 RG-58/RG-316） | 1 | — |
| 热缩管 | 多种直径，用于馈电点焊接与接续的绝缘 | 数 cm | — |
| 卡扣式铁氧体 mix 43（可选，调谐用） | 按同轴电缆 Ø 选 Fair-Rite 0443164251/0443167251 | 5–6 | [4.2](#42-扼流巴伦可选但建议用于测量) |

### 3.1. 元件使用的导线

任何铜导线，无论有无绝缘层都适用。对于带绝缘层的导线（PVC、聚乙烯），请记得应用 Vf 修正（参见 [TEORIA.zh.md § 2](TEORIA.zh.md)）。

在 VHF/UHF 频段，0.5 mm² 至 1.5 mm² 截面的导线都能很好地工作。更细的导线更易于操作；更粗的导线能更好地保持形状，我的建议是使用 0.5 mm²。在 435 MHz 时趋肤深度仅为 3 µm，因此所有电流都在导体表面流动。0.5 mm² 与 1.5 mm² 之间的损耗差异约为 0.025 dB —— 完全可以忽略。更细的导线带宽会减少约 8%，这在实际中也不足为道。

在 HF 频段，元件尺寸要大得多，通常使用直径 1–2 mm 的铜线（裸线或带绝缘），甚至使用多股绞线以减轻重量。

对于不超过 50W 的功率，细导线完全没有问题。实际的限制来自焊点与绝缘层（PVC 在约 70°C 时会软化），而不是来自导体本身。

在接续导线或闭合环形单元时，先从每端剥出约 10 mm，将两端并排贴合（可以拧合，或使用 Western Union 接法），用足量锡料焊接，并用热缩管保护接头。

<p align="center">
  <img src="images/pics/10mm_extra_soldering.jpg" width="300" alt="焊接前剥出 10 mm 的导线"/>
  <img src="images/pics/soldering_edges.jpg" width="300" alt="焊接前两端对接"/>
</p>
<p align="center">
  <img src="images/pics/soldered_edges.jpg" width="300" alt="已焊接的接头"/>
  <img src="images/pics/thermoretractile.jpg" width="300" alt="在焊接处套上热缩管"/>
</p>

### 3.2. 主梁

铝合金是理想材料：轻便、刚性好且易于加工。根据天线尺寸选择合适截面的方管或圆管即可。对于 UHF，PVC 管也完全适用。

**金属主梁会影响天线吗？** 在 quad 天线中，与 Yagi 不同，主梁垂直于环面，且元件通过撑杆与主梁分开。其影响微乎其微甚至不存在。**不需要像 Yagi 那样进行主梁修正。**

木质主梁同样可用，但更重且会吸收水分。其介电效应（εr ≈ 2）可能使频率偏移约 0.1% —— 在实际中无足轻重。

如果主梁是圆形而非方形，在电学上没有差别。唯一需要考虑的是机械方面：确保所有撑杆的 hub（集线座）固定在相同的角度方向（参见 3.5 节）。

<p align="center">
  <img src="images/pics/reflector_assembly_closed_boom.jpg" width="420" alt="安装在 PVC 主梁上的元件"/>
</p>

### 3.3. 撑杆

可使用玻璃纤维、山毛榉木或 PVC 制成的棒。必须是非导电材料。合适的直径取决于频段：在 VHF/UHF 频段，4–8 mm 的棒即可胜任。

<p align="center">
  <img src="images/pics/element_preparation.jpg" width="420" alt="3D 打印的 hub 与按长度切好的撑杆"/>
</p>

### 3.4. 紧固件与固定

每个元件都需要少量的标准紧固件，用于将夹具夹紧在撑杆上，并在运输过程中保持 print-in-place 组件处于折叠状态：

- **M3 × 12 mm 内六角圆柱头螺钉 —— 每元件 4 颗。** 每个撑杆夹一颗，将夹具的两半绕撑杆拉紧。12 mm 的长度是按 **8 mm 撑杆**设计的 —— 更细的撑杆（4–6 mm）夹具本体更薄，可能需要更短的螺钉（M3×8 或 M3×10）；购买前请在渲染好的零件上检查螺钉通道的深度。螺母座和螺钉间隙在 [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) 中按 M3 尺寸设计。
- **M3 螺母 —— 每元件 4 颗。** 在拧紧螺钉前嵌入每个夹具上的六角凹槽中。
- **橡皮筋 —— 每元件 1 条。** 缠绕在折叠后的 `all_in_one` 组件上，在运输和存放期间让四个夹具保持抵靠主梁环的闭合状态。

<p align="center">
  <img src="images/pics/element_assembly_screws.jpg" width="420" alt="已安装 M3 紧固件的模块"/>
</p>

### 3.5. 元件的对齐

所有方形环形单元都必须在主梁上**保持相同的旋转方向**。如果某个元件相对于其他元件发生旋转，互耦会恶化，因为电流段不再保持平行。

- **几度的误差：** 影响可忽略。
- **45° 旋转：** 互耦严重恶化，增益与 F/B 都会下降。

使用方形主梁时对齐很自然。使用圆形主梁时，应以紧定螺钉、贯穿销或一滴胶水来保证方向。

<p align="center">
  <img src="images/pics/reflector_assembly_open.jpg" width="320" alt="展开的元件（撑杆呈 X 形打开）"/>
  <img src="images/pics/reflector_assembly_closed.jpg" width="320" alt="折叠的元件（撑杆合拢）"/>
</p>

---

## 4. 逐步调谐

### 4.1. 所需工具

- 天线分析仪（NanoVNA、LiteVNA 或类似设备）
- 带有 VNA 连接器的短同轴电缆
- 电烙铁与焊锡
- 毫米刻度尺或数显卡尺
- 细口斜口钳

<p align="center">
  <img src="images/pics/nanovna_swr.jpg" width="420" alt="NanoVNA 显示天线的 Smith 图与 SWR"/>
</p>

### 4.2. 扼流巴伦（可选，但建议用于测量）

在馈电点使用扼流巴伦可以提高测量的可靠性，防止同轴电缆外屏蔽层辐射而扰动结果。没有扼流巴伦时，触碰或移动 VNA 的电缆可能会改变读数。

**对于 HF：** 经典的绕线扼流圈效果良好：在铁氧体磁环（FT-140-43 或类似）上绕 6–10 圈同轴电缆。

**对于 VHF/UHF：** 切勿使用绕线扼流圈 —— 在高频下，线圈匝间电容会产生寄生谐振。取而代之的是，使用 mix 43 材料的**卡扣式铁氧体（clamp-on）**，串联套在馈电点后方的同轴电缆上。5–6 颗即可提供足够的阻抗。

适用于 VHF/UHF 的卡扣式铁氧体型号参考：Fair-Rite 0443164251（电缆 ≤6.6 mm）、Fair-Rite 0443167251（电缆 ≤9.85 mm），或 Fair-Rite 0443164151（电缆 ≤12.7 mm），均为 mix 43 材料。可在 Mouser、DigiKey 或类似分销商处购得。

卡扣式铁氧体用手指即可开合，无需工具，且可完全重复使用。

**注：** 许多商用 quad 天线并未使用扼流巴伦也能良好工作。quad 的馈电点几何本身就具有良好的平衡性。扼流巴伦主要是为了在调谐时获得可靠的测量，而不是正常使用的必要条件。

<p align="center">
  <img src="images/pics/driven_element_solder.jpg" width="320" alt="驱动元焊接处的特写"/>
  <img src="images/pics/driven_element.jpeg" width="320" alt="带有同轴电缆并做密封处理的驱动元"/>
</p>

### 4.3. 调谐步骤

#### 第 1 步 —— 构建并校准 Vf

任何真实导线都有 Vf < 1。空气中的裸铜线约在 0.97–0.99 之间；带绝缘的导线视介质不同降至 0.90–0.97。推荐的做法是从一个近似值出发，通过测量进行校准：

1. 使用 [🧮 在线计算器](https://openquad-calc.ea4ipw.es) 计算所有元件的尺寸，将你所用导线的典型 Vf 作为起始值（裸铜线 0.99，薄 PVC ≈0.91，聚乙烯 ≈0.95，聚四氟乙烯 ≈0.97；完整表格见 [TEORIA.zh.md § 2.2](TEORIA.zh.md)）。底层公式为 `周长 = k × λ × Vf`，其中 `λ = 299,792.458 / f(MHz)` mm，`k_driven ≈ 1.022`（参见 [TEORIA.zh.md § 1](TEORIA.zh.md)）。
2. 按这些尺寸组装完整的天线。
3. 用 VNA 测量整个天线的谐振频率。
4. 将测得的频率输入 [🧮 计算器](https://openquad-calc.ea4ipw.es)，得到真实的 Vf 及修正后的尺寸。
5. 将每个环剪短到新的尺寸 —— 导线夹（[stls/regular_wire_clamp.stl](../stls/regular_wire_clamp.stl)）允许无需重新焊接即可完成此调整。

> 详见 [TEORIA.zh.md § 2.4](TEORIA.zh.md)。

**不要试图将独立的驱动元调到目标频率后再加入反射器，期望其保持不变。** 互耦总会使频率发生偏移；正因如此，我们在天线整体组装完毕后再进行测量。

#### 第 2 步 —— 逐个添加引向器

1. 将引向器 1 安装在驱动元前方 0.15λ 处。其周长应比驱动元短约 3%。
2. 测量。频率可能因互耦而略有上升或下降。
3. 如果 SWR 可接受，继续下一个引向器。
4. 对每个后续引向器重复。每个应比前一个短 3%。

**常见问题：添加引向器时 SWR 急剧上升。** 最常见的原因是引向器过长（过于接近驱动元的谐振频率）。当寄生元件与驱动元谐振在同一频率时，它吸收最大能量，导致 SWR 飙升。**解决方法：** 确认引向器确实比驱动元短 3%，必要时将其剪短。

#### 第 3 步 —— 最终调整

安装好所有元件之后，可能需要对驱动元进行微调，以使频率居中。如果引向器剪裁得当，通常无需再调整。

**提示：** 在 VNA 上使用 SWR 与频率的曲线视图（而不仅仅是史密斯圆图），可清楚地看到最低点与带宽所在位置。

<p align="center">
  <img src="images/pics/wire_clam_screw.jpg" width="320" alt="导线夹 —— 内六角螺钉一侧"/>
  <img src="images/pics/wire_clam_nut.jpg" width="320" alt="导线夹 —— 螺母一侧"/>
</p>

---

## 5. 常见问题与解决方案

### 谐振频率远低于预期

**可能原因：** 未考虑绝缘导线的 Vf。PVC 导线的 Vf 可能在 0.91–0.95 之间，这会使元件在电学上被加长。

**解决方法：** 按经验测量 Vf（步骤 1），并重新计算尺寸。

### 添加引向器时 SWR 大幅上升

**可能原因：** 引向器被剪成与驱动元等长，或非常接近。当寄生元件与驱动元谐振在同一频率时，它吸收最大能量。

**解决方法：** 确认引向器比驱动元短 3%。必要时将其剪短。

### 加入反射器后频率下降

**原因：** 反射器与驱动元之间的电感性互耦。这是正常行为，不是错误。

**解决方法：** 对驱动元进行预补偿（单独调到比目标高一些的频率），或同时安装驱动元与反射器后再进行调谐。

### 操作天线时频率发生偏移

**原因：** 在 VHF/UHF 频段，角部 1–2 mm 的位移就足以改变频率。

**解决方法：** 在进行最终测量之前，先将导线牢固地固定在撑杆上，调整张力使导线保持绷紧。

### 触碰电缆时 VNA 读数发生变化

**原因：** 同轴电缆外屏蔽层上的共模电流。VNA 的电缆此时表现为天线的一部分。

**解决方法：** 在馈电点加装 mix 43 的卡扣式铁氧体。如果没有铁氧体，至少在两次测量之间保持相同的电缆走向。

### SWR 良好但 F/B 较差

**可能原因：** 反射器未调整妥当。SWR 与 F/B 通常在反射器的不同长度上达到各自的最优值。

**解决方法：** 尝试将反射器加长或缩短 1–2%。或者，在反射器上使用一段短路短截线进行调整，这样无需改变其物理长度。

---

## 6. 参考构建的结果

作为本指南示例记录的天线（5 单元，435 MHz，0.5 mm² PVC 导线，实测 Vf = 0.91）实现了以下实测结果：

- **SWR：** 最低点处为 1.1（432 MHz），在 435 MHz 处 <1.6
- **实测 F/B：** 约 6 个 S 单位差（前向 S9，后向 S3）≈ 30–36 dB
- **谐振时阻抗：** 接近 50 Ω
- **可用带宽（SWR < 2）：** 约 430–440 MHz

> 要对照其他配置（2–7 单元）的理论预期值，以及与 Yagi 的等效关系，请参见 [TEORIA.zh.md § 4](TEORIA.zh.md)。

<p align="center">
  <img src="images/pics/70cm_open_2.jpeg" width="520" alt="完成的 5 单元 435 MHz 天线的 3/4 视角"/>
</p>

---

## 7. 预构建零件

每次发布时，CI 都会为最常见的 boom 和 spreader 尺寸预渲染一组 STL。每种组合都打包为单个 zip，包含三个可打印零件（`all_in_one`, `driven_element`, `regular_wire_clamp`）以及 PNG 预览图。下载与您硬件匹配的组合即可开始打印 — 无需 OpenSCAD。

如果预渲染的组合都不符合您的硬件，请参见下方 [§ 7.4](#74-构建自定义尺寸) 自行渲染。

### 7.1. 一体化模块（boom 卡环 + 4 个夹具）

<p align="center">
  <img src="images/pics/aio_open.jpg" width="320" alt="夹具展开的一体化模块"/>
  <img src="images/pics/aio_closed.jpg" width="320" alt="夹具收拢抵靠主梁卡环的一体化模块"/>
</p>

行为 boom 形状 × boom 尺寸，列为 spreader 直径。

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **圆形 14.9 mm** | <img src="images/generated/r_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_all_in_one.png" width="180"/> |
| **圆形 15.9 mm** | <img src="images/generated/r_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b15.9_s8.10_all_in_one.png" width="180"/> |
| **圆形 19.9 mm** | <img src="images/generated/r_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/r_b19.9_s8.10_all_in_one.png" width="180"/> |
| **方形 14.9 mm** | <img src="images/generated/s_b14.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b14.9_s8.10_all_in_one.png" width="180"/> |
| **方形 15.9 mm** | <img src="images/generated/s_b15.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b15.9_s8.10_all_in_one.png" width="180"/> |
| **方形 19.9 mm** | <img src="images/generated/s_b19.9_s4.05_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s6.07_all_in_one.png" width="180"/> | <img src="images/generated/s_b19.9_s8.10_all_in_one.png" width="180"/> |

### 7.2. Spreader 夹具

这两个零件仅依赖 spreader 直径（boom 的形状和尺寸无关），因此每种各只有三种变体。

| Spreader | 激励单元 | 导线夹具（无源） |
|---|---|---|
| **4.05 mm** | <img src="images/generated/r_b14.9_s4.05_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s4.05_regular_wire_clamp.png" width="180"/> |
| **6.07 mm** | <img src="images/generated/r_b14.9_s6.07_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s6.07_regular_wire_clamp.png" width="180"/> |
| **8.10 mm** | <img src="images/generated/r_b14.9_s8.10_driven_element.png" width="180"/> | <img src="images/generated/r_b14.9_s8.10_regular_wire_clamp.png" width="180"/> |

### 7.3. 下载

每个链接是包含该组合的三个 STL 与 PNG 预览的 zip。始终从 **最新发布版** 获取。

| Boom \ Spreader | 4.05 mm | 6.07 mm | 8.10 mm |
|---|---|---|---|
| **圆形 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_14.9mm_spreaders_8.10mm.zip) |
| **圆形 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_15.9mm_spreaders_8.10mm.zip) |
| **圆形 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/round_boom_19.9mm_spreaders_8.10mm.zip) |
| **方形 14.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_14.9mm_spreaders_8.10mm.zip) |
| **方形 15.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_15.9mm_spreaders_8.10mm.zip) |
| **方形 19.9 mm** | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_4.05mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_6.07mm.zip) | [zip](https://github.com/mangelajo/openquad-antenna/releases/latest/download/square_boom_19.9mm_spreaders_8.10mm.zip) |

### 7.4. 构建自定义尺寸

如果预渲染的组合都不符合您的硬件（或者您想尝试其他直径），可以自行渲染零件。通常需要调整三个参数，都位于 [src/all_in_one.scad](../src/all_in_one.scad) 文件中：

- `boom_is_round` — 圆管为 `true`，方管为 `false`。
- `boom_dia`（圆形）**或** `boom_side`（方形）— boom 的外部尺寸（毫米）。
- `spreaders_dia` — spreader 棒的外径（毫米）。

激励单元和常规导线夹具（[src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad)）仅依赖 `spreaders_dia` 和 `driven_element`（`true` / `false`）。

> ⚠️ **切片前请目视预检一体化模块 — 特别是枢轴部分。** 该零件采用 print-in-place（一次成型）方式：四个夹具通过细枢轴圆柱在打印时已与中心卡环连接，并带有小型锁定凹槽球，将每个夹具保持在打开状态（用于打印）或折叠状态（用于运输）。异常的 boom 或 spreader 尺寸可能使几何形状偏移到足以将枢轴熔合在一起（夹具无法转动），或打开过大（锁定凹槽无法卡住）。务必在 OpenSCAD 中按 **F6** 渲染模型，然后放大其中一个枢轴并确认：
>
> - 枢轴圆柱在其孔中有清晰的间隙环 — 没有熔合的墙壁。
> - 锁定凹槽球作为独立特征可见 — 没有与周围材料熔合。
> - 夹具体与枢轴框架板之间保持连续的间隙。
>
> 如果有任何看起来熔合或零厚度的部分，需要调整的值是 `print_gap` 和 `pivot_clearance`（位于 [src/all_in_one.scad](../src/all_in_one.scad) 顶部附近的 *Hidden* 部分）。

**方案 A — OpenSCAD 图形界面**

1. 安装 OpenSCAD（从 <https://openscad.org/downloads.html> 下载较新的 **2026.x 夜间版** — 旧的稳定版 2021.01 缺少此处使用的 manifold 后端）。
2. 打开 [src/all_in_one.scad](../src/all_in_one.scad)。右侧的 Customizer 面板仅显示上述四个 boom/spreader 参数（模型的其他参数已被有意隐藏）。
3. 编辑数值，按 **F5** 快速预览，然后按 **F6**（时钟图标）渲染完整几何形状。
4. 检查（特别是枢轴 — 见上方警告），然后 **文件 → 导出 → 导出为 STL…**。
5. 对 [src/antenna_spreader_clamp.scad](../src/antenna_spreader_clamp.scad) 重复操作，分别使用 `driven_element=true` 和 `driven_element=false`。

**方案 B — 命令行 / Makefile**

仓库附带一个 [Makefile](../Makefile)，封装了 OpenSCAD CLI。需要 `openscad` 位于您的 `PATH` 中（或传递 `OPENSCAD=/path/to/openscad`）。

最简单的方法：编辑 [src/all_in_one.scad](../src/all_in_one.scad) 顶部的 `boom_…` / `spreaders_dia` 默认值，然后：

```bash
make            # 构建 build/all_in_one.stl, build/driven_element.stl, build/regular_wire_clamp.stl
make renders    # 同时生成 800×800 PNG 预览图
```

或者直接调用 OpenSCAD 并使用 `-D` 覆盖参数，保持源文件不变：

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

运行 `make help` 查看所有可用 target（`all`, `matrix`, `zip`, `renders`, `docs-images`, `clean`）。

---

*73 来自 EA4IPW —— OpenQuad v1.0*
