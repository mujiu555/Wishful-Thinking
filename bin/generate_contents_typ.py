#!/usr/bin/env python3.12
"""Generate a `contents.typ` file listing all `.typ` files as `#link("path")[Title]`.

This script reuses `bin/parse_typ_metadata.py`'s `build_index` to discover `.typ` files
and then scans each file for a `#title[...]` directive to use as the link label. If no
title is found, the file's basename (without extension) is used.

By default it writes to `./root/contents.typ`.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Dict
import json
import subprocess
import sys

# NOTE: Do NOT import bin.parse_typ_metadata; instead call it as a subprocess and parse
# its JSON output. This avoids importing implementation directly and follows the user's request.


TITLE_RE = re.compile(r"^#title\[(.*)\]$")


def extract_title(path: Path) -> str:
    try:
        with path.open("r", encoding="utf-8") as fh:
            for line in fh:
                line = line.rstrip("\n")
                m = TITLE_RE.match(line)
                if m:
                    return m.group(1).strip()
    except Exception:
        pass
    # fallback: use filename without extension
    return path.stem


def build_contents(root_notes: Path, out: Path, lowercase_tags: bool = False) -> None:
    # Call the parser as a subprocess and capture JSON output
    cmd = [
        sys.executable,
        str(Path(__file__).with_name("parse_typ_metadata.py")),
        "--root",
        str(root_notes),
        "--compact",
    ]
    if lowercase_tags:
        cmd.append("--lowercase")

    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(f"parse_typ_metadata.py failed: {proc.stderr.strip()}")

    try:
        index: Dict[str, dict] = json.loads(proc.stdout)
    except Exception as exc:
        raise RuntimeError(
            f"failed to parse JSON from parser output: {exc}\nstdout:\n{
                proc.stdout[:2000]
            }"
        )

    # Sort entries for deterministic output by path
    entries = sorted(index.keys())

    # Build tag -> list[path] mapping using 'tags' property from JSON metadata.
    # Accept either a list of tags or a single string tag. Keep insertion deterministic
    # by using sorted lists when writing output below.
    tag_map: Dict[str, list] = {}
    files_with_tags = set()
    for rel in entries:
        meta = index.get(rel, {})
        tags = meta.get("tags") or meta.get("tag")
        if tags is None:
            continue
        # normalize single string to list
        if isinstance(tags, str):
            tags_list = [tags]
        elif isinstance(tags, (list, tuple)):
            tags_list = list(tags)
        else:
            # unknown format; skip
            continue

        for t in tags_list:
            if t is None:
                continue
            t_str = str(t).strip()
            if not t_str:
                continue
            if lowercase_tags:
                t_str = t_str.lower()
            tag_map.setdefault(t_str, []).append(rel)
            files_with_tags.add(rel)

    # Header per user request
    from datetime import datetime

    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    lines = []
    # Required header order
    lines.append('#import "/lib/lib.typ": *')
    lines.append('#show: schema.with("page")')
    lines.append("#title[My Works]")
    lines.append(f"#date[{now}]")
    # note: include backslash before @ as requested
    lines.append('#author(link("https://github.com/mujiu555")[GitHub\\@mujiu555])')
    lines.append("\n")

    lines.append("= Overview\n")
    for rel in entries:
        p = Path(rel)
        # Make the link path start with a leading slash so it matches other files (e.g. /root/notes/...)
        link_path = "/" + str(p).lstrip("./")
        # If the path starts with /root, remove that prefix so links become /notes/...
        if link_path.startswith("/root"):
            # remove just the '/root' prefix; keep the leading slash for the rest of the path
            link_path = link_path[len("/root") :]
            if not link_path.startswith("/"):
                link_path = "/" + link_path
        # Resolve the file path to extract title
        real_path = Path.cwd() / p
        title = extract_title(real_path)
        # Escape double-quotes in path and title (typst link expects string literal)
        link_path_escaped = link_path.replace('"', '\\"')
        lines.append(
            f'== #embed("{link_path_escaped}", sidebar: "only_title", open: false)\n'
        )

    # Add tag-based sections
    if tag_map:
        lines.append("\n= Tags\n")
        for tag in sorted(tag_map.keys()):
            lines.append(f"== {tag}\n")
            for rel in sorted(tag_map[tag]):
                p = Path(rel)
                link_path = "/" + str(p).lstrip("./")
                if link_path.startswith("/root"):
                    link_path = link_path[len("/root") :]
                    if not link_path.startswith("/"):
                        link_path = "/" + link_path
                link_path_escaped = link_path.replace('"', '\\"')
                lines.append(
                    f'=== #embed("{
                        link_path_escaped
                    }", sidebar: "only_title", open: false)\n'
                )

    # Files without tags
    untagged = [rel for rel in entries if rel not in files_with_tags]
    if untagged:
        lines.append("\n= Uncategorized\n")
        for rel in untagged:
            p = Path(rel)
            link_path = "/" + str(p).lstrip("./")
            if link_path.startswith("/root"):
                link_path = link_path[len("/root") :]
                if not link_path.startswith("/"):
                    link_path = "/" + link_path
            link_path_escaped = link_path.replace('"', '\\"')
            lines.append(
                f'=== #embed("{
                    link_path_escaped
                }", sidebar: "only_title", open: false)\n'
            )

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate a root/contents.typ linking to all .typ files"
    )
    parser.add_argument(
        "--root-notes",
        default="./root/notes",
        help="Root notes folder to scan for .typ files",
    )
    parser.add_argument(
        "--out", default="./root/contents.typ", help="Output contents.typ path"
    )
    parser.add_argument(
        "--lowercase",
        action="store_true",
        help="Pass through lowercase option to metadata builder",
    )
    args = parser.parse_args()

    root_notes = Path(args.root_notes)
    out = Path(args.out)
    build_contents(root_notes, out, lowercase_tags=args.lowercase)
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
