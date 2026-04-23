# Notation

The C4 model is notation-independent. That's the first rule — but *your* diagrams still need a coherent notation. These rules are from Simon Brown's *Visualising Software Architecture* chapter 13 and apply no matter what tool you render with.

## Principle: diagrams should stand alone

> A good way to think about this is to ask yourself whether each diagram can stand alone, and be (mostly) understood without a narrative.

If you find yourself saying "we'll explain it during the presentation" or "this doesn't make sense, but we'll talk through it" — the diagram is broken. Narrative complements a diagram; it should never be load-bearing.

## 1. Title

Every diagram has a title, and the title includes the **diagram type**:

- `System Context diagram: Internet Banking System`
- `Container diagram for Order Service`
- `Dynamic diagram — Reset password flow`
- `Deployment diagram for Production Environment`

Without the type, readers can't place the diagram in the hierarchy.

## 2. Key / legend

Any notation that isn't default must be in a key. Two kinds of assumption-laden notation to watch for:

- *"The grey boxes are the existing systems and the red boxes are the new systems."* — add a legend.
- *"These arrows represent data flows."* — add a legend.

Things to explain:
- Colours and their meaning.
- Shapes (if you use more than "box").
- Line styles (solid vs dashed, thick vs thin, straight vs curved).
- Borders (single, double, coloured, dotted).
- Acronyms.

Even the seemingly obvious can be misread by people with different backgrounds.

## 3. Elements

Default Simon Brown notation:

| Element | Info captured on the element |
|---|---|
| Person | Name, description |
| Software System | Name, description |
| Container | Name, **technology**, description |
| Component | Name, **technology**, description |

### Naming and description

> Naming is often cited as being one of the hardest things in software development.

Resist "boxes that only contain names". A one-sentence description or short bulleted list of responsibilities (7 ± 2 items) under the name removes ambiguity at the cost of a line or two. Worth it.

You can also keep a *simpler* version (name-only) for presentations where you'll narrate — but archive the version with descriptions in the repo.

### Colour

Colour is allowed and encouraged — it's a strong differentiator. Classic encodings:

- Existing vs new.
- Internal vs external.
- Off-the-shelf product vs custom build.
- Risk profile (red/amber/green).
- Ownership — your team vs other teams.
- Release status — untouched vs modified vs removed in this iteration.

**Rules.**
- If you use colour, put the scheme in the legend.
- Test for colour-blindness and mono-printing. A red/green distinction that disappears on a grayscale printer is a broken encoding.
- Don't use colour as the *only* carrier of critical information — redundant encoding (colour + shape, colour + label) saves readers who can't see the colours.

### Shape

Start with rectangles. Add shapes to *supplement* meaning, not to decorate.

Common useful shapes:
- **Stick figure / head-and-shoulders** for a person.
- **Cylinder** for a database.
- **Pipe** for a message queue/topic.
- **Folder** for a file system.
- **Rectangle** for everything else.

The Unified Modeling Language has many shape types; anecdotally, that shape count is a reason UML adoption stalled. Keep your shape vocabulary small.

### Border

Borders (double, coloured, dashed, dotted) are fine for emphasis or grouping — put them in the legend. A dotted box around an organisational boundary is a common, useful convention.

### Size

Make elements roughly the same size. Readers assume larger elements are *more important* or *more complex*. Only vary size if you are deliberately making that statement — otherwise you'll mislead.

## 4. Relationships (the lines)

Lines are routinely neglected — "the glue that holds all the boxes together" — yet they carry most of the diagram's meaning.

### Direction

Most real relationships are bidirectional (request + response, data flow both ways). For each relationship, **pick the most significant direction** and draw a single arrow.

Pick a convention and stick to it:
- Dependency style (most common) — arrow from initiator to receiver. `[Customer] --views accounts using--> [Internet Banking System]`.
- Data-flow style — arrow in the direction data moves.
- Event/message style — arrow from publisher to subscriber (watch out for this one reversing data flow).

Whichever you pick, be consistent within a diagram and across diagrams in the same set.

### Description

Every line has a label that reads as a sentence when connected by the from/to names. Prefer preposition endings:

- **Good**: `[Web App] --reads from and writes to--> [Database]`.
- **Bad**: `[Web App] --reads and writes--> [Database]` (direction ambiguous).

Test your labels by reading them aloud. "The web app reads from and writes to the database" — makes sense. "The web app reads and writes the database" — awkward.

### Technology / protocol

From Container level down, every inter-process relationship carries its protocol:

`HTTP`, `HTTPS`, `JSON/HTTPS`, `SOAP/HTTPS`, `gRPC/TLS`, `GraphQL over HTTPS`, `JDBC`, `ODBC`, `pgx`, `SMTP`, `AMQP`, `Kafka`, `NATS`, `WebSocket`, `MQTT`, `SFTP`, `XML/HTTPS`.

Intra-container component-to-component calls (method calls in the same process) usually don't need a protocol.

### Line style

Extra signals you can encode with line style:

- **Solid vs dashed** — synchronous vs asynchronous.
- **Colour** — HTTPS green, plain HTTP amber, warnings red.
- **Thickness** — critical vs nice-to-have.

As with elements: if you style a line, add the convention to the legend.

### One line vs many

When two elements have multiple relationships, you can choose:

- **Merge** — `[Customer] --views balances and makes payments using--> [Internet Banking System]`.
- **Split** — two arrows, one for each.

Merging keeps the diagram clean. Splitting is clearer when the relationships have very different semantics (one read, one write) or different protocols (REST call + event subscription).

**Rule of thumb**: minimise lines between a pair of elements. For detailed interaction flows, switch to a Dynamic diagram.

## 5. Layout

There's no "correct" orientation. Three rules that help:

- **Most important thing in the centre.** Work around it.
- **Users at the top** (or wherever — the convention matters less than consistency). If they're at the top of Context, keep them at the top of Container.
- **Consistent placement across diagrams in a set.** Reading an eight-diagram documentation set is much easier when the same external systems appear in the same positions.

Upside-down or back-to-front diagrams can work, but only if deliberate.

## 6. Acronyms

Avoid acronyms. If you use them, they go in the glossary / legend.

Exceptions: ubiquitous technical acronyms (HTTPS, SQL, JSON, XML, TCP/IP). When in doubt, write them out.

## 7. Listen for clarifications

If you find yourself adding verbal clarifications while presenting a diagram — "just to be clear, these arrows represent data flows"; "the green boxes are new" — that clarification belongs on the diagram or in the legend. The next reader won't have you there.

## Summary — every notation decision

| Decision | Default | When to change |
|---|---|---|
| Title | Always. Include diagram type. | — |
| Legend | Always when non-default notation present | If you only use boxes + labels + one arrow style, it can be implicit |
| Colour | Monochrome base | Add colour for one specific axis (existing/new, internal/external, etc.) |
| Shape | Rectangle + stick figure | Add cylinders, pipes, folders for clarity — never for decoration |
| Border | Single solid | Dotted for organisational boundary; double for emphasis |
| Size | Equal | Only if you're explicitly signalling size/complexity |
| Arrow direction | Initiator → receiver | Data-flow direction in pipelines; publisher → subscriber in event systems |
| Line label | Always | — |
| Protocol on line | From Container level down, always when crossing process boundary | — |
| Line style | Solid arrow | Dashed for async; colour for protocol family |
