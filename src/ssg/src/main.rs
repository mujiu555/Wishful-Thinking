mod config;
mod index;
mod meta;
mod parser;
mod render;
mod site;

use clap::{Parser, Subcommand};
use std::path::PathBuf;

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

/// Static site generator using Typst as markup language.
#[derive(Parser)]
#[command(name = "ssg", version, about)]
struct Cli {
    /// Project root directory (default: current directory)
    #[arg(short, long, default_value = ".")]
    root: PathBuf,

    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Build the site — parse, compile, and generate HTML
    Build,
    /// Create a new SSG project skeleton
    Init {
        /// Project name / directory
        name: Option<String>,
    },
    /// Remove the output directory and .ssg temp files
    Clean,
    /// Serve the output directory with a local HTTP server
    Serve {
        /// Port to listen on (default: 8080)
        #[arg(short, long, default_value = "8080")]
        port: u16,
    },
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

fn main() -> anyhow::Result<()> {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .format_timestamp_secs()
        .init();

    let cli = Cli::parse();
    let root = cli.root.canonicalize().unwrap_or(cli.root);

    match cli.command {
        Command::Build => cmd_build(&root),
        Command::Init { name } => cmd_init(&root, name.as_deref()),
        Command::Clean => cmd_clean(&root),
        Command::Serve { port } => cmd_serve(&root, port),
    }
}

// ---------------------------------------------------------------------------
// subcommands
// ---------------------------------------------------------------------------

fn cmd_build(root: &PathBuf) -> anyhow::Result<()> {
    log::info!("Building site in {}", root.display());

    let cfg = config::SsgConfig::load(root)?;

    // 1. Discover + parse all source files → Site model
    let site = site::build_site(&cfg.site, root)?;

    // 2. Render each document to HTML via typst compile
    let rendered = render::render_site(&site, &cfg.site, root)?;

    // Collect rendered output paths so the indexer doesn't overwrite them
    let rendered_paths: std::collections::HashSet<std::path::PathBuf> =
        rendered.iter().map(|(_, p)| p.clone()).collect();

    // 3. Generate index / category / tag listing pages
    index::generate_index_pages(&site, &cfg.site, root, &rendered_paths)?;

    // 4. Write site metadata as JSON (useful for debugging / external tools)
    let meta_json = serde_json::to_string_pretty(&site)?;
    let output_dir = root.join(&cfg.site.output_dir);
    std::fs::write(output_dir.join("site.json"), meta_json)?;

    log::info!(
        "Build complete — site is in {}",
        output_dir.display()
    );
    Ok(())
}

fn cmd_init(root: &PathBuf, name: Option<&str>) -> anyhow::Result<()> {
    let proj_dir = match name {
        Some(n) => root.join(n),
        None => root.clone(),
    };

    if proj_dir.exists() && proj_dir.read_dir()?.next().is_some() {
        anyhow::bail!(
            "'{}' already exists and is not empty.  Choose a different name.",
            proj_dir.display()
        );
    }

    std::fs::create_dir_all(&proj_dir)?;

    // ssg.toml
    std::fs::write(
        proj_dir.join("ssg.toml"),
        include_str!("templates/scaffold_ssg.toml"),
    )?;

    // Content directory with a sample document
    let content_dir = proj_dir.join("content");
    std::fs::create_dir_all(&content_dir)?;
    std::fs::write(
        content_dir.join("index.typ"),
        include_str!("templates/scaffold_index.typ"),
    )?;

    // Create category registration file
    let lib_dir = proj_dir.join("lib").join("_lib.typ");
    std::fs::create_dir_all(&lib_dir)?;

    // .gitignore
    std::fs::write(
        proj_dir.join(".gitignore"),
        include_str!("templates/scaffold_gitignore"),
    )?;

    log::info!(
        "Initialised new SSG project in '{}'",
        proj_dir.display()
    );
    log::info!("Next steps:");
    log::info!("  1. Link or copy the _lib.typ library into lib/");
    log::info!("  2. Run `ssg build` to generate the site");
    log::info!("  3. Run `ssg serve` to preview at http://localhost:8080");

    Ok(())
}

fn cmd_clean(root: &PathBuf) -> anyhow::Result<()> {
    let cfg = config::SsgConfig::load(root).unwrap_or_default();
    let output_dir = root.join(&cfg.site.output_dir);
    let ssg_dir = root.join(".ssg");

    for dir in &[&output_dir, &ssg_dir] {
        if dir.exists() {
            std::fs::remove_dir_all(dir)?;
            log::info!("Removed {}", dir.display());
        }
    }

    log::info!("Clean complete.");
    Ok(())
}

fn cmd_serve(root: &PathBuf, port: u16) -> anyhow::Result<()> {
    let cfg = config::SsgConfig::load(root)?;
    let output_dir = root.join(&cfg.site.output_dir);

    if !output_dir.exists() {
        log::warn!(
            "Output directory '{}' doesn't exist yet.  Run `ssg build` first.",
            output_dir.display()
        );
        std::fs::create_dir_all(&output_dir)?;
    }

    let serve_dir = output_dir.canonicalize()?;

    let addr = format!("0.0.0.0:{}", port);
    let server = tiny_http::Server::http(&addr)
        .map_err(|e| anyhow::anyhow!("Failed to start server on {}: {}", addr, e))?;

    log::info!(
        "Serving '{}' at http://localhost:{}",
        serve_dir.display(),
        port
    );
    log::info!("Press Ctrl+C to stop.");

    for request in server.incoming_requests() {
        let url_path = request.url().trim_start_matches('/');
        let path = if url_path.is_empty() {
            serve_dir.join("index.html")
        } else {
            let p = serve_dir.join(url_path);
            if p.is_dir() {
                p.join("index.html")
            } else {
                p
            }
        };

        match std::fs::read(&path) {
            Ok(data) => {
                let mime = mime_guess(&path);
                let ctype = format!("{}; charset=utf-8", mime);
                let header = tiny_http::Header::from_bytes(
                    "Content-Type".as_bytes(),
                    ctype.as_bytes(),
                )
                .unwrap_or_else(|_| {
                    tiny_http::Header::from_bytes(
                        "Content-Type".as_bytes(),
                        "application/octet-stream".as_bytes(),
                    )
                    .unwrap()
                });
                let response = tiny_http::Response::from_data(data).with_header(header);
                let _ = request.respond(response);
            }
            Err(_) => {
                let body = include_str!("templates/404.html")
                    .replace("__URL_PATH__", &escape_html(url_path));
                let header = tiny_http::Header::from_bytes(
                    "Content-Type".as_bytes(),
                    "text/html; charset=utf-8".as_bytes(),
                )
                .unwrap();
                let response = tiny_http::Response::from_string(body)
                    .with_status_code(404)
                    .with_header(header);
                let _ = request.respond(response);
            }
        }
    }

    Ok(())
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

fn mime_guess(path: &std::path::Path) -> String {
    match path.extension().and_then(|e| e.to_str()) {
        Some("html") => "text/html",
        Some("css") => "text/css",
        Some("js") => "text/javascript",
        Some("json") => "application/json",
        Some("png") => "image/png",
        Some("jpg") | Some("jpeg") => "image/jpeg",
        Some("svg") => "image/svg+xml",
        Some("woff2") => "font/woff2",
        Some("woff") => "font/woff",
        _ => "application/octet-stream",
    }
    .to_string()
}

fn escape_html(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
}
