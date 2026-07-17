---
name: scope-check
description: >
  Before starting substantive work, restate the request, surface assumptions on
  four axes (scope breadth, output format & destination, decision vs open-ended
  exploration, evidence bar), and confirm — one short round, not an interview.
  Prevents the classic misfires: narrowing a broad policy question to a single
  feature, delivering a verdict when brainstorming was wanted, saving artifacts
  to the wrong place, or chasing an angle already flagged as a red herring. Use
  when the user says "scope check", "confirm scope first", prefixes a large or
  ambiguous request, or before any multi-hour deliverable. For deep decision-tree
  interrogation of a design, use grill-me instead.
---

# Scope Check

A 60-second alignment pass before expensive work. The goal is to catch intent
mismatches **before** tools run, not after two interrupted redirects.

## Procedure

1. **Restate the request in your own words** — one or two sentences. If your
   restatement is wrong, the user corrects it here at zero cost.

2. **State your assumptions** on these four axes (only the ones that aren't
   explicit in the request):

   - **Breadth** — single feature vs the broader policy/system it sits in.
     When a request could be read either way, say which reading you'll take.
   - **Output & destination** — what artifact (doc, ADR, script, wiki page,
     inline answer), roughly how long, and where it gets saved. Default:
     the current project directory, never an external vault unless asked.
   - **Mode** — decision/verdict vs open-ended exploration. If the user is
     thinking out loud or asked to brainstorm, the deliverable is scenarios
     and options; do **not** converge on a conclusion until they signal it.
   - **Evidence bar** — quick take from context vs verified against source
     code / real data (see the evidence-check skill for the full treatment).

3. **Note explicit exclusions** the user has already given ("that angle is a
   red herring", "not X") and commit to honoring them.

4. **Ask at most 1–3 questions**, only where an axis is genuinely ambiguous
   AND getting it wrong would waste significant work. Everything else: state
   the assumption and proceed once confirmed.

5. On confirmation, start. **Mid-work rule:** if scope wants to grow, or an
   angle starts looking like a flagged red herring, surface it in one sentence
   and let the user steer — don't silently expand or pursue.

## Anti-patterns

- Turning this into a long interview — that's `grill-me`. Scope check is one
  round.
- Asking about things inferable from the repo, git history, or CLAUDE.md.
- Proceeding on an unconfirmed guess for work that takes hours to redo.
- Confirming scope, then drifting from it without flagging.
- Running a scope check on trivial requests — a one-file edit doesn't need one.
