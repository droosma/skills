#!/usr/bin/env python3
"""Lint skill and plugin manifests against the conventions we rely on.

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

import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO / "skills"
PLUGINS_DIR = REPO / "plugins"
MAX_DESCRIPTION = 1024
TOOLS = {"Claude Code", "Copilot CLI", "Pi", "OpenCode"}
MODE_FIELDS = {
    "marketplace-plugin": {
        "command",
        "marketplaceSource",
        "marketplaceMatch",
        "plugin",
        "installedMatch",
    },
    "pi-package": {"source", "installedMatch"},
    "opencode-plugin": {"plugin"},
    "skill-fallback": {"skill"},
}

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


def lint_plugin(manifest_path: Path) -> list[str]:
    problems: list[str] = []
    rel = manifest_path.relative_to(REPO)
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"{rel}: invalid JSON: {exc}"]

    name = manifest.get("name")
    if name != manifest_path.parent.name:
        problems.append(
            f"{rel}: name `{name}` != directory `{manifest_path.parent.name}`"
        )
    for field in ("description", "source", "testedVersion", "targets"):
        if not manifest.get(field):
            problems.append(f"{rel}: missing `{field}`")

    targets = manifest.get("targets")
    if not isinstance(targets, dict):
        return problems

    unknown_tools = set(targets) - TOOLS
    for tool in sorted(unknown_tools):
        problems.append(f"{rel}: unknown target tool `{tool}`")

    for tool, target in targets.items():
        if not isinstance(target, dict):
            problems.append(f"{rel}: target `{tool}` must be an object")
            continue
        mode = target.get("mode")
        if mode not in MODE_FIELDS:
            problems.append(f"{rel}: target `{tool}` has unknown mode `{mode}`")
            continue
        for field in sorted(MODE_FIELDS[mode]):
            if not target.get(field):
                problems.append(
                    f"{rel}: target `{tool}` mode `{mode}` missing `{field}`"
                )
        if mode == "skill-fallback":
            skill = target.get("skill")
            if skill and not (SKILLS_DIR / skill / "SKILL.md").exists():
                problems.append(
                    f"{rel}: target `{tool}` references missing skill `{skill}`"
                )

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

    plugin_files = (
        sorted(PLUGINS_DIR.glob("*/plugin.json")) if PLUGINS_DIR.exists() else []
    )
    for manifest_path in plugin_files:
        all_problems.extend(lint_plugin(manifest_path))

    if all_problems:
        print(
            f"{len(all_problems)} problem(s) in {len(skill_files)} skills and "
            f"{len(plugin_files)} plugins:\n"
        )
        for p in all_problems:
            print(f"  {p}")
        return 1

    print(
        f"OK: {len(skill_files)} skills and {len(plugin_files)} plugins pass "
        "all checks."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
