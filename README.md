# Agent Skills, Agents & Settings

Shared, version-controlled configuration for AI coding tools. **This repo is
the source of truth**: skills, agents, and global settings live here under git,
and the setup scripts symlink the tools' config locations to these files — so
edits and `git pull` apply everywhere, and changes the tools write land back
here as diffs.

## Layout

```
skills/     one directory per skill (SKILL.md + assets)
agents/     custom subagent definitions (.md)
settings/   global settings files, symlinked into place
  claude/     settings.json, CLAUDE.md        -> ~/.claude/
  copilot/    copilot-instructions.md         -> ~/.copilot/
  pi/         AGENTS.md                       -> ~/.pi/agent/
scripts/    repo tooling (linter)
```

## Supported Tools

| Tool         | Skills                       | Agents                              | Settings |
|--------------|------------------------------|-------------------------------------|----------|
| Claude Code  | `~/.claude/skills/`          | `~/.claude/agents/<name>.md`        | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` |
| Copilot CLI  | `~/.copilot/skills/`         | `~/.copilot/agents/<name>.agent.md` | `~/.copilot/copilot-instructions.md` |
| Pi           | `~/.pi/agent/skills/`        | — (no subagent concept)             | `~/.pi/agent/AGENTS.md` (+ `~/.pi/agent/extensions/` for hooks) |
| OpenCode     | `~/.config/opencode/skills/` (Linux) · `%APPDATA%\opencode\skills\` (Win) | — | — |

## Setup

### Windows (PowerShell)

> **Prerequisite:** Enable **Developer Mode** (`Settings → For developers`) so symlinks work without elevation.

```powershell
.\setup-links.ps1        # interactive multi-select
.\setup-links.ps1 -All   # everything, non-interactive
```

### Linux / macOS

```bash
./setup-links.sh         # interactive multi-select
./setup-links.sh --all   # everything, non-interactive
```

Link behavior: missing targets are created; stale symlinks into this repo are
repaired; symlinks pointing elsewhere are skipped; a real **settings** file in
the way is backed up to `<name>.pre-repo.bak` before linking; a real **skill**
dir in the way is skipped (merge it into the repo first).

## Skills

| Skill | What it does |
|---|---|
| `azure-preflight` | Confirm a working Azure / DevOps auth path (known-good order) before any Azure work |
| `c4` | Design C4 architecture diagrams (modelling; rendering via `mermaid`) |
| `checkpoint` | Durable PROGRESS.md checkpointing so long runs survive session limits and killed processes |
| `code-smells` | Fowler smell baseline (Mysterious Name, Feature Envy, …) as a design-quality lens on any code review |
| `evidence-check` | Adversarially verify every claim in a doc against primary sources; emits a claim-to-source table |
| `grill-me` | Relentless interview to stress-test a plan; updates CONTEXT.md/ADRs when the repo has them |
| `handoff` | Capture or resume session context via handoff files |
| `human-writing-style` | Strip AI tells from prose |
| `mermaid` | Syntactically-correct Mermaid diagrams of every type |
| `observable-language` | On-demand audit of feedback/criteria for container words (vague abstract nouns); rewrites them into filmable behaviour (bilingual NL/EN) |
| `scope-check` | One-round scope/format/mode alignment before expensive work |
| `tweakers-thread-scraper` | Archive a Tweakers forum thread to JSON/SQLite |
| `vtt-cleanup` | Strip Teams VTT transcripts down to speaker + text |
| `write-for-audience` | Calibrate docs to their target audience (non-technical / technical-adjacent / highly technical) with evidence-based readability rules |

## Agents

| Agent | What it does |
|---|---|
| `claim-verifier` | Hostile per-claim fact-checker used by `evidence-check` fan-outs |
| `azure-reader` | Read-only Azure/DevOps researcher with a reproducible command trail |

Linked to both Claude Code (`.md`) and Copilot CLI (`.agent.md`, [docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)).

## Settings

See `settings/README.md` for the file-by-file mapping and what is deliberately
kept out of git (credentials, machine state).

## Adding a New Skill

1. Create a folder under `skills/` (e.g. `skills/my-new-skill/`)
2. Add a `SKILL.md` with frontmatter and instructions — the `name` must match the folder, the description must stay under 1024 characters, and paths to bundled scripts must be relative to the skill directory (CI enforces all of this via `scripts/lint_skills.py`)
3. Add the skill to the table above
4. Re-run the setup script to symlink the new skill

## Linting & tests

```bash
python scripts/lint_skills.py                          # frontmatter, name/dir match, path portability
python skills/vtt-cleanup/tests/test_clean_vtt.py
python skills/tweakers-thread-scraper/tests/test_parse.py
```

CI (`.github/workflows/lint.yml`) runs all three on every push and PR.
