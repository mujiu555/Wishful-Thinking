use serde::{Deserialize, Serialize};
use std::path::Path;

/// Top-level SSG configuration, read from `ssg.toml`.
#[derive(Debug, Default, Deserialize)]
pub struct SsgConfig {
    #[serde(default)]
    pub site: SiteConfig,
}

/// Per-site settings — source layout, output target, library paths.
#[derive(Debug, Deserialize)]
pub struct SiteConfig {
    /// Site title used in `<title>` and index pages.
    #[serde(default = "default_title")]
    pub title: String,

    /// Base URL for absolute links (e.g. `https://example.com`).
    #[serde(default)]
    pub base_url: Option<String>,

    /// Directory containing Typst source files.
    #[serde(default = "default_source_dir")]
    pub source_dir: String,

    /// Directory where generated HTML is written.
    #[serde(default = "default_output_dir")]
    pub output_dir: String,

    /// Path to the `_lib.typ` Typst library.
    #[serde(default = "default_lib_dir")]
    pub lib_dir: String,

    /// Global share settings (mirrors `meta/share.typ`).
    #[serde(default)]
    pub share: ShareConfig,
}

/// Global toggles shared across all pages (sider, toc, etc.).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShareConfig {
    #[serde(default)]
    pub sider: bool,
    #[serde(default = "default_true")]
    pub toc: bool,
}

// ---------------------------------------------------------------------------
// defaults
// ---------------------------------------------------------------------------

fn default_title() -> String {
    "Untitled Site".into()
}

fn default_source_dir() -> String {
    "content".into()
}

fn default_output_dir() -> String {
    "public".into()
}

fn default_lib_dir() -> String {
    "lib/_lib.typ".into()
}

fn default_true() -> bool {
    true
}

// ---------------------------------------------------------------------------
// impls
// ---------------------------------------------------------------------------

impl Default for SiteConfig {
    fn default() -> Self {
        SiteConfig {
            title: default_title(),
            base_url: None,
            source_dir: default_source_dir(),
            output_dir: default_output_dir(),
            lib_dir: default_lib_dir(),
            share: ShareConfig::default(),
        }
    }
}

impl Default for ShareConfig {
    fn default() -> Self {
        ShareConfig {
            sider: false,
            toc: true,
        }
    }
}

impl SsgConfig {
    /// Load configuration from `ssg.toml` in the project root.
    /// Returns default config if the file doesn't exist.
    pub fn load(root: &Path) -> anyhow::Result<Self> {
        let config_path = root.join("ssg.toml");
        if config_path.exists() {
            let content = std::fs::read_to_string(&config_path)?;
            Ok(toml::from_str(&content)?)
        } else {
            log::warn!("No ssg.toml found in {}, using defaults", root.display());
            Ok(SsgConfig {
                site: SiteConfig::default(),
            })
        }
    }
}
