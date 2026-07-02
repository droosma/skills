# Agent Skills

Shared, version-controlled skills for AI coding tools.

## Supported Tools

| Tool         | Skills directory (user-level)                              |
|--------------|------------------------------------------------------------|
| Copilot CLI  | `~/.copilot/skills/`                                       |
| Claude Code  | `~/.claude/skills/`                                        |
| OpenCode     | `~/.config/opencode/skills/` (Linux) · `%APPDATA%\opencode\skills\` (Win) |

## Setup

### Windows (PowerShell)

> **Prerequisite:** Enable **Developer Mode** (`Settings → For developers`) so symlinks work without elevation.

```powershell
.\setup-links.ps1
```

### Linux / macOS

```bash
chmod +x setup-links.sh
./setup-links.sh
```

Both scripts provide an interactive multi-select to choose:

1. **Which tools** to link skills into
2. **Which skills** to link

Existing skills are **never overwritten** — the scripts skip any target that already exists.

## Skills

| Skill | What it does |
|---|---|
| `c4` | Design C4 architecture diagrams (modelling; rendering via `mermaid`) |
| `grill-me` | Relentless interview to stress-test a plan; updates CONTEXT.md/ADRs when the repo has them |
| `handoff` | Capture or resume session context via handoff files |
| `human-writing-style` | Strip AI tells from prose |
| `mermaid` | Syntactically-correct Mermaid diagrams of every type |
| `tweakers-thread-scraper` | Archive a Tweakers forum thread to JSON/SQLite |
| `vtt-cleanup` | Strip Teams VTT transcripts down to speaker + text |

## Adding a New Skill

1. Create a folder in the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` with frontmatter and instructions — the `name` must match the folder, the description must stay under 1024 characters, and paths to bundled scripts must be relative to the skill directory (CI enforces all of this via `scripts/lint_skills.py`)
3. Add the skill to the table above
4. Re-run the setup script to symlink the new skill

## Linting & tests

```bash
python scripts/lint_skills.py             # frontmatter, name/dir match, path portability
python vtt-cleanup/tests/test_clean_vtt.py
python tweakers-thread-scraper/tests/test_parse.py
```

CI (`.github/workflows/lint.yml`) runs all three on every push and PR.
