# Handoff: <repo-name> on <branch>

> **Last updated:** <ISO 8601 timestamp, e.g. 2026-06-01T14:32:00+02:00>
> **Iteration:** <n>  (increment each time this file is rewritten)
> **Written by:** <Claude / Copilot / Duncan>

---

## Next action

<One sentence. The very first thing the next agent should do. If multiple things are urgent, pick the one without which everything else is blocked.>

---

## Goal & success criteria

**Original ask (verbatim from the user):**
> <quote the user's literal request — do not paraphrase>

**Restated goal:** <one or two sentences capturing the actual intent, which may differ from the literal ask>

**Success criteria:**
- [ ] <concrete, testable outcome>
- [ ] <another>

**Explicitly out of scope:** <what was discussed and ruled out — saves the next agent from re-litigating>

---

## Current state

- **Branch:** `<branch-name>` (base: `<base-branch>` at commit `<short-sha>`)
- **Working dir:** `<absolute path>`
- **Last commit on branch:** `<short-sha> <message>`

**Uncommitted changes:**
- `path/to/file.ext:<lines>` — <what's in flight there>
- `path/to/other.ext` — <new file: purpose>

**What works right now:**
- <specific behavior, ideally with a command to confirm>

**What's broken or failing:**
- <specific failure>
  - Repro: `<exact command>`
  - Error: `<excerpt of the actual error message>`

---

## Decisions & rejected approaches

### Decisions made
- **<decision>** — chose because <reason>. Tradeoff accepted: <what was given up>.

### Approaches tried and rejected
> This is the most valuable section. Failed approaches are invisible from git. Capture them so the next agent doesn't repeat them.

- **<approach>** — tried, abandoned because <specific reason / what we learned>.

### Constraints discovered mid-task
- <thing that wasn't obvious going in — library limitation, platform quirk, business rule>

---

## Open questions

Decisions still owed by the user before work can proceed:
- <question, with the options that were on the table>

---

## Environment & repro

- **Run the app:** `<command>`
- **Run tests:** `<command>`
- **Lint / typecheck:** `<command>`
- **Services that must be up:** <e.g. local Postgres on 5432, Redis>
- **Env vars / secrets needed:** <names only — point to where the values live, never paste them>

---

## External references

- <ticket URL / PR URL / doc URL / Slack thread URL — anchor on the URL, add a line of context>

---

## User preferences observed this session

> Behavioral context that won't be in CLAUDE.md but should shape how the next agent responds.

- <e.g. "Wants terse responses; no trailing summaries">
- <e.g. "Prefers PowerShell over bash on this Windows machine">
- <e.g. "Pushed back on adding comments — keep code uncommented unless WHY is non-obvious">

---

## Previous iterations

<!-- On each update, prepend a one-line entry here so the chain is visible without opening the archive. -->

- <ISO timestamp> — <one-line summary of what that iteration covered>
