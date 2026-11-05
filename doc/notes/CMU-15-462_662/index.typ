#import "@preview/tysty:0.1.0": embed, entry, render-children
#import "../aut.typ": mujiu
#import "../tags.typ": topics

#entry(
  title: [CMU 15-462/662：计算机图形学归纳],
  id: "cmu-15462",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 31),
  authors: (mujiu,),
  tags: (topics.children.se.children.graphic.tag,),
)[
]

#embed(include "S1.typ")
#embed(include "S2.typ")
#embed(include "S3.typ")
#embed(include "S4.typ")
#embed(include "S5.typ")
