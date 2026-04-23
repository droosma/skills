# Data / chart diagrams

Pie, Quadrant, XY Chart, Sankey, Radar — for proportional, comparative, and flow data.

---

## Pie

Use for proportions of a whole. Not for trends, not for comparisons across categories.

```
pie showData
    title Browser share (hypothetical)
    "Chrome" : 62
    "Safari" : 20
    "Firefox" : 8
    "Edge" : 7
    "Other" : 3
```

- `showData` (optional) — renders numeric values next to slice labels.
- Values must be **positive numbers > 0**. Negatives error out.
- Up to 2 decimal places.
- Slices render clockwise in declaration order.

Config:
```
---
config:
  pie:
    textPosition: 0.75         # 0=centre, 1=outer edge
---
```

---

## Quadrant chart

Use for 2×2 prioritisation (effort/impact, importance/urgency, BCG matrix).

```
quadrantChart
    title Feature prioritisation
    x-axis Low Effort --> High Effort
    y-axis Low Impact --> High Impact
    quadrant-1 Do Now
    quadrant-2 Schedule
    quadrant-3 Deprioritise
    quadrant-4 Maybe
    Login redesign: [0.3, 0.8]
    Dark mode: [0.2, 0.4]
    GraphQL migration: [0.9, 0.7] radius: 12, color: #ff6b6b
    Refactor CI: [0.7, 0.3] color: #fab005
    Docs overhaul: [0.4, 0.5]
```

### Syntax

- `quadrantChart` header.
- `title` optional.
- `x-axis <left> --> <right>` — or `x-axis <left>` (left only).
- `y-axis <bottom> --> <top>` — or bottom only.
- `quadrant-N <label>` — N=1 top right, 2 top left, 3 bottom left, 4 bottom right.
- Data: `<label>: [x, y]` where x, y ∈ [0, 1].
- Per-point styling (trailing): `color: #rrggbb`, `radius: N`, `stroke-width: N`, `stroke-color: #rrggbb`.

---

## XY Chart (xychart-beta)

Use for line/bar charts with numeric or categorical axes.

```
xychart-beta
    title "Monthly active users"
    x-axis [Jan, Feb, Mar, Apr, May, Jun]
    y-axis "Users (k)" 0 --> 120
    bar [30, 45, 60, 75, 90, 110]
    line [30, 45, 60, 75, 90, 110]
```

### Variants

- `xychart-beta horizontal` — horizontal orientation
- `x-axis "Title" [cat1, cat2]` — categorical x
- `x-axis title min --> max` — numeric x
- `y-axis "Title" min --> max` — numeric only

### Data

- `line [vals…]` — line series
- `bar [vals…]` — bar series
- Multiple series: just add more `line`/`bar` lines

### Config

```
---
config:
  xyChart:
    width: 900
    height: 500
    showTitle: true
    showDataLabel: false
    xAxis:
      showLabel: true
      showTitle: true
      showAxisLine: true
    yAxis:
      showLabel: true
      showTitle: true
    chartOrientation: vertical   # or horizontal
    plotColorPalette: "#1971c2,#ff6b6b,#fab005"
---
```

---

## Sankey (sankey-beta)

Use for flow volumes between nodes. CSV-based format — unusual among Mermaid diagrams.

```
sankey-beta

Agricultural,Bio-conversion,124.729
Bio-conversion,Liquid,0.597
Bio-conversion,Losses,26.862
Bio-conversion,Solid,280.322
Bio-conversion,Gas,81.144
"Thermal generation","District heating",79.329
```

### Rules

- Three columns only: `source,target,value`.
- Standard CSV (RFC 4180) — quote strings with commas/quotes/newlines.
- Blank lines allowed for readability.
- Value is numeric.

Not suitable for labels, directions, or cyclical flows (it's a DAG visualisation).

---

## Radar (radar-beta)

Use for multi-dimensional comparison across the same axes.

```
radar-beta
    title Team skill coverage
    axis frontend["Frontend"], backend["Backend"]
    axis infra["Infra"], ml["ML"], data["Data"]
    curve alice["Alice"]{frontend: 90, backend: 40, infra: 20, ml: 10, data: 30}
    curve bob["Bob"]{frontend: 30, backend: 80, infra: 70, ml: 20, data: 50}
    curve carol["Carol"]{frontend: 20, backend: 50, infra: 30, ml: 80, data: 90}

    showLegend true
    graticule polygon
    ticks 5
    max 100
    min 0
```

### Syntax

- `radar-beta` header.
- `axis <id>["Label"]` — one or more axes per line.
- `curve <id>["Label"]{axis: value, axis: value, …}` — named-axis style.
- Or `curve <id>{val, val, val}` — positional, matches axis order.

### Config options

- `showLegend` (bool) — default true
- `max` / `min` — scale bounds
- `graticule` — `circle` or `polygon`
- `ticks` — concentric rings (default 5)

### Theme variables

Radar-specific: `axisColor`, `axisStrokeWidth`, `curveStrokeWidth`, `graticuleColor`, `cScale0`…`cScale12` (series colours).

---

## Common gotchas

- **Pie values must be positive.** Zero or negative errors out.
- **Quadrant coordinates are 0–1.** Use relative positions; don't try to pass raw scores.
- **XY Chart y-axis is numeric only.** For categorical y, swap orientation to horizontal.
- **Sankey doesn't support cycles.** If your flow loops, split it into phases.
- **Radar is still `-beta`.** Syntax may tighten in future releases; pin or verify.
