#import "/lib/typst-mode/lib/_lib.typ/lib.typ": tag

// Former categories are ordinary tags; no separate category registry.
#let registered = (tag.register)(
  "topics:root",
  "index",
  "about",
  "programming-languages",
  "computer-science",
  "computer-graphics",
  "mathematics",
  "projects",
  "writing",
  "cheatsheets",
)
#let topics = (:)
#for t in registered.slice(1) { topics.insert(t.name, t) }
