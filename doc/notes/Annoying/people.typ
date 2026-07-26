
#import "@preview/gentle-clues:1.2.0": *

#let chat(content, nickname: none, datetime: none) = {
  let a = left
  if nickname == none {
    a = right
    nickname = "Self"
  }
  [
    #align(a, text(datetime, size: 9pt, fill: gray))
    #clue(title: align(a, nickname))[
      #align(a, content)
    ]
  ]
}

#let mujiu = link("https://github.com/mujiu555")[暮玖(mujiu555)]
#let meowyou = link("https://github.com/mujiu555")[猫柚(Meow You)]
#let youzhi = link("https://github.com/mujiu555")[温幼芷(墨染)]
#let meowqi = link("https://github.com/mujiu555")[喵柒]
