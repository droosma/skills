# When *not* to use C4

From Simon Brown's *Visualising Software Architecture* summary (chapter 14):

> The C4 model is not universally applicable. It works well to describe, document, and diagram custom-built, bespoke software systems with a variety of software architectures (monolithic or distributed), built in a variety of general-purpose programming languages, deployed on a variety of platforms (on-premises or cloud). Solutions that are perhaps less suited to the C4 model include embedded systems/firmware, and solutions that rely on heavy customization rather than bespoke development (e.g. SAP and Salesforce). The C4 model is also less suited to diagramming libraries, frameworks, and SDKs.

The three poor-fit cases:

## 1. Embedded systems / firmware

**Why it's awkward**: the abstractions that matter in firmware are very different — timing, interrupts, memory layout, DMA, hardware peripherals, bus topology. A C4 container ("separately deployable unit") doesn't map well to a firmware image running on bare metal.

**Better tools**:
- Hardware block diagrams (the MCU, sensors, actuators, and the buses/GPIOs between them).
- State machines (UML state charts) for device modes.
- Sequence diagrams for protocol interactions.
- Memory maps, interrupt tables, timing diagrams for low-level concerns.

**Where C4 can still help**: at the very top — a System Context diagram showing the firmware as a box and the people/services/other systems that interact with it (a mobile app, a cloud backend, a user with physical controls). Below that, hand off to domain-specific notations.

## 2. Heavily-customised packaged products (SAP, Salesforce, low-code)

**Why it's awkward**: when 90% of your "system" is provided by the vendor, a C4 Container diagram that shows "Salesforce" as one box and your five custom Apex classes as five others is misleading — the vendor product is a vast internal world you can't describe with your own abstractions.

**Better tools**:
- The vendor's own architecture conventions (e.g. Salesforce's "Well-Architected Framework" diagrams, SAP's building-block diagrams).
- Business-process / BPMN diagrams for workflow-centric customisations.
- Data-flow diagrams for integration-heavy work.

**Where C4 can still help**: for the *integrations around* the product. Show the packaged product as a single `System_Ext` on a Context diagram; show how your bespoke integrations and customisations fit around it on a Container diagram. Don't try to decompose the product itself.

## 3. Libraries, frameworks, and SDKs

**Why it's awkward**: a library has no "deployable unit" in the C4 sense. It's code that consumers link into their own systems. There's no runtime boundary, no external system it talks to on its own — it runs inside whatever process uses it.

**Better tools**:
- UML class diagrams for the public API.
- Package / module diagrams for the internal structure.
- Sequence diagrams for typical usage patterns.
- API reference docs generated from source.

**Where C4 can still help**: if the library is substantial and has internal subsystems that users can reason about independently (a database driver with a connection pool, a query builder, a cache, and a metrics exporter), a Component-level diagram *can* be useful as a conceptual overview. But you're bending the model — be clear with readers that this isn't standard C4 usage.

## Other awkward cases (grey areas)

### Pure data pipelines

An ETL pipeline (Airflow DAG, Kafka Streams topology, dbt DAG) has a strong notion of "data flows between stages" that doesn't map cleanly to static structure. You *can* draw each stage as a container, but the resulting Container diagram is essentially a flowchart.

**Better**: a dedicated DAG / data-lineage diagram + a C4 Context diagram showing the pipeline as one box and the data sources / sinks around it.

### Plugin-based architectures

If the system is a host that loads third-party plugins at runtime, the plugins aren't really containers (they share the host's process) and aren't really components of the host (the host doesn't know them at build time). Mark plugins as a *category* of component on the Component diagram, with a note that specific plugins are loaded dynamically.

### Peer-to-peer systems

A protocol where every node runs the same software and has no central server is hard to diagram at Container level — you only want to draw one node, with a note that N of them exist and talk to each other. Use a Dynamic diagram to show the inter-node protocol; use a Deployment diagram to show N-node reality.

### Event-driven / choreography-heavy systems

A system where most logic is event handlers across many services, with no central orchestrator, is hard to draw statically without it becoming "choose your own adventure" (see `anti-patterns.md`).

**Better**: a Container diagram showing the event broker as a central container and each service that publishes/subscribes. Use one Dynamic diagram per business flow to show actual choreography. Avoid trying to cram all flows into the Container diagram.

## The principle

C4 is a tool. It's very good at one thing: reducing ambiguity when teams describe the *static structure of custom-built software systems*. It's not a universal architecture notation.

If you're forcing the abstractions to fit — your containers don't quite feel like deployable units, your components are mushy logical groupings that don't map to code, your diagram has to apologise for what it's omitting — consider whether C4 is the right tool. Even within a single system, C4 can cover the main application while other notations cover the firmware / packaged-product / library pieces.

And: even in the "less suited" cases, the System Context and Container diagrams almost always still add value. Draw those; stop there; use the right tool below.
