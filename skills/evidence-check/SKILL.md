---
name: evidence-check
description: >
  Adversarially verify every claim in a report, design doc, cost estimate, or plan
  against primary sources — source code, real usage data, official docs/pricing —
  until zero unsupported claims remain, and emit a claim-to-source citation table.
  One agent role drafts, a hostile role attacks each claim and tries to refute it.
  Use when the user says "evidence check", "fact-check this", "verify this report",
  "ground this in evidence", "attack every claim", "is this defensible", or before
  any stakeholder-facing document ships. Pairs with the claim-verifier agent for
  parallel per-claim verification.
---

# Evidence Check

Turn a plausible-sounding document into a defensible one. The core move is
**attack, don't confirm**: for each claim, actively try to refute it against a
primary source. A claim survives only if the refutation attempt fails.

## Inputs

1. The document (or draft) under review.
2. Where primary sources live: repo path(s), read-only query scripts, data files,
   official docs/pricing URLs. Ask if not obvious — never guess a source location.

## Procedure

### 1. Inventory the claims

Extract **every** falsifiable statement into a table. Skip pure opinions, but log
them separately so they can be labelled as such in the doc. Classify each claim:

| Class | Verified against |
|---|---|
| `code` | actual source (Grep/Read, exact file:line) |
| `data` | real usage/telemetry/db numbers (read-only queries) |
| `external` | official vendor docs, pricing pages, standards |
| `assumption` | nothing available — must be labelled in the doc |

### 2. Attack each claim

For each claim, attempt refutation against its primary source:

- `code`: find the actual implementation. Config values, defaults, and behavior
  must match what the code does **today**, not what a README or the doc says.
- `data`: re-run the query. Numbers must match within the doc's stated precision.
- `external`: fetch the current official page. Pricing and limits drift — a
  number without a dated source is unsupported.

With more than ~8 independent claims, fan out `claim-verifier` subagents in
parallel — one claim each, so no verifier anchors on another's verdict.

### 3. Verdicts

- **SUPPORTED** — refutation failed; record the citation (file:line, the exact
  query + result, or URL + date checked).
- **REFUTED** — counter-evidence found; record it. The doc must change.
- **UNVERIFIABLE** — no primary source reachable. The doc must label it an
  assumption, not state it as fact.

### 4. Fix and loop

Apply fixes: correct refuted claims, label assumptions, delete or demote angles
the evidence doesn't support (red herrings), replace hand-wavy prose with the
hard numbers found during verification. Then re-attack anything that changed.
Do not conclude until the table shows zero REFUTED and zero unlabelled
UNVERIFIABLE claims.

### 5. Deliver

Ship the corrected doc plus the claim-to-source table (appendix or sidecar file
next to the doc, e.g. `<doc-name>.evidence.md`). Save to the current project
directory.

## Anti-patterns

- Don't soften a refuted claim into hedged prose ("likely", "should be") — fix
  the number or delete the claim.
- Don't cite the document itself, a summary of it, or a previous conversation as
  evidence. Primary sources only.
- Don't accept "plausible" as "verified". A claim you couldn't check is
  UNVERIFIABLE, not SUPPORTED.
- Don't give an overall verdict on the doc before the table is complete.
- Don't verify a cherry-picked sample when the user asked for a full check —
  if you bound the sweep, say exactly what was skipped.
