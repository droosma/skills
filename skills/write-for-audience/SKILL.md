---
name: write-for-audience
description: >
  Calibrate documentation and explanatory text to its target audience (non-technical,
  technical-adjacent, or highly technical) and apply evidence-based readability practices
  so readers actually understand it. Use whenever the user asks to write, rewrite, review,
  or improve documentation, READMEs, guides, proposals, announcements, or explanations,
  or names an audience ("for management", "for the team", "for stakeholders", "for
  developers", "for a general audience"). Also use when the user says "make this clearer",
  "make this understandable", "explain this to X", "simplify this", "too technical",
  "not technical enough", or asks who a document should be written for. If the target
  audience is not stated and cannot be confidently inferred, ask before writing.
  Complements human-writing-style: this skill decides what to say and how to structure
  it for the reader; human-writing-style removes AI tells from the prose. Apply both
  to any prose output.
---

# Write for the audience

Most documentation fails for one reason: it is written from the author's head, not the reader's. The author knows the system, so they skip steps, use unexplained terms, and bury the point. Psychologists call this the **curse of knowledge**: once you know something, you cannot easily imagine not knowing it. Steven Pinker calls it "the single best explanation of why good people write bad prose."

This skill counteracts that. The method:

1. **Identify the audience** (ask if unclear).
2. **Identify the reader's goal** and pick the right document shape.
3. **Apply the universal readability rules** (they hold for every audience).
4. **Calibrate to the audience profile** (vocabulary, depth, structure).
5. **Run the self-check.**

Google's technical writing course reduces it to one equation worth memorizing:

> good documentation = knowledge the reader needs for the task − knowledge the reader already has

Everything below is about getting both terms of that subtraction right.

---

## Step 1: Identify the audience

Three profiles cover most documentation. Full calibration details per profile live in `audiences.md` — read it before writing anything longer than a paragraph.

| Profile | Who | They read to answer |
|---|---|---|
| **Non-technical** | Management, clients, end users, general public | "What does this mean for me, and what do I do?" |
| **Technical-adjacent** | PMs, support, ops, analysts, tech-savvy stakeholders. Know common terms (API, database, deploy, cloud), not specialist ones | "How does this affect the systems and processes I own?" |
| **Highly technical** | Developers, engineers, architects working in or near this domain | "How do I do this correctly, and what are the gotchas?" |

**When to ask.** If the user named the audience or the context makes it obvious (a README in a code repo → technical; "email to the client" → probably non-technical), proceed. Otherwise ask before writing — a wrong audience guess wastes the whole draft. Offer the three profiles above plus "mixed audience" as options (use a structured question tool like AskUserQuestion if available). Also ask when the signal is contradictory, e.g. "explain our architecture to the sales team."

**Mixed audience?** Never write for the average — a middle version serves nobody. Layer instead: plain-language summary up front for everyone, labelled detail sections for specialists. See "Mixed audiences" in `structure.md`.

---

## Step 2: Identify the reader's goal and document shape

A reader arrives with one of four needs (the Diátaxis framework):

- **Learning** something new → tutorial: guided, safe, one path, guaranteed success.
- **Getting a task done** → how-to guide: goal-named, steps, assumes competence.
- **Looking up a fact** → reference: complete, accurate, no narrative.
- **Understanding why** → explanation: background, reasoning, trade-offs.

Don't mix these in one document — a how-to that pauses for theory fails the person mid-task, and a reference page that teaches fails the person looking something up. Pick one; link to the others. Details in `structure.md`.

---

## Step 3: Universal readability rules

These are backed by reading research and hold for **every** audience, including experts. Plain language is not dumbing down: Nielsen Norman Group's studies found that even highly literate readers and domain specialists find information faster and prefer it in plain language. Simplify the language, never the content.

1. **Bottom line up front.** Put the most important information first — in the document, in each section, in each paragraph. Readers remember beginnings best, and many never reach the end. (Military BLUF, journalism's inverted pyramid.)

2. **Write for scanning, not reading.** Eyetracking research shows people read roughly a quarter of the words on a page. Meaningful headings (a reader should get the gist from headings alone), front-loaded first sentences, and lists for parallel items are what make scanning work.

3. **Short sentences, one idea each.** At an average of ~14 words per sentence, comprehension exceeds 90%; it drops fast beyond that. Flag any sentence over 25 words and try to split it (GOV.UK's tested limit).

4. **Short paragraphs, one topic each.** First sentence carries the point; a scanner reading only first sentences should still follow the argument.

5. **Active voice, strong verbs.** "The service rejects invalid tokens", not "invalid tokens are rejected by the service". Prefer verbs over nominalizations: "decide", not "make a decision".

6. **Common words.** Eyetracking shows a long word (8–9 letters) makes readers skip the short words after it. "Use", not "utilize"; "start", not "initiate" — for experts too.

7. **Respect working memory.** Readers hold about four new chunks at once. Introduce a few concepts, anchor them with an example, then continue. A paragraph that introduces six new terms loses everyone.

8. **Concrete over abstract.** An example, a number with context, or a named scenario beats an abstract description. If you can't give a concrete instance of a claim, question the claim.

9. **Beat the curse of knowledge.** You cannot judge your own text's clarity — you know too much. Reread as the target reader: every term, every assumed step, every "obviously". Better: have someone matching the audience read it. In their own words, what does it say? If they can't say, rewrite.

---

## Step 4: Calibrate to the audience

The one-line version of each profile (full treatment with ❌/✅ examples in `audiences.md`):

- **Non-technical:** outcomes and decisions, not mechanisms. Zero unexplained jargon. Analogies to familiar experience. Lead with what it means for them. Plain, not patronizing — assume missing context, never missing intelligence.
- **Technical-adjacent:** common terms fine as-is; specialist and internal terms get a one-clause gloss on first use. Interface-level, not implementation-level. This is the easiest audience to miscalibrate — when in doubt, gloss.
- **Highly technical:** precision beats simplicity — use the exact term of art. Skip the basics; link background instead of inlining it. Lead with the common case, then edge cases. Exact commands, versions, defaults, limits, copy-pasteable code. Plain sentence structure still applies; experts scan hardest of all.

---

## Self-check

Before returning output, verify each item. If one fails, revise and re-check.

1. **Audience named.** Do you know who this is for? If you guessed, was the signal strong enough — or should you have asked?
2. **BLUF.** Does the first paragraph deliver the single most important thing? Would a reader who stops after it still get the essential message?
3. **Headings test.** Reading only the headings, does the document's story come through?
4. **First-sentence test.** Reading only each paragraph's first sentence, does the argument still hold?
5. **Jargon audit.** For each technical term: does this audience profile know it? If not, is it glossed on first use (technical-adjacent) or removed/explained (non-technical)? For highly technical readers: is every term the *correct* term?
6. **Acronym audit.** Every acronym spelled out on first use, or dropped?
7. **Sentence length.** Any sentence over 25 words — can it split?
8. **Assumed steps.** Any place where the reader must already know an unstated step, tool, or fact to follow along? (This is the curse of knowledge leaking through.)
9. **Concreteness.** Does every major claim have an example, number, or scenario attached?
10. **Goal match.** Does the document shape match the reader's need (learn / do / look up / understand) without mixing shapes?
11. **Condescension check** (non-technical and technical-adjacent): any "simply", "just", "obviously", "as everyone knows"? Cut them — if it were simple for this reader, they wouldn't be reading the doc.
12. **Expert-respect check** (highly technical): any basics explained inline that this audience learned years ago? Replace with a link or delete.

Then apply the **human-writing-style** skill's self-check to the prose itself — audience calibration and AI-tell removal are separate passes, and documentation needs both.

---

## Further reference (sibling files)

Not auto-loaded. Read on demand with the file-reading tool.

- **`audiences.md`**: Full per-audience calibration — what each profile knows, wants, and hates, vocabulary rules, ❌/✅ rewrites of the same passage for all three audiences. **Read when** writing anything longer than a paragraph, or when unsure how far to simplify or how much to gloss.
- **`structure.md`**: Document structure — BLUF and the inverted pyramid, writing for scanners, heading craft, the Diátaxis document types, and layering for mixed audiences. **Read when** structuring a new document, restructuring an existing one, or writing for a mixed audience.
- **`references/sources.md`**: The research behind these rules (plain language guidelines, eyetracking studies, GOV.UK evidence, Diátaxis, Google's tech writing course). **Read when** the user asks to update or extend this skill, or challenges a rule and wants the evidence.
