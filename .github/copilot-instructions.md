# Copilot Instructions

## Repository Overview

This is a collection of shared AI coding-tool skills — prompt/instruction files that get symlinked into user-level config directories for Copilot CLI, Claude Code, and OpenCode. There is no application code, no build system, and no tests.

## Architecture

Each **skill** is a top-level directory containing:

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
  by tools to match user intent to skills, so it should enumerate trigger
  phrases and use cases.
---
```

The body below the frontmatter contains the skill's instructions — what the AI agent should do when the skill is activated.

### Setup scripts

`setup-links.ps1` (Windows) and `setup-links.sh` (Linux/macOS) interactively symlink selected skills into tool config directories. They **never overwrite** existing targets.

## Conventions

- Skill folder names are lowercase kebab-case.
- Reference files are Markdown, kept in `references/` within the skill folder.
- Skills are tool-agnostic — the same content works across all supported tools.
- Skills may reference each other by name (e.g., `c4` delegates rendering to `mermaid`).
- `description` in frontmatter should be comprehensive about trigger conditions — it's the primary mechanism for skill selection.

## Adding a New Skill

1. Create a folder at the repo root with a kebab-case name.
2. Add a `SKILL.md` with the frontmatter format above.
3. Optionally add `references/` and/or `assets/` directories for supporting content.
4. Re-run the setup script to symlink it into your tools.
