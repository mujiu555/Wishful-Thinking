use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

/// Metadata for a single document, parsed from a `#meta(…)` call in a Typst
/// source file.  Mirrors the `meta()` function in `lib/_lib.typ/meta.typ`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DocumentMeta {
    pub title: String,
    pub author: AuthorList,
    pub date: String,
    #[serde(default)]
    pub keywords: Vec<String>,
    pub id: String,
    pub parent_id: String,
    #[serde(default)]
    pub description: Option<String>,
    #[serde(default)]
    pub category: Option<String>,
    #[serde(default)]
    pub tags: Vec<String>,
    /// Extra key-value pairs from the `tbl` argument (spread into the doc).
    #[serde(default)]
    pub extra: HashMap<String, serde_json::Value>,

    // Internal bookkeeping — not serialised
    /// Relative path from the source directory to the `.typ` file.
    #[serde(skip)]
    pub source_path: String,
}

/// Typst `author` can be a single string or an array of strings.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum AuthorList {
    Single(String),
    Multiple(Vec<String>),
}

impl AuthorList {
    /// Flatten to a `Vec<String>` regardless of representation.
    pub fn to_vec(&self) -> Vec<&str> {
        match self {
            AuthorList::Single(s) => vec![s.as_str()],
            AuthorList::Multiple(v) => v.iter().map(|s| s.as_str()).collect(),
        }
    }

    /// Return a comma-separated string for display.
    pub fn display(&self) -> String {
        self.to_vec().join(", ")
    }

    /// Is the author list empty?
    pub fn is_empty(&self) -> bool {
        match self {
            AuthorList::Single(s) => s.is_empty(),
            AuthorList::Multiple(v) => v.is_empty(),
        }
    }
}

// ---------------------------------------------------------------------------
// Category
// ---------------------------------------------------------------------------

/// A category node in the hierarchy.  Mirrors `meta/categories.typ`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Category {
    pub id: String,
    /// Parent category id — same as `id` for root categories.
    pub parent: String,
    /// Document ids belonging to this category (in order of discovery).
    pub documents: Vec<String>,
}

// ---------------------------------------------------------------------------
// IndexEntry
// ---------------------------------------------------------------------------

/// A cross-reference index entry.  Mirrors `meta/indexer.typ`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IndexEntry {
    /// Display content for the reference.
    pub content: String,
    /// URL / fragment the entry points to.
    pub position: String,
    /// Any extra attributes stored with the entry.
    #[serde(default)]
    pub extra: HashMap<String, serde_json::Value>,
}

// ---------------------------------------------------------------------------
// Site
// ---------------------------------------------------------------------------

/// The complete site model built from all source files.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Site {
    /// All documents, in discovery order.
    pub documents: Vec<DocumentMeta>,

    /// Category id → category definition.
    #[serde(default)]
    pub categories: HashMap<String, Category>,

    /// Tag name → list of document ids.
    #[serde(default)]
    pub tags: HashMap<String, Vec<String>>,

    /// Global share settings.
    #[serde(default)]
    pub share: crate::config::ShareConfig,

    /// Document id → DocumentMeta lookup (built at construction time).
    #[serde(skip)]
    pub doc_map: HashMap<String, DocumentMeta>,

    /// Document id → IndexEntry map (populated post-render).
    #[serde(skip, default)]
    pub indexers: HashMap<String, IndexEntry>,
}

impl Site {
    /// Build a `Site` from a flat list of documents.
    pub fn from_documents(
        documents: Vec<DocumentMeta>,
        share: crate::config::ShareConfig,
    ) -> Self {
        let mut doc_map: HashMap<String, DocumentMeta> = HashMap::new();
        let mut categories: HashMap<String, Category> = HashMap::new();
        let mut tags: HashMap<String, Vec<String>> = HashMap::new();

        for doc in &documents {
            doc_map.insert(doc.id.clone(), doc.clone());

            // Category membership
            if let Some(ref cat) = doc.category {
                let entry = categories
                    .entry(cat.clone())
                    .or_insert_with(|| Category {
                        id: cat.clone(),
                        parent: cat.clone(),
                        documents: Vec::new(),
                    });
                entry.documents.push(doc.id.clone());
            }

            // Tag membership
            for tag in &doc.tags {
                tags.entry(tag.clone())
                    .or_default()
                    .push(doc.id.clone());
            }
        }

        Site {
            documents,
            categories,
            tags,
            share,
            doc_map,
            indexers: HashMap::new(),
        }
    }

    /// Look up a document by id.
    pub fn get(&self, id: &str) -> Option<&DocumentMeta> {
        self.doc_map.get(id)
    }

    /// Return the previous and next document relative to `id` in the
    /// overall document order (matching the Typst template's nav logic).
    pub fn prev_next(&self, id: &str) -> (Option<&DocumentMeta>, Option<&DocumentMeta>) {
        let mut prev = None;
        let mut found = false;
        for doc in &self.documents {
            if doc.id == id {
                found = true;
            } else if found {
                return (prev, Some(doc));
            } else {
                prev = Some(doc);
            }
        }
        if found {
            (prev, None)
        } else {
            (None, None)
        }
    }

    /// Return the parent document (if parent_id differs from id).
    pub fn parent(&self, id: &str) -> Option<&DocumentMeta> {
        let doc = self.get(id)?;
        if doc.parent_id != doc.id {
            self.get(&doc.parent_id)
        } else {
            None
        }
    }
}
