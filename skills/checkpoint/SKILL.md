---
name: checkpoint
description: >
  Make long multi-phase work survive session limits, killed processes, and context
  loss by maintaining a durable PROGRESS.md checkpoint: phases, status, artifact
  locations, and per-phase resume instructions — updated before and after every
  phase, with all outputs persisted to disk. Three modes: start (plan phases and
  write the checkpoint), update (mark progress), resume (verify claimed state
  against disk and continue at the first incomplete phase). Use when the user says
  "checkpoint", "make this resumable", "resume", when starting any scrape,
  migration, batch job, or orchestration expected to outlive one session, or when
  picking up work a previous session left unfinished.
---

# Checkpoint

Long runs die: session limits hit, background processes get killed, context gets
compacted. The fix is discipline, not luck — durable state on disk, updated at
phase boundaries, so **any** fresh session can resume without re-deriving intent.

Modes, picked from the user's wording: **start** (default for new work),
**update** (mid-run), **resume** ("resume", "continue", "pick up where we left off").

## The checkpoint file

`PROGRESS.md` in the project root (next to the work, committed if the project is
a repo). One file per effort; a new effort gets a fresh file.

```markdown
# <effort title>
Goal: <one sentence, incl. the user's verbatim ask>
Outputs land in: <directory>

## Phases
- [x] 1. <phase> — done <what/where the artifact is>
- [>] 2. <phase> — IN PROGRESS, <what's done so far, what remains>
- [ ] 3. <phase> — resume hint: <exact command / file / next item>

## Resume notes
- <auth method that worked, rate-limit delay chosen, gotchas discovered>
```

## Start mode

1. Break the work into phases **small enough to complete comfortably in one
   sitting** (rule of thumb: ≤ 15 minutes of unattended work each). Many small
   phases beat one heroic run.
2. Each phase must end with an artifact **on disk** — a file, db rows, a wiki
   page — never only conversation output.
3. Write `PROGRESS.md` before doing anything else.

## While working (update mode)

- Mark a phase `[>]` **before** starting it, `[x]` **after verifying** its
  artifact exists on disk (file present, row count matches, page saved).
- Record discoveries that a resuming session would otherwise re-derive: working
  auth path, chosen backoff delay, IDs, decisions.
- Long loops (scrapes, batch API calls) must write incrementally — JSONL append
  or per-item db insert with retry/backoff — so a killed process loses at most
  one item, never the batch.
- Background jobs: write output to files, not just stdout, and note the output
  path in `PROGRESS.md` so a later session can find partial results.

## Resume mode

1. Read `PROGRESS.md` in full.
2. **Verify claimed state against disk before trusting it** — check the files
   exist, count the rows. Disk wins over the checklist; fix the checklist if
   they disagree.
3. Restate the goal and next phase to the user in one sentence, then continue
   at the first phase that isn't verifiably done.

## Anti-patterns

- One giant phase ("scrape everything, then process") — if it dies at 90%, you
  resume at 0%.
- Marking `[x]` because the command was issued, not because the artifact was
  verified.
- Holding intermediate results only in context/memory. If it isn't on disk, it
  doesn't exist.
- Restarting from scratch when a checkpoint exists — always read and verify it
  first.
- Updating the checkpoint only at the end of the session. The whole point is
  that the end may never come.
