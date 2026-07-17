# Agents

Custom subagent definitions for Claude Code. Each `.md` file is one agent:
frontmatter (`name`, `description`, `tools`) plus the agent's system prompt.

The setup scripts symlink these into `~/.claude/agents/<name>.md` (Claude Code)
and `~/.copilot/agents/<name>.agent.md` (Copilot CLI). Copy into a project's
`.claude/agents/` or `.github/agents/` instead to scope one to a single repo.

| Agent | What it does |
|---|---|
| `claim-verifier` | Hostile fact-checker for a single claim; tries to refute it against primary sources and returns a verdict with citations. Fan out one per claim during an `evidence-check` pass. |
| `azure-reader` | Read-only Azure / Azure DevOps researcher; returns findings with the exact `az` commands used so numbers are reproducible in reports. |
