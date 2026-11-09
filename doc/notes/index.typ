#import "@preview/tysty:0.1.0": backlinks, embed, entry, lookup, mkcover, mkoutline, num, set-base, template
#import "tags.typ": topics
#import "aut.typ": mujiu
#show: template

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

#set-base("file:///home/dot/prj/proj.txt/Wishful-Thinking/doc/notes/")

#entry(
  cover: true,
  title: [GitHub\@Mujiu555's page],
  id: "index",
  file-path: "index.typ",
  date: datetime(year: 2025, month: 12, day: 14, hour: 23, minute: 46, second: 0),
  authors: (mujiu,),
  tags: (topics.children.index.tag,),
)[
  #mkoutline()
]

#embed(include "/doc/notes/about.typ")

#embed(include "/doc/notes/Assembly/S1.typ")
#embed(include "/doc/notes/Category/S1.typ")
#embed(include "/doc/notes/CIS194/S1.typ")
#embed(include "/doc/notes/CIS5520/index.typ")
#embed(include "/doc/notes/CMU-15-462_662/index.typ")
#embed(include "/doc/notes/CraftingInterpreters/S1.typ")
#embed(include "/doc/notes/FreeGLUT/index.typ")
#embed(include "/doc/notes/HowToSpeak/S1.typ")
#embed(include "/doc/notes/Missing-Semester/S1.typ")
#embed(include "/doc/notes/MIT-18_404j/S1.typ")
#embed(include "/doc/notes/MIT-6_042j/S1.typ")
#embed(include "/doc/notes/SICP/S1.typ")
#embed(include "/doc/notes/Stanford-CS107/S1.typ")
#embed(include "/doc/notes/TaPL/index.typ")
#embed(include "/doc/notes/c/index.typ")
#embed(include "/doc/notes/Universe/index.typ")
#embed(include "/doc/notes/xjtlu-cheatsheet/index.typ")

#embed(include "/doc/notes/idx.typ")
