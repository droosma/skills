# Anti-patterns — the "boxes and arrows" failure catalogue

From Simon Brown's *Visualising Software Architecture* chapter 3 ("We have a failure to communicate"). These are the failure modes he observed across *thousands* of software developers drawing architecture diagrams at his workshops. Each one has a recognisable shape. Use this list as a self-review before handing a diagram back.

## Purpose of architecture diagrams

Before the failures — the goals a good diagram serves:

- Help everyone understand the "big picture" of what's being built and how it fits the wider environment.
- Create a shared vision for the development team.
- Provide a "map" that developers use to navigate the source code.
- Provide a focus for technical conversations — feature design, tech debt, risk reviews, threat modelling.
- Fast-track the onboarding of new developers.
- Explain what's being built to people outside the team, technical or not.

When a diagram fails, it's usually failing at one of these.

---

## 1. The shopping list

**Shape**: a diagram that is essentially a bulleted list of technology names, maybe inside boxes.

*"There's a Unix box and a Windows box, with some additional product selections that include JBoss and Microsoft SQL Server. I don't know what those products are doing, plus there seems to be a connection missing between them."*

**Why it fails**: technology without responsibility. The reader knows what's being used but not what any of it does or why.

**Fix**: add responsibilities on each element; add relationships with purposes.

---

## 2. Boxes and no lines

**Shape**: a rich set of boxes (often decomposition of a middle tier into components) with **no arrows at all**.

*"It's great to see how the middle-tier has been decomposed, but there are no responsibilities and no interactions. Software architecture is about structure, which is about things (boxes) and how they interact (lines). This diagram has one, but not the other."*

**Why it fails**: tells half the story. You can see the parts but not how they cooperate.

**Fix**: add relationships. If a box has no inbound or outbound arrow on any diagram at any level, question why it's there.

---

## 3. The "functional view"

**Shape**: boxes labelled by business function ("Ordering", "Billing", "Shipping", "Reporting") with colour coding that isn't explained.

*"Imagine a building architect drawing you a diagram of your new house that simply had a collection of boxes labelled 'Cooking', 'Eating', 'Sleeping'."*

**Why it fails**: no responsibilities, no interactions, opaque colour code, no technology. Decomposes the domain rather than the system.

**Fix**: this is usually a *business capability map*, not a software architecture diagram. Keep it for a different audience; draw an actual Container diagram for the architecture.

---

## 4. The airline route map

**Shape**: a central spine that looks like an activity/pipeline diagram, surrounded by peripheral arrows in different colours and directions, with unexplained icons (green circles, clocks, …).

*"The central spine is great because it shows how data flows through a series of steps. But then it all goes wrong. There's a green circle that everything is pointing to, but I'm not sure why. And a clock. The left is equally confusing, with various lines of differing colours and styles zipping across one another."*

**Why it fails**: started as a sensible flow, accumulated ad-hoc annotations without rules.

**Fix**: split into two diagrams — a Dynamic diagram for the central flow, plus whatever the peripheral arrows are trying to show (probably a separate Container or Component diagram).

---

## 5. Generically true

**Shape**: boxes labelled with abstract/generic names — "transport", "archive", "audit", "business logic", "error handling", "action".

*"Most of the content is very generic. This diagram doesn't tell you much about the business domain at all."*

**Why it fails**: the diagram would apply to any system. Vague labels = no information.

**Fix**: name elements by *this* system's domain language. "Trade Risk Calculator" beats "business logic".

---

## 6. The "logical view"

**Shape**: boxes showing "logical" building blocks with no technology, no frameworks, no deployment details. Usually justified with "the solution can be built with any technology".

*"There's a common misconception that software architecture diagrams should be 'logical' in nature rather than include any references to technology or implementation details, especially before any code is written. We'll look at this misconception later in the book."*

**Why it fails**: technology choices *are* architecture. Omitting them leaves out the most consequential decisions.

**Fix**: add technologies, even if they're tentative. Mark unknowns explicitly ("TBD") rather than pretending they don't exist.

---

## 7. Missing technology details (on lines)

**Shape**: a reasonable Container-level diagram — boxes with responsibilities, labelled arrows — but **no protocol information** on inter-container lines. You can tell the boxes are a "Java EE application" and a "web server" but not how they communicate.

*"Is it SOAP? A JSON web API? XML over HTTPS? gRPC? Remote method invocation? Asynchronous messaging? It's not clear."*

**Why it fails**: the protocol is the most change-prone, most failure-prone, most performance-sensitive part of the line. Omitting it makes the diagram useless for interface discussions.

**Fix**: label every inter-container line with its protocol — HTTPS, JSON/HTTPS, gRPC, JDBC, SMTP, AMQP, etc.

---

## 8. HOCO — Homeless Old C# (or Java) Object

**Shape**: mixed abstraction levels. A box labelled "Application" alongside boxes that are actually components *inside* that application. A "data access" box and a "logger" box that could be frameworks, layers, or components. No boundary between the things and their container.

*"I'd like to draw a big box around most of the boxes to say 'all of these things live inside the console application'. I want to give those boxes a home."*

**Why it fails**: the reader can't tell which boxes are peers and which are inside others. Abstractions smeared across levels.

**Fix**: pick one abstraction level per diagram. Use `System_Boundary` / `Container_Boundary` to show where things live.

---

## 9. Choose your own adventure

**Shape**: an over-complicated diagram trying to show every path through an event-driven architecture. Forks everywhere, multiple paths eventually converging. Single-colour, no highlighting.

*"This diagram is trying to show everything, and the single colour being used does not help. Removing some information and/or using colour coding to highlight the different paths would help tremendously."*

**Why it fails**: tries to be both static structure *and* runtime behaviour at once. Ends up being neither.

**Fix**: separate concerns. A static structure diagram (Container / Component) shows what exists. One or more Dynamic diagrams, each for a specific flow, show what happens at runtime.

---

## 10. Anonymous clones

**Shape**: actors (stick figures) with no names, no labels, no roles.

*"I don't know who they are and why they are using the software."*

**Why it fails**: loses the main benefit of a Context diagram — answering "who uses this system and for what?"

**Fix**: every actor gets a name (role, persona, or named individual) and a one-line description.

---

## The multi-diagram failure modes

When you draw more than one diagram, extra failures emerge:

- **Inconsistent notation** between diagrams — colour coding drifts, shapes change, arrows mean different things.
- **Inconsistent naming** of the same element across diagrams.
- **No clear reading order** — which diagram goes first?
- **No clear transition** — how do you zoom from one diagram to the next?

**Fix**: treat the diagram set as a single document. Same element appears with the same name, same shape, same colour, same rough position across every diagram it's on. First diagram is the overview; subsequent ones zoom in.

---

## The "common problems" summary

From Simon Brown's distillation — if you see any of these in a diagram, flag it:

1. Notation (colours, shapes, line styles) is not explained, or is inconsistent.
2. The purpose of elements is ambiguous.
3. Relationships between elements are missing or ambiguous.
4. Generic terms (e.g. "business logic") are used.
5. Technology choices are missing.
6. Levels of abstraction are mixed on one diagram.
7. Too much or too little detail.
8. No context or a logical starting point.

When these compound across a diagram set, readers give up. The diagrams become decoration.

---

## The hidden-assumption test

> One of the easiest ways to understand whether a diagram makes sense is to give it to somebody else and ask them to interpret it without providing a narrative.

Before handing your diagram back, imagine removing yourself from the room. Can a reader who has never seen this system understand what it shows? If not, the diagram has become dependent on your narration — which means it's broken for documentation use.
