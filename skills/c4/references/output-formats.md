# Output formats for C4 diagrams

C4 is notation-independent. Once you've modelled the elements and relationships, you still have to choose how to render. Each tool has its sweet spot.

## Quick chooser

| Need | Pick |
|---|---|
| "Just in my README / Markdown docs, no extra tooling" | **Mermaid** |
| "Text-first modelling, one source → many views" | **Structurizr DSL** |
| "Richer layouts than Mermaid, self-hosted, CI-rendered" | **PlantUML C4 (C4-PlantUML)** |
| "Hand-drawn on a whiteboard, then digitised" | **draw.io / diagrams.net** with C4 shape library |
| "Interactive exploration, zoom, live filters" | **Ilograph** |
| "Local workspace viewer for Structurizr DSL" | **Structurizr Lite** (Docker) |
| "Inline rendering in MkDocs / Confluence / Hugo" | **Mermaid** or **Kroki** |

---

## Mermaid

**When to pick**: you want the diagram to render directly in a README.md, GitHub wiki, MkDocs / Docusaurus / Obsidian site, or a PR description, without installing anything else. Zero external tooling; diagram source is checked in.

**Good for**: System Context, Container, Component, Dynamic (with `C4Dynamic`), small Deployment diagrams. Code diagrams via `classDiagram`.

**Watch out for**:
- Layout is weaker than PlantUML C4 — no `Lay_U/D/L/R`, must influence via statement order and directional `Rel_*`.
- Sprites, tags, and `$link` are parsed but not rendered.
- Marked experimental upstream; can shift between versions.
- GitHub's renderer lags upstream by a few releases.

**How**: hand off to the `mermaid` skill, then reference its `c4.md`. This skill's `assets/examples/*.md` files already provide canonical Mermaid C4 examples for each diagram type.

---

## Structurizr DSL

**When to pick**: you want C4 to be the central way your team describes architecture. Define the model once, derive many views (Context, Container, Component, Deployment, Dynamic, Landscape), keep them consistent automatically.

Simon Brown's own tool. Also the best expression of the C4 philosophy — models and views are separate.

**Good for**: teams that maintain architecture docs long-term. Enterprise-scale (many systems, many teams). Version-controlled models. Multi-view consistency without redrawing.

**Watch out for**: steeper onramp than Mermaid. The DSL is a file, and to render you run Structurizr Lite (Docker) or export to PlantUML / Mermaid / DOT / JSON.

**Minimal example** (same Internet Banking System):

```
workspace "Big Bank plc" {
    model {
        customer = person "Personal Banking Customer" "A customer of the bank."

        enterprise "Big Bank plc" {
            mailSystem = softwareSystem "E-mail System" "Internal Exchange server."
            mainframe = softwareSystem "Mainframe Banking System" "Core banking."
            banking = softwareSystem "Internet Banking System" "Lets customers view accounts and make payments." {
                webApp = container "Web Application" "Delivers static content and SPA." "Java, Spring MVC"
                spa = container "Single-Page Application" "Banking features in the browser." "JavaScript, Angular"
                api = container "API Application" "JSON/HTTPS API." "Java, Spring MVC"
                db = container "Database" "User registrations, hashed creds, audit logs." "PostgreSQL" {
                    tags "Database"
                }
            }
        }

        customer -> banking "Uses"
        banking -> mailSystem "Sends e-mails using"
        banking -> mainframe "Reads/writes via"
        customer -> webApp "Visits bigbank.com using" "HTTPS"
        customer -> spa "Views balances and makes payments"
        spa -> api "Makes API calls to" "JSON/HTTPS"
        api -> db "Reads/writes" "JDBC"
    }

    views {
        systemContext banking "Context" {
            include *
            autoLayout
        }
        container banking "Containers" {
            include *
            autoLayout
        }
        theme default
    }
}
```

**Render** with Structurizr Lite:
```
docker run -it --rm -p 8080:8080 -v $PWD:/usr/local/structurizr structurizr/lite
```

**Export** via the CLI to Mermaid, PlantUML, or JSON:
```
structurizr-cli export -workspace workspace.dsl -format mermaid
```

---

## PlantUML C4 (C4-PlantUML)

**When to pick**: you want PlantUML-quality layouts (better than Mermaid's dagre-based output), self-hostable, and you're OK with an external rendering step (Kroki, a PlantUML server, or a local JAR).

**Good for**: publication-quality C4 diagrams, large diagrams where layout matters, teams that already use PlantUML.

**Minimal example**:

```
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

title Container diagram for Internet Banking System

Person(customer, "Customer", "A bank customer.")

System_Boundary(c1, "Internet Banking System") {
    Container(spa, "Single-Page App", "JavaScript, Angular", "Provides banking features.")
    Container(api, "API Application", "Java, Spring Boot", "Provides a JSON/HTTPS API.")
    ContainerDb(db, "Database", "PostgreSQL", "Stores users, auth, audit logs.")
}

System_Ext(mail, "E-mail System", "Microsoft Exchange.")
System_Ext(mf, "Mainframe", "Core banking.")

Rel(customer, spa, "Uses", "HTTPS")
Rel(spa, api, "Makes API calls to", "JSON/HTTPS")
Rel(api, db, "Reads/writes", "JDBC")
Rel(api, mail, "Sends e-mails via", "SMTP")
Rel(api, mf, "Calls", "XML/HTTPS")

Lay_R(spa, api)
Lay_R(api, db)

@enduml
```

**Note** the `Lay_*` statements — these give you explicit layout hints that Mermaid doesn't support.

**Render**:
- Online: https://www.plantuml.com/plantuml
- Self-hosted: docker `plantuml/plantuml-server`
- Inline in MkDocs: `mkdocs-kroki-plugin` or `plantuml-markdown`

---

## draw.io / diagrams.net

**When to pick**: you prefer drawing-tool UX to text. Good for whiteboarding, rapid iteration, or when colleagues want a tool they can click around in.

**Good for**: workshops, one-off diagrams for slide decks, teams unwilling to adopt text-based diagramming.

**Watch out for**: no source-controlled single source of truth. Diagrams drift from the code. Diffs are useless.

**How**: install the C4 shape library — drawio.com has a built-in C4 set, or import https://github.com/tobiashochguertel/c4-draw.io shapes.

---

## Ilograph

**When to pick**: you want an *interactive* architecture explorer — hover to see details, filter to show only infrastructure, click to drill into a container.

**Good for**: large/complex architectures where static diagrams get cluttered. Living documentation that stakeholders actually read.

**How**: define in Ilograph's YAML schema; host on ilograph.com or self-host the viewer. Similar conceptually to Structurizr but with different strengths (interactive exploration vs multi-view generation).

---

## Kroki

**When to pick**: you want to embed C4-PlantUML / Mermaid / other diagram-source formats inline in docs (MkDocs, Confluence, Hugo, Sphinx) without running multiple renderers.

Kroki is a meta-renderer: one HTTP service that accepts source in any of ~20 formats and returns SVG.

**How**: `docker run -p 8000:8000 yuzutech/kroki`. Point MkDocs' `mkdocs-kroki-plugin` at it. Now you can inline:

````
```plantuml
!include C4_Container.puml
…
```
````

…and have it rendered server-side in the docs build.

---

## Mixed strategies

Real teams often use more than one:

- **Structurizr DSL as source of truth**, **exported to Mermaid** for the README and to PlantUML for Confluence.
- **Mermaid for READMEs**, **PlantUML for published docs**.
- **draw.io for workshop brainstorms**, **Structurizr for the finished model**.

Avoid: maintaining the same diagram in two places by hand. Pick one source of truth and treat any other representation as generated.

## Recommendation matrix

- **Small team, docs in Git** → Mermaid via the `mermaid` skill.
- **Enterprise / many teams / many systems** → Structurizr DSL, with Mermaid and PlantUML exports for different consumption contexts.
- **One-off, high-polish diagram for a slide or paper** → PlantUML C4.
- **You're whiteboarding an idea** → draw.io, transcribe to Structurizr/Mermaid once stable.
