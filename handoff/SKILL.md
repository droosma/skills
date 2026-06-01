---
name: handoff
description: >
  Capture a session into a handoff file so a fresh LLM context can continue the work,
  or read an existing handoff to resume. Two modes: write (the default) captures the
  goal, decisions, rejected approaches, current state, and next action from the
  current session; read loads the existing handoff for this repo+branch back into
  context. Use when the user says "handoff", "create a handoff", "write a handoff",
  "read the handoff", "resume handoff", or wants to hand work off to a different
  agent / context / teammate.
---

# Handoff

Two modes, picked from the user's wording:

- **Write** (default — "handoff", "create a handoff", "write a handoff", any phrasing that isn't clearly read): capture the current session.
- **Read** ("read the handoff", "resume", "load the handoff"): read the existing handoff file back into context.

## File location

- **Vault:** `C:\Users\DuncanRoosma\OneDrive\SecondBrain\Work\Handoffs`
- **Archive:** `C:\Users\DuncanRoosma\OneDrive\SecondBrain\Work\Handoffs\archive`
- **Filename:** `<repo-name>--<sanitized-branch>.md` (one active handoff per repo+branch)

Use `handoff.ps1` rather than hand-building the path — it handles branch sanitization, detached HEAD, and non-git directories:

```powershell
pwsh -NoProfile -File D:\skills\handoff\handoff.ps1 -Action path      # current repo+branch handoff path
pwsh -NoProfile -File D:\skills\handoff\handoff.ps1 -Action archive   # move existing handoff to archive/ with timestamp
pwsh -NoProfile -File D:\skills\handoff\handoff.ps1 -Action list      # list all active handoffs
```

## Write mode

1. Resolve the path with `handoff.ps1 -Action path`.
2. If a file already exists there, read it — you are producing an updated iteration, not a fresh one. Note what's completed, changed, or new.
3. Gather repo state:
   - `git status -uno --short`
   - `git branch --show-current`
   - `git log --oneline -20`
   - `git diff --stat`
4. Draft the handoff from conversation context + git state using `template.md`. Fill in everything you can infer — don't ask the user about things visible in code or commits.
5. **Ask at most 1–2 questions, and only if critical context is genuinely missing.** Most valuable thing to ask about: approaches you tried mid-conversation and rejected, with reasons that aren't captured in any commit. If none of that is missing, skip the questions entirely.
6. Show the draft to the user, get confirmation.
7. Archive the old handoff (`handoff.ps1 -Action archive`), then write the new one.

## Read mode

1. Resolve the path with `handoff.ps1 -Action path`.
2. If no file exists: tell the user there's no handoff for this repo+branch and stop.
3. Read the file in full.
4. Run `git log --since="<last_updated from handoff>"` to check what's happened since it was written. If the repo state diverges from "Current state" in the handoff, trust the repo and flag the divergence.
5. Restate the goal and the next action to the user in one sentence, then continue work.

## What the handoff captures (see `template.md`)

Most actionable info at the top:

1. **Next action** — one sentence
2. **Goal & success criteria** — with the user's verbatim original ask
3. **Current state** — branch, file:line refs, what works, what's broken
4. **Decisions & rejected approaches** ← the highest-value section
5. **Open questions** — decisions still owed by the user
6. **Environment & repro** — run/test commands, services, env var names
7. **External references** — tickets, PRs, docs
8. **User preferences observed this session**

## Anti-patterns — keep these OUT

- Don't re-describe code the next agent will read anyway. Use `file.py:42` references.
- Don't summarize `git log`. Reference the commits.
- Don't include stale info that was overridden later in the conversation. Only the final state of any decision matters.
- Don't write vague status ("worked on auth"). Be specific or omit.
- Don't duplicate `CLAUDE.md`. The next agent already reads it.
- Don't write secrets — reference where to find them.
