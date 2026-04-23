# The C4 model — abstractions

Distilled from Simon Brown's *Visualising Software Architecture* (chapter 4, "A shared vocabulary") and c4model.com. This file covers *what the abstractions mean* — not how to draw them. For diagram types, see `diagram-types.md`. For notation, see `notation.md`.

## Why a shared vocabulary matters

> The dictionary definition for the word "component" is "a part of a larger whole". Imagine that you're building a web application, which itself uses a database. Given the dictionary definition, both of the following uses of "component" are valid:
> — "The web application is a component of the software system."
> — "The web application is made up of a number of components."
> In essence, the word "component" is being used to describe two very different levels of abstraction.
> — *Visualising Software Architecture*

The C4 model exists because "component", "module", "service", "subsystem" are overloaded. Teams argue past each other. C4 pins four specific terms to four specific meanings and asks everyone to use those.

## The hierarchy

A **software system** is made up of one or more **containers** (applications and data stores), each of which contains one or more **components**, which in turn are implemented by one or more **code** elements (classes, interfaces, objects, functions, etc.). And **people** use the software systems that we build.

```
People
   │
   └── use
          │
          ▼
   Software systems
          │ made up of
          ▼
     Containers  (apps and data stores)
          │ each contains
          ▼
      Components
          │ implemented by
          ▼
         Code
```

## Level 1 — Software System

The highest abstraction. Something that delivers value to its users, human or not. This includes:
- The software system you are modelling.
- The other software systems yours depends on (or depend on it).

Hard to pin down precisely because every organisation has its own word — "application", "product", "service". The practical test:

> A software system is something a single software development team is building, owns, has responsibility for, and can see the internal implementation details of. Perhaps the code for that software system resides in a single source code repository, and anybody on the team is entitled to modify it. In many cases, the boundary of a software system will correspond to the boundary of a single team.

**What a software system is *not* in C4**: product domains, bounded contexts, business capabilities, feature teams, tribes, squads. If you're tempted to draw one of those as a System, stop — you probably want a System Landscape instead.

## Level 2 — Container (not Docker!)

> In the C4 model, a container represents an application or a data store. A container is something that needs to be running in order for the overall software system to work.

Concretely:

- **Server-side web app** — Java/Spring on Tomcat, ASP.NET on IIS, Rails on WEBrick, Node.js, etc.
- **Client-side web app** — an SPA in the browser (Angular, React, Vue, Backbone, jQuery, Svelte, …).
- **Client-side desktop app** — WPF, Cocoa, Electron, JavaFX, Qt, …
- **Mobile app** — iOS, Android, Windows Phone.
- **Server-side console application** — a standalone, a batch process, a worker.
- **Serverless function** — AWS Lambda, Azure Function, Cloudflare Worker.
- **Database** — a schema in a relational DB, a document store, a graph DB, an analytical store.
- **Blob / object / content store** — S3 bucket, Azure Blob container, CDN origin.
- **File system** — a local FS or portion of a networked FS (SAN, NAS).
- **Shell script** — a single script if it's a deployable unit.
- **Message broker topic/queue** — Kafka topic, RabbitMQ queue, SQS queue.

A container is a **runtime boundary around some code or data**. The key property: communication *between* containers is usually out-of-process / remote, crossing a process or network boundary.

### Packaging vs containers

- **Same deployable, multiple containers?** — no. If two things are packaged as a single WAR and deployed as one unit, they're one container even if logically distinct.
- **Same physical server, multiple containers?** — yes. Three Java web apps on one Tomcat, three DB schemas on one Oracle instance: that's still three + three = six containers. How they're deployed is a separate concern (Deployment diagram).

Simon Brown's own phrasing: *I wanted a name that didn't imply anything about the physical nature of how that container is executed.* C4 containers predate Docker.

## Level 3 — Component

> A grouping of related functionality encapsulated behind a well-defined interface. If you're using a language like Java or C#, the simplest way to think of a component is that it's a collection of implementation classes behind an interface.

Key rules:

- **Not separately deployable.** Components share a container's process space. The container is the deployable unit.
- **Components should be real.** Evident in the code. Not a whiteboard abstraction that has no mapping to actual packages/modules/files.
- **Packaging of components is orthogonal.** One JAR per component, one JAR for many, one DLL split across many components — a separate concern from the Component diagram.

Component mapping by language:

- **OO (Java, C#, C++)**: classes + interfaces inside a logical grouping.
- **Procedural (C)**: C files in a directory.
- **JavaScript**: a module composed of objects and functions.
- **Functional (F#, Haskell)**: a module (logical grouping of functions and types).
- **Relational DB**: a logical grouping of tables, views, stored procedures, triggers.

## Level 4 — Code

Classes, interfaces, enums, functions, objects. The programming-language building blocks. The C4 model acknowledges this level exists but usually expects the IDE to show it, not a diagram.

## People

Actors, roles, personas, named individuals. Minimum info: **name**, **description**. Not: dev team members, ops engineers (unless they interact with the system through its own interfaces).

## Edge cases

### Microservices you own → a collection of containers

A system made of 3 microservices, each a Java app + MySQL schema → 6 containers (3 apps + 3 schemas). All six live inside one `System_Boundary` on a Container diagram.

### Microservices you don't own → external software systems

If the microservices are operated by another team/org and you can't see inside them, treat each as a `System_Ext` on your Context diagram. Don't cross that boundary.

### Serverless

Same rules as microservices. Each serverless function = one container (separately deployable, runs in its own process space).

### Managed data services (S3, RDS, DynamoDB, Azure SQL, …)

Show as containers on the Container diagram *if you own the buckets/schemas/tables*. You don't run the infra, but you're responsible for the data structure — they're integral to your architecture. Reserve the deployment details (which AWS region, which bucket naming scheme) for the Deployment diagram.

### Platforms, frameworks, and libraries

Not components, not containers. They're **technology choices** of the containers/components that use them. Spring, React, Rails → put them in the `techn` field, not on the diagram as boxes.

### Log files

Usually omit from the Container diagram. They're everywhere and add noise. Include a "File System" container only when the system stores business-critical state on disk.

### Modules and subsystems

C4 deliberately avoids these terms. If your team uses them, define them in a glossary — they're not part of the C4 model. Most people can map their "module" idea onto either Component or Container depending on whether it's separately deployable.

## Why this all matters

The C4 model exists to close one specific gap: the distance between how architects describe a system (diagrams) and how the system is implemented (code). When components on your diagram don't correspond to real packages/modules in your repo, the diagram has become fiction — and fiction ages badly.

Keep Components real. Keep Containers a property of your deployment pipeline (what gets shipped as one unit vs. separately). Keep Systems a property of team ownership. When those three things are true, the diagram reflects reality, which is the only reason to draw one.
