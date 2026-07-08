---
description: Turn a reference website into a consistent block theme design system — extract design tokens, normalize into theme.json, implement components as dynamic blocks, generate a UI library review page, then assemble pages conversationally
---

# WordPress Block Theme Pipeline Skill

This skill powers the `/make-block` command: a production line that converts a
**reference website URL and/or design mockup images** into a block theme whose
visual consistency is guaranteed **by structure, not by discipline**.

## Trigger Keywords

- "/make-block"
- "把這個網站做成 block theme"
- "照這個網址做主題"
- "照這張設計稿做主題"、"我上傳設計稿，幫我做成 block theme"
- "Clone this site's design into a block theme"
- "Build a block theme from these mockups"
- 組裝階段: "用 block 組頁面"、"這區要從資料庫撈文章"、"這裡要開欄位"

## The Constitution — Single Source of Truth

Consistency does not come from remembering to use the same style on every
page. It comes from every visual value having exactly ONE source:

| Visual concern | Single source | Forbidden elsewhere |
|----------------|---------------|---------------------|
| Colors / font sizes / spacing / radius / shadows | `theme.json` tokens | Hard-coded hex / px |
| Component markup & appearance | Dynamic block + its CSS | Copied markup, class overrides |
| Pages | Templates — reference and arrange only | Inline styles, redefined components |

Every stage of the pipeline, and every assembly-mode edit, must respect this
table. The consistency audit (below) makes violations mechanical to detect.

## Pipeline Overview

```
URL ──▶ 1 Extract ──▶ 2 theme.json ──▶ 3 Dynamic Blocks ──▶ 4 UI Library Page ──▶ 🚦 user review
         (record)      (+ /init-theme)   (npm build)          (single gate)
                                                                   │ approved
                                                                   ▼
                                                        Assembly Mode (conversational)
```

Stages 1-4 run without stopping. The ONLY gate is the UI library page — the
single-source design makes late corrections cheap: fixing a token in
`theme.json` or a component's CSS propagates everywhere automatically.

## Stage Details

### 1. Extract (URL and/or images)

**URL route (agent-browser)** — load each reference URL and run
`scripts/extract-tokens.js` via `agent-browser eval` — it walks visible
elements and collects computed styles: colors (with usage counts and roles),
font sizes/weights/families, spacing values, radii, shadows, and container
widths. Screenshot each page for the component inventory analysis.

**Image route (design mockups)** — when the input is png/jpg/webp/pdf files
or pasted images, extract visually:
- Palette: sample dominant colors; ground estimates with ImageMagick when
  available (`magick <img> -format %c -colors 16 histogram:info:- | sort -rn`).
- Type scale: estimate from relative sizes; ask for exact values if the user
  has the design source (Figma/Sketch) rather than guessing.
- Spacing / radius / container width: measure pixel proportions against a
  stated assumed design width (e.g. 1440px).
- Tag every image-derived value with `"source": "image-estimate"` in the raw
  token file. Estimates are corrected at the UI library gate, where the user
  compares rendered blocks against the mockup side by side.

**Mixed input** — URL-derived values win on token conflicts (computed styles
are precise); images fill the gaps: components, states, and layouts the live
site does not show.

Extraction output is a DRAFT, not the truth: third-party widgets add noise,
hover/focus states are not captured (URL route), image measurements are
estimates (image route), and role classification is heuristic. Record
everything in `design/design-tokens.raw.json` and
`design/component-inventory.md`; the user audits visually at the UI library
gate instead of reviewing raw JSON.

Component inventory taxonomy:
- **element** — atomic: button, tag, avatar, icon-box, input, section-head
- **section** — composed: hero, faq, pricing, card-grid, cta-band, logo-wall
- **template** — full pages: home, about, archive, single

For each component record: name (kebab-case), variants, content parameters,
and the pages it appears on.

### 2. Normalize → theme.json

Run the `/init-theme` block-mode flow first for the theme chassis (tooling,
CI, base templates). Then collapse raw tokens into semantic scales:

- **Colors**: cluster near-identical values (ΔE or simple RGB distance), keep
  6-10 semantic slots: `base`, `contrast`, `primary`, `secondary`, `accent`,
  `border`, plus surface tints as needed. Name by ROLE, never by appearance
  (`primary`, not `blue`).
- **Font sizes**: snap measured sizes to a scale; register in
  `settings.typography.fontSizes` with `fluid` enabled.
- **Spacing**: derive a scale (e.g. 4/8/16/24/40/64) for
  `settings.spacing.spacingSizes`.
- **Layout**: `contentSize` / `wideSize` from measured container widths.

Write `design/token-mapping.md` (raw → semantic → seen-at) as the audit trail.

### 3. Dynamic Blocks

One block per inventory element/section, under `blocks/<slug>/`, generated
from `templates/block/` in this skill:

```
blocks/card/
├── block.json      # attributes = variants + content params; textdomain = theme's.
├── render.php      # server-side markup, BEM classes, token-only styling.
├── edit.js         # variant controls via @wordpress/components.
└── style.css       # component CSS; var(--wp--preset--*) references only.
```

Conventions:
- Block namespace = theme slug (e.g. `my-theme/card`).
- `render.php` escapes all output (`esc_html`, `esc_url`, `esc_attr`) and
  never queries the database unless the block is a data block (assembly mode).
- CSS class scheme: `.wp-block-<ns>-<slug>` root + BEM elements
  (`&__title`, `&__media`) + variant modifiers (`&--ghost`).
- Registration: `functions.php` globs `blocks/*/block.json` into
  `register_block_type` on `init`.
- Build: `package.json` with `@wordpress/scripts`; `npm run build` outputs to
  `blocks/*/build/` (or `build/blocks/`); the theme's `scripts/build.php` and
  release workflow must run `npm ci && npm run build` before packaging.

### 4. UI Library Page (the single gate)

Generate `patterns/ui-library.php` inserting every block × every variant,
grouped with heading separators. Create a draft page on the local site via
WP-CLI (inside the container for wp-env/DDEV) and report:
- Front-end preview URL + editor URL
- Table of generated blocks (name, variants, source component)
- The consistency report

Review loop: user reports issues in natural language → fix at the single
source only → `npm run build` → refresh → re-audit. Never patch a page.

### 5. Consistency Audit

`scripts/audit-consistency.sh` checks, all must pass before reporting:

| Check | Tool | Pass condition |
|-------|------|----------------|
| Hard-coded hex / px in block CSS & templates | `rg` | 0 findings (whitelisted: `0px`, `1px` borders, media queries) |
| Duplicated markup structure across blocks/templates | `ast-grep` / `rg` | 0 findings |
| Inventory component without a block | script diff | listed, user decides |
| Coding standards / static analysis | `composer phpcs && composer phpstan` | clean |

Output: `design/consistency-report.md`.

## Assembly Mode Guide

After UI library approval the user directs page assembly conversationally.
Map their intent to exactly one of these mechanisms — do not invent hybrids:

| User intent | Mechanism | Notes |
|-------------|-----------|-------|
| Section lists posts from the database | `WP_Query` in the block's `render.php`; attributes `postType` / `count` / `taxonomy` | Prefer extending the existing display block (e.g. card) with a `source: query` mode over duplicating it |
| Text/image/link editable per page | Block attributes | Edited inline in the editor; no admin page needed |
| Site-wide settings (phone, social links, footer text) | Options page via the `option-page` skill; blocks read `get_option()` | One options page for the theme, not one per block |
| Extra field on posts, shown in a component | `register_post_meta` (+ editor panel); block reads meta in `render.php` | Sanitize on save, escape on output |

Assembly rules (constitution applied):
- Pages are composed ONLY of existing custom blocks and core blocks.
- Zero new CSS during assembly. A visual need that CSS would solve means a
  missing block variant — add the variant, rebuild, then use it.
- Each assembled page lands as `templates/<slug>.html` or `patterns/<slug>.php`
  (sections meant for reuse become patterns).
- Re-run the consistency audit after each page.

## Requirements

- A running local WordPress (wp-env / DDEV / Local) — for block registration
  and the UI library page
- Node.js + npm (`@wordpress/scripts`)
- agent-browser (global install) — URL extraction; not needed for image-only input
- ImageMagick (`magick`) — recommended for mockup palette sampling
- Composer, WP-CLI — inherited from the theme chassis
- `rg`, `ast-grep`, `jq` — audit tooling

## Outputs

```
design/                        # Pipeline records & audit trail.
theme.json                     # Token single source (via /init-theme chassis).
blocks/<slug>/                 # One dynamic block per component.
patterns/ui-library.php        # The review gate page.
patterns/*.php                 # Reusable sections (assembly).
templates/*.html               # Assembled pages (assembly).
package.json                   # @wordpress/scripts build.
```

## Troubleshooting

1. **`npm run build` fails on a block** — check `block.json` `editorScript`
   paths match `@wordpress/scripts` conventions (`file:./build/index.js` or
   the src auto-detection layout).
2. **UI library page renders unstyled** — block styles registered but not
   enqueued: verify `style` in `block.json` and that `register_block_type`
   points at the BUILT block.json, not the source one.
3. **wp-env: `wp post create` fails** — run inside the container:
   `wp-env run cli wp post create …`.
4. **Extraction returns hundreds of colors** — normal; Stage 2 clustering
   handles it. If clustering keeps >12 colors, the site itself is
   inconsistent — pick the dominant values and note the discards in
   `token-mapping.md`.

## Related

- `commands/make-block.md` — the command entry point.
- `wp-theme-dev-init` — theme chassis (tooling, CI, base templates).
- `option-page` — global settings pages in assembly mode.
- `wp-frontend` — CSS/BEM/Gutenberg conventions.
