# WordPress Block Theme Pipeline Skill

Turns a **reference website URL and/or design mockup images** into a
consistent block theme design system, fully automated up to a single review
gate:

```
URL / mockups → extract tokens → theme.json → dynamic blocks → UI library page → 🚦 you review
                                                                          │
                                                              conversational page assembly
```

Consistency is guaranteed by structure — every visual value has one source
(`theme.json` for tokens, one block per component), pages only reference — and
verified mechanically by the consistency audit.

## Usage

```
/make-block https://reference-site.com
/make-block designs/home.png designs/about.png
/make-block https://reference-site.com designs/new-pricing.png   # curated mode
```

URL-only input auto-discovers the site via its sitemap (one representative
page per template). Mixed input = **curated mode**: your screenshots drive
coverage (pages, hover/open/error states, breakpoints — the fast path), the
URL is scanned only to calibrate precise token values, and sitemap discovery
is skipped. The
pipeline runs without stopping and ends with the URL of a **UI Library page**
on your local WordPress site containing every generated block in every
variant. Review it, report issues in natural language ("主色太暗"、"button
hover 不對"), and each fix lands at the single source so it propagates
everywhere.

After approval, assemble pages conversationally: tell the assistant which
sections pull posts from the database, which fields should be editable in the
admin, etc. See the Assembly Mode Guide in `SKILL.md`.

## Layout

```
skills/wp-block-theme-pipeline/
├── SKILL.md                        # Constitution, stage details, assembly guide.
├── scripts/
│   ├── discover-pages.mjs          # Sitemap discovery + template clustering.
│   ├── extract-tokens.js           # agent-browser eval — computed-style scan.
│   └── audit-consistency.sh        # Single-source enforcement (rg-based).
└── templates/
    ├── block/                      # block.json / render.php / edit.js / style.css.
    ├── package.json.template       # @wordpress/scripts build.
    ├── register-blocks.php.template
    └── ui-library.php.template     # Review gate pattern skeleton.
```

## Requirements

- Running local WordPress (wp-env / DDEV / Local)
- Node.js + npm, Composer, WP-CLI
- agent-browser (URL input), ImageMagick (image input), rg, ast-grep, jq

## Related

- `/make-block` — the command entry point (`commands/make-block.md`).
- `wp-theme-dev-init` — scaffolds the theme chassis; called automatically.
- `option-page` — global settings pages in assembly mode.
