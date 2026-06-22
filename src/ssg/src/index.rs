use crate::config::SiteConfig;
use crate::meta::Site;
use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Generate all index/listing HTML pages: home page, category pages, tag pages.
///
/// `rendered` is the set of HTML paths already produced by typst rendering;
/// the indexer will not overwrite any of those files.
pub fn generate_index_pages(
    site: &Site,
    config: &SiteConfig,
    project_root: &Path,
    rendered: &HashSet<PathBuf>,
) -> anyhow::Result<()> {
    let output_dir = project_root.join(&config.output_dir);
    fs::create_dir_all(&output_dir)?;

    // Home page — list of all documents.  If a rendered document already
    // occupies index.html (e.g. `content/index.typ`) we merge its body
    // content into the shell so that navigation, tags, and the document
    // listing all appear on the same page.
    let home_path = output_dir.join("index.html");
    if rendered.contains(&home_path) {
        // Read the typst-rendered body content
        let raw = fs::read_to_string(&home_path)?;
        let body_content = extract_body(&raw).unwrap_or_else(|| raw.clone());

        let mut docs_html = String::new();
        for doc in &site.documents {
            docs_html.push_str(&doc_list_item(doc, false));
        }

        let merged = page_shell(
            config,
            &config.title,
            &format!(
                r#"{}
<hr>
<p class="count">{} document(s)</p>
<ul class="doc-list">
{}
</ul>"#,
                body_content,
                site.documents.len(),
                docs_html,
            ),
        );
        fs::write(&home_path, merged)?;
        log::info!("Merged document + listing → {}", home_path.display());
    } else {
        let home_html = build_home_page(site, config);
        fs::write(&home_path, home_html)?;
        log::info!("Wrote {}", home_path.display());
    }

    // Category pages
    if !site.categories.is_empty() {
        let cat_dir = output_dir.join("category");
        fs::create_dir_all(&cat_dir)?;

        // Category index
        let cat_index = build_category_index(site, config);
        fs::write(cat_dir.join("index.html"), cat_index)?;

        // Per-category pages
        for (cat_id, cat) in &site.categories {
            let html = build_category_page(site, config, cat_id, &cat.documents);
            fs::write(cat_dir.join(format!("{}.html", slugify(cat_id))), html)?;
        }
        log::info!("Wrote {} category page(s)", site.categories.len());
    }

    // Tag pages
    if !site.tags.is_empty() {
        let tag_dir = output_dir.join("tag");
        fs::create_dir_all(&tag_dir)?;

        // Tag cloud index
        let tag_index = build_tag_index(site, config);
        fs::write(tag_dir.join("index.html"), tag_index)?;

        // Per-tag pages
        for (tag_name, doc_ids) in &site.tags {
            let html = build_tag_page(site, config, tag_name, doc_ids);
            fs::write(tag_dir.join(format!("{}.html", slugify(tag_name))), html)?;
        }
        log::info!("Wrote {} tag page(s)", site.tags.len());
    }

    Ok(())
}

// ---------------------------------------------------------------------------
// HTML builders
// ---------------------------------------------------------------------------

fn build_home_page(site: &Site, config: &SiteConfig) -> String {
    let mut docs_html = String::new();
    for doc in &site.documents {
        docs_html.push_str(&doc_list_item(doc, false));
    }

    page_shell(
        config,
        &config.title,
        &format!(
            r#"<h1>{}</h1>
<p class="count">{} document(s)</p>
<ul class="doc-list">
{}
</ul>"#,
            escape(&config.title),
            site.documents.len(),
            docs_html,
        ),
    )
}

fn build_category_index(site: &Site, config: &SiteConfig) -> String {
    let mut items = String::new();
    let mut cats: Vec<_> = site.categories.keys().collect();
    cats.sort();

    for cat_id in cats {
        let cat = &site.categories[cat_id];
        let count = cat.documents.len();
        items.push_str(&format!(
            r#"<li><a href="{}.html">{} ({})</a></li>
"#,
            slugify(cat_id),
            escape(cat_id),
            count,
        ));
    }

    page_shell(
        config,
        &format!("Categories — {}", config.title),
        &format!(
            r#"<h1>Categories</h1>
<ul class="cat-list">
{}
</ul>"#,
            items,
        ),
    )
}

fn build_category_page(
    site: &Site,
    config: &SiteConfig,
    cat_id: &str,
    doc_ids: &[String],
) -> String {
    let mut items = String::new();
    for doc_id in doc_ids {
        if let Some(doc) = site.get(doc_id) {
            items.push_str(&doc_list_item(doc, true));
        }
    }

    page_shell(
        config,
        &format!("{} — {}", cat_id, config.title),
        &format!(
            r#"<h1>Category: {}</h1>
<p class="count">{} document(s)</p>
<ul class="doc-list">
{}
</ul>
<p><a href="index.html">← All categories</a></p>"#,
            escape(cat_id),
            doc_ids.len(),
            items,
        ),
    )
}

fn build_tag_index(site: &Site, config: &SiteConfig) -> String {
    let mut items = String::new();
    let mut tags: Vec<_> = site.tags.keys().collect();
    tags.sort();

    for tag in tags {
        let count = site.tags[tag].len();
        items.push_str(&format!(
            r#"<li><a href="{}.html">{} ({})</a></li>
"#,
            slugify(tag),
            escape(tag),
            count,
        ));
    }

    page_shell(
        config,
        &format!("Tags — {}", config.title),
        &format!(
            r#"<h1>Tags</h1>
<ul class="tag-list">
{}
</ul>"#,
            items,
        ),
    )
}

fn build_tag_page(
    site: &Site,
    config: &SiteConfig,
    tag_name: &str,
    doc_ids: &[String],
) -> String {
    let mut items = String::new();
    for doc_id in doc_ids {
        if let Some(doc) = site.get(doc_id) {
            items.push_str(&doc_list_item(doc, true));
        }
    }

    page_shell(
        config,
        &format!("#{} — {}", tag_name, config.title),
        &format!(
            r#"<h1>Tag: #{}</h1>
<p class="count">{} document(s)</p>
<ul class="doc-list">
{}
</ul>
<p><a href="index.html">← All tags</a></p>"#,
            escape(tag_name),
            doc_ids.len(),
            items,
        ),
    )
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/// The outer HTML shell common to every listing page.
fn page_shell(_config: &SiteConfig, title: &str, body: &str) -> String {
    include_str!("templates/page_shell.html")
        .replace("__TITLE__", &escape(title))
        .replace("__BODY__", body)
}

/// Link to a document's HTML page relative to the site root.
fn doc_link(doc: &crate::meta::DocumentMeta) -> String {
    let rel = Path::new(&doc.source_path).with_extension("html");
    format!("/{}", rel.to_string_lossy())
}

/// Link to a document from a page that is `levels` directories deep.
fn doc_link_up(doc: &crate::meta::DocumentMeta, levels: usize) -> String {
    let rel = Path::new(&doc.source_path).with_extension("html");
    let prefix = "../".repeat(levels);
    format!("{}{}", prefix, rel.to_string_lossy())
}

/// Extract the inner HTML between `<body>` and `</body>` tags.
///
/// Returns `None` if the body tags aren't found.
fn extract_body(html: &str) -> Option<String> {
    let start_marker = "<body>";
    let end_marker = "</body>";
    let start = html.find(start_marker)? + start_marker.len();
    let end = html.find(end_marker)?;
    Some(html[start..end].to_string())
}

/// Build a single `<li>` entry for a document listing.
fn doc_list_item(doc: &crate::meta::DocumentMeta, up_one: bool) -> String {
    let link = if up_one {
        doc_link_up(doc, 1)
    } else {
        doc_link(doc)
    };
    let date = &doc.date;
    let author = doc.author.display();
    let cat_badge = doc
        .category
        .as_ref()
        .map(|c| format!(" <span class=\"category\">{}</span>", escape(c)))
        .unwrap_or_default();

    let tags_html = if doc.tags.is_empty() {
        String::new()
    } else {
        let tags: Vec<String> = doc
            .tags
            .iter()
            .map(|t| {
                format!(
                    " <a href=\"tag/{}.html\" class=\"tag\">{}</a>",
                    slugify(t),
                    escape(t)
                )
            })
            .collect();
        format!(" <span class=\"tags\">{}</span>", tags.join(""))
    };

    format!(
        r#"<li>
  <a href="{}">{}</a>{}
  <span class="meta">{} — {}{}</span>
</li>
"#,
        link,
        escape(&doc.title),
        cat_badge,
        date,
        escape(&author),
        tags_html,
    )
}

/// Minimal HTML escaping.
fn escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

/// Slugify a string for use in a filename.
fn slugify(s: &str) -> String {
    s.to_lowercase()
        .chars()
        .map(|c| {
            if c.is_alphanumeric() || c == '-' {
                c
            } else {
                '-'
            }
        })
        .collect::<String>()
        .trim_matches('-')
        .to_string()
}
