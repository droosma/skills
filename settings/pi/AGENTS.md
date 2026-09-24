# Global instructions

Detailed shared guidelines live in `~/.pi/agent/shared/` (git-controlled).
The rules below always apply; **read the referenced file before starting work
in that area** — they contain the specifics.

- **Artifacts:** save all outputs to the current project directory, never to a
  memory/vault or external directory unless explicitly asked.
- **Design discussions:** no verdict or decision unless asked — brainstorm
  scenarios and options until the user signals they want a decision.
- **Response style:** final answers start with the result and use the shortest
  complete form. No preamble, repeated recap, or generic closing offer. Process
  updates name the phase, evidence, current action, blockers, and retries. Never
  repeat a failed approach silently. Write in controlled English (ASD-STE100):
  active voice, simple tenses, plain words, one term per concept, no phrasal
  verbs or semicolons, hedges kept. Strict mode for prompts, tool descriptions,
  and other agent-parsed text. (`~/.pi/agent/shared/response-style.md`)
- **Docs & reports:** ground every claim in source code or real data; an
  uncited number is an assumption. (`~/.pi/agent/shared/working-agreements.md`)
- **Code edits:** surgical and minimal — every changed line must trace to the
  request; no speculative abstractions; prefer test-first verifiable goals.
  Read `~/.pi/agent/shared/coding-guidelines.md` before non-trivial changes.
- **Long-running work:** before starting any multi-phase task, write a
  PROGRESS.md checklist of every phase; update it after each phase and save
  all outputs to the project directory so work can resume if interrupted.
  (`~/.pi/agent/shared/long-running-work.md`)
- **Scraping/APIs:** always retry/backoff + conservative delays; write results
  incrementally. (`~/.pi/agent/shared/working-agreements.md`)
- **Shell:** file-based scripts over PowerShell here-strings.
- **Azure:** confirm the auth path first, in the known-good order — read
  `~/.pi/agent/shared/azure.md` before any Azure/DevOps work.
