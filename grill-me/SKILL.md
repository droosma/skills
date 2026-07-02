---
name: grill-me
description: >
  Interview the user relentlessly about a plan or design — one question at a time, each with a
  recommended answer — until every branch of the decision tree is resolved, then record the
  decisions. If the repo documents its domain language (CONTEXT.md) or decisions (docs/adr/),
  also challenges the plan against those and updates them inline as decisions crystallise.
  Use when the user says "grill me", wants to stress-test a plan or design, wants shared
  understanding before building, or wants their thinking challenged before committing to an approach.
---

# Grill me

Nobody knows exactly what they want. The point of this session is to find out — by walking down every branch of the design tree until user and agent share one picture of what's being built. The output is a set of resolved decisions, not code.

## Before the first question

1. **Absorb what exists.** Read the plan/description the user gave. Explore the codebase for anything the plan touches. Never ask a question the code can answer — explore instead, then confirm your reading only if it's load-bearing.
2. **Check for docs mode.** If the repo has a `CONTEXT.md` (or `CONTEXT-MAP.md`) or a `docs/adr/` directory, docs mode is on (see below). The user asking for glossary/ADR updates also turns it on.
3. **Map the branches.** Privately list the decision areas the plan opens: scope and non-goals, data model, interfaces/contracts, failure modes, edge cases, migration/rollout, operational concerns. Track each as open or resolved throughout the session. Answers will spawn new branches — add them; answers will prune branches — drop them.
4. **State your understanding** of the plan in two or three sentences, then ask the first question.

## The loop

- **One question at a time.** Ask, then wait for the answer. Multiple questions at once is bewildering and lets the user dodge the hard one.
- **Order by leverage.** Start with the decision that constrains the most other decisions or carries the most risk. Leave naming, formatting, and other reversible details for last — or skip them.
- **Always give your recommended answer** with a one-line reason. You have opinions; share them. If a structured-question tool (e.g. AskUserQuestion) is available, use it with your recommendation as the first option — but keep it to one question per call.
- **Don't rubber-stamp answers.** This is the difference between grilling and note-taking:
  - When an answer has edge cases, stress-test it with a concrete scenario: "You said orders cancel atomically — what happens to a half-shipped order?"
  - When an answer contradicts an earlier decision, the code, or the docs, surface the contradiction immediately and make the user pick.
  - When you disagree, say so and argue it once. If the user holds their position after hearing the argument, defer and move on — record the decision as theirs.
- **Sharpen fuzzy language.** When the user uses a vague or overloaded term ("account", "job", "sync"), propose a precise one and make them choose.
- **Announce branch changes** briefly when an answer opens or closes a line of questioning, so the user can see the tree shrinking.

## Docs mode

Active when the repo already documents its domain (step 2) or the user asks for it.

- **Challenge against the glossary.** If `CONTEXT.md` defines a term and the user uses it differently, call it out: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"
- **Update `CONTEXT.md` inline** the moment a term is resolved — don't batch. Format: `references/CONTEXT-FORMAT.md`. Keep it a pure glossary; no implementation details.
- **Offer an ADR sparingly** — only when a decision is (1) hard to reverse, (2) surprising without context, AND (3) the result of a real trade-off. Format and numbering: `references/ADR-FORMAT.md`.
- **Create files lazily.** No `CONTEXT.md` yet? Create it when the first term is resolved. No `docs/adr/`? Create it with the first ADR.

## Ending the session

The session is done when every branch is resolved or explicitly parked — not when the questions get boring. Then:

1. **Write the decisions down.** Summarise: decisions made (with the one-line why), alternatives rejected (with why — these are invisible in git and the most valuable thing to record), and questions parked (with what unblocks them).
2. **Put the record somewhere durable.** Update the plan document if one exists; otherwise offer to write the summary to a file the user names, or into a handoff (see the `handoff` skill). In docs mode, `CONTEXT.md` and ADRs are already up to date because you updated them inline.
3. **Name the first implementation step** so the session ends pointed at action.

## Anti-patterns

- **Batching questions.** One at a time, always.
- **Interviewing about the codebase.** If `grep` can answer it, don't ask.
- **Agreeable note-taking.** Accepting every answer unchallenged produces a transcript, not a design.
- **Grilling past the point of value.** Once the load-bearing decisions are resolved, resist inventing branches to keep the interview alive.
- **Letting the decisions evaporate.** Ending with the conclusions only in chat history defeats the purpose — always produce the written record.
