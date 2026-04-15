# Cubical Quad 天线的理论基础

**作者 EA4IPW —— OpenQuad 指南的理论补充**

本文档汇总了支撑 Cubical Quad 天线设计的理论基础、公式与参考文献。实际建造的案例记录在 [README.zh.md](README.zh.md)。

Cubical Quad 是一种带有寄生元件的天线（类似 Yagi），其中每个元件都是一个周长为整个波长的方形环。与同等数量元件的 Yagi 相比，它的增益高约 2 dB，前后比更好，且馈电点阻抗更接近 50 Ω。

本指南的公式与步骤对任何频率都适用。

---

## 1. 公式及其来源

### 1.1. 基本常数：从光速到神奇的数值「1005」

这个常数自 1960 年代以来就在天线文献中出现（参见末尾的参考文献），但我们还是看一下它的来源。

真空中的波长为：

    λ = c / f

其中 c = 299,792,458 m/s。以英尺表示：

    λ (pies) = 983.57 / f(MHz)

一个周长为整个波长的方形环并不会精确地在理论上的 λ 处谐振。由于电流绕过角部以及场的曲率，它需要稍长一点（约 2.2%）才能谐振。这就得到了经典的经验常数：

    983.57 × 1.021 ≈ 1005

**注：** 与偶极子不同 —— 偶极子由于开放端部的「end effect」会比理论值*缩短*约 5%（从 492 缩为 468）—— 一个闭合的 loop 需要*更长*，因为它没有开放端部。

### 1.2. 各元件的公式

这些公式给出的是**整个 loop 的总周长**：

| 元件 | 周长 (pies) | 周长 (mm) | 来源 |
|---|---|---|---|
| 驱动元 | 1005 / f | 1005 / f × 304.8 | 在 f 处谐振 |
| 反射器 | 1030 / f | 1030 / f × 304.8 | 长约 2.5% → 感性 |
| 引向器 1 | 975 / f | 975 / f × 304.8 | 短约 3% → 容性 |
| 引向器 N+1 | Director_N × 0.97 | Director_N × 0.97 | 3% 递减序列 |

其中 f 以 MHz 为单位。

**派生尺寸：**

- 正方形一边的长度：`lado = perímetro / 4`
- 撑杆臂长（从中心到角部）：`spreader = lado × √2 / 2 = lado × 0.7071`

### 1.3. 常数 1030 与 975 的来源

它们并非随意取值，而是基于驱动元的基本常数（1005）推导而来：

| 常数 | 计算 | 作用 |
|---|---|---|
| 1005 | 984 × 1.021 | 在工作频率谐振的 loop |
| 1030 | 1005 × 1.025 | 反射器：长 2.5% → 谐振频率偏低 → 感性 |
| 975 | 1005 × 0.970 | 引向器：短 3% → 谐振频率偏高 → 容性 |

感性反射器与容性引向器共同产生所需的相位，使天线朝单一方向辐射（从反射器指向引向器）。

### 1.4. 元件之间的间距

| 区段 | 距离 |
|---|---|
| 反射器 → 驱动元 | 0.20λ |
| 驱动元 → 引向器 1 | 0.15λ |
| 引向器 → 引向器 | 0.15λ |

其中 λ 是自由空间中的波长：

    λ (mm) = 300,000 / f(MHz)
    λ (pulgadas) = 11,811 / f(MHz)
    λ (pies) = 984 / f(MHz)

**重要：** 间距取决于自由空间中的波长，而**不**取决于导线的 velocity factor。无论你为元件使用何种导线，主梁的长度都保持一致。

---

## 2. Velocity Factor (Vf)：为什么重要以及如何计算

### 2.1. 什么是 Vf

前一节的公式假设使用**真空中的裸铜线**（Vf = 1.0）。如果使用带绝缘的导线（PVC、聚乙烯、特氟龙），波在导体中传播得更慢，从而减小了在相同频率谐振所需的物理长度。

绝缘层增加了沿导体分布的电容，减缓了传播。这意味着你需要**更少的导线**来完成一个电学波长。

### 2.2. 典型的 Vf 值

| 导线类型 | 近似 Vf |
|---|---|
| 裸铜线 | 1.00 |
| PTFE/特氟龙绝缘 | 0.97–0.98 |
| 聚乙烯绝缘 | 0.95–0.96 |
| 薄 PVC 绝缘 | 0.91–0.95 |
| 厚 PVC 绝缘（450/750V 安装导线） | 0.90–0.93 |

**注意：** 这些只是参考值。真实的 Vf 取决于绝缘层厚度相对于导体直径的比例。一根 1.5 mm² 的家用安装导线（H07V-K，UNE-EN 50525）的 PVC 外皮相对比 6 mm² 的同款导线要厚，因此 Vf 更低。

### 2.3. 考虑 Vf 修正后的公式

将每个常数乘以 Vf：

    Driven = (1005 × Vf) / f(MHz) × 304.8    (mm)
    Driven = (1005 × Vf) / f(MHz) × 12        (pulgadas)
    Driven = (1005 × Vf) / f(MHz)              (pies)

反射器的 1030 与引向器 1 的 975 同理处理。

### 2.4. 如何测量你导线的 Vf

最直接的方法是经验法：

1. 使用裸铜线的公式（Vf = 1.0）计算驱动元的周长。
2. 制作该环。
3. 同时制作反射器。
4. 用 NanoVNA 测量其谐振。
5. 计算真实的 Vf：**Vf = f_resonancia_medida / f_objetivo**

例如：如果你是为 435 MHz 计算的，但环在 400 MHz 处谐振，那么你的 Vf 就是 400/435 = 0.92。

根据我的经验，仅用引向器元件来计算 Vf 并不可行，
你需要有反射器，它的安装会使频率向下偏移。

这之所以可行，是因为小于 1 的 Vf 意味着整体在电学上「过长」，因此谐振在预期频率之下。

---

## 3. 任意频率下的尺寸计算

对于中心频率 f（以 MHz 为单位）与 velocity factor Vf：

**周长 (mm)：**

    Reflector   = (1030 × Vf) / f × 304.8
    Driven      = (1005 × Vf) / f × 304.8
    Director 1  = (975 × Vf) / f × 304.8
    Director 2  = Director 1 × 0.97
    Director 3  = Director 2 × 0.97
    ……以此类推

**周长 (pulgadas)：**

    Reflector   = (1030 × Vf) / f × 12
    Driven      = (1005 × Vf) / f × 12
    Director 1  = (975 × Vf) / f × 12
    Director 2  = Director 1 × 0.97
    ...

**间距 (mm)：**（与 Vf 无关）

    Reflector → Driven:   300,000 / f × 0.20
    Driven → Director:    300,000 / f × 0.15
    Director → Director:  300,000 / f × 0.15

**间距 (pulgadas)：**

    Reflector → Driven:   11,811 / f × 0.20
    Driven → Director:    11,811 / f × 0.15
    Director → Director:  11,811 / f × 0.15

---

## 4. 预期的理论性能

### 4.1. 各配置下的增益与 F/B

| 元件数 | 近似增益 (dBd) | 近似增益 (dBi) | 前后比 F/B |
|---|---|---|---|
| 2 (R + DE) | ~5.5 | ~7.6 | 10–15 dB |
| 3 (R + DE + D1) | ~7.5 | ~9.6 | 15–20 dB |
| 4 (R + DE + D1 + D2) | ~8.5 | ~10.6 | 18–22 dB |
| 5 (R + DE + D1–D3) | ~9.2 | ~11.3 | 20–25 dB |
| 6 (R + DE + D1–D4) | ~9.7 | ~11.8 | 20–25 dB |
| 7 (R + DE + D1–D5) | ~10.0 | ~12.1 | 20–25 dB |

dBd（相对偶极子）与 dBi（相对各向同性天线）的数值。dBi = dBd + 2.15。

从 4–5 单元起，收益逐渐减小（每增加一个引向器约 0.5 dB）。对大多数应用而言，3–5 单元是增益、复杂度与调谐便利性之间的最佳折中点。

### 4.2. 与 Yagi 的等效关系

作为一般参考，N 单元的 quad 在相近主梁长度下的表现大致等同于 N+2 单元的 Yagi。

### 4.3. F/B 的实际验证

调谐到一个已知的中继台或信标，将天线对准信源，记录 S 表读数，旋转 180° 再比较。根据 IARU Region 1 R.1（1981）规范，每一个 S 单位差约等于 6 dB，不过商用设备上 S 表的校准可能差异显著，尤其是在 S3 以下 —— 许多接收机在该区间每个 S 单位只对应 2–3 dB。

---

## 5. 参考文献

### 书籍与技术文档

- **L. B. Cebik (W4RNL), "Cubical Quad Notes" —— 卷 1、2、3。** 关于 quad 设计的权威参考。可在以下链接获取：https://antenna2.github.io/cebik/content/bookant.html
- **William Orr (W6SAI), "All About Cubical Quad Antennas."** 使 quad 在业余无线电界广为流传的经典之作。
- **ARRL Antenna Book —— Chapter 12: Quad Arrays.** 公式 1005/1030/975 的出处。

### 在线文章

- **Cebik 关于 quad 的文章**（由 G0UIH 编入索引）：https://q82.uk/cebikquad
- **"Why the old formula of 1005/freq sometimes doesn't work for loop antennas"** —— 关于 Vf 对带 PVC 绝缘导线 loop 的影响的说明：https://q82.uk/1005overf
- **W8JI —— Cubical Quad** —— 严谨的技术分析：https://www.w8ji.com/quad_cubical_quad.htm
- **Practical Antennas —— Wire Quads：** https://practicalantennas.com/designs/loops/wirequad/
- **Electronics Notes —— Cubical Quad Antenna：** https://www.electronics-notes.com/articles/antennas-propagation/cubical-quad-antenna/quad-basics.php

### 建造指南

- **"Build a High Performance Two Element Tri-Band Cubical Quad" (KB5TX)：** https://kb5tx.org/oldsite/DIY%20(Do%20it%20Youself)/Build%20a%20Hi-Performance%20Quad.pdf
- **"A Five-Element Quad Antenna for 2 Meters" (N5DUX)：** http://www.n5dux.com/ham/files/pdf/Five-Element%20Quad%20Antenna%20for%202m.pdf
- **"Building a Quad Antenna"：** https://www.computer7.com/building-a-quad-antenna/

### 在线计算器

- **YT1VP Cubical Quad Calculator：** https://www.qsl.net/yt1vp/CUBICAL%20QUAD%20ANTENNA%20CALCULATOR.htm（不含 Vf 修正）
- **CSGNetwork Cubical Quad Calculator：** http://www.csgnetwork.com/antennae5q2calc.html

### 所引用的标准

- **IARU Region 1 Technical Recommendation R.1 (1981)：** S 表的定义。1 个 S 单位 = 6 dB，VHF 下 S9 = −93 dBm（50 Ω 下的 5 µV）。

---

*73 来自 EA4IPW —— OpenQuad v1.0*
