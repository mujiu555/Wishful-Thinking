#import "@preview/tysty:0.1.0": embed, entry, render-children
#import "../aut.typ": mujiu

#entry(
  title: [D-Flat System Main Description],
  date: datetime(year: 2025, month: 12, day: 14, hour: 23, minute: 46, second: 0),
  authors: (mujiu,),
  id: "universe-index",
  parent-id: "index",
)[
  #render-children[Index]
]

#embed(include "LiliumCandidum.typ")
#embed(include "ArgyranthemumFrutescens.typ")
#embed(include "IrisGermanica.typ")
#embed(include "LycorisRadiata.typ")
#embed(include "MyosotisSylvatica.typ")
#embed(include "Lambda.typ")
#embed(include "Lexer.typ")
#embed(include "Compiler.typ")
#embed(include "StandardLibrary.typ")
#embed(include "Editor&IDE.typ")
