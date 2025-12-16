#!/usr/bin/env python3.12
"""Parse metadata headers from `.typ` files under `root/notes` and output JSON.

Follows the rules in `doc/SPEC.blog.md`:
- metadata lines begin with exactly three slashes: `///`
- format: `/// TYPE: value` where TYPE is case-insensitive token
- currently recognizes `TAG` (comma-separated list) and preserves unknown types as lists

Usage:
  ./bin/parse_typ_metadata.py --root ./root/notes --out meta.json --pretty

By default, paths in the output are relative to the current working directory.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Any

METADATA_RE = re.compile(r"^///\s*([A-Za-z0-9_]+)\s*:\s*(.*)$")


def parse_metadata(path: Path, lowercase_tags: bool = False) -> Dict[str, Any]:
    """Parse contiguous `///` metadata lines at the top of `path`.

    Returns a metadata dict. Recognized:
      - TAG -> tags: list[str]
    Unknown TYPEs are stored as lists under their uppercase TYPE token.
    """
    metadata: Dict[str, Any] = {}

    try:
        with path.open("r", encoding="utf-8") as fh:
            for line in fh:
                if not line.startswith("///"):
                    break
                m = METADATA_RE.match(line)
                if not m:
                    # malformed metadata line: ignore conservatively
                    continue
                typ = m.group(1).strip().upper()
                val = m.group(2).strip()

                if typ == "TAG":
                    raw = [p.strip() for p in val.split(",") if p.strip()]
                    if lowercase_tags:
                        raw = [p.lower() for p in raw]
                    # dedupe while preserving order
                    seen = set()
                    tags: List[str] = []
                    for t in raw:
                        if t not in seen:
                            seen.add(t)
                            tags.append(t)
                    metadata["tags"] = tags
                else:
                    metadata.setdefault(typ, []).append(val)
    except Exception:
        # re-raise to surface I/O problems to the caller
        raise

    return metadata


def find_typ_files(root: Path) -> List[Path]:
    return sorted(p for p in root.rglob("*.typ") if p.is_file())


def build_index(root: Path, lowercase_tags: bool = False) -> Dict[str, Any]:
    result: Dict[str, Any] = {}
    files = find_typ_files(root)
    for p in files:
        meta = parse_metadata(p, lowercase_tags=lowercase_tags)
        # Ensure every file has an explicit `tags` key per request.
        if "tags" not in meta:
            meta["tags"] = []
        # store path relative to cwd (user-friendly)
        try:
            rel = str(p.relative_to(Path.cwd()))
        except Exception:
            rel = str(p)
        result[rel] = meta
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract metadata headers from .typ files and emit JSON")
    parser.add_argument("--root", default="./root/notes", help="Root folder to scan for .typ files")
    parser.add_argument("--out", help="Write JSON output to this file (otherwise stdout)")
    # Pretty output is the default per user request. Use --compact to get compact output.
    parser.add_argument("--pretty", action="store_true", default=True, help="Pretty-print JSON output (default)")
    parser.add_argument("--compact", action="store_true", help="Produce compact JSON output (overrides --pretty)")
    parser.add_argument("--lowercase", action="store_true", help="Lowercase tags when parsing TAG entries")
    args = parser.parse_args()

    root = Path(args.root)
    if not root.exists():
        print(f"Error: root path does not exist: {root}", file=sys.stderr)
        return 2

    index = build_index(root, lowercase_tags=args.lowercase)

    # Determine indentation: pretty by default unless --compact is passed.
    use_pretty = args.pretty and not args.compact
    indent = 2 if use_pretty else None

    if args.out:
        with Path(args.out).open("w", encoding="utf-8") as outfh:
            json.dump(index, outfh, ensure_ascii=False, indent=indent)
    else:
        if use_pretty:
            print(json.dumps(index, ensure_ascii=False, indent=2))
        else:
            print(json.dumps(index, ensure_ascii=False, separators=(",", ":")))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
