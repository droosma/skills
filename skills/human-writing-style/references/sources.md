# Sources: AI writing pattern references

External resources that document AI writing tells. Use these to discover new patterns and keep this skill current.

## How to use this file

**Adding a source:** Append a new entry to the list below with the URL, a short description, and what it's good for.

**Updating the skill:** When you want to refresh the skill's rules:

1. Read this file to get the source list.
2. Fetch each source (or the ones that seem most relevant).
3. Compare what you find against the existing rules in `rules.md`, vocabulary in `vocabulary.md`, and the self-check in `SKILL.md`.
4. Identify patterns that aren't covered yet or existing rules that need stronger examples.
5. Propose additions or edits to the appropriate file.

The goal is incremental improvement: add what's missing, strengthen what's weak, don't duplicate what's already there.

---

## Sources

### tropes.fyi

- **URL:** https://tropes.fyi/
- **Directory:** https://tropes.fyi/directory
- **What it covers:** Named and categorized AI writing tropes with examples. Organized by category (sentence-structure, formatting, paragraph-structure, composition, tone, word-choice). Each trope has a dedicated page at `https://tropes.fyi/tropes/{slug}`.
- **Good for:** Discovering structural and compositional patterns (not just word-level tells). Particularly strong on: rhetorical self-QA, short punchy fragment abuse, fractal summaries, one-point dilution, listicle-in-prose, invented concept labels, false vulnerability, dead metaphor beating.
- **Last reviewed:** 2026-05-22

### Wikipedia: Signs of AI writing

- **URL:** https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing
- **What it covers:** A field guide to AI writing tells observed on Wikipedia. Covers significance inflation, legacy/trend language, superficial analyses, over-attribution, social media presence mentions, canned emphasis on notability, formatting tells.
- **Good for:** Word-level and phrase-level tells with before/after examples from real articles. Strong on the "significance machine" and vague attribution patterns. Also covers formatting tells (bold abuse, em dashes, heading capitalization).
- **Last reviewed:** 2026-05-22

### Load Bearing: The load-bearing vocabulary of Claude

- **URL:** https://louisabraham.github.io/load-bearing/
- **Source:** https://github.com/louisabraham/load-bearing
- **What it covers:** A continuously updated analysis of vocabulary clusters in public GitHub pull request descriptions. It identifies a fast-growing Claude-associated writing register through word distributions rather than a hand-written list of bad words.
- **Good for:** Spotting clusters in technical and code-review prose, especially stance adverbs, argumentative verbs, and compressed engineering compounds. Use it as evidence for a small curated watchlist, not as a blacklist: the published ranking contains many ordinary words and legitimate technical terms.
- **Last reviewed:** 2026-08-28

### StoryScope: Investigating idiosyncrasies in AI fiction

- **Paper:** https://arxiv.org/abs/2604.03136
- **HTML:** https://arxiv.org/html/2604.03136
- **Repository:** https://github.com/jenna-russell/storyscope
- **Dataset:** https://huggingface.co/datasets/jjrussell10/storyscope
- **What it covers:** A comparison of 10,272 human-written stories with five AI mirrors per prompt, producing 61,608 stories and 304 narrative features across plot, agents, events, time, setting, revelation, perspective, social relationships, situatedness, and style.
- **Good for:** Narrative-level patterns that word lists miss. The strongest reusable findings concern thematic over-explanation, tidy single-track plots, moral closure, chronological simplicity, revelation depth, escalation, intertextual specificity, and the tendency to express emotion through bodies and settings.
- **Scope limit:** The stories average roughly 5,000 words. The results support guidance for fiction and other narrative prose, not a general detector or mandatory style guide for emails, documentation, marketing copy, or short posts.
- **Last reviewed:** 2026-09-01
