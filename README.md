# Wishful Thinking

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![conventional commit compliant](https://img.shields.io/badge/git%20commit-conventional%20commit-brightgreen.svg?style=flat-square)](https://www.conventionalcommits.org/en/v1.0.0/#specification)
[![git flow compliant](https://img.shields.io/badge/branch-git%20flow-brightgreen.svg?style=flat-square)](./doc/README.gitflow.md)

Notes and other thoughts.

## Background

This is a project mix all diary, lecture notes, self-learning notes,
my attempts to learn theoretical & applied computer science together.

Most Important part is design for my Lilies Programming Language,
a compiler, an interpreter, REPL for it, an editor using it as default
extension language (though plugin system will developed using native binary,
so that it will support almost all language with given `.h` c header.
Compile a shared library and load it using editor API.
But the support to extend editor with lilies are built-in.), an IDE
layer for corresponding editor, and (maybe) a loadable image for bare
mental language runtime.

This repository contains all my crazy thinkings and related attempts.
This repository will only contains text-based resources though.

For each sub-project, you may find its README and LICENSE on its own
directory.

### Referencing

[CS Plan](https://cs-plan.com)
[CsDiy](https://csdiy.wiki)

## Install

This is (probably) a plain-text project.

I don't think it is worth to installing.

## Structure

The whole project is organized in following structure:

```txt
Root: /                         ; Project root
+- .git/                        ; git repository
+- .github/
|  +- workflows/                ; CI/CD configuration
+- .typsite/                    ; SSG configuration
+- bin/                         ; build results
|  +- deploy.sh
|  +- gen-todos.sh
+- doc/                         ; documentation & copyright information
|  +- licenses/                 ; when adopting other library, place license here
|  +- root/                     ; detailed README for each subproject
|  +- notes/                    ; notes not about to be published
|  +- LICENSE                   ; copy of LICENSE adopted by the project
|  +- LICENSE.apache            ; copy of original LICENSE
|  +- README                    ; README for directory `doc`
|  +- README.commit.md          ; git commit convention
|  +- README.gitflow.md         ; git flow convention
|  +- README.release.md         ; semantic versioning 
+- inc/                         ; public header
+- lib/                         ; public library, installed from bin
+- publish/                     ; generated site
+- root/                        ; Site root
|  +- lib/                      ;
|  +- notes/                    ; notes to be published
+- src/                         ; source code for each subproject
+- test/                        ; public test files
+- tmp/                         ; temporay files
+- todos/                       ; todo list, from git commit
+- .gitignore
+- .gitmodules
+- LICENSE
+- README.md
```

For each subproject, it will be organize into two parts,

- one is its documentation, it will be placed in the `doc/root/<name>` directory,
- other is its source code, it will be placed in the `src/<name>` directory.

What's more, organize for those sub directory will be:

```txt
Root: doc/root/<name>
+- <ft>/                         ; link, probobly
|  +- Sample.<ft>
|  +- ...
+- LICENSE
+- README.md

Root: src/<name>
+- src/
+- <build-script>
```

## Usage

The Typst notes use [typst-mode](https://github.com/mujiu555/typst-mode) as a
Git submodule at `lib/typst-mode`, tracking its `feat/share` branch. The parent
repository pins the exact library commit.

```sh
git submodule update --init --recursive
typst compile --root . doc/notes/index.typ /tmp/wishful-thinking.pdf
```

To deliberately update the library, run `git submodule update --remote lib/typst-mode`
and review and commit the resulting submodule pointer change.

Notes import `/lib/typst-mode/lib/_lib.typ/lib.typ`, use
`authors: ([Author name],)`, call `mkheading()`, and embed notes with
`embed(include "path.typ")`. Former categories are regular tags defined in
`doc/notes/tags.typ`. References use global `mkindex(label, content)` and
`lookup(label, content)` calls.

Most of the notes will be written in markdown, typst, or LaTeX.
But some of which may be done with org-mode.
So, it will be nice to have a configured Emacs.

## Plans

- Applied Computer Science
  - Computer Graphic
    - [-] CMU-15-462\_662
    - [-] FreeGLUT
  - Operating System
  - Compiler Principle
- Theoretical Computer Science
  - [ ] ITTCS
  - [X] SICP
  - [ ] HTDP
  - [X] MIT-18.404j
  - Theory of Computation
    - [X] MIT-6.004
  - Pgrogramming Paradigm
    - [X] Stanford-CS107
  - Type Theory
    - Type System
      - TaPL: Type and Programming Languages
      - PFPL: Practical Foundations for Programming Languages
  - Programming Language Theory
  - Program Theory
  - Lambda Calculus
- Software Engineering
  - [X] Missing-Semester
  - [-] tools\_maps
  - [ ] buildYOLisp
  - [ ] Craft Interpreter
  - [X] c
  - [ ] hecto
  - [ ] d\_flat
    - Lilies: General purpose programming language based on S-Expression,
      act as an IR for d\_flat system.
    - Margarita: Higher layer programming language based on M-Expression
    - Editor:
    - Library: Including one for standard library as a
      general purpose programming language and
      one for text processing and mark up language.
  - [ ] leetcode
- Mathematics
  - DiscreteMathematics
    - [ ] MIT-6.042j
  - Category Theory
- [X] HowToSpeak

## 第 0 层：数学基础

这一层不是类型论本身，但没有它你读不懂后面的东西。

| 领域 | 为什么需要 | 关键内容 |
|---|---|---|
| **离散数学** | 所有形式化的语言基础 | 集合、关系、函数、归纳法、递归 |
| **数理逻辑入门** | 逻辑的语法/语义 | 命题逻辑、一阶逻辑、真值表、赋值、模型 |
| **可计算性理论** | 理解"可判定"和"不可判定" | 图灵机、λ 演算、可判定性、停机问题、哥德尔编码 |
| **集合论基础** | 类型论的对标框架 | ZFC、基数、序数、良序、选择公理 |
| **序论/格论** | 逻辑的代数语义 | 偏序、格、完备格、Heyting 代数、不动点定理 |

**强度**：对类型论 ★★★★★，对类型系统 ★★★☆☆，对形式化方法 ★★★★★。

---

### 第 1 层：逻辑

这是类型论和形式化方法的共同源头。

#### 1.1 经典逻辑

- **命题逻辑**：连接词、真值表、范式、完备性。
- **一阶逻辑（FOL）**：量词、谓词、模型、可靠性、完全性（哥德尔 1929）。
- **高阶逻辑（HOL）**：量化命题和函数、标准语义 vs. Henkin 语义。
- **模型论**：紧致性、Löwenheim-Skolem、超积。
- **证明论**：自然演绎、相继式演算、切消定理、正规化。

#### 1.2 直觉主义/构造逻辑

- **直觉主义命题逻辑（IPC）**：拒绝排中律、双重否定。
- **直觉主义一阶逻辑（IQC）**：Kripke 语义、BHK 解释。
- **构造性数学**：Bishop 的构造性分析、构造性集合论（CZF/IZF）。
- **模态逻辑**：S4、S5、Kripke 语义、分阶段计算（Davies-Pfenning）。
- **线性逻辑**：Girard 的线性逻辑、资源敏感推理。
- **次协调逻辑**：允许矛盾不爆炸、Belnap 的四值逻辑。
- **三值/多值逻辑**：K3、Ł3、FDE。

#### 1.3 元理论

- **哥德尔不完备定理**：第一、第二、Löb 定理。
- **塔斯基真理层级**：真理谓词的不可定义性。
- **可靠性/完全性/可判定性**：三大元理论性质。
- **序数分析**：证明论序数、Γ₀、ε₀。

**强度**：对类型论 ★★★★★，对类型系统 ★★★☆☆，对形式化方法 ★★★★★。

---

### 第 2 层：类型论核心

这是你的核心目标之一。

#### 2.1 λ 演算

- **无类型 λ 演算**：α/β/η 归约、Church-Rosser、Y 组合子、Church 编码。
- **简单类型 λ 演算（STLC）**：类型规则、强规范化、Curry-Howard。
- **System F**：多态、二阶逻辑、Parametricity。
- **System Fω**：类型算子、高阶多态。
- **λμ-演算**：经典逻辑的类型论对应、call/cc、continuation。

#### 2.2 Curry-Howard 对应

- **命题即类型，证明即项**：核心对应表。
- **证明归一化 = 程序求值**：计算侧的解释。
- **扩展对应**：模态逻辑 ↔ 模态类型论，线性逻辑 ↔ 线性类型论。

#### 2.3 依赖类型论

- **Martin-Löf 类型论（MLTT）**：Π 类型、Σ 类型、Id 类型、宇宙。
- **构造演算（CoC）**：impredicative Prop、PTS 框架。
- **归纳类型**：W 类型、归纳族、归纳-递归类型。
- **共归纳类型**：余归纳、守卫递归、▷ 模态。
- **宇宙层级**：Type₀ : Type₁ : ...、累积性、宇宙多态。
- **外延 vs. 内涵**：类型等价、单价性。

#### 2.4 高阶类型论

- **同伦类型论（HoTT）**：类型即空间、证明即路径、单价性公理。
- **立方类型论（Cubical TT）**：计算语义、Kan 运算、立方模型。
- **观测类型论（OTT）**：外延类型论的计算解释。
- **效果类型论**：代数效果、处理器、模态。

**强度**：对类型论 ★★★★★，对类型系统 ★★★★☆，对形式化方法 ★★★★★。

---

### 第 3 层：类型系统（编程语言视角）

这是你的另一个核心目标。类型系统是类型论在编程语言中的工程化。

#### 3.1 基础

- **操作语义**：小步、大步、上下文。
- **指称语义**：CPO、不动点、域论。
- **公理语义**：Hoare 逻辑、最弱前置条件。
- **类型判断**：`Γ ⊢ e : τ` 的推导规则。
- **类型推导**：Hindley-Milner、Algorithm W、合一。

#### 3.2 类型系统特性

| 特性 | 关键内容 |
|---|---|
| **多态** | 参数多态、特设多态、子类型多态 |
| **子类型** | 子类型关系、变异、F-界量化 |
| **递归类型** | 等递归 vs. 同递归、μ 类型 |
| **存在类型** | 抽象类型、模块、封装 |
| **依赖类型** | 全依赖、部分依赖、类型族 |
| **线性类型** | 资源敏感、唯一性类型、会话类型 |
| **效果系统** | 代数效果、monad、handler |
| **精化类型** | 细化类型、SMT 集成、Liquid Haskell |
| **所有权类型** | Rust 的 borrow checker、分离逻辑 |
| **分级类型** | 安全级别、信息流控制 |

#### 3.3 类型系统元理论

- **可靠性（Soundness）**：类型良好的程序不会出错。
- **进展 + 保持**：小步语义的可靠性证明。
- **规范化**：强规范化、弱规范化。
- **参数性**：Reynolds 的参数性定理、自由定理。
- **类型推断的可判定性**：哪些系统可推断，哪些不可。

#### 3.4 实现技术

- **类型检查算法**：双向类型检查、elaboration。
- **合一算法**：Robinson 合一、高阶合一。
- **类型类**：Haskell 的字典传递、相干性。
- **模块系统**：ML 模块、函子、签名。
- **宏与元编程**：Template Haskell、Racket 宏、分阶段计算。

**强度**：对类型论 ★★★★☆，对类型系统 ★★★★★，对形式化方法 ★★★★☆。

---

### 第 4 层：支撑性数学

这一层不是类型论本身，但它是理解类型论"为什么这样设计"的关键。

#### 4.1 范畴论

- **基础**：范畴、函子、自然变换、伴随。
- **笛卡尔闭范畴**：STLC 的语义。
- **局部笛卡尔闭范畴**：依赖类型论的语义。
- **拓扑斯**：直觉主义逻辑的范畴语义。
- **单子与代数理论**：Monad、Lawvere 理论、代数效果。
- **高阶范畴**：∞-groupoid、HoTT 的范畴语义。
- **Curry-Howard-Lambek**：逻辑 = 类型论 = 范畴论。

#### 4.2 序论/格论

- **偏序、全序、预序**：基本序结构。
- **格、完备格**：并、交、分配律。
- **Heyting 代数**：直觉主义逻辑的代数语义。
- **布尔代数**：经典逻辑的代数语义。
- **不动点定理**：Knaster-Tarski、Kleene 迭代。
- **域论**：CPO、Scott 拓扑、指称语义。

#### 4.3 代数

- **通用代数**：签名、代数、同态、自由代数。
- **半群、幺半群、群**：基本代数结构。
- **环、模、域**：线性代数的基础。
- **代数理论**：Lawvere 理论、单子、代数效果。

#### 4.4 集合论

- **ZFC 公理**：集合论基础。
- **基数、序数**：无穷的层级。
- **力迫法**：独立性证明。
- **大基数**：集合论的强度层级。

**强度**：对类型论 ★★★★★，对类型系统 ★★★★☆，对形式化方法 ★★★★☆。

---

### 第 5 层：形式化方法

这是类型论和类型系统的**应用侧**。

#### 5.1 证明助手

| 工具 | 基础 | 特点 |
|---|---|---|
| **Coq** | CoC + 归纳类型 | 成熟、工业级、提取 |
| **Agda** | MLTT + 宇宙 | 依赖类型、终止检查、sized types |
| **Lean 4** | CoC + 归纳类型 | 数学库、元编程、自动化 |
| **Isabelle/HOL** | HOL | 经典逻辑、自动化强 |
| **Idris 2** | MLTT + 线性类型 | 编程导向、partial/total |
| **F* / A* ** | 依赖类型 + 效果 | 程序验证、SMT 集成 |

#### 5.2 形式化技术

- **证明搜索**：自动定理证明、SMT、归结。
- **策略语言**：Ltac、Elab、元编程。
- **程序提取**：Coq → OCaml/Haskell、证明即程序。
- **验证**：程序验证、编译器验证（CompCert）、操作系统验证（seL4）。
- **形式化数学**：Mathlib、UniMath、HoTT 库。

#### 5.3 类型论与形式化的交叉

- **证明无关性**：Proof irrelevance、命题截断。
- **单价性**：HoTT 的单价性公理、立方模型。
- **计算解释**：规范化、canonicity、一致性。
- **反射**：证明反射、元编程、tactic。

**强度**：对类型论 ★★★★★，对类型系统 ★★★★☆，对形式化方法 ★★★★★。

---

### 第 6 层：前沿与交叉

这一层是你已经触及的方向，适合深入。

| 方向 | 核心问题 | 关键文献 |
|---|---|---|
| **同伦类型论（HoTT）** | 类型 = 空间，证明 = 路径 | HoTT Book |
| **立方类型论** | HoTT 的计算语义 | Cubical Agda、CCHM 模型 |
| **分阶段计算** | 模态类型论、代码生成 | Davies-Pfenning、MetaOCaml |
| **效果类型论** | 代数效果、处理器 | Plotkin-Power、Lexical effects |
| **线性类型论** | 资源敏感、会话类型 | Girard、Wadler、Session Types |
| **精化类型** | 类型 + 逻辑约束 | Liquid Types、F* |
| **依赖类型系统** | 全依赖编程 | Idris、Agda、Lean |
| **类型论语义** | 范畴模型、立方模型 | Awodey、Warren、Shulman |
| **证明论** | 序数分析、切消 | Gentzen、Schütte、Pohlers |
| **计算效应** | Monad、代数效果 | Moggi、Plotkin-Power |

---

### 学习路径建议

按依赖关系，我建议这个顺序：

```
第 0 层（数学基础）
    ↓
第 1 层（逻辑）← 重点：经典逻辑 + 直觉主义逻辑 + 证明论
    ↓
第 2 层（类型论）← 重点：λ 演算 + Curry-Howard + 依赖类型
    ↓
第 4 层（支撑数学）← 重点：范畴论 + 序论/格论
    ↓
第 3 层（类型系统）← 重点：类型规则 + 元理论 + 实现
    ↓
第 5 层（形式化方法）← 重点：证明助手 + 程序提取
    ↓
第 6 层（前沿）
```

**第 1、2 层是核心**，第 4 层是理解第 2 层的关键，第 3 层是工程化，第 5 层是应用，第 6 层是研究。

### 1. 经典逻辑（必备）

- **命题逻辑、谓词逻辑**：理解 `∧ ∨ → ¬ ∀ ∃` 的经典语义。
- **模型论基础**：`⊨` 是什么，真值表、赋值、模型。
- **证明论基础**：`⊢` 是什么，公理系统、自然演绎、相继式演算。
- **可靠性 / 完全性**：`⊢ A ⟹ ⊨ A` 和 `⊨ A ⟹ ⊢ A`。

**为什么**：没有这个，你不知道直觉主义逻辑**拒绝了什么**。你不知道排中律为什么是"经典"的标志，不知道双重否定消除为什么重要，不知道 `⊢ False` 但 `⊭ False` 为什么意味着不可靠。

### 2. 形式化方法（必备）

- **形式语法、语义、推理规则**。
- **结构归纳、良基归纳**。
- **操作语义、指称语义**。
- **类型系统基础**：类型判断、类型规则、类型推导。

**为什么**：类型论本身就是形式化方法的一部分。你需要懂得"形式系统"的语言，才能读懂 MLTT、CoC 的规则。

### 3. 集合论（强烈推荐）

- **ZFC 公理**：理解"集合"作为基础框架的形态。
- **基数、序数**：理解"无穷"的层级，这是序数分析的基础。
- **可计算性理论**：图灵机、可判定性、不可判定性。

**为什么**：类型论和集合论是两个**平行**的基础框架。不懂集合论，你不知道类型论在"替代什么"。序数分析更是直接建立在集合论的序数概念上。

### 4. 序论 / 格论（强烈推荐）

- **偏序、格、完备格**。
- **Heyting 代数**：直觉主义逻辑的代数语义。
- **Kripke 模型**：直觉主义逻辑的可能世界语义。
- **不动点定理**：Kleene 迭代、Knaster-Tarski。

**为什么**：直觉主义逻辑的语义不在真值表里，在 Heyting 代数里。不理解格论，你无法理解"为什么 `A ∨ ¬A` 不成立"。

### 5. 范畴论（推荐，但不是必须）

- **Curry-Howard-Lambek 对应**：逻辑 = 类型论 = 范畴论。
- **笛卡尔闭范畴**：STLC 的语义。
- **拓扑斯**：直觉主义逻辑的范畴语义。

**为什么**：如果你想理解"类型论和范畴论的对偶关系"，你需要范畴论。但如果你只关心类型论本身，可以先跳过。

### 6. 古典哲学 / 数学哲学（可选，但很有启发）

- **柏拉图主义 vs. 构造主义**：数学对象是"发现"的还是"构造"的？
- **Brouwer 的直觉主义**：为什么他拒绝排中律？
- **希尔伯特纲领**：为什么哥德尔定理是它的终结？
- **形式主义、逻辑主义、直觉主义**：三大数学哲学流派。

**为什么**：这些是"为什么"层面的问题。不懂它们，你只知道"类型论拒绝了排中律"，但不知道"为什么有人要拒绝排中律"。哲学给了你动机。

如果你已经懂了一些类型论，想补齐"基本认知"，建议顺序：

1. **经典命题逻辑 + 谓词逻辑**（模型论 + 证明论）：`⊢`、`⊨`、可靠性、完全性。
2. **可计算性理论**：图灵机、可判定性、哥德尔编码。
3. **集合论基础**：ZFC、基数、序数。
4. **序论 / 格论**：偏序、格、Heyting 代数。
5. **直觉主义逻辑**：BHK 解释、Kripke 模型、与经典逻辑的翻译。
6. **形式化方法**：操作语义、类型系统、结构归纳。
7. **数学哲学**：柏拉图主义、构造主义、希尔伯特纲领。
8. **范畴论**（可选）：Curry-Howard-Lambek、笛卡尔闭范畴、拓扑斯。

**前四步是"必备的基础认知"**，后面是"深入理解"。

## Related Efforts

Not yet. (Laugh

After all, this is just a diary.

## Maintainers

[github@mujiu555(暮玖)](https://github.com/mujiu555)

## Contributing

You may pull all repository and walk through any part you interested in.
Make Pr if you have found any problem or have method to improve those notes.

## License

Apache License ver. 2.
