#import "@local/tysty:0.1.0": tag

// Former categories are ordinary tags; no separate category registry.
#let topics = (tag.register)(
  "topics:root",
  (
    index: (:),
    about: (:),
    cs: (
      plt: (:),
      tt: (:),
      formal-method: (:),
    ),
    mathematics: (
      category-t: (:),
      computation-t: (:),
      discrete-m: (:),
    ),
    se: (
      graphic: (:),
      security: (:),
      pl: (:),
      os: (:),
    ),
    writing: (:),
    cheatsheets: (:),
  ),
)
