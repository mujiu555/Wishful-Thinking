#import "../lib/_lib.typ/meta.typ": meta
#meta(
  title: "Hello, World!",
  author: ("Your Name",),
  date: datetime(year: 2026, month: 6, day: 16),
  keywords: ("hello",),
  id: "hello-world",
  parent_id: "hello-world",
  description: [My first SSG page.],
  category: "general",
  tag: ("hello",),
)

= Hello, World!

Welcome to your new static site, powered by Typst and SSG.

This is a regular Typst document — headings, lists, *emphasis*, **bold**,
code blocks, and everything else you'd expect.

== Next Steps

- Edit this file or add new `.typ` files in the `content/` directory.
- Run `ssg build` to regenerate the HTML.
- Run `ssg serve` to preview locally.

Happy writing!
