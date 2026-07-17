# Audience profiles: full calibration

Three profiles, plus how to handle a mix. For each: what they know, what they're reading to find out, what loses them, and concrete vocabulary and structure rules.

A profile is a starting point, not a box. Google's technical writing guidance warns that knowledge diverges quickly even within one role — two "developers" can differ more than a developer and a PM. When you know specifics about the actual readers (they're Java developers new to cloud; they're a board that includes a former CTO), let the specifics override the profile.

---

## Non-technical

**Who:** management, executives, clients, end users, sales, HR, the general public.

**What they know:** their own domain deeply — budgets, customers, legal exposure, their daily workflow. Nothing about yours. They use software constantly but have no model of how it works inside, and don't need one.

**What they're reading to find out:** *What does this mean for me? What changed? What do I need to decide or do? What does it cost, what's the risk, when does it happen?*

**What loses them instantly:**
- One unexplained technical term. They don't skip it and keep going — they stall, feel the document isn't for them, and stop reading.
- Mechanism-first explanations. They asked what and why; you answered how.
- Undefined acronyms. To an outsider, an acronym is a password they don't have.

### Rules

1. **Outcomes, not mechanisms.** Describe what the reader sees, gains, loses, or must do. The internals only appear if a decision depends on them.

   ❌ *We migrated the session store from sticky in-memory sessions to a Redis-backed distributed cache.*
   ✅ *Users will no longer get logged out when we release updates. Releases can also happen during business hours now instead of at night.*

2. **Zero unexplained jargon.** If a technical term is unavoidable (it will come up in meetings, it's in the contract), define it in one plain clause the first time and reuse it consistently. Otherwise replace it with the plain-language thing it does.

3. **Spell out or drop acronyms.** First use: full words, acronym in parentheses only if the reader will encounter it again. If it appears once, don't introduce the acronym at all.

4. **Analogies to familiar experience.** The most powerful tool for this audience. Map the unknown onto something they use daily — but pick one analogy and keep it consistent; switching analogies mid-document is worse than none.

   ✅ *An API is like a restaurant menu: it lists what you can ask the kitchen for, without you needing to know how the kitchen works.*

5. **Numbers need context.** "Latency dropped from 800ms to 120ms" means nothing here. "Pages that took about a second now load instantly" does. Comparisons, fractions, and before/after beat raw figures.

6. **Aim low on reading level, high on respect.** Plain-language research (including medical communication, where stakes are highest) recommends roughly grade 6–8 reading level for general audiences. That constrains *sentence structure and word choice*, never depth or honesty. This reader may control your budget; assume missing context, never missing intelligence. Cut every "simply", "just", and "obviously".

7. **Structure: short, decision-shaped.** Bottom line in the first two sentences. Then: what this means for you → what happens next → what we need from you. One page beats five. If detail must exist, append it clearly labelled so the main text stays clean.

---

## Technical-adjacent

**Who:** product managers, support engineers, ops and delivery staff, data analysts, technically minded stakeholders, developers from a *different* domain. Familiar with common technical vocabulary; not with your specialty's.

**What they know:** what an API, database, server, deployment, integration, or cloud service *is* and roughly what it's for. How systems connect at the box-and-arrow level. What they don't have: your specialty's terms of art, your internal service names, or the implementation layer.

**What they're reading to find out:** *How does this affect the systems, processes, and people I'm responsible for? What do I tell my stakeholders? What breaks, what changes, what do I need to plan for?*

**This is the easiest audience to miscalibrate.** Write as for experts and you lose them on specialist terms; write as for non-technical readers and you waste their time and annoy them by explaining what a database is. The failure is invisible, too — they're used to partially understanding technical documents and won't complain. They'll just take away less than you intended.

### Rules

1. **Common terms: use freely, don't define.** API, database, server, cloud, deploy/release, frontend/backend, integration, uptime, bug, environment, repository, encryption, latency (as "delay"). Defining these reads as condescension.

2. **Specialist and internal terms: one-clause gloss on first use.** This is the signature move for this audience — the term plus a compressed definition, inline, then use the term freely.

   ✅ *Jobs go through the message queue (a buffer that holds work until a worker is free), so a traffic spike delays processing instead of dropping requests.*
   ✅ *The change makes the endpoint idempotent — calling it twice has the same effect as calling it once — so retries are now safe.*

   **When in doubt, gloss.** A reader who knew the term skims past six words; a reader who didn't just stayed with you. The cost is asymmetric.

3. **Internal names never travel bare.** Service names, team codenames, project names mean nothing outside your team. First use: what it is, then the name. *"The billing reconciliation service (internally: Ledger) …"*

4. **Interface level, not implementation level.** Describe what components do and how they connect, not how they're built. This reader can hold "the sync service pulls from the CRM every 15 minutes"; they don't need the retry strategy — unless it affects something they own, in which case state the *consequence*: "if the CRM is down, data can be up to an hour stale."

5. **Box-and-arrow diagrams earn their space here** more than for any other audience. Components and data flows, not class internals.

6. **Impact framing.** Every technical fact should connect to something in their world: a process, a customer-visible behavior, a timeline, a cost. If a paragraph contains no such connection, ask why this audience needs it at all.

---

## Highly technical

**Who:** developers, engineers, architects, SREs working in or adjacent to this domain. They may know the general field better than you and just lack your project's specifics.

**What they're reading to find out:** *How do I do this correctly? What are the exact parameters, defaults, and limits? What's non-obvious — the gotchas, the constraints, the reasons behind surprising decisions?*

**What loses them:**
- Explaining basics. Hand-holding reads as either padding or condescension, and it buries what they came for.
- **Imprecision.** A "simplified" term that's slightly wrong destroys trust in the whole document. This audience runs on precision; one detected inaccuracy and they stop believing the rest.
- Burying the common case under exhaustive generality.

### Rules

1. **Exact terms of art, no substitutes.** If it's optimistic locking, say optimistic locking — not "a clever conflict-avoidance technique". The precise term is the *fastest* form of communication here: it invokes everything the reader already knows.

2. **Don't explain the basics — link them.** Assume competence in the field; provide their missing piece only. If some readers might lack background, link it ("assumes familiarity with X; see …") instead of inlining it. This keeps the doc fast for the majority and rescues the minority.

3. **Lead with the common case.** The path 90% of readers need comes first, complete and copy-pasteable. Edge cases, advanced options, and escape hatches come after, clearly separated. (The pattern that makes Stripe's docs the industry benchmark.)

4. **Specifics are the content.** Exact commands, request/response examples, version numbers, defaults, limits, timeout values, error messages *verbatim* (they get googled and grepped). Code samples must run as pasted — a broken sample is worse than none.

5. **Document the why for anything surprising.** Experts trip on decisions that look wrong without context. One sentence of rationale ("we poll instead of using webhooks because the upstream API caps webhook consumers at 10") prevents both confusion and well-intentioned "fixes".

6. **State gotchas explicitly — never make the reader infer a footgun.** "Deleting a key is eventually consistent: reads may return the value for up to 30s" beats discovering it in production.

7. **Plain prose still applies.** Expertise raises tolerance for dense *content*, not for bad *writing*. NN/g's research holds for experts — they scan hardest of all, they prefer short sentences and active voice, and they find answers faster in plain language. Complex jargon in simple sentences: yes. Simple ideas in complex sentences: never.

   ❌ *Utilization of the caching layer facilitates a reduction in database load.*
   ✅ *The cache cuts database load by about 60% (measured at p95 traffic).*

---

## One passage, three audiences

The same change, calibrated three ways.

**Non-technical:**
> Starting next month, the reports page loads in about two seconds instead of thirty. We fixed the part of the system that was recalculating everything from scratch each time someone opened a report. Nothing changes in how you use the page.

**Technical-adjacent:**
> Report generation now uses a pre-computed cache (results are calculated ahead of time and stored) instead of querying the live database on every page load. Reports load in ~2s instead of ~30s. Trade-off to be aware of: data in a report can be up to 15 minutes old. If a customer needs live figures, the "refresh" button forces a recalculation.

**Highly technical:**
> Report queries now read from a materialized view refreshed every 15 min (`REFRESH MATERIALIZED VIEW CONCURRENTLY`, so reads don't block). p95 load time dropped 31s → 1.8s. The `?fresh=true` query param bypasses the view and hits the base tables — it's rate-limited to 10/min per org because it restores the old full-scan cost. Staleness is bounded by the refresh interval plus refresh duration (~40s at current volume).

Notice what stays constant: bottom line first, short sentences, active voice, concrete numbers. Only the vocabulary, depth, and what-counts-as-the-point change.

---

## Mixed audiences

Common cases: an incident report read by engineers and executives; an architecture decision record read by developers and auditors; release notes read by users and integrators.

**Never average.** A document pitched "in the middle" over-explains for experts and under-explains for everyone else — it serves nobody. Layer instead; see `structure.md` ("Mixed audiences: layering") for the patterns: plain summary first, labelled depth sections, progressive disclosure.
