# Validation

Mermaid's parser is strict and terse: errors usually say "Parse error on line N" with a caret pointing at the nearest token. The fixes are almost always one of the things below.

## Validate before returning

If the user is in an environment where you can execute commands, render the diagram with `mmdc` and inspect the exit code. On failure, the stderr tells you the line and the expected/got tokens.

### Install mmdc

```
npm install -g @mermaid-js/mermaid-cli
```

Or Docker:
```
docker pull minlag/mermaid-cli
```

### Validate a diagram

```
mmdc -i diagram.mmd -o /tmp/out.svg
echo $?                          # 0 = parses and renders, non-zero = failure
```

Or pipe stdin:
```
cat <<'EOF' | mmdc -i - -o /tmp/out.svg
flowchart LR
    A --> B
EOF
```

### Render to other formats

```
mmdc -i diagram.mmd -o out.png -t dark -b transparent
mmdc -i diagram.mmd -o out.pdf
mmdc -i README.md -o README.rendered.md       # processes fenced mermaid blocks
```

### Useful flags

| Flag | Purpose |
|---|---|
| `-i` / `--input` | Input file (or `-` for stdin) |
| `-o` / `--output` | Output file (format from extension) |
| `-t` / `--theme` | `default`, `base`, `dark`, `forest`, `neutral` |
| `-b` / `--backgroundColor` | `white`, `transparent`, `#hex` |
| `-w` / `--width` | Width in px |
| `-H` / `--height` | Height in px |
| `--cssFile` | Custom CSS (animations, overrides) |
| `--configFile` | JSON config file |
| `--puppeteerConfigFile` | Puppeteer options (sandbox, proxy) |

If the environment can't run `mmdc`, the user's best option is https://mermaid.live — paste the block, instant feedback.

## Common parse errors and fixes

### "Parse error on line N"

- **Unquoted label with special chars** → wrap the label in `"…"`.
- **Reserved word as ID** (`end`, `class`, `subgraph`, `state`, …) → rename or quote.
- **Wrong header for the diagram type** (e.g. `graph` syntax under `stateDiagram`) → match the header to the body.
- **Smart quotes** (`" "` vs `" "`) — paste from Word/Google Docs often sneaks these in. Replace with straight ASCII quotes.

### "Expecting 'SEMI', 'NEWLINE'…"

Usually a missing newline after a statement. Put each statement on its own line.

### "No such participant X"

Sequence diagram referenced an actor before declaring it (in the wrong order) or typed the ID differently from the declaration.

### "Cannot read properties of undefined"

Often a frontmatter typo: unquoted YAML value with a colon, or wrong indentation in `themeVariables`. Validate YAML with a linter first.

### Diagrams render in `mmdc` but not on GitHub

GitHub lags the upstream parser. Common culprits:

- `architecture-beta`, `block-beta`, `packet-beta`, `sankey-beta`, `radar-beta`, `xychart-beta` — beta diagrams may not be supported yet; flag it to the user.
- `@{ shape: … }` modern shape syntax (v11.3+) — older renderer versions don't recognise it.
- Icon-shape `fa-` names — need FontAwesome available in the renderer.

### Layout looks wrong

Mermaid has limited control over layout:

- **Flowchart**: try `config.layout: elk` or `defaultRenderer: dagre`.
- **C4 in Mermaid**: no layout primitives; reorder declarations and use directional `Rel_*`.
- **Architecture**: reorder services within groups.
- **Sequence**: participant declaration order is the only lever.

## Pre-flight checklist

Run this mentally before handing a diagram back. Each item, if violated, is a common cause of "it didn't render":

- [ ] The fenced block is ` ```mermaid ` (not plain ` ``` `).
- [ ] The first non-frontmatter line is a valid diagram header for the content (`flowchart`, `sequenceDiagram`, `classDiagram`, `stateDiagram-v2`, `erDiagram`, `C4Context`/`C4Container`/…, `gantt`, `pie`, `journey`, `gitGraph`, `timeline`, `mindmap`, `requirementDiagram`, `architecture-beta`, `block-beta`, `packet-beta`, `sankey-beta`, `radar-beta`, `xychart-beta`, `quadrantChart`, `kanban`).
- [ ] Every arrow connects two declared things (nodes, participants, states, entities, etc.).
- [ ] Labels with punctuation, spaces, or reserved words are double-quoted.
- [ ] No reserved words are used as IDs.
- [ ] Frontmatter YAML (if present) is valid — ending `---` line, consistent indentation, hex colours (not names) under `themeVariables`.
- [ ] No trailing content after the last valid statement (e.g. stray `end` with no opening `subgraph`).
- [ ] Diagram-specific traps checked:
  - Flowchart: `end` as node → quote it.
  - Sequence: actors exist before arrows use them.
  - Class: `~T~` for generics, not `<T>`.
  - State: use `stateDiagram-v2`.
  - C4: `System_Boundary(a, "X") {` — brace on same line as declaration.
  - Architecture: `-beta` suffix, anchors are single letters (`:T`, `:B`, `:L`, `:R`).
  - Pie: values > 0.
  - Sankey: exactly 3 CSV columns.

## Worst offenders (personal hit parade)

1. **Smart quotes from pasted text.**
2. **`end` as a flowchart node ID.**
3. **Using `graph` when you wanted `flowchart` features (or vice versa).**
4. **Forgetting the `-beta` suffix.**
5. **Unquoted labels containing `(…)` that Mermaid interprets as another shape.**
6. **Writing `A -->|text| B` in a class diagram** (class uses `A --> B : text`).
7. **Unbalanced `activate`/`deactivate` in sequence diagrams.**
