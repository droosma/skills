# Settings

Git-controlled source of truth for global tool configuration. The setup scripts
symlink the **target locations to these files**, so edits here (and `git pull`)
apply globally, and changes made by the tools land back in this repo as diffs.

| Repo file | Symlinked to | What it is |
|---|---|---|
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code user settings: model, permission allow/deny lists |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Claude Code global instructions (loaded every session) |
| `copilot/settings.json` | `~/.copilot/settings.json` | Copilot CLI user settings: model, allowed URLs, plugins, status line |
| `copilot/copilot-instructions.md` | `~/.copilot/copilot-instructions.md` | Copilot CLI user-level custom instructions |
| `pi/AGENTS.md` | `~/.pi/agent/AGENTS.md` | Pi global instructions (loaded every session) |
| `shared/` | `~/.claude/shared/`, `~/.copilot/shared/` **and** `~/.pi/agent/shared/` | Tool-agnostic guideline modules, one small file per topic |

## Shared guidelines — write once, use in both tools

Cross-tool rules live in `shared/` so nothing is copy-pasted between the two
instruction files:

- **Claude Code** imports them natively: `claude/CLAUDE.md` contains
  `@~/.claude/shared/<topic>.md` lines, which Claude Code inlines at session
  start (imports resolve through the `~/.claude/shared` symlink).
- **Copilot CLI** has no import mechanism, so
  `copilot/copilot-instructions.md` carries a one-line summary per topic plus
  a pointer to the full file in `~/.copilot/shared/` — progressive disclosure:
  the agent reads the detail only when working in that area.
- **Pi** also has no import mechanism (it loads `~/.pi/agent/AGENTS.md` as
  global instructions), so `pi/AGENTS.md` follows the same summary + pointer
  pattern as Copilot, referencing `~/.pi/agent/shared/`.

To add a rule: edit (or add) a file in `shared/`, then reference it from
`claude/CLAUDE.md` (`@~/.claude/shared/<file>.md`) and add a summary line to
both `copilot/copilot-instructions.md` and `pi/AGENTS.md`. Keep each file
small — everything in CLAUDE.md-imported files is loaded into context every
session.

Current modules: `working-agreements.md` (artifacts, design discussions, docs
grounding, scraping, shell), `coding-guidelines.md` (surgical changes,
simplicity first, verifiable goals — adapted from Karpathy's LLM-pitfall
observations), `long-running-work.md` (PROGRESS.md checkpointing),
`azure.md` (auth path order).

The setup scripts back up any pre-existing real file to `<name>.pre-repo.bak`
before creating the symlink, and never touch files that are already correct
symlinks into this repo.

## Pi — skills, instructions, and extensions (hooks)

Pi discovers skills from `~/.pi/agent/skills/` (directories containing a
`SKILL.md`), the same layout the other tools use, so the setup scripts symlink
skill directories there directly. Pi's analog to Claude/Copilot hooks is
**extensions** — TypeScript modules in `~/.pi/agent/extensions/`. If this repo
gains a top-level `extensions/` directory, the setup scripts link each entry
(`.ts` file or extension folder) into place so pi can hot-reload them with
`/reload`.

Pi's `~/.pi/agent/settings.json` is **not** symlinked: pi writes machine state
into it (e.g. `lastChangelogVersion`), which would churn in git. Manage pi
model/theme preferences directly in that file.

Deliberately **not** managed here:

- `~/.claude/.credentials.json`, `~/.copilot/config.json`,
  `~/.pi/agent/auth.json`, `~/.pi/agent/settings.json` — credentials and
  machine state (trusted folders, caches, changelog version) don't belong in
  git.
- Project-level `.claude/settings.json` — per-repo, committed in that repo.

## Permission allowlist notes

The allow list is read-only only (az `show`/`list`, git inspection); the deny
list blocks az mutation verbs. `az devops invoke` is deliberately not allowed
(it can POST via `--http-method`).
