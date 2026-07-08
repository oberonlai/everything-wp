# Everything WP

A comprehensive AI-powered toolkit for WordPress plugin development. This project provides commands, skills, and agents that help AI assistants generate high-quality WordPress plugin code following best practices.

> Other languages: [繁體中文](README.zh-TW.md)

## 🎯 Overview

Everything WP is designed to work with AI coding assistants (like Claude, Cursor, etc.) to accelerate WordPress plugin development while maintaining code quality and WordPress coding standards.

### Key Features

- **15 Commands** - Interactive workflows for common plugin development tasks
- **3 Skill Areas** - Deep knowledge bases for backend, frontend, and plugin initialization
- **4 Agents** - Planner, task executor (TDD-aware), code reviewer, and code quality
- **End-to-End Workflow** - From planning to release, with diff-scoped reviews and quality gates
- **WordPress.org Ready** - Built-in submission review and compliance checks

## 📦 Installation

### Claude Code (recommended)

Install as a Claude Code plugin:

```
/plugin marketplace add oberonlai/everything-wp
/plugin install everything-wp@everything-wp
```

After install, all commands, agents, and skills are immediately available.

### Manual install (Cursor / other tools)

Copy the directory contents to your AI assistant's configuration folder:

```bash
# For Cursor
cp -r everything-wp/* ~/.cursor/

# For Claude Code (manual, instead of plugin install)
cp -r everything-wp/* ~/.claude/
```

### For Gemini / Antigravity

Add the skills path to your configuration.

## 🚀 Commands

### Code Generation Commands

| Command | Description |
|---------|-------------|
| `/init-plugin` | Initialize plugin development environment with testing suite, GitHub Actions, and build scripts |
| `/init-theme` | Initialize a classic theme with template hierarchy, PHPCS, PHPStan, PHPUnit, i18n, GitHub Actions, and build scripts |
| `/custom-table` | Generate custom database table with Repository class for CRUD operations |
| `/list-table` | Generate WP_List_Table class for admin data display |
| `/option-page` | Generate WordPress settings page using Settings API |
| `/rest-api` | Generate REST API controller with authentication and validation |
| `/wp-ajax` | Generate AJAX handler with nonce verification and permission checks |
| `/api-wrapper` | Generate external API wrapper class with retry and logging |
| `/frontend-page` | Generate frontend page (Shortcode, Block, or Template) |

### Quality & Testing Commands

| Command | Description |
|---------|-------------|
| `/verify` | Run all code quality checks (PHPStan + PHPUnit + PHPCS). Recurring error patterns become rule proposals for `rules/wp-essentials.md` |
| `/test` | Execute PHPUnit tests and analyze failures (fast iteration during dev) |
| `/test-generate` | Generate PHPUnit tests for existing code (legacy retrofit only — not needed in TDD flow) |

> For one-off PHPStan or PHPCS runs, use `composer phpstan` / `composer phpcs` directly. Dedicated `/analyse` and `/lint` commands were removed since task-executor handles them scoped, and `/verify` handles them full.

### Planning & Review Commands

| Command | Description |
|---------|-------------|
| `/plan` | Create implementation plan, saved under `spec/<feature-name>/` as `overview.md` + area files numbered by build order (`01-`, `02-`, …) |
| `/todo` | Execute development tasks from a spec file. Supports `--tdd`, `--tdd=unit`, `--tdd=int` for Red-Green-Refactor workflow |
| `/review` | Senior-engineer code review on the current diff (Security, Performance, Simplification, Test gap, i18n). Generalizable findings become rule proposals for `rules/wp-essentials.md` |
| `/submit-review` | Review plugin for WordPress.org submission compliance |
| `/release` | Sync version numbers across all carrier files, commit, tag, and push to trigger the release workflow |

## 📚 Skills

### wp-backend
Core WordPress backend development knowledge:
- PHP Coding Standards
- OOP Patterns
- Security Best Practices
- Database Operations
- Performance Optimization
- PHPStan Configuration
- WordPress.org Submission Rules

### wp-frontend
Frontend development standards:
- CSS Coding Standards
- JavaScript Coding Standards
- HTML Best Practices

### wp-plugin-dev-init
Plugin initialization resources:
- Bootstrap templates
- Activator/Deactivator classes
- GitHub Actions workflow
- Build scripts

## 🤖 Agents

### planner
3-layer task breakdown (Operation Flow → User Stories → Development Tasks). Reads the codebase, optionally fetches user-provided URLs or `@skill-name` references, and saves a structured spec under `spec/<feature-name>/`. Recommends `--tdd` mode based on the feature type.

### task-executor
Implements tasks from a spec file. Updates checkboxes per task as they complete. Supports:
- **Standard mode**: direct implementation following codebase conventions
- **TDD mode** (`--tdd`, `--tdd=unit`, `--tdd=int`): mandatory Red-Green-Refactor per behavior
- **Scoped quality check**: PHPCS / PHPStan on changed files + full PHPUnit, with pre-existing failure detection

### code-reviewer
Diff-scoped, read-only senior code review. Reports findings in five areas — Security, Performance, Simplification, Test coverage gap, and i18n — with severity (🔴 Must / 🟡 Should / 🔵 Nice) and concrete fix suggestions. Does not modify code.

### code-quality
Unified agent invoked by quality commands:
- **generate** mode: Generate tests for existing code (`/test-generate`)
- **test** mode: Execute and analyze PHPUnit tests (`/test`)
- **verify** mode: Execute all checks in sequence (`/verify`)

### submission-reviewer
Reviews the whole plugin for WordPress.org submission compliance (license, readme.txt, forbidden files, third-party docs, privacy, dismissible notices). Invoked by `/submit-review`.

## 🔄 Recommended Workflow

```
/plan <feature description>                # → spec/<feature-name>/overview.md + area files
       ↓
/todo spec/<feature-name>/<area>.md --tdd  # → implement with Red-Green-Refactor
       ↓
/review                                    # → diff-scoped 5-area review
       ↓ fix 🔴 / 🟡 findings
/verify                                    # → full-project quality gate
       ↓
human commit + PR
       ↓ (when ready to publish)
/submit-review                             # → WordPress.org compliance check
```

Each command has a distinct scope:

| Command | Scope | Purpose |
|---------|-------|---------|
| `/todo` Step 5 | Changed files (PHPCS/PHPStan) + full suite (PHPUnit) | Confirm new code is clean and didn't break anything |
| `/review` | Changed files (diff) | Catch issues automated tools miss (security, perf, i18n, etc.) |
| `/verify` | Whole project | Release gate — full PHPStan / PHPUnit / PHPCS |
| `/submit-review` | Whole plugin | wp.org submission compliance |

## 📋 Example Usage

### Creating a New Plugin

```
User: /init-plugin

AI: I'll help you initialize a new WordPress plugin.
    [Asks about namespace, autoload directory, dev tools]
    [Creates composer.json, phpunit.xml, GitHub Actions, etc.]
```

### Adding a Custom Database Table

```
User: /custom-table orders

AI: I'll create a custom orders table.
    [Asks about columns, indexes, relationships]
    [Generates Orders_Table.php and Orders_Repository.php]
```

### Running Quality Checks

```
User: /verify

AI: Starting full quality check...
    
    Step 1/3: PHPStan Static Analysis
    ✅ PHPStan Level 6: 0 errors
    
    Step 2/3: PHPUnit Unit Tests
    ✅ 23 tests passed, 92% coverage
    
    Step 3/3: PHPCS Code Style
    ✅ 0 errors, 0 warnings
    
    ╔═══════════════════════════════════════╗
    ║      Code Quality Report              ║
    ╠═══════════════════════════════════════╣
    ║ Overall │ ✅ Ready for release!       ║
    ╚═══════════════════════════════════════╝
```

### Preparing for WordPress.org Submission

```
User: /submit-review

AI: Running WordPress.org submission review...
    
    ✅ License: GPL-2.0+ detected
    ✅ readme.txt: All required sections present
    ❌ Forbidden Files: Found .DS_Store
    ✅ Third-Party Services: Documented
    ✅ Privacy: No tracking without consent
    
    Action required: Remove .DS_Store before submission
```

### Planning a Feature

```
User: /plan Build a booking system with time slot selection and email confirmation

AI: [Step 1] Scanning src/ ...
    ## Codebase Analysis
    - Namespace: MyPlugin\ | Layers: Repository/Service/Admin/REST
    - Convention: Snake_Case class, constructor DI via Container
    - Reusable: Mailer service, Repository base
    - Conflicts: none

    [Step 3] Operation Flow:
    - Customer browses available time slots
    - Customer submits booking with contact info
    - Admin reviews and confirms booking
    - Email confirmation sent

    [Step 5] Saved plan to spec/booking-system/
    - overview.md
    - customer-flow.md
    - admin-flow.md

    Next step: /todo spec/booking-system/customer-flow.md --tdd=int
    Reason: REST endpoints + DB writes → integration tests
```

### Executing Tasks with TDD

```
User: /todo spec/booking-system/customer-flow.md --tdd=int

AI: TDD mode: int

    Task 1/4: Create Booking entity

    🔴 Red: test_booking_can_be_created — FAILED ✓
    🟢 Green: PASSED ✓
    🔵 Refactor: Extracted validation — PASSED ✓

    ✓ Updated spec checkbox

    [... more tasks ...]

    Step 5 — Scoped Quality Check
    PHPCS (changed files): ✅ clean
    PHPStan (changed files): ✅ clean
    PHPUnit (full suite): ✅ 47 passed, 0 failed
```

### Reviewing the Diff

```
User: /review

AI: 📂 Files reviewed: 3 files
    📊 Findings: 🔴 1 Must · 🟡 2 Should · 🔵 1 Nice

    Security
    🔴 src/REST/Booking_Controller.php:58 — Capability check missing
       Code: register_rest_route( ..., 'methods' => 'POST', 'callback' => ... )
       Issue: POST endpoint accepts any authenticated user; no permission_callback.
       Suggested fix: Add 'permission_callback' => fn() => current_user_can( 'edit_posts' )

    Performance
    No issues found in this area.

    i18n
    🟡 src/Admin/Booking_Page.php:34 — Hardcoded string without __()
       Code: echo '<h2>Booking Management</h2>';
       Suggested fix: echo esc_html__( 'Booking Management', 'myplugin' );

    Recommendation:
    - Fix the 🔴 capability issue before /verify or PR
```

## 📁 Directory Structure

```
everything-wp/
├── commands/           # Interactive command workflows
│   ├── init-plugin.md
│   ├── init-theme.md
│   ├── custom-table.md
│   ├── list-table.md
│   ├── option-page.md
│   ├── rest-api.md
│   ├── wp-ajax.md
│   ├── api-wrapper.md
│   ├── frontend-page.md
│   ├── verify.md
│   ├── test.md
│   ├── test-generate.md
│   ├── plan.md
│   ├── todo.md
│   ├── review.md
│   └── submit-review.md
│
├── skills/             # Knowledge bases
│   ├── wp-backend/     # Backend development
│   │   ├── coding-standards-php.md
│   │   ├── oop-patterns.md
│   │   ├── security.md
│   │   ├── custom-tables.md
│   │   ├── performance.md
│   │   ├── phpstan.md
│   │   └── org-submission.md
│   │
│   ├── wp-frontend/    # Frontend development
│   │   └── coding-standards/
│   │
│   ├── wp-plugin-dev-init/  # Plugin initialization
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   └── scripts/
│   │
│   └── wp-theme-dev-init/   # Classic theme initialization
│       ├── SKILL.md
│       ├── templates/
│       └── scripts/
│
├── agents/             # AI agents
│   ├── planner.md
│   ├── task-executor.md
│   ├── code-reviewer.md
│   ├── code-quality.md
│   └── submission-reviewer.md
│
└── rules/              # Global rules
    └── wp-essentials.md
```

## 🔧 Requirements

- WordPress 6.0+
- PHP 8.0+
- Composer
- WP-CLI (for testing setup)
- Node.js (for frontend builds)

## 📄 License

GPL-2.0 or later

## 🙏 Credits

Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code).

Built for the WordPress community.
