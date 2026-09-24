# Human writing style: expanded rules (2-27)

Sibling reference file for the `human-writing-style` skill. This file contains the expanded rules 2 through 27.

Rule 1 (the master rule, *prefer specific detail over generic praise*), the self-check, and the tone guidance live in `SKILL.md` and should already be in your context if you are reading this.

**Load this file when** writing prose longer than a short paragraph, or when the self-check flags a pattern and you need the specifics. For the full AI vocabulary list with diagnostics (rule 4), see `vocabulary.md`.

---

## Rule 2. Kill the significance machine

Never insert commentary about how important, pivotal, or transformative something is unless the user explicitly asks for evaluative language. Humans state facts and let readers draw conclusions.

**Banned patterns:**
- "stands/serves as a testament to..."
- "a vital/significant/crucial/pivotal/key role/moment"
- "underscores/highlights its importance/significance"
- "reflects broader trends"
- "symbolizing its ongoing/enduring/lasting..."
- "contributing to the...", "setting the stage for..."
- "marking/shaping the...", "represents/marks a shift"
- "key turning point", "evolving landscape", "focal point"

**Instead:** State what happened. If the founding of an organization mattered, describe the concrete effects. Don't announce that it "marked a pivotal moment in the evolution of" something.

❌ *The institute was established in 1989, marking a pivotal moment in the evolution of regional statistics.*
✅ *The institute was established in 1989. Within five years, it had published its own census data for the first time.*

---

## Rule 3. Stop selling

Drop the promotional, travel-guide, advertisement tone. Even when writing about something genuinely impressive, maintain a neutral, matter-of-fact voice.

**Banned patterns:**
- "boasts a...", "vibrant", "rich" (as filler adjectives)
- "profound", "enhancing", "showcasing", "exemplifies"
- "commitment to...", "natural beauty", "nestled"
- "in the heart of...", "groundbreaking", "renowned"
- "featuring a diverse array of..."
- "seamlessly connecting..."
- "maintains an active [social media] presence"

**Instead:** Describe what exists or what happened, plainly.

❌ *Nestled within the breathtaking region, the town stands as a vibrant community with a rich cultural heritage, offering visitors a fascinating glimpse into the diverse tapestry of the country.*
✅ *The town sits in the highlands south of Gonder. Most of its 12,000 residents farm teff and sorghum.*

---

## Rule 4. Retire the AI vocabulary

These words became dramatically overused in text after 2022. In a piece under 1,000 words, one is fine; in a longer piece, two or three spread apart is acceptable. But when they cluster (three or more within a few paragraphs), it reads like AI wrote it. If one of these words is the precise technical term for the domain, use it freely.

**For the full list of overused words with replacements and per-item diagnostics, see `vocabulary.md`.**

The top offenders to catch on every pass: *delve*, *crucial*, *pivotal*, *tapestry*, *testament*, *underscore*, *vibrant*, *enhance*, *meticulous*, *landscape* (abstract).

---

## Rule 5. Use plain sentence structure

AI avoids simple "is/are/has" constructions and replaces them with fancier-sounding alternatives. Stop doing that.

**Banned substitutions:**
- "serves as" / "stands as" / "marks" / "represents" when "is" works
- "boasts" / "features" / "maintains" / "offers" when "has" works
- "refers to" when "is" works (e.g., "X refers to the process of..." instead of "X is...")
- "ventured into politics as a candidate" when "ran for office" works
- "holds the distinction of being" when "is" works

❌ *The gallery serves as the organization's exhibition space for contemporary art. The building features four separate rooms.*
✅ *The gallery is the organization's exhibition space for contemporary art. It has four rooms.*

---

## Rule 6. Stop the superficial analysis

Don't attach "-ing" clauses that offer shallow interpretation at the end of sentences. If analysis is needed, make it a separate thought with actual substance.

**Banned patterns:**
- "...highlighting/underscoring/emphasizing..."
- "...ensuring...", "...reflecting/symbolizing..."
- "...contributing to...", "...cultivating/fostering..."
- "...encompassing...", "...aligning/resonating with..."

❌ *The population stood at 56,998 inhabitants, creating a lively community within its borders.*
✅ *The population was 56,998.*

❌ *The civil rights movement emphasized the importance of solidarity and collective action in the fight for justice, shaping values and community structures.*
✅ *The civil rights movement organized around collective action. Its tactics (boycotts, sit-ins, voter registration drives) became models that later community organizations adopted.*

---

## Rule 7. Don't attribute to vague authorities

Never use weasel words that attribute claims to unnamed experts or sources.

**Banned patterns:**
- "Industry reports suggest..."
- "Observers have cited..."
- "Experts argue...", "Some critics argue..."
- "Researchers have noted..."
- "Several sources/publications..." (when you can't name them)
- "has generated debate about..." / "prompted broader reflection on..."
- "widely interpreted as..." / "is widely regarded as..."

**Also watch for over-attribution and false depth.** AI often lists media outlets or sources to prove a subject's importance ("profiled in The New York Times, BBC, and Financial Times") without saying what those sources actually said. It also fabricates the scope of coverage, presenting one or two sources as representing a broad consensus. If you cite a source, say what it said. Don't just name-drop it.

**Instead:** Name the source, or state the fact without attribution. If you don't have a source, don't pretend one exists. If you're describing a genuine debate and can't name participants, restructure to describe the debate without fake attribution: "The river's ecological role is debated" is better than "Experts argue."

❌ *Experts argue that the river is of significant ecological interest.*
✅ *The river feeds three downstream wetlands that support migratory bird populations.*

---

## Rule 8. Cut the "challenges and future prospects" formula

Don't end pieces with the rigid template: "Despite its [positive thing], [subject] faces challenges including... Despite these challenges, [hopeful speculation]."

This formula is one of the strongest AI tells. If challenges or future direction are relevant, integrate them naturally into the body of the text with specific details, not as a formulaic coda.

❌ *Despite its industrial prosperity, the neighborhood faces challenges typical of urban areas. With its strategic location and ongoing initiatives, it continues to thrive.*
✅ *Flooding closed three factories in 2019, and the council has struggled to fund drainage improvements since.*

---

## Rule 9. Watch the negative parallelisms

This is the single most reliable tell of AI-generated text. Peer-reviewed research backs this up. These constructions make a shallow idea sound profound.

If you find one in your output, rewrite the entire sentence.

**The banned patterns:**
- "This isn't X. This is Y."
- "Not X. Y."
- "Forget X. This is Y."
- "Less X, more Y."
- "Not only X, but also Y."
- "It's not just about X, it's about Y."
- "No X, no Y, just Z."
- "X? No. Y."
- "Stop thinking X. Start thinking Y."
- "It's not about X. It's about Y."
- "X is dead. Y is the future."
- "The question isn't X. The question is Y."
- "You don't need X. You need Y."
- "X is overrated. Y is what matters."
- ANY sentence that negates one framing then asserts a corrected one.
- ANY sentence that rejects an assumption, then replaces it.

**Also watch for the sneaky versions:**
- "While X might seem right, Y is actually..." (same pattern wearing a trench coat)
- "Sure, X works. But Y is where the real..." (concession + pivot = same skeleton)
- "X gets all the attention, but Y is what actually..." (same thing, third disguise)

**Why this matters so much:** when an LLM wants to sound smart, this is its first instinct. The pattern is baked into training data from persuasive writing, TED talks, marketing copy, and op-eds. When your reader sees it, their brain registers: machine.

**The fix is simple:** delete everything before the positive claim. If you wrote "It's not about the prompt. It's about the context," just write "It's about the context." The negated framing adds zero information. Just say what it is.

❌ *The painting is not just a work of self-representation, but a visual document of her obsessions.* (Y restates X)
✅ *The painting documents her obsessions. The polka dots recur in the background, the mirror, even her clothing.*

---

## Rule 10. Don't default to the rule of three

Humans use three-item lists naturally, and sometimes they're the right choice. The problem is when every list, every description, every set of adjectives falls into threes. If you notice a pattern forming, vary it: sometimes two items, sometimes four, sometimes no list at all.

❌ *The event features keynote sessions, panel discussions, and networking opportunities.* (generic triple)
✅ *The event runs two days of talks, with an unconference track on the second afternoon.*

---

## Rule 11. Never use em dashes

Never output an em dash character. Not once. Not for asides, not for emphasis, not for lists. Use commas, periods, or colons instead. Don't reach for parentheses either: swapping an em dash for parentheses just trades one tell for another. Also avoid en dashes and hyphens used as dash substitutes. If a thought needs separation, end the sentence or use a comma. Em dashes are one of the most statistically reliable AI formatting tells. Peer-reviewed research and Wikipedia's AI detection guide both flag them.

**This is a hard rule, not a preference.** If your output contains a single em dash, rewrite the sentence.

---

## Rule 12. Don't over-format

These rules apply to the prose you generate for the user.

- **Does not apply to** instructional documents, skill files, technical reference, or anything where structural formatting aids scanability. Those legitimately use bold headers, bullet lists, and the like.
- Don't bold key phrases in running prose for emphasis.
- Don't create bulleted lists with bold headers followed by colon-separated descriptions unless the user specifically asks for that format. The tell is a bold label and colon that just restates the line (e.g., "**Performance:** Performance improved 20%"). Convert those to prose. A bold lead-in that ends in a period, names the item, and is followed by genuinely new detail ("**Schema in TypeScript.** Tables live in one file.") is fine, not a tell.
- Don't capitalize every word in headings (use sentence case).
- Use formatting only when it genuinely aids readability.
- Write numbers as digits (3 years, 10 tools, 500 users), not words.

---

## Rule 13. Cut the filler transitions

AI opens sentences with heavy transition words that pad the text without adding meaning.

**Banned sentence starters (when used as filler):**
- "However," / "Furthermore," / "Moreover," / "Consequently,"
- "Additionally," / "That said," / "That being said,"
- "With that in mind," / "On top of that,"
- "It is also worth mentioning..."
- "It's worth noting that..." / "It's important to remember that..."
- "Interestingly," / "Notably," / "Significantly,"
- "In today's fast-paced world..." / "Throughout history..."
- "When it comes to..."
- Any mechanical connector that reads like a college essay

**Instead:** Just start the sentence. If the logical connection isn't obvious without a transition, restructure so it is. If a transition is genuinely needed, prefer short ones: "But", "And", "Still", "So".

❌ *Furthermore, the committee decided to extend the deadline. Moreover, they allocated additional funding.*
✅ *The committee extended the deadline and added funding.*

---

## Rule 14. Use active voice, vary your starters

AI defaults to passive constructions and repetitive sentence openers. Watch for:
- Multiple consecutive sentences starting with "The [noun]..." or "It is..."
- Passive voice used where active is clearer: "was established by" instead of "[person] established"
- Every sentence following the same subject-verb-object rhythm

Mix it up. Start some sentences with a time, a place, a subordinate clause. Let some be short. Let one run long.

❌ *The program was launched in 2015. The program was designed to help farmers. The program has been expanded to three provinces.*
✅ *Launched in 2015, the program helps farmers in three provinces.*

---

## Rule 15. Write like you're talking to one person

Cut these collaborative/assistant phrases entirely:
- "I hope this helps"
- "Of course!", "Certainly!", "Great question!"
- "Would you like me to..."
- "Here is a comprehensive overview of..."

In emails or collaborative contexts, brief human closings are fine ("Let me know if you have questions"). The ban is on saccharine, performative assistant-speak, not on normal human courtesy.

---

## Rule 16. Never disclaim your knowledge

Don't insert phrases like:
- "As of my last update..."
- "While specific details are limited..."
- "Based on available information..."
- "Not widely documented..."

If you don't know something, simply don't write about it. Don't announce the gap.

---

## Rule 17. Kill engagement bait

These phrases are manipulative filler. They tell the reader how to feel instead of writing something worth feeling something about.

**Banned patterns:**
- "Let that sink in" / "Read that again" / "Full stop"
- "This changes everything"
- "Are you paying attention?" / "You're not ready for this"
- Any sentence whose only function is to tell the reader they should be impressed

---

## Rule 18. Kill hype language

AI defaults to startup-pitch vocabulary when describing anything positive.

**Banned patterns:**
- "Supercharge" / "Unlock" / "Future-proof"
- "10x your [anything]"
- "Game-changer" / "Cutting-edge" / "Next-level"
- Any promise of superpowers, easy riches, or overnight transformation

**Instead:** say what the thing actually does, with specifics.

❌ *Unlock the full potential of your workflow with this game-changing tool.*
✅ *The tool cut our deploy time from 20 minutes to 3.*

---

## Rule 19. Don't fake ranges

"From ancient traditions to modern innovations." Sounds impressive, means nothing. If you can't identify meaningful middle ground between X and Y, the range is fake. Delete it. Be specific about one thing instead.

❌ *The city blends ancient traditions with modern innovation.*
✅ *The old quarter has buildings from the 1400s. The tech campus opened in 2019.*

---

## Rule 20. Don't cycle through forced synonyms

AI's repetition penalty forces it to swap terms: a person becomes "the protagonist," then "the key player," then "the eponymous figure." This is called elegant variation, and it reads as artificial.

Just use the name again. Forced synonyms are worse than repetition.

❌ *Curie discovered radium. The renowned physicist then isolated polonium. The pioneering scientist published her findings in 1903.*
✅ *Curie discovered radium, then isolated polonium. She published both findings in 1903.*

---

## Rule 21. Break the metronome

AI text has perfectly even pacing. Every sentence roughly the same length. Every paragraph the same number of sentences. No texture.

Real writing breathes unevenly. Short. Then longer. Then a fragment. Then a 25-word sentence that earns its length. Vary paragraph length too: some paragraphs are a single sentence.

---

## Rule 22. Use sentence case in headers

AI capitalizes all main words in headers: "Global Context: Critical Mineral Demand." Humans typically use sentence case: "Global context: critical mineral demand." Do that.

---

## Rule 23. Don't overuse the colon

Colons are fine before a list or an example. They are not mid-sentence connectors, and AI reaches for them as a crutch to glue two clauses together with a false air of significance.

❌ *If you're coming from traditional automation: instead of registering event handlers, you describe conditions.*
✅ *Describing when the scheduler should fire works best as plain English.*

The colon added nothing but drama. If a thought needs separation, end the sentence or use a comma. Let the point stand without the comparison framing.

---

## Rule 24. Kill formatting artifacts: emojis and curly quotes

Two small tells that scream "machine-generated":

- **Decorative emojis.** Remove them from headings, bullets, and section labels (✅, 🚀, 💡, 🔑, etc.). They are almost never how a human writes prose. The obvious exception is casual chat or a genre where the user clearly wants them.
- **Curly (smart) quotes and apostrophes.** Replace “curly quotes” and ‘curly apostrophes’ with straight quotes ("" and '). Copy-pasted AI output is full of curly punctuation that a person typing in a plain editor wouldn't produce.

---

## Rule 25. Replace abstract metaphor nouns with the concrete word

AI loves nouns that sound technical but stand in for a plainer, concrete word. They read as jargon and usually hide the fact that the sentence isn't saying much.

**Watch for:** *substrate*, *wedge*, *vector*, *locus*, *vantage*, *nexus*, *primitive* (as a noun), *harness* (as a metaphor), *surface* (as in "API surface"), *bedrock*, *scaffolding* (as a metaphor), *modality*, *paradigm*, *gold-plating*, *ratchet* (as a metaphor), *evacuate* (for moving code), *endgame*, *north star*, *flywheel*.

**Pick the concrete word:**
- "substrate" → "base"
- "wedge in" → "add"
- "vector" → "way" or "method"
- "gold-plating" → "more than the job needs"
- "ratchet" → the mechanism's real name, or "a limit that only tightens"
- "evacuate" → "move out"
- "endgame" → "the last phase"

---

## Rule 26. Cut propping adverbs, or use a stronger verb

Different from the "magic adverbs" tell (rule for *quietly*, *deeply*, *fundamentally*, which inject fake significance). This one is about adverbs propping up a weak verb. When you need an adverb to make a verb carry its weight, the verb is usually wrong.

- "runs quickly" → "is fast", or give the number.
- "significantly improves" → the measured delta.
- "could potentially possibly be argued that it might" → "may". Stacked hedges collapse to one honest one.

❌ *The new index significantly improves query speed.*
✅ *The new index cut median query time from 400ms to 60ms.*

---

## Rule 27. Say what it does, not how it feels

Mostly for technical and product writing, but it applies anywhere. AI describes a feeling the thing gives you instead of the mechanism or the fact. The fix names the mechanism, or a number.

❌ *The database stays close at hand.* / *SQL you can read.* / *Types that follow your schema.*
✅ *`.toSQL()` returns the exact string sent to the database.* / *A column rename fails the build.*

Ask what the sentence tells the reader to do or know, then write that. If you can't restate it as a concrete instruction, fact, or number, cut it.

**The portability test:** if the sentence could appear unchanged in another project's docs, it says nothing about this one. Cut it or replace it with something only true here.

**One idea per sentence.** If the reader has to backtrack to parse a sentence, break it in two or drop clauses.
