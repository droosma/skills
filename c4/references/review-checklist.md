# Diagram review checklist

Run against every C4 diagram before returning it. From *Visualising Software Architecture* Appendix A.

Any "no" is a bug.

## General

- [ ] Does the diagram have a **title**?
- [ ] Is the **diagram type** clear (Context / Container / Component / Code / Dynamic / Deployment / Landscape)?
- [ ] Is the **scope** clear (which system or container is in focus)?
- [ ] Does the diagram have a **key / legend** for any notation beyond the defaults?

## Elements

- [ ] Does **every element have a name**?
- [ ] Do you understand the **type** of every element (its level of abstraction — software system, container, component, etc.)?
- [ ] Do you understand **what every element does** (one-sentence description of responsibilities)?
- [ ] Where applicable, do you understand the **technology choices** associated with every element (Container level and below)?
- [ ] Are all **acronyms and abbreviations** explained (or ubiquitous)?
- [ ] Is the meaning of all **colours** used clear?
- [ ] Is the meaning of all **shapes** used clear?
- [ ] Is the meaning of all **icons** used clear?
- [ ] Is the meaning of all **border styles** used (solid, dashed, double, dotted) clear?
- [ ] Is the meaning of all **element sizes** used clear (if sizing varies)?

## Relationships

- [ ] Does **every line have a label** describing the intent of the relationship?
- [ ] Does the **description match the direction** of the arrow? (Read it aloud — if it's nonsense, fix wording or direction.)
- [ ] Where applicable, do you understand the **technology / protocol** on every inter-container / inter-component relationship (HTTPS, JSON/HTTPS, gRPC, JDBC, AMQP, SMTP, …)?
- [ ] Are all **acronyms** on relationship labels explained?
- [ ] Is the meaning of all **colours** on relationships clear?
- [ ] Is the meaning of all **arrowheads** used clear?
- [ ] Is the meaning of all **line styles** used (solid, dashed, dotted) clear?

## C4-specific sanity

- [ ] **One level of abstraction** per diagram — no components on a Container diagram, no containers on a Context diagram, etc.
- [ ] On a **Container diagram**: the system-in-focus is wrapped in a `System_Boundary`, and the people / external systems from the Context diagram are repeated around it.
- [ ] On a **Component diagram**: the container-in-focus is wrapped in a `Container_Boundary`, and surrounding containers / external systems appear for context.
- [ ] On a **Deployment diagram**: containers are nested inside `Deployment_Node` / `Node` blocks representing real infrastructure; the environment is named in the title (Live / Staging / Dev / DR).
- [ ] On a **Dynamic diagram**: exactly one abstraction level; interactions are numbered or otherwise clearly ordered.
- [ ] On a **System Landscape diagram**: no single system in focus; organisational boundary drawn as a dotted box.
- [ ] **No frameworks or libraries** drawn as components or containers — they belong in the `techn` field.
- [ ] **No Docker-specific "container"** has leaked in — a C4 Container is any separately-deployable unit (app, SPA, mobile app, schema, bucket, queue, script, function).
- [ ] Element count is sane (≤ ~20 shapes). If not, split the diagram or raise the abstraction level.

## Consistency across a diagram set

- [ ] The same **element name** is used for the same thing across diagrams.
- [ ] The same **colour / shape / border** encoding is used across diagrams.
- [ ] Element **placement** is roughly consistent across diagrams (users at the top if that's your convention, external systems on the right, etc.).
- [ ] **Reading order** is clear (Context → Container → Component → Code, and Dynamic / Deployment / Landscape as supplements).

## Documentation / evidence

- [ ] (If extracted from a codebase) Every element cites the file(s) it was derived from.
- [ ] (If extracted from a codebase) Assumptions and gaps are flagged explicitly, not hidden.
- [ ] (If for long-lived docs) The diagram's source is version-controlled alongside the code.

## Stand-alone test

- [ ] If you hand this diagram to someone outside the team with no narrative, can they understand what it shows?

If the answer to that last one is "no, I'd need to explain it" — the diagram is not ready. Fix it, don't rely on narration.
