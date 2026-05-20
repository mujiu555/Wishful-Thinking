/// - references (dict[str, dict]):
///   - key (str): reference name
///   - value (dict):
///     - label (label): the target label
///
/// Records user-declared label positions for index page generation.
/// Does NOT replace built-in citation — use Typst's citation for
/// bibliographic references.
#let references = state("references", (:))

/// Register a reference (label position) for index generation.
/// - name (str): reference identifier
/// - label (label): the label to record
/// -> none
#let register-reference(name, label) = {
  references.update(prev => (..prev, (name): (label: label)))
}

/// Create a Typst built-in label and auto-register it in the metadata index.
/// Use this in place of raw `<name>` / `#label("name")` when the
/// label should also appear in generated index pages.
/// - name (str): label identifier
/// -> content
#let mklabel(name) = {
  let lbl = label(name)
  register-reference(name, lbl)
  lbl
}
