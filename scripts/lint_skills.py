#!/usr/bin/env python3
"""Lint every SKILL.md in this repo against the conventions we rely on.

Checks per skill:
  - frontmatter parses and contains `name` and `description`
  - `name` matches the directory name (tools key skill identity on this)
  - description is <= 1024 characters (Claude Code hard limit)
  - SKILL.md contains no absolute drive-letter paths (breaks symlinked installs)
  - relative files referenced from SKILL.md (markdown links and backtick
    paths like `references/foo.md`) actually exist

Exit code 0 = clean, 1 = problems found.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO / "skills"
MAX_DESCRIPTION = 1024

# repo-relative paths mentioned in prose that look like files inside the skill
BACKTICK_PATH_RE = re.compile(r"`((?:references|assets|scripts|tests)/[\w./ -]+\.\w+)`")
MD_LINK_RE = re.compile(r"\[[^\]]*\]\(\.?/?([^)#]+\.md)\)")
DRIVE_PATH_RE = re.compile(r"[A-Za-z]:\\[\w\\]")


def parse_frontmatter(text: str) -> dict[str, str] | None:
    m = re.match(r"^---\r?\n(.*?)\r?\n---", text, re.DOTALL)
    if not m:
        return None
    fm: dict[str, str] = {}
    key = None
    for line in m.group(1).splitlines():
        km = re.match(r"^(\w[\w-]*):\s*(.*)$", line)
        if km:
            key = km.group(1)
            val = km.group(2).strip()
            fm[key] = "" if val in (">", "|", ">-", "|-") else val
        elif key and line.startswith((" ", "\t")):
            fm[key] = (fm[key] + " " + line.strip()).strip()
    return fm


def lint_skill(skill_md: Path) -> list[str]:
    problems: list[str] = []
    rel = skill_md.relative_to(REPO)
    text = skill_md.read_text(encoding="utf-8")

    fm = parse_frontmatter(text)
    if fm is None:
        return [f"{rel}: no YAML frontmatter block"]

    name = fm.get("name")
    description = fm.get("description")
    dir_name = skill_md.parent.name

    if not name:
        problems.append(f"{rel}: frontmatter missing `name`")
    elif name != dir_name:
        problems.append(f"{rel}: name `{name}` != directory `{dir_name}`")

    if not description:
        problems.append(f"{rel}: frontmatter missing `description`")
    elif len(description) > MAX_DESCRIPTION:
        problems.append(
            f"{rel}: description is {len(description)} chars (max {MAX_DESCRIPTION})"
        )

    body = text.split("---", 2)[-1]
    for m in DRIVE_PATH_RE.finditer(body):
        line_no = body[: m.start()].count("\n") + text[: len(text) - len(body)].count("\n") + 1
        problems.append(
            f"{rel}:{line_no}: absolute drive-letter path — use a path relative "
            f"to this skill's directory instead"
        )

    referenced = set(BACKTICK_PATH_RE.findall(body)) | set(MD_LINK_RE.findall(body))
    for ref in sorted(referenced):
        if ref.startswith(("http://", "https://")):
            continue
        if (skill_md.parent / ref).exists():
            continue
        # cross-skill references ("see `references/c4.md` in the mermaid skill")
        if any((d / ref).exists() for d in SKILLS_DIR.iterdir() if d.is_dir()):
            continue
        problems.append(f"{rel}: references `{ref}` which does not exist")

    return problems


def main() -> int:
    skill_files = sorted(
        p for p in SKILLS_DIR.glob("*/SKILL.md") if ".git" not in p.parts
    )
    if not skill_files:
        print("No SKILL.md files found — wrong working directory?", file=sys.stderr)
        return 1

    all_problems: list[str] = []
    for skill_md in skill_files:
        all_problems.extend(lint_skill(skill_md))

    if all_problems:
        print(f"{len(all_problems)} problem(s) in {len(skill_files)} skills:\n")
        for p in all_problems:
            print(f"  {p}")
        return 1

    print(f"OK: {len(skill_files)} skills pass all checks.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
