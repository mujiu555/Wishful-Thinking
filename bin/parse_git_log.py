#!/usr/bin/env python3.12
"""
parse_git_log.py

Parse git commit messages based on the project specification in
`doc/SPEC.commit.md`.

Usage:
  - Read from a file:  python3.12 bin/parse_git_log.py commits.txt
  - Read from stdin:  cat commits.txt | python3.12 bin/parse_git_log.py

Output is JSON array of parsed commits to stdout. By default it's pretty-printed.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict


@dataclass
class Header:
    type: str
    scope: Optional[str]
    breaking: bool
    description: str


@dataclass
class Section:
    type: str
    title_desc: Optional[str]
    items: List[str]
    text: Optional[str]


@dataclass
class Commit:
    header: Header
    body: List[Section]
    footer: Dict[str, object]


_header_re = re.compile(r"^(?P<type>[a-zA-Z0-9_-]+)(?P<bang>!)?(?:\((?P<scope>[^)]+)\))?\s*:\s*(?P<desc>.+)$", re.IGNORECASE)


def split_commits(raw: str) -> List[str]:
    """Split a large git log into individual commit message blocks.

    Heuristics used:
    - If input contains lines starting with 'commit ' (git default), split on those lines and drop the initial 'commit <hash>' line.
    - Otherwise, split on a separator line of 72 dashes, or on blank lines separating messages.

    Assumptions (reasonable defaults):
    - Each commit block contains the commit message (header + optional body + optional footer).
    - If commit metadata (Author/Date) exist, the actual message starts after the first blank line following metadata.
    """
    lines = raw.splitlines()
    # detect git-style 'commit <hash>' marks
    if any(l.startswith("commit ") for l in lines):
        commits: List[str] = []
        current: List[str] = []
        for line in lines:
            if line.startswith("commit "):
                if current:
                    commits.append("\n".join(current))
                    current = []
                # keep the commit line as part of header for possible metadata parsing
                current.append(line)
            else:
                current.append(line)
        if current:
            commits.append("\n".join(current))
        # For each commit block, extract the message portion (after metadata blank line)
        result = []
        for block in commits:
            blines = block.splitlines()
            # find the first empty line after possible metadata lines (Author/Date)
            for i, l in enumerate(blines):
                if l.strip() == "":
                    # message is the rest (strip leading indentation)
                    msg = "\n".join(_strip_leading_spaces(blines[i + 1 :]))
                    result.append(msg)
                    break
            else:
                # no blank line found, treat whole block as message
                result.append("\n".join(_strip_leading_spaces(blines)))
        return result

    # fallback: split on 72+ dashes
    sep_re = re.compile(r"^-{3,}$")
    commits = []
    current = []
    for line in lines:
        if sep_re.match(line.strip()):
            if current:
                commits.append("\n".join(current))
                current = []
        else:
            current.append(line)
    if current:
        commits.append("\n".join(current))
    # If only one commit and many blank-line separated messages, try splitting on double-blank
    if len(commits) == 1:
        parts = re.split(r"\n\s*\n\s*\n", commits[0])
        if len(parts) > 1:
            return [p.strip() for p in parts if p.strip()]
    return [c.strip() for c in commits if c.strip()]


def _strip_leading_spaces(lines: List[str]) -> List[str]:
    # Remove common leading indentation (like git's 4-space indent) from message lines
    if not lines:
        return lines
    # compute minimal leading spaces among non-empty lines
    min_lead = None
    for l in lines:
        if l.strip() == "":
            continue
        m = re.match(r"^(\s*)", l)
        if m:
            lead = len(m.group(1))
            if min_lead is None or lead < min_lead:
                min_lead = lead
    if min_lead is None:
        min_lead = 0
    return [l[min_lead:] if len(l) >= min_lead else l for l in lines]


def parse_message(msg: str) -> Commit:
    lines = [l.rstrip() for l in msg.splitlines()]
    # drop leading/trailing blank lines
    while lines and lines[0].strip() == "":
        lines.pop(0)
    while lines and lines[-1].strip() == "":
        lines.pop()

    if not lines:
        # empty commit
        hdr = Header(type="", scope=None, breaking=False, description="")
        return Commit(header=hdr, body=[], footer={})

    # header is the first non-empty line
    header_line = lines[0]
    m = _header_re.match(header_line)
    if not m:
        # If header doesn't match, be permissive: treat whole first line as description with unknown type
        hdr = Header(type="unknown", scope=None, breaking=False, description=header_line)
        rest = lines[1:]
    else:
        t = m.group("type").lower()
        bang = bool(m.group("bang"))
        scope = m.group("scope")
        desc = m.group("desc").strip()
        hdr = Header(type=t, scope=scope, breaking=bang, description=desc)
        rest = lines[1:]

    # Separate body and footer: footers normally start with 'Request:' or known footer keys
    footer_keys = ("Request:", "Reviewed-by:", "Reviewed-by", "Breaking-change:", "Breaking-Change:")
    footer_start = None
    for i, l in enumerate(rest):
        if any(l.startswith(k) for k in footer_keys):
            footer_start = i
            break
    body_lines = rest if footer_start is None else rest[:footer_start]
    footer_lines = [] if footer_start is None else rest[footer_start:]

    # Parse body into sections. A section starts with a line like 'feature:' or 'fix:' optionally followed by a short desc.
    sections: List[Section] = []
    i = 0
    section_title_re = re.compile(r"^(?P<type>[a-zA-Z0-9_-]+)\s*:(?:\s*(?P<desc>.*))?$", re.IGNORECASE)
    current_section: Optional[Section] = None
    buffer: List[str] = []

    def flush_section():
        nonlocal current_section, buffer
        if current_section is None and not buffer:
            return
        if current_section is None:
            # when no explicit section titles, treat the whole body as a 'description' section
            # split into paragraphs and use each paragraph as an item to populate `items`
            paras: List[str] = []
            cur: List[str] = []
            for bl in buffer:
                if bl.strip() == "":
                    if cur:
                        paras.append("\n".join(cur))
                        cur = []
                else:
                    cur.append(bl)
            if cur:
                paras.append("\n".join(cur))
            items = [p.strip() for p in paras if p.strip()]
            sections.append(Section(type="description", title_desc=None, items=items, text=None))
            buffer = []
            return
        # parse items (numbered lists, bullet lists) or treat paragraphs as items
        items: List[str] = []
        text_lines: List[str] = []
        list_item_re = re.compile(r"^\s*(?:\d+\.|[-*])\s*(.+)$")
        # split buffer into paragraphs
        paras: List[str] = []
        cur = []
        for bl in buffer:
            if bl.strip() == "":
                if cur:
                    paras.append("\n".join(cur))
                    cur = []
            else:
                cur.append(bl)
        if cur:
            paras.append("\n".join(cur))

        for para in paras:
            plines = para.splitlines()
            # if any line in paragraph looks like a list item, extract list items
            if any(list_item_re.match(pl) for pl in plines):
                for pl in plines:
                    m_item = list_item_re.match(pl)
                    if m_item:
                        items.append(m_item.group(1).strip())
                    else:
                        # continuation lines: append to last item if exists, else collect as text
                        if items:
                            items[-1] = items[-1] + "\n" + pl.strip()
                        else:
                            text_lines.append(pl)
            else:
                # treat whole paragraph as a single item
                if para.strip():
                    items.append(para.strip())

        text = None if items else ("\n".join(text_lines).strip() if text_lines else None)
        sections.append(Section(type=current_section.type, title_desc=current_section.title_desc, items=items, text=text))
        buffer = []

    while i < len(body_lines):
        line = body_lines[i]
        if line.strip() == "":
            # blank line separates items/sections
            buffer.append("")
            i += 1
            continue
        sm = section_title_re.match(line)
        if sm:
            # new section starts
            # flush previous
            flush_section()
            current_section = Section(type=sm.group("type").lower(), title_desc=(sm.group("desc") or None), items=[], text=None)
            # start fresh buffer
            buffer = []
            i += 1
            # collect lines until next blank line that leads to another section title or footer
            while i < len(body_lines) and not section_title_re.match(body_lines[i]):
                buffer.append(body_lines[i])
                i += 1
            flush_section()
            current_section = None
        else:
            buffer.append(line)
            i += 1
    # flush any leftover
    flush_section()

    # parse footer lines into a dict of keys->values
    footer: Dict[str, object] = {}
    for fl in footer_lines:
        if ":" in fl:
            k, v = fl.split(":", 1)
            key = k.strip()
            val = v.strip()
            if key.lower() == "request":
                # parse issue ids like '#112, #118' or '#none' -> produce list of id strings (empty list for #none)
                found = re.findall(r"#(\d+|none)", val, flags=re.IGNORECASE)
                ids = [f for f in found if f.lower() != "none"]
                footer[key] = ids
            else:
                footer[key] = val
        else:
            if fl.strip():
                prev = footer.get("misc", "")
                footer["misc"] = f"{prev}{fl.strip()}\n"

    return Commit(header=hdr, body=sections, footer=footer)


def parse_many(text: str) -> List[Commit]:
    blocks = split_commits(text)
    return [parse_message(b) for b in blocks]


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Parse git commit messages into structured JSON (per doc/SPEC.commit.md).")
    parser.add_argument("file", nargs="?", help="File containing git log or commit messages. Reads stdin when omitted.")
    parser.add_argument("--compact", action="store_true", help="Output compact JSON (no pretty print)")
    args = parser.parse_args(argv)

    if args.file:
        try:
            with open(args.file, "r", encoding="utf-8") as f:
                text = f.read()
        except Exception as e:
            print(f"Error reading {args.file}: {e}", file=sys.stderr)
            return 2
    else:
        text = sys.stdin.read()

    commits = parse_many(text)
    out = [asdict(c) for c in commits]
    if args.compact:
        json.dump(out, sys.stdout, ensure_ascii=False)
    else:
        json.dump(out, sys.stdout, ensure_ascii=False, indent=2)
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
