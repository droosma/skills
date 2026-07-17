---
name: observable-language
description: >
  Audit the user's own writing for container words — vague abstract nouns
  (controle, eigenaarschap, kwaliteit, professioneel, senior, sterk /
  ownership, quality, professional, strategic, strong, impact) that sound
  meaningful but name no observable behaviour, so nobody can act on or steer
  by them. Rewrites them into filmable behaviour using the golden question and
  the Situation-Behavior-Impact scaffold. Bilingual (Dutch + English).
  ON-DEMAND ONLY — never auto-trigger on ordinary writing. Use only when the
  user explicitly asks: "check for container words", "containerwoorden",
  "observable-language", "make this concrete / observable / specific",
  "audit this feedback for vague language", "waaraan zie je dat", "is this
  container language", or when reviewing feedback, evaluations, 360s, or
  competency / framework criteria for actionability. Complements
  human-writing-style (that strips AI tells from generated prose; this audits
  human-written feedback for non-observable language) — different lane.
---

# Observable language

A **container word** is an abstract noun that sounds meaningful but names no observable behaviour. Everyone pours their own meaning into it, so nobody can act on it or steer by it.

> "Je hebt de backlog onder controle."

*Controle* is a container. It feels like praise, but the reader learns nothing: what would you see someone doing when the backlog is "under control" versus when it isn't? Until that is answered, the sentence can't be acted on, disputed, or coached against.

This skill finds container words in the user's writing and rewrites them into **filmable behaviour**. It runs **only when asked** — it is not a pass on every piece of prose.

The lineage (full citations in `references/sources.md`): *containerbegrip* is a Van Dale headword; the concrete/abstract split is Hayakawa's **ladder of abstraction**; freezing a process into an abstract noun is a **nominalisation** in the NLP Meta Model; "can you film it?" is the **Dead Man's Test** and operational definitions from behaviour analysis; the rewrite scaffold is **SBI** (Situation-Behavior-Impact) from the Center for Creative Leadership.

---

## The method

### 1. Detect — the camera test

For every abstract noun, ask: **can you point a camera at it? Could a dead man do it?** If you can't film it, it's a candidate container word.

| You can film it | You can't film it (container) |
|---|---|
| code review, refinement, deployment, standup | controle · eigenaarschap · kwaliteit · professioneel |
| "closes 4 stories a sprint", "reviews within a day" | control · ownership · quality · professionalism · leadership |

The test decides, not any fixed list of words: a word not shown here can still be a container (if you can't film it, treat it as one), and any word here is fine when it's grounded (step 2).

### 2. Judge in context — don't over-flag

Abstraction is not the enemy. Good writing uses the whole ladder; the problem is an abstraction that is **never brought down**. Flag a container word only when it stands as an ungrounded conclusion.

❌ *"Ze neemt goed eigenaarschap."* — conclusion, no behaviour. **Flag it.**
✅ *"Ze neemt eigenaarschap: ze signaleert risico's vroeg en komt met een voorstel voordat iemand erom vraagt."* — the abstraction is immediately grounded in filmable behaviour. **Leave it.**

If the observable behaviour is present in the same breath, the container word is a fine headline. Don't strip it.

### 3. Ask the golden question

For each flagged word, surface the question that recovers the missing behaviour:

> **"Waaraan zie je dat?"** / **"What would I see you doing if that were true?"**

Variants: *Wat doet iemand dan precies? · Hoe merk je dat? · Wat zou anders zijn als het níet zo was? / What specifically makes you say that? · How would you notice?*

### 4. Rewrite to observable behaviour (SBI)

Turn the answer into **Situation → Behaviour → Impact**: where/when, the behaviour you could film, and the effect it had. Keep the output in the language of the input.

❌ *Duncan neemt veel eigenaarschap.*
✅ *Duncan signaleert risico's vroeg, betrekt de juiste stakeholders en komt met een voorstel voordat anderen erom vragen.*

❌ *You have the backlog under control.*
✅ *Stories stay open under two sprints on average, stakeholders always know the top priority, and refinement sessions are prepared — so the team rarely gets surprised.*

More worked rewrites (feedback line, framework criterion, English case) in `examples.md`.

---

## When NOT to flag

- **Grounded abstractions** — the behaviour is stated nearby (step 2).
- **Terms of art** — a word that is precisely defined in the domain (a named competency level, a metric with a definition). If it has a shared, checkable meaning here, it isn't a container.
- **Headings and titles** — a section called "Ownership" is a label, not a claim.
- **Quoted material** — don't rewrite what someone else said; flag it for a follow-up question instead.
- **Casual, low-stakes prose** — this skill is for feedback, evaluations, and criteria people are judged and steered by. Don't audit a chat message unless asked.

---

## Output modes

- **Audit** (default): a list. For each hit — the container word, one line on why it's vague here, the golden question to ask, and a suggested observable rewrite. Group by sentence; don't rewrite the whole document.
- **Correct**: rewrite the passage inline, replacing each ungrounded container word with filmable behaviour, and note where you had to invent a plausible behaviour the user must confirm (you can't film what you weren't told).

When you don't know the concrete behaviour behind a container word, **say so and ask** — don't fabricate specifics. The honest move is the golden question, not a confident guess.

---

## Self-check

Before returning output, verify each item. If one fails, revise and re-check.

1. **Camera test.** Does every word you flagged genuinely fail the camera test, and does every word you left grounded pass it?
2. **No over-flagging.** Did you leave abstractions that are operationalised in the same breath? Terms of art with a shared definition here?
3. **Golden question present.** Does every flag carry a "waaraan zie je dat?" that would actually recover the behaviour?
4. **Rewrites are filmable.** Is each suggested rewrite something you could point a camera at — a behaviour, ideally with situation and impact (SBI) — not another abstraction?
5. **No fabricated specifics.** Where you invented a behaviour or number, did you mark it as needing the user's confirmation rather than asserting it?
6. **Language match.** Is the output in the same language as the input (Dutch in, Dutch out)?
7. **Scope.** Is this feedback/evaluation/criteria-grade writing the user asked you to audit — not ordinary prose you decided to police?

---

## Further reference (sibling files)

Not auto-loaded with this skill. Read on demand with the file-reading tool.

- **`examples.md`**: Full before/after rewrites — a 360 feedback line, the "backlog onder controle" framework criterion, and an English case — each walked through detect → golden question → SBI rewrite. **Read when** rewriting anything longer than a single sentence, or to see how the steps interact.
- **`references/sources.md`**: The validated lineage with citations (Van Dale, Hayakawa's ladder of abstraction, NLP Meta Model nominalisations, the Dead Man's Test and its critique, CCL's SBI). **Read when** the user asks to update, extend, or challenge this skill and wants the evidence.
