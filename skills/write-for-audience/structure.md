# Document structure

How to organize a document so readers find what they came for. Four topics: putting the point first, writing for scanners, choosing the document type, and layering for mixed audiences.

---

## Bottom line up front (BLUF)

Put the conclusion, decision, or key fact in the first sentences — then support it. The U.S. military standardized this as BLUF; journalism calls it the inverted pyramid. Both exist because of the same two facts about readers:

- Attrition: readership drops with every paragraph. Whatever is at the end reaches the fewest people.
- Memory: people best remember the beginning of what they read (the serial-position effect). Put the message where memory is strongest.

BLUF is fractal — apply it at every level:

- **Document:** first paragraph answers "what is this and what's the takeaway?"
- **Section:** first sentence states the section's conclusion; the rest supports it.
- **Paragraph:** first sentence carries the point (this doubles as the scanner's path — see below).
- **Sentence:** lead with the information-carrying words. "Rotate the API key if the audit fails", not "In the event that a failure of the audit occurs, it will be necessary to rotate the API key."

❌ *We investigated the memory growth reported last week. We profiled the worker over 48 hours and compared heap snapshots across deploys. We found that the HTTP client pool was never releasing connections. So the fix is to cap the pool.*
✅ *The memory leak is fixed: the HTTP client pool never released connections, and we've capped it. Details: we profiled the worker over 48 hours…*

The one exception: tutorials. A learner needs steps in execution order, not importance order. BLUF still applies to the tutorial's *introduction* (what you'll build, what you need), just not to the steps.

---

## Writing for scanners

Twenty years of Nielsen Norman Group eyetracking research says the same thing: **people don't read online, they scan.** On an average page visit, people read about a quarter of the words. They sweep across the top, then down the left edge, fixating on whatever stands out (the F-pattern). If your key information sits mid-paragraph on the right-hand side of a long text block, it effectively doesn't exist.

You don't fight scanning; you build for it:

1. **Headings that carry information.** A reader skimming only the headings should get the document's story. "Rollback takes 15 minutes and loses in-flight jobs" beats "Rollback considerations". Questions work well as headings when readers arrive with questions ("What happens to existing sessions?").

2. **Front-load everything.** First paragraph of the doc, first sentence of each paragraph, first words of each list item and link. Scanners read beginnings; put the payload there.

3. **Lists for parallel items, prose for reasoning.** Three or more parallel facts (options, steps, criteria) go in a list — scanners see the structure instantly. But an argument, a trade-off, or a causal chain belongs in prose; bulleting it hides the connections. A document that is *all* bullets has the same problem as one that is all prose.

4. **Tables for lookups.** When readers will come to compare or look up values (options × properties, versions × support dates), a table beats both prose and lists.

5. **Bold sparingly, for search targets.** Bold the terms a scanner is hunting for (a setting name, a deadline, a warning) — not for emphasis. If a page has bold everywhere, it has bold nowhere.

6. **One page, one purpose.** Scanners decide in seconds whether a page has what they need. A page that covers three loosely related things fails that test three ways. Split it.

---

## Choosing the document type (Diátaxis)

The Diátaxis framework identifies four reader needs, and a distinct document shape for each. The single most useful discipline it offers: **don't mix shapes in one document.**

| | Reader is **studying** | Reader is **working** |
|---|---|---|
| **Practical steps** | **Tutorial** — a lesson | **How-to guide** — a recipe |
| **Knowledge** | **Explanation** — background & why | **Reference** — facts to look up |

**Tutorial** — for a beginner acquiring skill. One guaranteed-to-work path, concrete steps, visible results early and often. The author is responsible for the learner's success: no choices, no detours, no "alternatively you could…". Minimal explanation — link it.

**How-to guide** — for a competent person with a goal. Named after the goal ("Rotate credentials without downtime"). Assumes the basics; states prerequisites, then steps. Addresses a real-world task, including its messy conditionals — but doesn't teach and doesn't digress into theory.

**Reference** — for looking up facts. Complete, accurate, consistent in structure, shaped like the thing it describes. No persuasion, no instruction, no opinion. Boring is a feature: readers consult reference material like a map.

**Explanation** — for understanding. The why: design rationale, trade-offs, context, alternatives considered, constraints. The only type where discussion and opinion belong. Readers arrive curious, not blocked — it can afford to be read at leisure.

Symptoms of mixing: a tutorial that stops to explain theory (learner loses momentum); a how-to that teaches basics (expert wades through padding); a reference page with narrative (lookup becomes excavation); an explanation with embedded steps (nobody can find them later).

Audience interacts with type: non-technical readers mostly need explanation and the occasional how-to; highly technical readers consume all four but live in reference and how-to. Whatever the type, the audience profile (see `audiences.md`) still sets vocabulary and depth.

---

## Mixed audiences: layering

When one document genuinely serves several audiences (incident reports, ADRs, release notes, project proposals), **never write for the average** — layer, so each reader takes their own path and stops when satisfied. This is progressive disclosure, and NN/g's research on it shows it improves learnability, efficiency, and error rate: show what most readers need first, defer the rest to a clearly labelled next layer.

Patterns, in order of how often they're the right answer:

1. **Summary + depth sections.** Open with a plain-language summary written for the least technical reader — the whole story in a few sentences, no jargon. Then labelled sections that go deeper. The label does the routing: "Technical details", "For integrators", "Impact on support workflows". Each layer must stand alone; don't make the executive read the stack trace to find the customer impact, and don't make the engineer reverse-engineer specifics from the summary's simplifications.

2. **Parallel documents, cross-linked.** When the audiences' needs barely overlap (user-facing release notes vs. API changelog), one document per audience beats sections in one document. Link them so each audience can find the other view.

3. **Inline expansion.** Collapsible sections (`<details>` in Markdown/HTML), footnotes, or "see appendix" for detail that only some readers want, at the exact point where they'd want it. Good for optional depth; bad as the main structure — content hidden in collapsed sections is invisible to scanners and to search/Ctrl-F on some platforms.

Two rules that keep layers honest:

- **The summary must be true.** Simplified, yes; wrong, no. If the plain version says "no customer data was exposed" the technical section can't reveal "except the email addresses in the logs". Experts read the summary too — a summary that contradicts the details destroys trust in both.
- **Layers go plain → technical, never the reverse.** The non-technical reader gives up if they must cross a technical layer to reach their part; the technical reader skips an executive summary without cost.
