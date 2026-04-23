# Rendering Mermaid in Markdown

Every ecosystem that supports Mermaid accepts the same ` ```mermaid ` fenced block, but each has quirks.

## GitHub (github.com) & GitHub Enterprise

Native since 2022. Nothing to install. Renders on:

- Markdown files in any repo.
- Issues, PRs, PR reviews, Discussions.
- Wikis (as of ~2023).
- Gists.

**Version lag**: GitHub typically runs a Mermaid version a few minor releases behind upstream. `-beta` diagrams (architecture, block, packet, radar, sankey, xychart) may not render until they graduate. Test with a small change first if you're targeting GitHub specifically.

**File extension for raw SVG**: GitHub will not render `.mmd` files natively; commit the diagram in a `.md` with a fenced block for it to appear.

## GitLab

Native since v10.3. Same fenced-block syntax. Generally stays closer to upstream than GitHub, but still lags beta diagrams.

## MkDocs (Material for MkDocs)

Two working setups — pick one.

### Option A: `pymdownx.superfences` with custom fence (recommended)

`mkdocs.yml`:
```yaml
markdown_extensions:
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format

extra_javascript:
  - https://unpkg.com/mermaid@11/dist/mermaid.min.js
```

Then in a page:
```
<script>
  mermaid.initialize({ startOnLoad: true });
</script>
```

Or use the Material theme feature:
```yaml
theme:
  name: material
  features:
    - content.code.copy

plugins: []

markdown_extensions:
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
```

Material has built-in mermaid support since 9.x — diagrams auto-render when this extension is configured.

### Option B: `mermaid2` plugin

```
pip install mkdocs-mermaid2-plugin
```

`mkdocs.yml`:
```yaml
plugins:
  - mermaid2:
      version: 11
```

## Docusaurus

Native since v2.5. Enable in `docusaurus.config.js`:

```js
module.exports = {
  markdown: {
    mermaid: true,
  },
  themes: ['@docusaurus/theme-mermaid'],
};
```

Install theme:
```
npm i @docusaurus/theme-mermaid
```

Theme supports the same fenced block and honours front-matter `config`.

## Obsidian

Native. Works with the standard fenced block. Older community plugins may ship an outdated Mermaid; if something renders in mmdc but not Obsidian, that's usually why. Settings → Community plugins → Mermaid → update.

## Notion

Limited-native. Select a code block, set language to "Mermaid" via the language picker. Not every feature is supported (older Mermaid version). Beta diagrams frequently fail.

## Confluence Cloud

**Atlassian's native code macro does not render Mermaid.** Options:

1. **Marketplace app** — "Mermaid Diagrams for Confluence" (Atlassian Marketplace). Paid for larger sites.
2. **Pre-render**: run `mmdc -i diagram.mmd -o diagram.svg`, insert the SVG as an attachment. Loses editability but always works.
3. **draw.io app** — not Mermaid, but handles most diagramming needs and is often already installed.

Confluence Server (self-hosted, EOL 2024) had more options via macros.

## VS Code

- **Markdown Preview Mermaid Support** extension — renders `.md` files in the preview pane.
- **Mermaid Editor** extension — live editor for `.mmd` files.
- **GitHub Markdown Preview** — mirrors what GitHub would render.

## Hugo

Use a shortcode. Install `emgag/hugo-mermaid` or write a custom shortcode:

`layouts/shortcodes/mermaid.html`:
```html
<div class="mermaid">{{ .Inner | safeHTML }}</div>
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  mermaid.initialize({ startOnLoad: true });
</script>
```

In a page:
```
{{< mermaid >}}
flowchart LR
    A --> B
{{< /mermaid >}}
```

## Static SVG / PNG export

For environments that don't run Mermaid client-side (LaTeX, print, Confluence without the app, legacy wikis), pre-render:

```
mmdc -i diagram.mmd -o diagram.svg
mmdc -i diagram.mmd -o diagram.png -t dark -b transparent -w 1600 -H 900
mmdc -i diagram.mmd -o diagram.pdf
```

**Markdown → Markdown with inline SVGs**:
```
mmdc -i README.template.md -o README.md
```

`mmdc` parses fenced `mermaid` blocks, renders each, writes an SVG alongside, and rewrites the block as an image reference. Useful for CI that ships rendered docs alongside source.

## Which to pick

| Scenario | Recommendation |
|---|---|
| README.md on GitHub / GitLab | Native, no setup. |
| Internal docs site (MkDocs) | `pymdownx.superfences` custom fence. |
| Docs under Docusaurus | Built-in `theme-mermaid`. |
| Personal knowledge base (Obsidian) | Native, update the plugin. |
| Confluence | Pre-render with mmdc → SVG, or buy the marketplace app. |
| LaTeX / print / slide deck | Pre-render to PNG/SVG/PDF with mmdc. |
| One-shot diagram to share | https://mermaid.live, export PNG. |

## Pitfalls

- **Raw HTML in labels** blocked by strict `securityLevel` — set `securityLevel: loose` if you need `<br>`, font tags, click events.
- **Fonts differ**: renderers use the page's CSS font stack. Diagrams that look right locally may re-flow in production.
- **Dark mode**: pick `theme: dark` via frontmatter for a native dark look, or style with `themeVariables` on `theme: base` for full control.
- **CSP / sandbox**: client-side Mermaid needs to evaluate its own JS. Strict CSP can block this; use pre-rendered SVGs instead.
