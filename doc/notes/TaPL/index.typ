#import "@preview/tysty:0.1.0": embed, entry
#import "../aut.typ": mujiu
#import "../tags.typ": topics

#entry(
  title: [Types and Programming Languages：阅读与习题归纳],
  id: "tapl",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 31),
  authors: (mujiu,),
  tags: (topics.children.cs.children.tt.tag,),
)[
  正文与习题围绕同一套术语和推理方法展开：从无类型算术表达式的语法入手，借助项上的归纳理解求值规则，再走向 ML 实现。建议按章节交替阅读正文和对应解答，用习题检验定义与证明方法。

]

#embed(include "S1.typ")
#embed(include "E1.typ")
