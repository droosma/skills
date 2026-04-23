---
name: c4
description: Design and produce C4 model software-architecture diagrams (System Context, Container, Component, Code, Dynamic, Deployment, System Landscape) — choosing the right level of abstraction, identifying the people / software systems / containers / components, labelling every element and relationship, and extracting architecture from a real codebase when given one. Use when the user asks to describe, document, visualise, sketch, draw, model, or "do a C4" on a system, service, microservice, or architecture; when they ask for a system context, container, component, deployment, or landscape diagram; when they describe a system in ad-hoc "boxes and arrows" terms and want it structured; or when they want to reverse-engineer architecture from a repository. Rendering the final diagram is a separate concern — for Mermaid output use the `mermaid` skill; for other notations (Structurizr DSL, PlantUML C4, draw.io, Ilograph, Structurizr Lite) see `references/output-formats.md`.
---

# C4 model — designing architecture diagrams

The C4 model is a shared vocabulary for describing the static structure of a software system at four levels of abstraction, plus three supplementary dynamic/infra views. It's notation-independent and tooling-independent — this skill focuses on *what to put on the diagram and why*, not on how to render it.

For the rendering half, use the `mermaid` skill (or any of the other notations in `references/output-formats.md`).

> The core idea, from Simon Brown's *Visualising Software Architecture*:
> A **software system** is made up of one or more **containers** (applications and data stores), each of which contains one or more **components**, which in turn are implemented by one or more **code** elements. People use the software systems.

## Workflow

1. **Clarify scope.** Name the *one* software system in focus. If several systems are in scope, you're drawing a System Landscape, not a Context diagram.
2. **Pick the level(s).** Default to System Context + Container — this is enough for most teams. Add Component only where it earns its keep; Code only from the IDE on demand; Dynamic / Deployment / Landscape where the question requires them. See `references/diagram-types.md`.
3. **Populate the abstractions.** For each element on the diagram, decide which kind it is (Person, System, Container, Component) and capture: name, description, and — from Container level down — technology. See `references/c4-model.md` for definitions and edge cases (microservices, serverless, managed data services, frameworks vs components).
4. **Draw the relationships.** Every arrow gets a labelled sentence and, where it crosses a process boundary, a protocol. See `references/notation.md`.
5. **Sanity-check.** Run the diagram against `references/review-checklist.md`. Every "no" is a bug.
6. **Render.** Pick an output format from `references/output-formats.md`. For Mermaid, hand over to the `mermaid` skill (see `references/c4.md` in that skill). For text-native modelling, prefer Structurizr DSL.

When the user provides a codebase instead of a description, follow `references/code-to-c4.md`: find containers from manifests/Dockerfiles/IaC, find components from package structure and public interfaces, cite your evidence, flag guesses.

## The 4 levels in one page

| Level | Shows | Audience | Shown as |
|---|---|---|---|
| 1. System Context | The system-in-focus as one box, surrounded by people and external systems it talks to. No tech detail. | Everyone, technical or not. | `Person`, `System`, `System_Ext` |
| 2. Container | Inside the system box: apps, services, and data stores. Technology choices. How they communicate. | Technical staff, including ops. | `Container`, `ContainerDb`, `ContainerQueue`, wrapped in `System_Boundary` |
| 3. Component | Inside one container: grouped functionality. Optional. | Developers. | `Component`, wrapped in `Container_Boundary` |
| 4. Code | Inside one component: classes/functions. Usually generated, rarely drawn. | Developers. | UML class diagram (plain Mermaid `classDiagram`) |

Three supplementary diagrams:

- **Dynamic** — how a specific feature works at runtime, step by step. Pick one abstraction level and stay on it.
- **Deployment** — maps containers onto infrastructure for a specific environment. Nodes nest (region → VPC → cluster → pod). One diagram per environment.
- **System Landscape** — a context diagram widened to multiple systems in an org, department, or product domain. No single system in focus.

The default for "draw an architecture diagram" is a **Container diagram**. If the audience is non-technical or scope is uncertain, draw a **System Context** first.

## The abstractions — quick reference

- **Person** — an actor, role, persona. Not the dev team. Not the ops team. Usually the end user or a named external role.
- **Software System** — the highest level. Owned by one team. Usually one deployable boundary. Not a bounded context, not a business capability, not a squad.
- **Container (not Docker)** — a separately-deployable/runnable unit with its own process space. Web app, SPA, mobile app, serverless function, database schema, object-store bucket, message queue, shell script. If two things can deploy independently, they're two containers. If one WAR contains logical sub-apps, it's one container.
- **Component** — a grouping of related functionality behind an interface, sharing a container's process space. Components must be *real*, evident in the code — not whiteboard fiction.
- **Code** — classes, interfaces, functions. Rarely worth drawing.

Edge cases (microservices you own vs don't own, serverless, managed data services, log files, frameworks, modules/subsystems) are in `references/c4-model.md`.

## What makes a C4 diagram good

From Simon Brown's review checklist (see `references/review-checklist.md`):

- **Titled.** Diagram type + system name. `Container diagram for Order Service`.
- **Scoped.** Obvious which system or container is in focus.
- **Keyed.** Any non-default notation (colours, shapes, borders) explained.
- **Every element named, typed, described**, and (from Container down) **technology labelled**.
- **Every relationship labelled** with a sentence that matches the arrow direction. Prefer preposition endings: "reads from", "makes API calls to", "sends e-mails via".
- **Inter-container/inter-component relationships carry the protocol** (HTTPS, JSON/HTTPS, gRPC, JDBC, AMQP, SMTP, …).
- **No mixed abstraction levels.** One level per diagram.
- **No acronyms without a glossary**, except ubiquitous ones (HTTPS, SQL, JSON).
- **Consistent placement** across diagrams — if users are at the top of Context, keep them at the top of Container.
- **Bounded count** — roughly ≤ 20 shapes. More than that usually means the wrong level.

And the anti-patterns to avoid (catalogued from the book as "the shopping list", "boxes and no lines", "the functional view", "the logical view", "missing technology details", "HOCO", "choose your own adventure", "anonymous clones", "the airline route map"): see `references/anti-patterns.md`. Each one is a failure mode you'll recognise in real-world diagrams — and almost all of them happen by accident when drawing fast.

## When *not* to use C4

C4 works well for custom-built software (monolith or distributed) in general-purpose languages on-prem or in the cloud. It's a poor fit for:

- Embedded systems / firmware.
- Solutions that are mostly customisation of a packaged product (SAP, Salesforce, low-code).
- Libraries, frameworks, and SDKs (use UML class diagrams).

Even in the "poor fit" cases, System Context and Container diagrams often still add value.

Full discussion: `references/when-not-to-use.md`.

## Extracting C4 from a codebase

When the user gives a repo rather than a description, the workflow changes:

1. **Find the system boundary** — one repo usually = one system. Monorepos may contain several (each deployable root).
2. **Find the containers** from evidence: `Dockerfile*`, `docker-compose*.yml`, `k8s/*.yaml`, `helm/`, Terraform (`*.tf`), `serverless.yml`, `main.tf`, CI deploy steps, `package.json`/`pom.xml`/`go.mod`/`Cargo.toml` roots, manifests like `app.yaml`, `fly.toml`, `cdk.*`, `pulumi.*`.
3. **Find external systems** from: env vars referencing third-party hosts, SDK imports (AWS SDK, Stripe SDK, Twilio, SendGrid, Auth0), OIDC/SAML config, HTTP client base URLs.
4. **Find components** from: top-level package structure, Spring `@Component`/`@Service`/`@Repository`, NestJS modules, Django apps, Rails engines, clear public-interface boundaries, route registration files.
5. **Cite evidence.** For every element you draw, note the file(s) that justify it. Anything you can't cite, flag as an assumption.

Full heuristics by language/framework in `references/code-to-c4.md`.

## Output formats

C4 is notation-independent. This skill doesn't render — it models. For rendering:

| Format | Best for | How |
|---|---|---|
| **Mermaid** | Markdown / README / GitHub / MkDocs; quick, no tooling | Use the `mermaid` skill; see its `references/c4.md` |
| **Structurizr DSL** | Text-native C4 modelling, multi-diagram consistency, version control | https://structurizr.com — workspace DSL defines once, renders many views |
| **PlantUML C4** | Richer layout than Mermaid, self-hosted | `!include C4_Container.puml` macros |
| **draw.io / diagrams.net** | Hand-drawing, whiteboards, icon libraries | Import the C4 shape library |
| **Ilograph** | Interactive exploration (zoom, live filter) | ilograph.com |
| **Structurizr Lite** | Local workspace viewer for DSL | Docker image `structurizr/lite` |
| **C4-PlantUML-Kroki** | Inline in MkDocs/Confluence via Kroki | https://kroki.io |

Full guidance on when to pick which: `references/output-formats.md`.

## References

Load the reference that matches the question:

- `references/c4-model.md` — the abstractions (Person, Software System, Container, Component, Code) in depth; edge cases (microservices, serverless, managed services, frameworks, modules, subsystems)
- `references/diagram-types.md` — the 7 diagram types (Context, Container, Component, Code, Dynamic, Deployment, System Landscape) — intent, audience, content, motivation, when to recommend
- `references/notation.md` — title / legend / colour / shape / border / size / arrow-direction / description / line-style / acronyms / layout rules, straight from the book
- `references/anti-patterns.md` — the ten classic "boxes and arrows" failures and their fixes
- `references/code-to-c4.md` — per-language / per-framework heuristics for finding containers and components in a real codebase
- `references/output-formats.md` — Mermaid, Structurizr DSL, PlantUML C4, draw.io, and how to choose
- `references/when-not-to-use.md` — where C4 fits and where it doesn't
- `references/review-checklist.md` — pre-flight checklist derived from *Visualising Software Architecture* Appendix A

## Worked examples

Fictional "Internet Banking System" from Simon Brown's book, at each diagram level. These use Mermaid for rendering but are really *modelling* examples — the elements, their labels, their tech, and their relationships are the C4 content; the Mermaid is incidental.

- `assets/examples/system-context.md`
- `assets/examples/container.md`
- `assets/examples/component.md`
- `assets/examples/dynamic.md`
- `assets/examples/deployment.md`
- `assets/examples/system-landscape.md`
- `assets/examples/structurizr-dsl.md` — the same example in Structurizr DSL for comparison
