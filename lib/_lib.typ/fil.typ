#import "./meta.typ": current, fetch-meta

#let embed(file) = context {
  let p = current.get()
  include (file)
  current.update(prev => p)
}
