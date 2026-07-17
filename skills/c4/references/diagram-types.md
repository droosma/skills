# The C4 diagrams

Seven diagram types — four static, three supplementary. All from Simon Brown's *Visualising Software Architecture*.

Shneiderman's mantra organises them:

> Overview first, zoom and filter, then details on demand.

Start at the top, go deeper only when needed. Most teams only need System Context + Container. Don't draw what you won't maintain.

---

## 1. System Context diagram

**Intent.** Set the scene. Answer: what is this system, who uses it, what does it touch?

**Audience.** Everyone. Technical and non-technical, inside and outside the team. The one diagram you can put in front of a business stakeholder.

**Content.** Two kinds of element:
- **People** (actors, roles, personas, named individuals). Info: name, description.
- **Software systems** — your system in focus, plus the external systems it talks to. Info: name, description. No technology.

Your system is the box in the centre; external systems and people cluster around it. Annotate every line with the purpose of the interaction — high-level, no protocols.

**Motivation.**
- Makes scope and boundaries explicit. No assumptions.
- Shows what's being added to an existing environment.
- A starting point for conversations — technical and non-technical.
- Identifies whose door you knock on for inter-system interface details.

**Recommended?** Yes, for all teams. Often the first artefact of a requirements workshop.

**Example (text).** A Personal Banking Customer uses the Internet Banking System to view accounts and make payments. The Internet Banking System uses the bank's existing Mainframe Banking System to get account info and make payments, and the bank's existing E-mail System to send emails to customers.

---

## 2. Container diagram

**Intent.** Open up the system box. Show the high-level shape: apps, data stores, primary technology choices, how they communicate.

**Audience.** Technical staff, inside and outside the team — software developers, ops, support.

**Content.** Three kinds of element:
- **People and software systems** — repeat the surrounding cast from the Context diagram. Continuity matters.
- **Containers** (inside the system boundary) — apps and data stores. Info: name, technology, description/responsibilities.

Wrap the in-focus containers in a `System_Boundary` (explicit software-system boundary). Annotate every relationship with **purpose** *and* **technology/protocol** (HTTP, HTTPS, JSON/HTTPS, gRPC/TLS, JDBC, SMTP, AMQP, …).

Include managed-data services (S3 buckets, RDS schemas, Azure SQL) as containers — you own them even if you don't run them. Include a "File System" container only if it holds business-critical state; skip log files for brevity.

**Motivation.**
- High-level technology choices visible in one picture.
- Communication flows between apps/data stores are explicit.
- Developers can answer: "where do I write code for feature X?"

**Recommended?** Yes, for all teams.

**Example (text).** The Internet Banking System contains: a Java/Spring Web Application (serves HTML + the SPA), a JavaScript/Angular Single-Page App (runs in the browser), a C#/Xamarin Mobile App, a Java/Spring API Application, and a Relational Database schema. The SPA and Mobile App call the API over JSON/HTTPS. The API reads/writes the DB over JDBC, calls the Mainframe over XML/HTTPS, and sends e-mails via the E-mail System over SMTP.

---

## 3. Component diagram

**Intent.** Open up one container. Show its components, their responsibilities, their tech.

**Audience.** Developers and architects. Rarely outside the team.

**Content.** Four kinds of element:
- People and software systems (context, from the Container diagram).
- Other containers (context).
- The container in focus — wrapped in a `Container_Boundary`.
- **Components** inside that container. Info: name, technology, description/responsibilities.

Reflect the architectural style — if the container is a layered app, show layers; if it's hexagonal, show adapters and ports. Annotate inter-component relationships; intra-container calls usually don't need a `techn` (they're in-process).

**Motivation.**
- Shows how a container decomposes — a "where to write code" map.
- Surfaces dependencies between components.
- Summarises implementation details (frameworks, libraries) without drowning in them.

**Recommended?** Optional. Many teams skip this level because it rots fastest — components change more often than containers. Consider it for larger monoliths, during up-front design, or when onboarding many developers. Skip it for simple containers (microservice APIs, data stores).

**Example (text).** The API Application container decomposes into Sign-In Controller, Accounts Summary Controller, Reset Password Controller (all Spring MVC Rest Controllers), plus Security Component, Mainframe Facade, and E-mail Component (Spring Beans). The controllers use the Beans; the Beans call the DB, mainframe, and e-mail system respectively.

---

## 4. Code diagram

**Intent.** Classes, interfaces, fields, methods inside one component. UML class diagram — usually generated from the code.

**Audience.** Developers.

**Content.** UML class diagram or equivalent. Limit scope to one component; otherwise you get a mess of overlapping boxes.

**Motivation.** Bridges the gap from architecture to code. Maps coarse-grained components to actual classes.

**Recommended?** Rarely. The IDE does this on demand. Draw only for the most complex components or for teaching purposes.

---

## 5. Dynamic diagram (supplementary)

**Intent.** How does *one specific feature* work at runtime?

**Audience.** Depends on the abstraction level:
- Systems collaborating → technical + non-technical.
- Containers collaborating → technical.
- Components collaborating → developers.
- Code collaborating → developers.

**Content.** A sequence or collaboration diagram showing how elements (or instances) interact to perform one feature. Can be drawn at any abstraction level (systems, containers, components, code) — but **pick one level per diagram**.

Two styles:
- **Sequence** — participants across the top, time flows down, horizontal arrows are messages. Numbered order is built in.
- **Collaboration** — free-form boxes with numbered arrows. Simpler on a whiteboard; works well when the layout is irregular.

**Motivation.** Static-structure diagrams don't explain *how a feature flows*. A dynamic diagram fills that gap for feature reviews, threat modelling, incident post-mortems.

**Recommended?** Sparingly. An app with 100 features doesn't need 100 dynamic diagrams — create them for patterns, critical flows, or recurring incident scenarios.

---

## 6. Deployment diagram (supplementary)

**Intent.** Map software-system / container **instances** onto infrastructure for a **specific environment** (dev, staging, prod, DR).

**Audience.** Architects, developers, infra, ops, support.

**Content.**
- **Software system instances** — when you need to distinguish one deployment of a third party from another.
- **Container instances** — same.
- **Deployment nodes** — physical, virtualised, containerised, PaaS: racks, regions, VPCs, VMs, pods, runtimes, browsers, devices. Nest them (region → VPC → cluster → pod).
- **Infrastructure nodes** — DNS, load balancers, firewalls, WAFs, CDNs.

Feel free to use cloud-provider icons (AWS, Azure, GCP) for the deployment-node boxes, but include them in the legend.

**Motivation.** The Container diagram should stay deployment-agnostic. Deployment concerns (Kubernetes, Fargate, Lambda, region failover) belong here, not smushed into the Container diagram.

**Recommended?** Yes for all teams, particularly for live/production environments. Draw one per environment.

**Cloud-architecture diagrams** (a common relative): same advice. Don't stop at icons — show your apps and data stores *inside* the cloud nodes. A diagram that lists AWS services but not what each service is for is half a picture.

---

## 7. System Landscape diagram (supplementary)

**Intent.** Step up from a single system. Show how multiple systems in a group, department, domain, or organisation fit together.

**Audience.** Technical and non-technical, inside and outside the software development team.

**Content.** A Context diagram without one system in focus. Shows people and software systems related to a scope — a team, a department, a bounded context, a product domain, an enterprise. Often draws an **organisational boundary** (dotted) around internal systems, with external systems outside it.

**Motivation.**
- Impact analysis when a system is added/removed/restructured.
- Bridges into enterprise architecture thinking without requiring a full EA model.
- Surfaces silos.

**Recommended?** Yes for larger organisations.

---

## Zoom levels, audiences, and volatility

| Diagram | Abstraction | Volatility | Who reads it |
|---|---|---|---|
| System Context | highest | lowest — months to years | everyone |
| Container | high | low — months | technical |
| Component | mid | high — weeks | developers |
| Code | lowest | highest — days | developers |
| Dynamic | any | matches source level | matches source level |
| Deployment | orthogonal | matches environment cadence | architects + ops |
| Landscape | highest++ | low — months to years | everyone |

Use this to decide what to maintain. Keep System Context and Container as the team's primary artefacts. Redraw Component diagrams lazily (on demand). Generate Code diagrams from the IDE; don't commit them.

## The "just enough" rule

> Although the C4 model has the number 4 in its name, you don't need to use all four levels of diagrams. The four levels are there for completeness, providing a way to start with the software system as a single box, gradually zooming in.
> — *Visualising Software Architecture*

Simon Brown's own default: **System Context + Container is enough for most teams.** Add Component only if it pays off. Add Code only when it matters (rare). Add Dynamic / Deployment / Landscape when the question they answer is the one being asked.

Don't draw for completeness. Draw for a purpose.
