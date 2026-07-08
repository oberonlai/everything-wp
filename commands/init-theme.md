---
description: Initialize a WordPress classic theme with template hierarchy, PHPCS, PHPStan, PHPUnit, i18n, GitHub Actions, and build scripts
required_skills:
  - wp-theme-dev-init
  - wp-frontend
---

# Init Theme Command

This command scaffolds a complete **classic (PHP-based) WordPress theme** and its
development environment, following the official WordPress Theme Handbook.

> **Theme type**: WordPress officially recommends **block themes** as the modern
> method. This command intentionally targets **classic themes** (the PHP template
> hierarchy). If the user wants a block theme, tell them this command is for
> classic themes and stop.

## What This Command Does

1. **Detect Mode** — Greenfield (new theme) vs Augment (existing theme)
2. **Collect Theme Information** — via AskUserQuestion (Greenfield only)
3. **Generate Files** — from templates in the skill's `templates/` folder
4. **Configure Tooling** — PHPCS, PHPStan, PHPUnit, i18n, GitHub Actions, build script
5. **Verify** — run `composer phpcs`, `composer phpstan`, `composer test`, `composer build`

## When to Use

- Starting a new classic WordPress theme
- Adding coding standards / CI / build tooling to an existing classic theme

## How It Works

### Step 0: Detect Mode — Greenfield vs Augment

**CRITICAL**: Before any file generation, determine which mode you are in.

#### Detection logic

```
1. Look for style.css in the project root.
2. If style.css exists AND contains a `Theme Name:` header → Augment mode.
   Otherwise → Greenfield mode candidate — verify the directory is safe first.
```

You may use the helper script (does the same detection and outputs JSON):
```bash
php @everything-wp/skills/wp-theme-dev-init/scripts/detect-theme.php .
```

#### Greenfield safety check — do not scaffold in the wrong directory

Before proceeding with Greenfield mode, verify the current directory looks like a
fresh theme folder. Misfires (e.g. running in `wp-content/themes/` root) would
scatter files across the wrong place.

Refuse to proceed and ask the user to confirm if any of these are true:
- Directory contains **5 or more files/folders** that aren't `.git`, `.github`,
  `.claude`, `README.md`, or `LICENSE`
- Directory contains sibling theme folders (each with a `style.css` carrying a
  `Theme Name:` header) — a strong signal we're in `wp-content/themes/`
- Directory basename is `themes`, `wp-content`, or matches `wordpress*`

If any check fails, print:
```
⚠️  This directory does not look like a fresh theme folder.
    Greenfield mode would scaffold files here, possibly damaging existing content.
    Are you sure you want to continue? (y/N)
```
Default No.

#### Mode comparison

| Concern | Greenfield | Augment |
|---------|-----------|---------|
| `style.css` (theme header) | Generate from `style.css.template` | **Do not touch.** Parse it to auto-fill name / slug / version / text domain. |
| Template files (`index.php`, `header.php`, …) | Generate all from templates | **Skip by default.** Only generate a specific template if it does not already exist AND the user opts in. |
| `functions.php`, `inc/` | Generate | Skip if `functions.php` exists; never overwrite. Offer to add `inc/` files only if missing. |
| `composer.json` | Create via `setup-composer.php` | Merge new keys via `setup-composer.php` (deep-merge, backs up first). |
| `.phpcs.xml.dist` | Generate | Ask if exists; never overwrite a custom ruleset. |
| `.github/workflows/release.yml` | Generate | Ask if exists. |
| `scripts/build.php` | Generate | Ask if exists. |
| `readme.txt` | Generate | Ask if exists. |
| `languages/*.pot` | Generate via `wp i18n make-pot` | Ask if exists. |
| `.gitignore` | Append entries (idempotent) | Same — append only missing lines. |
| Dev tool install (`composer require --dev`) | Run | Run — additive, safe. |

#### Augment mode interaction rules

- **Announce the mode**: `Detected existing theme: <name> v<version>. Running in AUGMENT mode — will not touch style.css or existing template files.`
- **Auto-fill what you can** from `style.css` (name, slug, version, text domain).
- **For every potentially destructive write**, ask: `<file> already exists. (o)verwrite / (s)kip / (b)ack up and replace?`
- **Default to skip.**

In Augment mode you can simply run the orchestrator script, which enforces all of
the above:
```bash
bash @everything-wp/skills/wp-theme-dev-init/scripts/init.sh
```

### Step 1: Collect Theme Information (Greenfield)

Use the AskUserQuestion tool. Ask multiple questions per call for efficiency.

**First Question Set (Theme Identity):**

```json
{
  "questions": [
    {
      "question": "What is the theme name? (e.g., 'My Cool Theme')",
      "header": "Theme Name",
      "multiSelect": false,
      "options": [
        { "label": "Use current directory name (Recommended)", "description": "Derive the theme name from the current folder name" },
        { "label": "Enter custom name", "description": "Specify a custom theme name" }
      ]
    },
    {
      "question": "What is the initial version number?",
      "header": "Version",
      "multiSelect": false,
      "options": [
        { "label": "1.0.0 (Recommended)", "description": "Standard initial version" },
        { "label": "0.1.0", "description": "Pre-release version for early development" },
        { "label": "Enter custom version", "description": "Specify a custom version" }
      ]
    }
  ]
}
```

**Second Question Set (Header Fields):**

```json
{
  "questions": [
    {
      "question": "What is the theme description?",
      "header": "Description",
      "multiSelect": false,
      "options": [ { "label": "Enter description", "description": "A brief description of the theme" } ]
    },
    {
      "question": "Who is the theme author?",
      "header": "Author",
      "multiSelect": false,
      "options": [
        { "label": "Use default (Your Name)", "description": "Placeholder author name" },
        { "label": "Enter custom author", "description": "Author name and website URL" }
      ]
    },
    {
      "question": "What license should be used?",
      "header": "License",
      "multiSelect": false,
      "options": [
        { "label": "GPL v2 or later (Recommended)", "description": "Standard WordPress-compatible license" },
        { "label": "GPL v3 or later", "description": "Newer GPL version" },
        { "label": "Enter custom license", "description": "Specify a different license" }
      ]
    }
  ]
}
```

Also collect (with sensible defaults, ask only if the user wants to change them):
- **Requires at least** (default `6.4`)
- **Tested up to** (default the current stable WordPress version)
- **Requires PHP** (default `8.0`)
- **Tags** (default empty; e.g. `blog, custom-menu, translation-ready`)

### Step 2: Derive Values

| Value | How to derive |
|-------|---------------|
| `{{THEME_SLUG}}` | kebab-case of the theme name (e.g. "My Cool Theme" → "my-cool-theme") |
| `{{TEXT_DOMAIN}}` | same as `{{THEME_SLUG}}` |
| `{{FUNCTION_PREFIX}}` | `{{THEME_SLUG}}` with `-` → `_` (e.g. "my_cool_theme") |
| `{{CONST_PREFIX}}` | UPPER_SNAKE of `{{FUNCTION_PREFIX}}` (e.g. "MY_COOL_THEME") |
| `{{LICENSE_URI}}` | GPL v2 → `https://www.gnu.org/licenses/gpl-2.0.html` |

### Step 3: Files to Generate

Templates live in `@everything-wp/skills/wp-theme-dev-init/templates/`. Apply the
mode rules from Step 0. Replace all `{{PLACEHOLDER}}` tokens.

| # | File | Template | Greenfield | Augment |
|---|------|----------|-----------|---------|
| 1 | `style.css` | `style.css.template` | ✅ Generate | 🔴 Skip — never touch |
| 2 | `index.php` | `index.php.template` | ✅ Generate | 🟡 Skip if exists |
| 3 | `functions.php` | `functions.php.template` | ✅ Generate | 🔴 Skip if exists |
| 4 | `inc/setup.php` | `inc/setup.php.template` | ✅ Generate | 🟡 Add only if missing |
| 5 | `inc/enqueue.php` | `inc/enqueue.php.template` | ✅ Generate | 🟡 Add only if missing |
| 6 | `header.php` / `footer.php` / `sidebar.php` | respective templates | ✅ Generate | 🟡 Skip if exists |
| 7 | `single.php` / `page.php` / `archive.php` / `search.php` / `404.php` / `comments.php` | respective templates | ✅ Generate | 🟡 Skip if exists |
| 8 | `template-parts/content.php` / `content-none.php` | respective templates | ✅ Generate | 🟡 Skip if exists |
| 9 | `readme.txt` | `readme.txt.template` | ✅ Generate | 🟡 Ask if exists |
| 10 | `.phpcs.xml.dist` | `phpcs.xml.dist.template` | ✅ Generate | 🟡 Ask if exists |
| 11 | `phpstan.neon` | `phpstan.neon.template` | ✅ Generate | 🟡 Ask if exists |
| 12 | `phpunit.xml.dist` | `phpunit.xml.dist.template` | ✅ Generate | 🟡 Ask if exists |
| 13 | `tests/bootstrap.php` | `tests/bootstrap.php.template` (theme-aware) | ✅ Generate | 🟡 Ask if exists |
| 14 | `tests/test-sample.php` | `tests/test-sample.php.template` | ✅ Generate | 🟡 Ask if exists |
| 15 | `bin/install-wp-tests.sh` | `bin/install-wp-tests.sh` (copy, no placeholders) | ✅ Copy | 🟡 Ask if exists |
| 16 | `.github/workflows/release.yml` | `release-workflow.yml.template` | ✅ Generate | 🟡 Ask if exists |
| 17 | `scripts/build.php` | `build.php.template` | ✅ Generate | 🟡 Ask if exists |

> **`screenshot.png`**: this is a binary image the skill cannot generate. Remind
> the user to add one (recommended 1200×900) at the theme root.

### Step 4: Composer + Tooling Setup

Before this step, ask for the **test database** used by PHPUnit (default
`wordpress_test` / `root` / empty password / `localhost`). Only ask for custom
values if the user wants them.

1. **Configure `composer.json`** (backs up any existing file first):
   ```bash
   php @everything-wp/skills/wp-theme-dev-init/scripts/setup-composer.php . {{THEME_SLUG}} <db-name> <db-user> <db-pass> <db-host>
   ```
   This adds require-dev (PHPCS/WPCS/PHPCompatibilityWP + the phpcs installer,
   PHPStan + `szepeviktor/phpstan-wordpress`, PHPUnit 9.6 + `wp-phpunit` +
   `yoast/phpunit-polyfills`), scripts (`phpcs`, `phpcbf`, `phpstan`, `test`,
   `test:install`, `build`, `make-pot`), and allow-plugins config.

2. **Install dependencies:**
   ```bash
   composer install
   ```

   > **PHPUnit is pinned to `^9.6`** — the WordPress test suite is not compatible
   > with PHPUnit 10/11. If an existing `composer.json` pins a different PHPUnit
   > version, stop and confirm with the user before continuing.

3. **Internationalization:**
   ```bash
   mkdir -p languages
   wp i18n make-pot . languages/{{TEXT_DOMAIN}}.pot --domain={{TEXT_DOMAIN}}
   ```
   (In Augment mode, ask before regenerating an existing `.pot`.)

4. **Update `.gitignore`** (append only missing lines): `/vendor/`, `/build/`,
   `.phpcs.cache`, `phpunit.xml`, `.phpunit.result.cache`, `/node_modules/`,
   `*.bak.*`.

### Step 5: Verify

```bash
composer phpcs        # coding standards (run phpcbf to auto-fix)
composer phpstan      # static analysis
composer test:install # ⚠️ drops & recreates the test DB — confirm first
composer test         # PHPUnit
composer build        # produces build/{{THEME_SLUG}}-v<version>.zip
```

> **⚠️ Data-loss warning**: `bin/install-wp-tests.sh` drops and recreates the
> configured test database (`wordpress_test` by default). Confirm the name does
> not collide with real data. In **wp-env / DDEV** environments, run
> `test:install` / `test` inside the container (e.g. `wp-env run cli composer test`),
> not on the host.

Then remind the user of the Theme Check plugin for WordPress.org submission and
to add `screenshot.png`.

## Example Interaction

```
User: /init-theme

Claude: I'll set up a classic WordPress theme. First, let me detect the mode…
        No style.css found → Greenfield mode. This looks like a fresh folder.

[Uses AskUserQuestion for theme identity, header fields]

Claude: Generating theme files (style.css, index.php, functions.php, template
        hierarchy), configuring PHPCS, PHPStan, PHPUnit, i18n, GitHub Actions, and
        the build script… Running composer phpcs / phpstan / test / build to verify.

        ✅ Done. Add a screenshot.png (1200×900) and you're ready to develop.
```

## Requirements

- Composer
- WP-CLI (for i18n; optional but recommended)
- MySQL/MariaDB + Subversion (svn) — for the PHPUnit `test:install` step
- Git

## Related

- `/init-plugin` — the plugin counterpart.
- `wp-theme-dev-init` — the underlying skill with full documentation.
- `wp-frontend` — WordPress frontend development patterns.
