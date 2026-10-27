#import "/lib/typst-mode/lib/_lib.typ/lib.typ": embed, meta, mkcover, mkheading, template
#show: template
#import "tags.typ": topics
#import "aut.typ": mujiu

#show raw: set text(
  font: "Maple Mono NF",
  size: 9pt,
)

#set text(
  lang: "zh",
  region: "cn",
  size: 10.5pt,
  font: (
    (name: "Libertinus Serif", covers: "latin-in-cjk"),
    "Source Han Serif SC",
  ),
)

#meta(
  title: [GitHub\@Mujiu555's page],
  id: "index",
  date: datetime(year: 2025, month: 12, day: 14, hour: 23, minute: 46, second: 0),
  authors: (mujiu,),
  tags: (topics.children.index.tag,),
)

#mkcover()

#embed(include "/doc/notes/about.typ")
#embed(include "/doc/notes/contents.typ")

#embed(include "/doc/notes/Assembly/S1.typ")
#embed(include "/doc/notes/Category/S1.typ")
#embed(include "/doc/notes/CIS194/S1.typ")
#embed(include "/doc/notes/CIS5520/index.typ")
#embed(include "/doc/notes/CMU-15-462_662/S1.typ")
#embed(include "/doc/notes/CMU-15-462_662/S2.typ")
#embed(include "/doc/notes/CMU-15-462_662/S3.typ")
#embed(include "/doc/notes/CMU-15-462_662/S4.typ")
#embed(include "/doc/notes/CMU-15-462_662/S5.typ")
#embed(include "/doc/notes/CraftingInterpreters/S1.typ")
#embed(include "/doc/notes/FreeGLUT/S0.typ")
#embed(include "/doc/notes/FreeGLUT/S1.typ")
#embed(include "/doc/notes/HowToSpeak/S1.typ")
#embed(include "/doc/notes/Missing-Semester/S1.typ")
#embed(include "/doc/notes/MIT-18_404j/S1.typ")
#embed(include "/doc/notes/MIT-6_042j/S1.typ")
#embed(include "/doc/notes/SICP/S1.typ")
#embed(include "/doc/notes/Stanford-CS107/S1.typ")
#embed(include "/doc/notes/TaPL/E1.typ")
#embed(include "/doc/notes/TaPL/S1.typ")
#embed(include "/doc/notes/c/S-1.typ")
#embed(include "/doc/notes/c/S1.typ")
#embed(include "/doc/notes/c/S2.typ")
#embed(include "/doc/notes/Universe/Compiler.typ")
#embed(include "/doc/notes/Universe/D_Flat.typ")
#embed(include "/doc/notes/Universe/Editor&IDE.typ")
#embed(include "/doc/notes/Universe/Lambda.typ")
#embed(include "/doc/notes/Universe/Lexer.typ")
#embed(include "/doc/notes/Universe/LiliumCandidum.typ")
#embed(include "/doc/notes/Universe/Margarita.typ")
#embed(include "/doc/notes/Universe/StandardLibrary.typ")
#embed(include "/doc/notes/itles/S1.typ")
#embed(include "/doc/notes/xjtlu-cheatsheet/CAN201.typ")
#embed(include "/doc/notes/xjtlu-cheatsheet/CPT205-FreeGLUT.typ")
#embed(include "/doc/notes/xjtlu-cheatsheet/CPT205.typ")

#embed(include "/doc/notes/idx.typ")
