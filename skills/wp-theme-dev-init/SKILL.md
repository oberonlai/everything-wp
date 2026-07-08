---
description: Initialize WordPress theme development environment (classic or block) with templates, PHPCS, PHPStan, PHPUnit, i18n, GitHub Actions, and build scripts
---

# WordPress Theme Development Initialization Skill

This skill scaffolds a complete WordPress theme — **classic** (PHP template
hierarchy) or **block** (HTML block templates + `theme.json`) — and its
development tooling, following the official WordPress Theme Handbook conventions.

> **Note on theme type**: WordPress officially recommends **block themes** as the
> modern method; **classic themes** (PHP template hierarchy: `index.php`,
> `header.php`, `single.php`, …) remain fully supported for projects that need the
> traditional templating model. This skill supports both — the type is chosen by
> the user (Greenfield) or auto-detected via `templates/index.html` (Augment).

## Trigger Keywords

This skill is triggered when the user says any of the following:
- "Initialize WordPress theme development"
- "Set up WordPress classic theme"
- "Scaffold a classic WordPress theme"
- "Set up a block theme" / "Scaffold a WordPress block theme"
- "請幫我初始化 WordPress 佈景主題開發"
- "建立傳統主題開發環境"
- "建立區塊主題（block theme）開發環境"

## Features

1. **Detect Theme Information (Augment mode)**
   - Reads the `style.css` header of an existing theme
   - Extracts theme name, slug (text domain), version, and type
     (`block` if `templates/index.html` exists, else `classic`)

2. **Scaffold Classic Theme Files (Greenfield mode, classic)**
   - `style.css` (theme header + starter CSS), `index.php` (required)
   - `functions.php` + `inc/setup.php` + `inc/enqueue.php`
   - Template hierarchy: `header.php`, `footer.php`, `sidebar.php`,
     `single.php`, `page.php`, `archive.php`, `search.php`, `404.php`,
     `comments.php`
   - `template-parts/content.php`, `template-parts/content-none.php`

2b. **Scaffold Block Theme Files (Greenfield mode, block)** — templates in
   `templates/block/`
   - `style.css` (theme header only — global styles live in `theme.json`)
   - `theme.json` (v3 schema: layout, typography, color palette, template parts)
   - Minimal `functions.php` (text domain, editor style, stylesheet enqueue)
   - Block templates: `templates/index.html` (required), `single.html`,
     `page.html`, `archive.html`, `search.html`, `404.html`
   - Template parts: `parts/header.html`, `parts/footer.html`

3. **Configure Coding Standards**
   - Installs PHP_CodeSniffer + WordPress Coding Standards (WPCS)
   - Adds PHPCompatibility for cross-version PHP checks
   - Generates `.phpcs.xml.dist` with text-domain and prefix enforcement

4. **Configure Static Analysis (PHPStan)**
   - Installs `phpstan/phpstan` + `szepeviktor/phpstan-wordpress`
   - Generates `phpstan.neon` (level 5; classic scans `functions.php`, `inc/`,
     `template-parts/` — block scans `functions.php` only, via
     `block/phpstan.neon.template`)

5. **Configure Unit Testing (PHPUnit)**
   - Installs `phpunit/phpunit:^9.6`, `wp-phpunit/wp-phpunit`, `yoast/phpunit-polyfills`
   - Ships `phpunit.xml.dist`, a **theme-aware** `tests/bootstrap.php` (registers
     and activates the theme under test), a sample test, and the canonical
     `bin/install-wp-tests.sh`

6. **Set Up Internationalization (i18n)**
   - Creates `languages/` and generates a `.pot` via `wp i18n make-pot`
     (also extracts strings from `theme.json` and block template HTML)
   - Wires `load_theme_textdomain()` and `Domain Path: /languages`

7. **Set Up GitHub Actions**
   - `qa` job (PHPCS + PHPStan) + `test` job (PHPUnit matrix on MySQL) →
     `release` job (build ZIP on tag, create Release)
   - Version read from the `style.css` header

8. **Create Build Script**
   - `scripts/build.php` produces a distributable ZIP, excluding dev files

## Official Recommended Route (Block Theme)

Grounded in the WordPress Theme Handbook:

1. **`style.css`** — required, same header rules as classic. Global styles do
   NOT go here; they live in `theme.json`.
2. **`templates/index.html`** — required. Its presence is what makes WordPress
   treat the theme as a block theme.
3. **`theme.json`** — the heart of a block theme: settings (layout, typography,
   color, spacing), styles, and template-part registration. Use `"version": 3`
   (WordPress 6.6+).
4. **`parts/`** — reusable template parts (header, footer) referenced by
   templates via `<!-- wp:template-part /-->`.
5. **`functions.php`** — optional and minimal; most classic theme supports
   (`title-tag`, `html5`, `post-thumbnails`, …) are automatic in block themes.
6. **Site Editor** — end users customize templates visually; keep the shipped
   templates simple and let `theme.json` drive the design.

## Official Recommended Route (Classic Theme)

Grounded in the WordPress Theme Handbook:

1. **`style.css`** — required. Carries the theme header (Theme Name, Version,
   Text Domain, License, etc.). Required header fields for the theme directory:
   Theme Name, Author, Description, Version, Requires at least, Tested up to,
   Requires PHP, License, License URI, Text Domain.
2. **`index.php`** — required. The ultimate fallback in the template hierarchy;
   its presence is what makes the folder a usable theme.
3. **`functions.php`** — strongly recommended. Register theme support in a
   function hooked to `after_setup_theme` (`title-tag`, `post-thumbnails`,
   `html5`, `custom-logo`, `automatic-feed-links`, `responsive-embeds`),
   `register_nav_menus()`, `load_theme_textdomain()`, and enqueue assets via
   `wp_enqueue_scripts`.
4. **Template hierarchy files** — implement only what you need; WordPress
   cascades down to `index.php`.
5. **`screenshot.png`** — recommended 1200×900 (a binary file the skill cannot
   generate; add it manually).
6. **Theme Check** — before submitting to WordPress.org, install the official
   Theme Check plugin and run it in the admin.

## Usage

In your theme directory, tell the AI assistant:

```
Initialize WordPress theme development
```

Or run the `/init-theme` command.

## Manual Execution (Augment mode only)

```bash
bash skills/wp-theme-dev-init/scripts/init.sh
```

`init.sh` only supports the **Augment** path (an existing theme with a
`style.css` header). The **Greenfield** path (a brand-new theme) is executed by
the agent following `commands/init-theme.md`, generating files from templates.

## Requirements

- Composer
- WP-CLI (for `wp i18n make-pot`; optional but recommended)
- MySQL/MariaDB + Subversion (svn) — for the PHPUnit `test:install` step
- Git

> **PHPUnit version**: pinned to `^9.6`. The WordPress test suite is not
> compatible with PHPUnit 10/11, and `yoast/phpunit-polyfills:^2.0` targets
> PHPUnit 9. Do not bump PHPUnit past 9.x.

## Output

After completion, the following may be created:
- Classic: `style.css`, `index.php`, `functions.php` and the template hierarchy,
  `inc/setup.php`, `inc/enqueue.php`,
  `template-parts/content.php`, `template-parts/content-none.php`
- Block: `style.css`, `theme.json`, minimal `functions.php`,
  `templates/*.html`, `parts/header.html`, `parts/footer.html`
- `composer.json` (PHPCS + PHPStan + PHPUnit dev tools + scripts)
- `.phpcs.xml.dist`, `phpstan.neon`, `phpunit.xml.dist`
- `tests/bootstrap.php`, `tests/test-sample.php`, `bin/install-wp-tests.sh`
- `.github/workflows/release.yml`
- `scripts/build.php`
- `languages/{{TEXT_DOMAIN}}.pot`
- `readme.txt`

## Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{{THEME_NAME}}` | Display name (e.g., "My Cool Theme") |
| `{{THEME_SLUG}}` | Directory / text-domain slug (e.g., "my-cool-theme") |
| `{{THEME_VERSION}}` | Version (e.g., "1.0.0") |
| `{{THEME_DESCRIPTION}}` | Short description |
| `{{THEME_URI}}` | Theme homepage URL |
| `{{AUTHOR_NAME}}` / `{{AUTHOR_URI}}` | Author name / URL |
| `{{REQUIRES_WP}}` | Minimum WordPress version (Requires at least) |
| `{{TESTED_UP_TO}}` | Tested up to WordPress version |
| `{{REQUIRES_PHP}}` | Minimum PHP version |
| `{{LICENSE}}` / `{{LICENSE_URI}}` | License name / URL |
| `{{TAGS}}` | Comma-separated theme tags |
| `{{TEXT_DOMAIN}}` | i18n text domain (same as slug) |
| `{{FUNCTION_PREFIX}}` | snake_case function prefix (e.g., "my_cool_theme") |
| `{{CONST_PREFIX}}` | UPPER_SNAKE constant prefix (e.g., "MY_COOL_THEME") |

## Coding Standards Notes

The generated `.phpcs.xml.dist` uses the `WordPress` standard plus
`PHPCompatibilityWP`. It enforces the theme text domain on all i18n calls and
requires the theme prefix on global functions, classes, and constants. Run
`composer phpcbf` to auto-fix most violations.

## Troubleshooting

1. **`dealerdirect/phpcodesniffer-composer-installer` blocked**
   - Composer 2.2+ requires allow-listing plugins. `setup-composer.php` adds it
     to `config.allow-plugins` automatically.

2. **`wp: command not found` during i18n**
   - Install WP-CLI, or run `composer make-pot` later once WP-CLI is available.

3. **GitHub Actions release 403**
   - The workflow already sets `permissions: contents: write` on the release job.

4. **Theme rejected by Theme Check**
   - Theme Check is a runtime admin plugin, not a Composer package. Install it in
     WordPress and run it before submitting to WordPress.org.
