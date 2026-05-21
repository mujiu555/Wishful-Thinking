// kodama-style template for Wishful-Thinking.
// Styling is applied through set/show rules on native Typst elements,
// so users write plain Typst markup — no need for CSS-class-style calls.

#import "style/theme.typ": *
#import "style/components.typ": bracketed-slug, mkheader, slug, taxon, taxon-upper
#import "meta.typ": fetch-meta

/// Apply the kodama-inspired page style via `#show: template`
#let template(doc) = {
  set page(
    paper: "a4",
    margin: 2em,
    header: context {
      let doc = fetch-meta()

      // left: back link
      let back = none
      if doc.at("parent_id", default: none) != none {
        let pos = fetch-meta(n: "indexers").at(
          doc.parent_id + ":" + doc.parent_id,
          default: none,
        )
        if pos != none {
          back = link(pos.position, text(size: 0.75em, fill: meta-color, "[back]"))
        }
      }

      // right: title · category · date
      let parts = ()
      let t = doc.at("title", default: "")
      if t != "" { parts.push(t) }
      if doc.at("category", default: none) != none {
        parts.push(text(fill: taxon-color, doc.category))
      }
      if doc.at("date", default: none) != none {
        parts.push(doc.date.display("[year]-[month]-[day]"))
      }
      let meta-content = if parts.len() > 0 {
        text(size: 0.75em, fill: meta-color, parts.join(text("  ·  ")))
      }

      if back != none and meta-content != none {
        grid(
          columns: (1fr, 4fr),
          align(left, back), align(right, meta-content),
        )
      } else if back != none {
        align(left, back)
      } else if meta-content != none {
        align(right, meta-content)
      }
    },
  )
  doc
}
