#import "@preview/tysty:0.1.0": embed, entry
#import "../aut.typ": mujiu
#import "../tags.typ": topics

#entry(
  title: [西浦课程速查归纳],
  id: "xjtlu-cheatsheets",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 31),
  authors: (mujiu,),
  tags: (topics.children.cheatsheets.tag,),
)[
  这里汇集按课程组织的复习速查。网络与图形学是并列的课程分支；CPT205 的图形学概念与 FreeGLUT API 则可对照阅读，将几何变换和投影对应到具体绘图操作。

]

#embed(include "CAN201.typ")
#embed(include "CPT205.typ")
#embed(include "CPT205-FreeGLUT.typ")
