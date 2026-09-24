# Copilot Instructions

## Repository Overview

This is a collection of shared AI coding-tool skills — prompt/instruction files that get symlinked into user-level config directories for Claude Code, Copilot CLI, Pi, and OpenCode. There is no application code and no build system. `scripts/lint_skills.py` checks skill frontmatter and relative file references, and the `tweakers-thread-scraper` and `vtt-cleanup` skills have Python tests under `tests/`.

## Architecture

Each **skill** is a directory under `skills/` containing:

```
skill-name/
├── SKILL.md              # Required — main instructions (YAML frontmatter + body)
├── references/           # Optional — detailed reference docs loaded on demand
└── assets/               # Optional — examples, templates, static content
```

### SKILL.md format

Every `SKILL.md` must start with YAML frontmatter containing exactly two fields:

```yaml
---
name: skill-name
description: >
  A single paragraph explaining when to invoke the skill. This text is used
  by tools to match user intent to skills, so it names the categories of
  intent the skill serves, plus the few literal phrases users actually type.
---
```

The body below the frontmatter contains the skill's instructions — what the AI agent should do when the skill is activated.

### Setup scripts

`setup-links.ps1` (Windows) and `setup-links.sh` (Linux/macOS) symlink skills, agents, plugins, and settings into tool config directories (interactive multi-select, or `-All` / `--all`). They skip existing real skill directories and foreign symlinks; an existing real settings file is backed up to `<name>.pre-repo.bak` before it is linked.

## Conventions

- Skill folder names are lowercase kebab-case.
- Reference files are Markdown, kept in `references/` within the skill folder.
- Skills are tool-agnostic — the same content works across all supported tools.
- Skills may reference each other by name (e.g., `c4` delegates rendering to `mermaid`).
- `description` in frontmatter is the primary mechanism for skill selection. Describe intent categories rather than listing near-synonym phrasings, and keep it under the 1024-character limit that `scripts/lint_skills.py` enforces.

## Adding a New Skill

1. Create a folder under `skills/` with a kebab-case name.
2. Add a `SKILL.md` with the frontmatter format above.
3. Optionally add `references/` and/or `assets/` directories for supporting content.
4. Re-run the setup script to symlink it into your tools.
