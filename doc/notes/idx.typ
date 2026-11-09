#import "tags.typ": topics
#import "aut.typ": mujiu
#import "@preview/tysty:0.1.0": entry, render-tags

#entry(
  title: [Index],
  id: "idx",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 29, hour: 3, minute: 46, second: 0),
  authors: (mujiu,),
  tags: (topics.children.index.tag,),
)[
  #render-tags(topics)
]
