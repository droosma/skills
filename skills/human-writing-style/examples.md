# Worked examples: rules applied together

Sibling reference file for the `human-writing-style` skill. **Load this file when** writing longer prose, or when you want to see how the individual rules interact across a full paragraph.

The before/after pairs in `SKILL.md` and `rules.md` are short by design; they isolate a single pattern. In real text the rules interact, and a good rewrite applies several at once.

---

## Example 1: Corporate boilerplate → specific prose

**❌ Before (AI-typical):**

*In today's rapidly evolving digital landscape, our company stands as a testament to innovation, boasting a vibrant team of meticulous engineers who foster groundbreaking solutions. Additionally, we're committed to enhancing customer experiences, which is crucial in the fast-paced world of enterprise software. Industry reports suggest that our approach, blending cutting-edge technology with deep customer empathy, underscores our pivotal role in shaping the future of the industry. Despite challenges in a competitive market, our team continues to thrive, delivering value-driven experiences that align with our commitment to excellence.*

**✅ After:**

*We build enterprise software. The team is thirty engineers, most of whom spent time in customer support earlier in their careers, a hiring choice that shows up in how the product handles errors. We shipped sixteen releases last year, and the median turnaround on a customer-reported bug is under two business days. The market is competitive; we lost two accounts to larger vendors last quarter, which is part of why we're putting more effort into support quality than into feature count.*

**What changed and why:**

- **Rule 1 (master):** every generic claim got a specific replacement: "thirty engineers," "sixteen releases," "under two business days," "two accounts last quarter."
- **Rule 2 (significance machine):** cut "stands as a testament," "pivotal role in shaping the future."
- **Rule 3 (stop selling):** cut "vibrant," "groundbreaking," "commitment to excellence."
- **Rule 4 (AI vocabulary):** removed the clustering. No "enhancing," "crucial," "foster," "pivotal," "align with," "meticulous."
- **Rule 5 (plain structure):** "is" replaces "stands as."
- **Rule 7 (vague authorities):** "industry reports suggest" deleted, not replaced.
- **Rule 8 (challenges formula):** challenges are integrated as a specific fact ("lost two accounts"), not a formulaic coda.
- **Rule 13 (filler transitions):** no "Additionally," "Furthermore."
- **Rule 14 (active voice):** active throughout; sentence openers vary (subject, subject, noun phrase, noun phrase).

**One more thing.** The rewrite is about 30% shorter. A lot of "AI-ness" is simply over-length, saying in 80 words what needs 30. When a paragraph feels AI-generated, aggressive cutting is often the first and most effective move. If the remaining sentences still feel generic after a cut, that's when rules 1-22 start doing real work.

---

## Example 2: Negative parallelisms, engagement bait, and metronome rhythm

**❌ Before (AI-typical):**

*It's not about writing more content. It's about writing better content. From ancient storytelling traditions to modern AI-powered tools, the landscape of content creation has undergone a transformative shift. This isn't just a trend. This is the future of communication. Let that sink in. Furthermore, the key to success doesn't lie in volume; it lies in authenticity. By leveraging cutting-edge technology while maintaining a human touch, creators can unlock unprecedented levels of engagement. The implications here are profound. What makes this particularly interesting is the interplay between automation and creativity.*

**✅ After:**

*Write less. Write better. AI tools can generate a thousand words in seconds, but readers still close tabs after two bad paragraphs. The creators who keep audiences are the ones who say something specific. One newsletter I follow sends 400 words every Tuesday. It has a 62% open rate. The author told me she spends 3 hours on those 400 words. Most of that time is cutting.*

**What changed and why:**

- **Rule 9 (negative parallelisms):** "It's not about X. It's about Y" and "This isn't X. This is Y" both deleted. The positive claims stand on their own.
- **Rule 17 (engagement bait):** "Let that sink in" deleted.
- **Rule 19 (false ranges):** "From ancient storytelling traditions to modern AI-powered tools" cut. It sounds broad, means nothing.
- **Rule 4 (AI vocabulary):** removed "landscape," "transformative," "leveraging," "cutting-edge," "unlock," "unprecedented," "interplay."
- **Rule 13 (filler transitions):** "Furthermore" cut.
- **Rule 11 (em dashes):** replaced with periods and commas.
- **Rule 21 (metronome):** the original had every sentence at roughly the same length. The rewrite varies: 3 words, then 3, then longer, then specific numbers, then a short closer.
- **Rule 1 (master rule):** generic claims replaced with specific numbers (400 words, 62% open rate, 3 hours).

---

## How to use this file

When you're rewriting a paragraph and the result still feels AI-ish after one pass, come back here. The pattern to learn is not the specific words used in this example but the **motion**: from generic importance-claims to specific, checkable facts, with length cut along the way.
