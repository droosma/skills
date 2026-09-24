# StoryScope guidance for narrative prose

This reference translates findings from
[StoryScope: Investigating idiosyncrasies in AI fiction](https://arxiv.org/abs/2604.03136)
into editing prompts for fiction and story-like prose.

Read the findings as corpus-level tendencies. They are not a recipe for proving
authorship, and they do not make every opposite choice "human."

## Evidence and scope

The StoryScope corpus contains 10,272 prompts. Each prompt has one human-written
story and five AI-generated mirrors from Claude, DeepSeek, Gemini, GPT, and
Kimi. The resulting 61,608 stories average roughly 5,000 words.

The pipeline extracts 304 features across ten dimensions:

- Agents.
- Social networks.
- Events.
- Plot.
- Setting.
- Temporal structure.
- Revelation.
- Perspective.
- Situatedness.
- Style.

After excluding selected style features, the narrative-only classifier reaches
93.2% macro-F1 for human versus AI detection and 68.4% macro-F1 for six-way
source attribution. These figures describe performance on the paper's held-out
test set. They are not percentages of rules that apply to every story.

The research concerns long-form fiction. Apply it cautiously to anecdotes,
narrative essays, case studies, and scene-based openings. Do not transfer it
wholesale to technical documents, reference text, ordinary correspondence, or
other genres that reward explicitness and complete answers.

## Findings translated into writing prompts

| Observed tendency | Review prompt | Bad correction |
|---|---|---|
| AI narrators explicitly explain the theme more often. The paper reports 77% for AI stories and 52% for human stories. | Has the scene, image, choice, or consequence already conveyed the theme? Cut the explanation if it only repeats what the reader understood. | Hiding the point of an argument, tutorial, or factual explanation. |
| AI stories show tighter thematic unity and more central moral questions. | Does every event point to the same lesson? Allow secondary motives, accidental consequences, or details that do not resolve into one message when the story supports them. | Adding irrelevant subplots or contradictions to create noise. |
| AI plots favor tidy, single-track structures and fewer unresolved elements. | Did the ending close every conflict at once? Decide which relationship, question, or consequence should remain open. | Withholding information the genre promises to answer. |
| Human stories show more moral ambiguity around protagonist choices. | Does the prose announce that a choice was right, brave, healing, or necessary? Show its benefit and cost, then let the reader judge. | Making every character morally vague or refusing to take a position. |
| Human stories use more chronological discontinuity and temporal complexity. | Is straight chronology serving the story, or did it happen by default? Consider omission, summary, memory, delayed context, or a shifted frame when one improves the telling. | Inserting a flashback solely to appear sophisticated. |
| AI resolutions more often depend on internal understanding and conventional closure. | Does insight solve a problem that would also require action, compromise, chance, or another person's response? Let the consequence test the insight. | Removing a justified emotional realization. |
| AI revelations more often answer a question without deeply recontextualizing earlier scenes. | Does the reveal change how the reader interprets an earlier action, object, or line? If not, decide whether it needs stronger setup. | Turning every fact into a twist. |
| Claude shows unusually flat event escalation in the paper's corpus. | Does intensity rise in equal steps? Introduce pauses, false relief, reversals, or uneven consequences when they belong in the story. | Forcing constant volatility into a restrained story. |
| AI stories use vague allusions more often than specific named references. | Would a character with this background name the book, song, myth, place, or person? Use the specific reference when it is credible. | Adding references to display knowledge or inventing sources. |
| AI stories rely heavily on physical sensations and setting as mirrors of emotion. | Are tight chests, cold hands, dim rooms, rain, and oppressive weather doing the work in scene after scene? Vary the channel: action, avoidance, dialogue, attention, memory, or a plain emotion word may fit better. | Removing sensory writing altogether. |
| AI stories cluster more tightly in narrative feature space. | Did the draft choose the first plausible plot, setting, relationship, and ending? Look for one choice that belongs specifically to this character and situation. | Adding random novelty that the story cannot support. |

## Model fingerprints

StoryScope also reports model-specific tendencies:

- Claude has flatter event escalation, a more uniform narrative voice, more
  epilogues, fewer dream sequences, and quieter endings.
- GPT uses gossip and rumor as plot mechanisms more often than the other
  sources in the corpus.
- Gemini favors tidy endings, extended denouements, bleak settings, and
  external character description.
- DeepSeek supplies context earlier than the other sources.
- Kimi has fewer distinctive narrative fingerprints and sits near the center
  of the AI cluster.

Use these only as diagnostic hints when reviewing output from a known model.
They are weak reasons to change an individual passage. A story may need a bleak
setting, early context, gossip, an epilogue, or a quiet ending.

## Safe editing sequence

1. Identify the genre and whether narrative shape matters.
2. Preserve the user's events, factual claims, voice, and intended meaning.
3. Mark places where the narrator explains what the scene already shows.
4. Check whether chronology, escalation, revelation, and closure were chosen or
   merely defaulted.
5. Revise the smallest number of places that make the story feel predetermined.
6. Read again for coherence. Restore explicit context if the revision made the
   piece confusing.

## Misuses to avoid

- Do not claim these features prove that a passage was written by AI.
- Do not describe 93.2% macro-F1 as 93.2% accuracy.
- Do not ban explicit themes, chronological plots, resolved endings, sensory
  detail, or moral clarity.
- Do not add complexity without narrative purpose.
- Do not apply fiction findings as hard rules for technical or instructional
  prose.
- Do not change a user's plot while presenting the work as a style-only rewrite.

## Primary sources

- Paper: https://arxiv.org/abs/2604.03136
- HTML paper: https://arxiv.org/html/2604.03136
- Code and data: https://github.com/jenna-russell/storyscope
- Released dataset: https://huggingface.co/datasets/jjrussell10/storyscope

