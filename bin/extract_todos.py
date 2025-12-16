#!/usr/bin/env python3.12
"""
extract_todos.py

Read JSON produced by `bin/parse_git_log.py` (from stdin or a file) and
extract all `todo` and `done` section items. Remove any items from the
todo list that are identical to items in done. Output is JSON with two
keys: `todo` and `done` containing lists of items (normalized strings).

Normalization: collapse consecutive whitespace into a single space and
strip leading/trailing whitespace. This helps match logically-equal items
that differ only in spacing.

Usage:
  cat parsed.json | python3.12 bin/extract_todos.py
  python3.12 bin/extract_todos.py parsed.json
"""
from __future__ import annotations

import argparse
import json
import sys
from typing import List, Dict, Any


def normalize(s: str) -> str:
    # collapse whitespace and strip
    return " ".join(s.split()).strip()


def collect_sections(parsed: List[Dict[str, Any]], section_type: str) -> List[str]:
    seen: Dict[str, None] = {}
    for commit in parsed:
        for sec in commit.get("body", []):
            if not isinstance(sec, dict):
                continue
            if sec.get("type") == section_type:
                for item in sec.get("items", []) or []:
                    if not isinstance(item, str):
                        continue
                    n = normalize(item)
                    if n and n not in seen:
                        seen[n] = None
    return list(seen.keys())


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Extract todo/done items from parse_git_log.py JSON output")
    parser.add_argument("file", nargs="?", help="JSON file to read (reads stdin if omitted)")
    parser.add_argument("--compact", action="store_true", help="Compact JSON output")
    args = parser.parse_args(argv)

    if args.file:
        with open(args.file, "r", encoding="utf-8") as f:
            parsed = json.load(f)
    else:
        parsed = json.load(sys.stdin)

    if not isinstance(parsed, list):
        print("Expected a JSON array of commits as input", file=sys.stderr)
        return 2

    todos = collect_sections(parsed, "todo")
    dones = collect_sections(parsed, "done")

    # Remove done items from todos (exact match after normalization)
    done_set = set(dones)
    filtered_todos = [t for t in todos if t not in done_set]

    out = {"todo": filtered_todos, "done": dones}
    if args.compact:
        json.dump(out, sys.stdout, ensure_ascii=False)
    else:
        json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
