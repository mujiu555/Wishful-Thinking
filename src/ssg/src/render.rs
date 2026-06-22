use crate::config::SiteConfig;
use crate::meta::{DocumentMeta, Site};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Instant;

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Render every document in the site to HTML via `typst compile`.
///
/// Returns a vector of `(doc_id, output_html_path)` for successfully rendered
/// documents.
pub fn render_site(
    site: &Site,
    config: &SiteConfig,
    project_root: &Path,
) -> anyhow::Result<Vec<(String, PathBuf)>> {
    let source_dir = project_root.join(&config.source_dir);
    let output_dir = project_root.join(&config.output_dir);
    let ssg_dir = project_root.join(".ssg");
    let lib_dir = project_root.join(&config.lib_dir);

    // Ensure clean work directory
    if ssg_dir.exists() {
        std::fs::remove_dir_all(&ssg_dir)?;
    }
    std::fs::create_dir_all(&ssg_dir)?;

    // Write the shared preamble that registers all documents & categories
    let preamble_path = write_preamble(site, &ssg_dir, &lib_dir)?;
    log::info!("Wrote preamble to {}", preamble_path.display());

    // Generate per-document wrapper files
    let wrappers: Vec<(String, PathBuf, PathBuf)> = site
        .documents
        .iter()
        .map(|doc| {
            let wrapper_path = write_wrapper(
                doc,
                site,
                &ssg_dir,
                &preamble_path,
                &source_dir,
                &lib_dir,
            )
            .unwrap();

            let html_path =
                output_path(doc, &output_dir);

            (doc.id.clone(), wrapper_path, html_path)
        })
        .collect();

    // Create output directories
    for (_id, _wrapper, html_path) in &wrappers {
        if let Some(parent) = html_path.parent() {
            std::fs::create_dir_all(parent)?;
        }
    }

    // Compile in parallel
    let total = wrappers.len();
    let completed = AtomicUsize::new(0);
    let start = Instant::now();

    log::info!("Compiling {} document(s) to HTML…", total);

    let results: Vec<(String, PathBuf)> = wrappers
        .into_iter()
        .filter_map(|(id, wrapper, html)| {
            match compile_one(&wrapper, &html, project_root) {
                Ok(()) => {
                    let n = completed.fetch_add(1, Ordering::Relaxed) + 1;
                    log::info!("[{}/{}] {} → {}", n, total, id, html.display());
                    Some((id, html))
                }
                Err(e) => {
                    log::error!("Failed to compile '{}': {}", id, e);
                    None
                }
            }
        })
        .collect();

    let elapsed = start.elapsed();
    log::info!(
        "Compiled {}/{} document(s) in {:.1}s",
        results.len(),
        total,
        elapsed.as_secs_f64()
    );

    Ok(results)
}

// ---------------------------------------------------------------------------
// preamble generation
// ---------------------------------------------------------------------------

/// Write `.ssg/_preamble.typ` containing `#meta(…)` calls for every document
/// in the site (so cross-document navigation works).
fn write_preamble(
    site: &Site,
    ssg_dir: &Path,
    lib_dir: &Path,
) -> anyhow::Result<PathBuf> {
    let path = ssg_dir.join("_preamble.typ");
    let mut f = std::fs::File::create(&path)?;

    let lib_rel = path_rel(ssg_dir, lib_dir);

    writeln!(
        f,
        "{}",
        include_str!("templates/preamble.typ").replace("__LIB_REL__", &lib_rel),
    )?;

    // Register all categories
    for cat in site.categories.keys() {
        writeln!(f, "#register-category({:?})", cat)?;
    }
    writeln!(f)?;

    // Register all documents
    for doc in &site.documents {
        write_meta_call(&mut f, doc)?;
    }

    Ok(path)
}

/// Serialize a `DocumentMeta` as a `#meta(…)` Typst call.
fn write_meta_call(f: &mut impl Write, doc: &DocumentMeta) -> std::io::Result<()> {
    write!(f, "#meta(\n  title: {:?},\n", doc.title)?;

    // author
    match &doc.author {
        crate::meta::AuthorList::Single(s) => {
            // meta.typ asserts author is array or content, so wrap in a tuple
            writeln!(f, "  author: ({:?},),", s)?;
        }
        crate::meta::AuthorList::Multiple(v) => {
            write!(f, "  author: (")?;
            for (i, s) in v.iter().enumerate() {
                if i > 0 {
                    write!(f, ", ")?;
                }
                write!(f, "{:?}", s)?;
            }
            writeln!(f, "),")?;
        }
    }

    // date → datetime(year: Y, month: M, day: D)
    if let Ok(parsed) = chrono::NaiveDate::parse_from_str(&doc.date, "%Y-%m-%d") {
        writeln!(
            f,
            "  date: datetime(year: {}, month: {}, day: {}),",
            parsed.format("%Y"),
            parsed.format("%m").to_string().trim_start_matches('0').to_string(),
            parsed.format("%d").to_string().trim_start_matches('0').to_string(),
        )?;
    } else {
        writeln!(f, "  date: datetime(year: 2024, month: 1, day: 1),")?;
    }

    // keywords
    if !doc.keywords.is_empty() {
        write!(f, "  keywords: (")?;
        for (i, kw) in doc.keywords.iter().enumerate() {
            if i > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{:?}", kw)?;
        }
        // Trailing comma ensures Typst sees an array, not a parenthesized scalar
        writeln!(f, ",),")?;
    }

    writeln!(f, "  id: {:?},", doc.id)?;
    writeln!(f, "  parent_id: {:?},", doc.parent_id)?;

    if let Some(ref desc) = doc.description {
        // meta.typ requires description to be content, not string
        writeln!(f, "  description: [{}],", desc)?;
    }
    if let Some(ref cat) = doc.category {
        writeln!(f, "  category: {:?},", cat)?;
    }
    if !doc.tags.is_empty() {
        write!(f, "  tag: (")?;
        for (i, t) in doc.tags.iter().enumerate() {
            if i > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{:?}", t)?;
        }
        // Trailing comma ensures Typst sees an array, not a parenthesized scalar
        writeln!(f, ",),")?;
    }

    // Extra fields from tbl
    if !doc.extra.is_empty() {
        write!(f, "  tbl: (")?;
        for (i, (k, v)) in doc.extra.iter().enumerate() {
            if i > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{}: {}", k, value_to_typst(v))?;
        }
        writeln!(f, "),")?;
    }

    writeln!(f, ")\n")?;
    Ok(())
}

/// Convert a JSON value to its Typst literal representation.
fn value_to_typst(v: &serde_json::Value) -> String {
    match v {
        serde_json::Value::String(s) => format!("{:?}", s),
        serde_json::Value::Number(n) => n.to_string(),
        serde_json::Value::Bool(b) => b.to_string(),
        serde_json::Value::Null => "none".to_string(),
        serde_json::Value::Array(arr) => {
            let items: Vec<String> = arr.iter().map(value_to_typst).collect();
            format!("({})", items.join(", "))
        }
        serde_json::Value::Object(obj) => {
            let items: Vec<String> = obj
                .iter()
                .map(|(k, v)| format!("{}: {}", k, value_to_typst(v)))
                .collect();
            format!("({})", items.join(", "))
        }
    }
}

// ---------------------------------------------------------------------------
// per-document wrapper
// ---------------------------------------------------------------------------

/// Write the wrapper `.typ` file for a single document.
///
/// The wrapper imports the preamble (all docs + categories), applies the
/// template, and includes the content file.
fn write_wrapper(
    doc: &DocumentMeta,
    _site: &Site,
    ssg_dir: &Path,
    preamble_path: &Path,
    source_dir: &Path,
    lib_dir: &Path,
) -> anyhow::Result<PathBuf> {
    // Mirror the source directory structure inside .ssg/
    let rel_doc_dir = Path::new(&doc.source_path)
        .parent()
        .unwrap_or(Path::new(""));
    let wrapper_dir = ssg_dir.join(rel_doc_dir);
    std::fs::create_dir_all(&wrapper_dir)?;

    let stem = Path::new(&doc.source_path)
        .file_stem()
        .unwrap_or_default()
        .to_string_lossy();
    let wrapper_path = wrapper_dir.join(format!("{}.wrapper.typ", stem));

    let mut f = std::fs::File::create(&wrapper_path)?;

    // Compute paths relative to the wrapper's directory
    let preamble_rel = path_rel(&wrapper_dir, preamble_path);
    let lib_rel = path_rel(&wrapper_dir, lib_dir);

    let source_rel = path_rel(&wrapper_dir, &source_dir.join(&doc.source_path));
    let wrapper = include_str!("templates/wrapper.typ")
        .replace("__LIB_REL__", &lib_rel)
        .replace("__PREAMBLE_REL__", &preamble_rel)
        .replace("__SOURCE_REL__", &source_rel);
    write!(f, "{}", wrapper)?;

    Ok(wrapper_path)
}

// ---------------------------------------------------------------------------
// compilation
// ---------------------------------------------------------------------------

/// Run `typst compile` for a single wrapper file.
fn compile_one(wrapper: &Path, html_out: &Path, project_root: &Path) -> anyhow::Result<()> {
    let output = Command::new("typst")
        .arg("compile")
        .arg("--features")
        .arg("html")
        .arg("--root")
        .arg(project_root)
        .arg(wrapper)
        .arg(html_out)
        .output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("typst compile failed:\n{}", stderr);
    }

    Ok(())
}

/// Determine the output HTML path for a document, preserving the source
/// directory structure.
fn output_path(doc: &DocumentMeta, output_dir: &Path) -> PathBuf {
    let rel_path = Path::new(&doc.source_path).with_extension("html");
    output_dir.join(rel_path)
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/// Compute a relative path from `from` to `to` for use in Typst `#import` /
/// `#include` statements.  Both paths are expected to be absolute or relative
/// to the same base.
fn path_rel(from: &Path, to: &Path) -> String {
    // Canonicalize both to resolve any symlinks / .. segments
    let from = from.canonicalize().unwrap_or(from.to_path_buf());
    let to = to.canonicalize().unwrap_or(to.to_path_buf());

    // If they share a common prefix, compute a relative path.
    // Otherwise fall back to the absolute `to` path.
    let from_comps: Vec<_> = from.components().collect();
    let to_comps: Vec<_> = to.components().collect();

    // Strip common prefix
    let mut common = 0;
    while common < from_comps.len()
        && common < to_comps.len()
        && from_comps[common] == to_comps[common]
    {
        common += 1;
    }

    // Number of `..` segments to go from `from` up to the common ancestor
    let up = from_comps.len() - common;

    let mut result = std::path::PathBuf::new();
    for _ in 0..up {
        result.push("..");
    }
    for comp in &to_comps[common..] {
        result.push(comp);
    }

    // If the result is empty (same directory), return "."
    let s = result.to_string_lossy().to_string();
    if s.is_empty() {
        ".".to_string()
    } else {
        s
    }
}
