# WordPress Classic Theme Development Initialization Skill

A complete automation skill for scaffolding a **classic (PHP-based) WordPress
theme** and its development environment, following the official Theme Handbook.

> WordPress officially recommends **block themes** as the modern method. This
> skill targets **classic themes** by design. Choose it when you want the
> traditional PHP template hierarchy.

## Features

- ✅ Classic theme template hierarchy scaffold (`index.php`, `header.php`, …)
- ✅ `functions.php` with official `add_theme_support` setup
- ✅ Existing-theme detection (Augment mode)
- ✅ PHP_CodeSniffer + WPCS coding standards
- ✅ PHPStan static analysis (`szepeviktor/phpstan-wordpress`)
- ✅ PHPUnit with a theme-aware test bootstrap
- ✅ Internationalization (i18n) with `.pot` generation
- ✅ GitHub Actions workflow (qa + test + release)
- ✅ Build script for release packaging
- ✅ Greenfield / Augment dual-mode safety

## Installation

This skill is located at:
```
skills/wp-theme-dev-init/
```

## Usage

### Automatic Trigger

Say to the AI assistant:
```
Initialize WordPress theme development
```

Or in Chinese:
```
請幫我初始化 WordPress 佈景主題開發
```

Or run the command:
```
/init-theme
```

### Manual Execution (Augment mode only)

```bash
bash skills/wp-theme-dev-init/scripts/init.sh
```

`init.sh` handles the Augment path (existing theme). The Greenfield path (new
theme) is executed by the agent following `commands/init-theme.md`.

## Directory Layout of a Generated Classic Theme

```
my-cool-theme/
├── style.css              # Required — theme header + starter CSS.
├── index.php              # Required — fallback template.
├── functions.php          # Loads inc/setup.php and inc/enqueue.php.
├── header.php
├── footer.php
├── sidebar.php
├── single.php
├── page.php
├── archive.php
├── search.php
├── 404.php
├── comments.php
├── template-parts/
│   ├── content.php
│   └── content-none.php
├── inc/
│   ├── setup.php          # after_setup_theme: supports, menus, widgets, i18n.
│   └── enqueue.php        # wp_enqueue_scripts: styles and scripts.
├── tests/
│   ├── bootstrap.php      # Theme-aware PHPUnit bootstrap.
│   └── test-sample.php
├── bin/
│   └── install-wp-tests.sh
├── assets/                # css / js / images (your own).
├── languages/
│   └── my-cool-theme.pot
├── screenshot.png         # Add manually — recommended 1200×900.
├── readme.txt
├── composer.json          # Dev tools + scripts.
├── .phpcs.xml.dist
├── phpstan.neon
├── phpunit.xml.dist
├── scripts/build.php
└── .github/workflows/release.yml
```

## Composer Scripts

| Script | Purpose |
|--------|---------|
| `composer phpcs` | Check coding standards |
| `composer phpcbf` | Auto-fix coding standard violations |
| `composer phpstan` | Run static analysis |
| `composer test:install` | Install the WordPress test suite (drops & recreates the test DB) |
| `composer test` | Run PHPUnit tests |
| `composer build` | Build a distributable theme ZIP |
| `composer make-pot` | Regenerate the translation template |

## Requirements

- Composer
- WP-CLI (for i18n; optional)
- MySQL/MariaDB + Subversion (svn) — for `composer test:install`
- Git

## Release Flow

1. Update the `Version` field in `style.css`.
2. `git tag v1.0.1`
3. `git push origin v1.0.1`
4. GitHub Actions runs PHPCS, builds the ZIP, and creates the Release.

## Related

- `/init-plugin` — the plugin counterpart of this command.
- `wp-frontend` — WordPress frontend development patterns.
- `wp-backend` — WordPress backend development patterns.
