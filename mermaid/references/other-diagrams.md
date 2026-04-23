# Other diagrams

Block, Packet, Mindmap, Requirement, GitGraph — the remaining types.

---

## Block (block-beta)

Use when you need a grid layout of boxes that doesn't fit flowchart ranks. Newer; decent column control.

```
block-beta
    columns 3
    a["A"]
    b["B"]
    c["C"]

    d["Wide block"]:3
    e:1 f:1 g:1
```

### Features

- `columns N` — grid width.
- `name[label]` — block with label.
- `name:N` — block spans N columns.
- `block:name:N\n…\nend` — nested block group, span N cols.
- `space` or `space:N` — empty cells.
- Connections via arrows `A --> B` with optional `|label|`.

### Shapes

Inside a block: `block:id("shape-name", "label")` or shape sigils similar to flowchart.

Options: `rounded`, `stadium`, `circle`, `cylinder`, `diamond`, `hexagon`, `doublecircle`, `arrowblock`.

### Example

```
block-beta
    columns 5

    block:frontend:2
        spa["SPA"]
        mobile["Mobile App"]
    end

    space

    block:backend:2
        api["API"]
        worker["Worker"]
    end

    block:storage:5
        db[("Postgres")]
        cache[("Redis")]
        bucket[("S3")]
        space space
    end

    spa --> api
    mobile --> api
    api --> db
    api --> cache
    api --> bucket
    worker --> db
```

---

## Packet (packet-beta)

Use for network packet field layouts.

### Byte-range form

```
packet-beta
    title TCP packet
    0-15: "Source port"
    16-31: "Destination port"
    32-63: "Sequence number"
    64-95: "Acknowledgement number"
    96-99: "Data offset"
    100-105: "Reserved"
    106-111: "Flags"
    112-127: "Window"
    128-143: "Checksum"
    144-159: "Urgent pointer"
    160-191: "Options (if any)"
```

### Incremental `+N` form (v11.7+)

```
packet-beta
    +16: "Source port"
    +16: "Destination port"
    +32: "Sequence number"
    +32: "Acknowledgement number"
    +4: "Data offset"
    +6: "Reserved"
    +6: "Flags"
```

`+N` means "next N bits starting from the end of the previous field".

Can mix with explicit ranges:
```
packet-beta
    +16: "Source port"
    32-63: "Sequence number"
```

---

## Mindmap

Use for hierarchical idea trees. Indentation-based.

```
mindmap
    root((C4 Model))
        Core diagrams
            Context
            Container
            Component
            Code
        Supplementary
            Dynamic
            Deployment
            System Landscape
        Tooling
            Structurizr
            PlantUML C4
            Mermaid C4
```

### Root shapes

- `root[Square]`
- `root(Rounded)`
- `root((Circle))`
- `root)Cloud(`
- `root))Bang((`
- `root{{Hexagon}}`
- `root` (plain text)

Any node can take these shapes.

### Icons and classes

```
mindmap
    root((Project))
        Backend::icon(fa fa-server)
        Frontend::icon(fa fa-desktop):::urgent

    classDef urgent fill:#f96,stroke:#333
```

- `::icon(css-class)` — renders an icon from a CSS icon font.
- `:::className` — applies a classDef.

### Markdown in labels

```
mindmap
    root["**Main topic**
    with *italic* and
    multiple lines"]
```

### Gotchas

- **Indentation matters** — Mermaid infers nesting from relative indent. Keep it consistent (use spaces, not tabs; pick 2 or 4 and stick to it).
- **Only one root.** Multiple roots at the same level merge into one tree weirdly.
- **Mindmaps lazy-load in v9.4+** — on huge ones this can produce brief blank renders.

---

## Requirement Diagram

Use for formal requirements with traceability. Niche; mostly for safety-critical / regulated domains.

```
requirementDiagram

    requirement top_req {
        id: 1
        text: "The system shall be available 99.9% of the time."
        risk: high
        verifymethod: test
    }

    performanceRequirement perf_req {
        id: 1.1
        text: "P95 API latency under 200ms."
        risk: medium
        verifymethod: test
    }

    functionalRequirement login_req {
        id: 2
        text: "Users authenticate via OAuth2."
        risk: medium
        verifymethod: demonstration
    }

    element api_service {
        type: service
        docref: architecture.md
    }

    element auth_service {
        type: service
        docref: architecture.md
    }

    top_req - contains -> perf_req
    top_req - contains -> login_req
    perf_req - satisfies -> api_service
    login_req - satisfies -> auth_service
    api_service - derives -> perf_req
```

### Requirement types

`requirement`, `functionalRequirement`, `interfaceRequirement`, `performanceRequirement`, `physicalRequirement`, `designConstraint`.

### Element fields

- Requirement: `id`, `text`, `risk` (`low`/`medium`/`high`), `verifymethod` (`analysis`/`inspection`/`test`/`demonstration`)
- Element: `type` (free-text), `docref` (free-text)

### Relationship types

`contains`, `copies`, `derives`, `satisfies`, `verifies`, `refines`, `traces`.

### Direction

```
source - <type> -> dest
dest <- <type> - source
```

Both are valid; pick whichever reads better.

---

## Git Graph

Use for Git branching and commit history. Heavily stylised; good for teaching branching strategies, less good for reflecting real repos (which have too many commits).

```
gitGraph
    commit
    commit
    branch develop
    checkout develop
    commit
    commit
    checkout main
    merge develop
    commit tag: "v1.0.0"
    branch hotfix
    commit id: "abc123" type: HIGHLIGHT
    checkout main
    merge hotfix
```

### Keywords

- `commit` — new commit on current branch
- `branch <name>` — create and switch to branch
- `checkout <name>` — switch branches
- `merge <branch>` — merge into current
- `cherry-pick id: "commit-id"` — pick a commit

### Commit attributes

```
commit id: "custom-id" type: HIGHLIGHT tag: "release"
```

- `id` — custom label (default: auto)
- `type`:
  - `NORMAL` (default) — solid circle
  - `REVERSE` — crossed circle
  - `HIGHLIGHT` — filled rectangle
- `tag` — version label

### Direction and config

```
gitGraph LR:             %% or TB, BT
    commit
```

```
---
config:
  gitGraph:
    showBranches: true
    showCommitLabel: true
    mainBranchName: trunk
    mainBranchOrder: 0
    parallelCommits: false
    rotateCommitLabel: true
---
```

### Gotchas

- **No hash computation** — `id` is just a label.
- **`main` is default branch name** — change via `mainBranchName` config.
- **`parallelCommits: true`** aligns commits across branches by declaration order rather than time — makes teaching material cleaner.
- **No support for multiple parents per commit** beyond a standard merge — octopus merges are not representable.
