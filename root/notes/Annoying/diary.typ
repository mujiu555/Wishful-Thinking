#import "/lib/lib.typ": *

#import "@preview/gentle-clues:1.2.0": *

#show: schema.with("page")
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#title[Not actually even a diary]
#date[2025-12-21 00:25]

#let chat(content, nickname: none, datetime: none) = {
  let a = left
  if nickname == none {
    a = right
    nickname = "Self"
  }
  [
    #html.align(a, html.text(datetime, size: 9pt, fill: gray))
    #clue(title: html.align(a, nickname))[
      #html.align(a, content)
    ]
  ]
}

#let mujiu = link("https://github.com/mujiu555")[暮玖(mujiu555)]
#let meowyou = link("https://github.com/mujiu555")[猫柚(Meow You)]

= 2025-12-21 01:35: Nothing Special

Of course, this should be written in the form of mail.
Or, in my original plan, as chat history.

To difficult to design a function.

#chat(datetime: [2025-12-21 01:42])[
  With nickname, made up, date time, when it was sent, and content.
  But after all, just keep it simple.
  Not bad to calling library.
]

#chat(nickname: mujiu, datetime: [2025-12-21 02:11])[
  It works now.
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:12])[
  Finally
]

= 2025-12-21 02:13: Silent Message

#chat(datetime: [2025-12-21 02:13])[
  You know, I always alone,
  There is no one to talk to.

  They never concerning what I said,
  the things I'm caring about.

  Assembly code, Computation theory, Mathematics,
  the thing they never understand, the things they never ever care about.

  I cannot even cry,
  Nobody will give even a glance.

  Right,
  you know.
]

On my poor stupid.

#chat(datetime: [2025-12-21 02:23])[
  The reason why you feel suffering,
  is only that you are trying every effort to spare others.

  So stupid.

  What the fuck you even written?

  In fucking English.

  You desired caring.

  Long for love.
]

#chat(datetime: [2025-12-21 02:30])[
  No, never, ever, thinking about girls.
  You mother fucker stupid.

  The only thing you can archive is messing up everything.

  Weeb, ah,

  They, won't ever, even, want you to be their friend.

  Understand?
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:37])[
  甚至唯一会主动给你发消息的还是steam推广和github education通知.

  笑嘻了.
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:39])[
  大学三年连个屁都放不出来,

  还lilies, 白日做梦.

  天天就光玩你那破汇编去吧.
  饭都吃不起的家伙.

  谁理你啊
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:40])[
  人缘还差, 性格跟粑粑似的.

  照镜子都不犯恶心吗

  还计算机
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:41])[
  天天摆烂, 屁事情不干光玩有的没的去吧

  马上期末了, 等死
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:42])[
  懒到生蛆, 吃屎都赶不上热乎的
]

#chat(nickname: meowyou, datetime: [2025-12-21 02:43])[
  每天除了意淫有人喜欢你以外还能干什么.

  呵
]
