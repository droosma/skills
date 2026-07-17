# Research sources

The evidence behind this skill's rules. Read when updating or extending the skill, or when a rule is challenged and you need the source. Verified July 2026; URLs can rot — search for the title if a link fails.

## Audience analysis & the curse of knowledge

- **Google Technical Writing One — Audience** — https://developers.google.com/tech-writing/one/audience
  The "good docs = needed knowledge − current knowledge" equation; defining audiences by role *and* proximity to knowledge; curse-of-knowledge in engineering docs; guidance for global/ESL readers (simple words, no idioms or culture-bound metaphors).
- **Steven Pinker on the curse of knowledge** — https://www.psychologicalscience.org/observer/the-curse-of-knowledge-pinker-describes-a-key-cause-of-bad-writing (see also *The Sense of Style*, 2014)
  "The single best explanation of why good people write bad prose." Experts can't simulate not-knowing; remedies: concrete detail, showing drafts to outside readers.

## Plain language (evidence base)

- **Federal Plain Language Guidelines** — https://www.plainlanguage.gov/guidelines/ (redirects to digital.gov)
  The canonical guideline set: audience first, important-first organization, active voice, verbs over nominalizations, common words, short sentences (one idea), short paragraphs (one topic), design for scanning, and *test with real users*.
- **GOV.UK content design guidance** — https://www.gov.uk/guidance/content-design/writing-for-gov-uk
  Field-tested at national scale. Key evidence: at ~14-word average sentence length readers understand 90%+; check any sentence over 25 words; long words (8–9 letters) cause readers to skip the short words that follow.
- **GOV.UK: "Sentence length: why 25 words is our limit"** — https://insidegovuk.blog.gov.uk/2014/08/04/sentence-length-why-25-words-is-our-limit/
- **GOV.UK content principles: research background** — https://www.gov.uk/government/publications/govuk-content-principles-conventions-and-research-background/govuk-content-principles-conventions-and-research-background
  Plain-language rules help *both* low- and high-literacy readers find information faster and more accurately — the basis for "plain language is not dumbing down".
- **Readability Guidelines (Content Design London)** — https://readabilityguidelines.co.uk/
  Community-maintained, evidence-linked style rules.
- **W3C WCAG 3.1.5 Reading Level** — https://www.w3.org/WAI/WCAG22/Understanding/reading-level.html
  Accessibility framing: lower-secondary reading level as the target for general content.
- **Caution on readability formulas** — https://www.noslangues-ourlanguages.gc.ca/en/blogue-blog/readability-formulas-eng
  Flesch-Kincaid & co. are diagnostics for overly complex text, not writing targets; optimizing for the formula can degrade actual clarity. (Why this skill gives grade-level ranges as calibration, not as a score to chase.)

## How people read (eyetracking & scanning)

- **NN/g: F-shaped pattern (original 2006 study + 2017 update)** — https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content-discovered/ and https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/
  People scan, not read; ~20–28% of words read on an average visit; the F-pattern is what scanning looks like when formatting gives no cues — good headings, front-loading, and lists break it.
- **NN/g: Progressive disclosure** — https://www.nngroup.com/articles/progressive-disclosure/
  Deferring secondary content improves learnability, efficiency, and error rate — the research basis for the mixed-audience layering patterns.
- NN/g finding cited widely (2016): readers understand jargon-free content significantly faster — even domain experts prefer plain language.

## Structure

- **BLUF (bottom line up front)** — https://en.wikipedia.org/wiki/BLUF_(communication)
  Military communication standard; key information first.
- **Inverted pyramid** — https://en.wikipedia.org/wiki/Inverted_pyramid_(journalism)
  Journalism's version of the same principle; robust to readers stopping at any point.
- **Diátaxis** — https://diataxis.fr/ (start: https://diataxis.fr/start-here/)
  Four reader needs → four document types (tutorial, how-to, reference, explanation); don't mix them.
- **Cognitive load / working memory** — Sweller's cognitive load theory; Cowan (2001) "The magical number 4 in short-term memory" — working memory holds ~4 chunks, the basis for limiting new concepts per passage. Overview: https://en.wikipedia.org/wiki/Cognitive_load

## Style guides worth consulting for specifics

- **Microsoft Writing Style Guide** — https://learn.microsoft.com/en-us/style-guide/welcome/ — warm-but-crisp voice, bias-free language, UI terminology.
- **Google developer documentation style guide** — https://developers.google.com/style — word list, accessibility, code-sample conventions.
- **Write the Docs guide** — https://www.writethedocs.org/guide/ — community-maintained documentation practice.
- **Stripe API docs** — https://docs.stripe.com/api — the working example of expert-audience calibration: use-case-first, common case before edge cases, copy-pasteable everything.
