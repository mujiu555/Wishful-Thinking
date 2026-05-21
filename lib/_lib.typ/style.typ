// kodama-style template for Wishful-Thinking.
// Styling is applied through set/show rules on native Typst elements,
// so users write plain Typst markup — no need for CSS-class-style calls.

#import "style/theme.typ": *
#import "style/components.typ": bracketed-slug, mkheader, slug, taxon, taxon-upper

/// Apply the kodama-inspired page style via `#show: template`
#let template(doc) = {
  // - page
  set page(paper: "iso-b6", margin: 2em)

  // - base text
  set text(font: text-font, size: base-font-size, fill: text-color)
  set par(justify: true, leading: p-line-height)

  // - headings (h1 gets accent left bar)
  let heading-sizes = (1.4em, 1.2em, 1.1em, 1.0em)
  show heading: it => {
    let sz = heading-sizes.at(it.level - 1, default: 0.9em)
    if it.level == 1 {
      block(
        stroke: (left: (thickness: 3pt, paint: accent-color)),
        inset: (left: 0.5em),
        above: 1.2em,
        below: 0.3em,
        text(weight: heading-font-weight, size: 1.3em, fill: heading-color, it),
      )
    } else {
      set text(weight: heading-font-weight, size: sz, fill: heading-color)
      set block(above: 1em, below: 0.3em)
      it
    }
  }

  // - code / raw
  show raw.where(block: true): it => block(
    fill: code-bg,
    radius: block-radius,
    inset: 0.5em,
    above: 0.5em,
    below: 1em,
    it,
  )
  show raw.where(block: false): it => box(fill: code-bg, radius: block-radius, inset: (x: 3pt, y: 1pt), it)

  // - link (dotted underline; underline doesn't create a new link, so no recursion)
  show link: it => underline(stroke: dotted-stroke, it)

  // - horizontal rule
  show line: set line(stroke: hr-stroke)

  // - blockquote: left bar + italic
  show quote: it => {
    set text(fill: quote-text-color, style: "italic")
    block(
      fill: luma(250),
      stroke: (left: (thickness: 3pt, paint: quote-bar-color)),
      radius: blockquote-radius,
      inset: (x: 1em, y: 0.6em),
      above: 0.5em,
      below: 0.5em,
      it,
    )
  }

  // - table
  show table: it => {
    set table(stroke: 0.5pt + table-border-color, fill: (none, table-alt-row-bg))
    set text(size: 0.95em)
    it
  }
  show table.header: set text(weight: 600)

  // - figure / caption
  show figure: it => block(above: 0.8em, below: 0.8em, it)
  show figure.caption: set text(size: 0.85em, fill: meta-color)

  // - math display
  show math.equation.where(block: true): set align(center)

  // - lists
  show list: set block(above: 0.3em, below: 0.3em)
  show enum: set block(above: 0.3em, below: 0.3em)

  doc
}
