#import "@preview/tysty:0.1.0": embed, entry, render-children
#import "../aut.typ": mujiu
#import "../tags.typ": topics

#entry(
  title: [从 C 语言到理论计算机科学：系列归纳],
  id: "c-series",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 31),
  authors: (mujiu,),
  tags: (topics.children.se.children.pl.tag,),
)[
  #render-children[c]
]

#embed(include "S-1.typ")
#embed(include "S1.typ")
#embed(include "S2.typ")
