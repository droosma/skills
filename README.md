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

## Adding a New Skill

1. Create a folder in the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` with frontmatter and instructions
3. Re-run the setup script to symlink the new skill

## Repo Structure

```
skills/
├── setup-links.ps1      # Windows setup (interactive)
├── setup-links.sh        # Linux/macOS setup (interactive)
├── README.md
├── c4/
│   └── SKILL.md
├── human-writing-style/
│   └── SKILL.md
└── mermaid/
    └── SKILL.md
```
