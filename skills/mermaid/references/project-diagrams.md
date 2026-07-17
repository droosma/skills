# Project-planning diagrams

Gantt, Kanban, Timeline, User Journey — the "time / task / progress" family.

---

## Gantt

Use for project schedules with dates and dependencies.

### Header and config

```
gantt
    title My Project
    dateFormat YYYY-MM-DD
    axisFormat %Y-%m-%d
    excludes weekends, 2026-12-25
    weekend friday                     %% v11.0+, which day counts as weekend
    todayMarker stroke-width:3px,stroke:#0ff,opacity:0.5
    tickInterval 1week
```

**dateFormat** — input format for task dates. Common: `YYYY-MM-DD`, `YYYY-MM-DD HH:mm`.
**axisFormat** — output format on the axis. Uses d3-time-format: `%Y`, `%m`, `%d`, `%H:%M`, `%b %Y`, etc.
**excludes** — skip these ranges: `weekends`, specific dates, day names.
**weekend** — which single day is "weekend" when only one day off.
**tickInterval** — axis tick spacing: `1day`, `1week`, `2weeks`, `1month`, `1year`.

### Sections and tasks

```
gantt
    title Launch plan
    dateFormat YYYY-MM-DD

    section Design
        Wireframes        :done,    d1, 2026-01-05, 5d
        High-fi mockups   :active,  d2, after d1, 7d

    section Build
        Backend API       :crit,    b1, 2026-01-12, 14d
        Frontend          :         f1, after b1, 10d
        Integration       :         i1, after f1, 5d

    section Launch
        Beta              :milestone, m1, after i1, 0d
        Public release    :milestone, m2, 2026-02-28, 0d
```

### Task syntax

```
Task Name : [status,] [id,] start-or-dep, duration-or-end
```

**Status** (optional first field):
- `done` — completed (grey)
- `active` — in progress (highlighted)
- `crit` — critical path (red border)
- `milestone` — zero-duration marker

Multiple statuses: `crit, active`.

**id** (optional) — referenceable later in `after <id>` / `until <id>`.

**Date forms**:
- Explicit: `2026-01-05, 2026-01-10`
- Duration: `2026-01-05, 5d`
- After another: `after b1, 10d`
- After multiple: `after b1 b2, 10d`
- Until: `2026-01-05, until b1`

**Duration units**: `ms`, `s`, `m`, `h`, `d`, `w`, `M` (month), `y` (year). Fractional: `1.5w`.

### Vertical markers

```
vert 2026-03-15
```

### Click / interaction

```
click task1 href "https://jira.example.com/browse/PROJ-123"
click task1 call showDetails(task1)
```

### Gotcha notes

- **Sections group visually**, they don't affect ordering.
- **`after` dependencies resolve by ID**, not task name.
- **`milestone` tasks have 0 duration** but still take an id+date.
- **`crit` is just visual**; Mermaid doesn't calculate the critical path.

---

## Kanban

Use for a board snapshot — columns of work-in-progress.

### Basic

```
kanban
    todo[To Do]
        Fix login bug
        Refactor config
    inprogress[In Progress]
        Migrate database
    done[Done]
        Ship login page
```

### With IDs and metadata

```
kanban
    todo[To Do]
        bug1[Fix login bug]@{ assigned: "alice", ticket: "PROJ-123", priority: "High" }
        ref1[Refactor config]@{ assigned: "bob", priority: "Low" }
    inprogress[In Progress]
        db1[Migrate database]@{ assigned: "carol", ticket: "PROJ-145", priority: "Very High" }
    done[Done]
        ship1[Ship login page]@{ assigned: "alice", ticket: "PROJ-101" }
```

**Supported metadata keys**: `assigned`, `ticket`, `priority` (values: `Very High`, `High`, `Low`, `Very Low`).

**Ticket URL linking** (config):
```
---
config:
  kanban:
    ticketBaseUrl: 'https://example.atlassian.net/browse/#TICKET#'
---
```

`#TICKET#` is replaced by the `ticket` value.

---

## Timeline

Use for chronological events with optional grouping.

```
timeline
    title History of React
    section v0 era
        2013 : Released by Facebook
    section v16+ era
        2017 : Fiber rewrite
        2018 : Hooks proposed
             : Context API stabilised
    section v18+ era
        2022 : Concurrent rendering
        2023 : Server Components
```

### Syntax

- `title` — optional diagram title
- `section` — group label (all events under a section share a colour)
- `<period> : <event>` — one event per period
- Multiple events under one period: extra lines starting with `:` continue adding events
- Or inline: `2018 : Hooks proposed : Context API stabilised`

### Direction (v11.14+)

```
timeline
    direction LR       %% default
    direction TD       %% top-down (vertical)
```

### Force newlines in long events

```
2023 : Server Components <br> general availability
```

---

## User Journey

Use to map steps a user goes through with satisfaction scores.

```
journey
    title Account signup journey
    section Discover
        See ad: 3: User
        Visit landing page: 5: User
    section Sign up
        Fill form: 3: User
        Email verification: 2: User, System
    section First use
        See dashboard: 5: User
        Complete profile: 4: User
```

### Syntax

- `journey` header
- `title` optional
- `section <name>` groups steps
- Steps: `<step description>: <score>: <comma-separated actors>`
- **Score** is 1–5 (1=terrible, 5=delightful). Renderers show this as face emojis/colours.

### Gotchas

- **One score per step, not a range.** For "varies" use two separate steps.
- **Actor list is freetext** — whatever you type appears in the rendered cell.
- **Not for detailed UX flows** — use flowchart or sequence for that.
