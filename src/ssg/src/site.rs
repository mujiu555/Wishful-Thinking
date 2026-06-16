use crate::config::SiteConfig;
use crate::meta::{AuthorList, DocumentMeta, Site};
use crate::parser;
use serde_json::Value;
use std::collections::HashMap;
use std::path::Path;
use walkdir::WalkDir;

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Scan the source directory, parse `#meta(…)` from every `.typ` file, and
/// assemble a `Site` model.
pub fn build_site(config: &SiteConfig, project_root: &Path) -> anyhow::Result<Site> {
    let source_dir = project_root.join(&config.source_dir);
    let lib_dir = project_root.join(&config.lib_dir);

    if !source_dir.exists() {
        anyhow::bail!(
            "Source directory '{}' does not exist.  Create it or set `site.source_dir` in ssg.toml.",
            source_dir.display()
        );
    }

    if !lib_dir.exists() {
        log::warn!(
            "Typst library '{}' not found — navigation and styling may not work.",
            lib_dir.display()
        );
    }

    let mut documents: Vec<DocumentMeta> = Vec::new();
    let mut errors: Vec<String> = Vec::new();

    for entry in WalkDir::new(&source_dir)
        .follow_links(true)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        let path = entry.path();

        // Only process .typ files
        if path.extension().and_then(|s| s.to_str()) != Some("typ") {
            continue;
        }
        if !path.is_file() {
            continue;
        }

        let rel_path = path
            .strip_prefix(&source_dir)
            .unwrap_or(path)
            .to_string_lossy()
            .to_string();

        match process_file(path, &rel_path) {
            Ok(Some(doc)) => documents.push(doc),
            Ok(None) => {
                log::debug!("Skipping {} (no #meta call)", rel_path);
            }
            Err(e) => {
                let msg = format!("{}: {}", rel_path, e);
                log::error!("{}", msg);
                errors.push(msg);
            }
        }
    }

    if documents.is_empty() {
        anyhow::bail!(
            "No documents with #meta(...) found in '{}'.  \
             Add at least one .typ file with a #meta(...) call.",
            source_dir.display()
        );
    }

    if !errors.is_empty() {
        log::warn!(
            "{} file(s) had parse errors and were skipped.",
            errors.len()
        );
    }

    // Sort: by date newest-first, then by path for determinism
    documents.sort_by(|a, b| {
        b.date
            .cmp(&a.date)
            .then_with(|| a.source_path.cmp(&b.source_path))
    });

    log::info!("Found {} document(s) in {}", documents.len(), source_dir.display());

    Ok(Site::from_documents(documents, config.share.clone()))
}

// ---------------------------------------------------------------------------
// internals
// ---------------------------------------------------------------------------

/// Read a single `.typ` file, parse its `#meta(…)` call, and return a
/// `DocumentMeta` (or `None` if the file has no meta call).
fn process_file(path: &Path, rel_path: &str) -> anyhow::Result<Option<DocumentMeta>> {
    let source = std::fs::read_to_string(path)?;
    let fields = match parser::parse_meta_call(&source) {
        Some(f) => f,
        None => return Ok(None),
    };

    let doc = fields_to_document(fields, rel_path)?;
    Ok(Some(doc))
}

/// Convert the raw parsed field map into a `DocumentMeta`.
fn fields_to_document(
    fields: HashMap<String, Value>,
    source_path: &str,
) -> anyhow::Result<DocumentMeta> {
    // Required: id
    let id = get_string(&fields, "id")?;

    // Required: title
    let title = get_string(&fields, "title").unwrap_or_default();

    // author: string or array of strings
    let author = parse_author(&fields);

    // date: datetime object → ISO string
    let date = parse_date(&fields).unwrap_or_else(|| {
        log::warn!("{}: no valid date found, using today", id);
        chrono::Local::now().format("%Y-%m-%d").to_string()
    });

    // parent_id defaults to id
    let parent_id = get_string(&fields, "parent_id").unwrap_or_else(|_| id.clone());

    // Optional fields
    let description = get_string_opt(&fields, "description");
    let category = get_string_opt(&fields, "category");
    let keywords = parse_string_array(&fields, "keywords");
    let tags = parse_string_array(&fields, "tag");

    // Extra fields from `tbl`
    let mut extra = fields
        .get("tbl")
        .and_then(|v| v.as_object())
        .map(|obj| {
            obj.iter()
                .map(|(k, v)| (k.clone(), v.clone()))
                .collect::<HashMap<String, Value>>()
        })
        .unwrap_or_default();

    // Merge any unrecognised top-level keys into extra (though by convention
    // these should be inside `tbl`).
    let known_keys = [
        "title", "author", "date", "keywords", "id", "parent_id",
        "description", "category", "tag", "abstract", "tbl",
    ];
    for (key, val) in &fields {
        if !known_keys.contains(&key.as_str()) && !extra.contains_key(key) {
            log::debug!("{}: storing unknown key '{}' in extra", id, key);
            extra.insert(key.clone(), val.clone());
        }
    }

    Ok(DocumentMeta {
        title,
        author,
        date,
        keywords,
        id,
        parent_id,
        description,
        category,
        tags,
        extra,
        source_path: source_path.to_string(),
    })
}

// ---------------------------------------------------------------------------
// field helpers
// ---------------------------------------------------------------------------

fn get_string(fields: &HashMap<String, Value>, key: &str) -> Result<String, anyhow::Error> {
    fields
        .get(key)
        .and_then(|v| v.as_str())
        .map(|s| s.to_string())
        .ok_or_else(|| anyhow::anyhow!("Missing or invalid field '{}' in #meta(...)", key))
}

fn get_string_opt(fields: &HashMap<String, Value>, key: &str) -> Option<String> {
    fields
        .get(key)
        .and_then(|v| {
            if v.is_null() {
                None
            } else if let Some(s) = v.as_str() {
                Some(s.to_string())
            } else {
                Some(v.to_string())
            }
        })
}

fn parse_author(fields: &HashMap<String, Value>) -> AuthorList {
    match fields.get("author") {
        Some(Value::String(s)) => AuthorList::Single(s.clone()),
        Some(Value::Array(arr)) => {
            let names: Vec<String> = arr
                .iter()
                .filter_map(|v| v.as_str().map(|s| s.to_string()))
                .collect();
            if names.is_empty() {
                AuthorList::Single(String::new())
            } else if names.len() == 1 {
                AuthorList::Single(names.into_iter().next().unwrap())
            } else {
                AuthorList::Multiple(names)
            }
        }
        _ => AuthorList::Single(String::new()),
    }
}

fn parse_date(fields: &HashMap<String, Value>) -> Option<String> {
    let date_val = fields.get("date")?;
    match date_val {
        Value::Object(obj) => {
            let year = obj.get("year")?.as_i64()?;
            let month = obj.get("month")?.as_i64()?;
            let day = obj.get("day")?.as_i64()?;
            Some(format!("{:04}-{:02}-{:02}", year, month, day))
        }
        Value::String(s) => Some(s.clone()),
        _ => None,
    }
}

fn parse_string_array(fields: &HashMap<String, Value>, key: &str) -> Vec<String> {
    match fields.get(key) {
        Some(Value::String(s)) => vec![s.clone()],
        Some(Value::Array(arr)) => arr
            .iter()
            .filter_map(|v| v.as_str().map(|s| s.to_string()))
            .collect(),
        _ => Vec::new(),
    }
}
