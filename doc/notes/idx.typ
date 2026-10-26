#import "tags.typ": registered

#context for t in registered {
  ((t.name): (t.get-doc)())
}
