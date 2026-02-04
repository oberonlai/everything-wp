# Everything WP

A comprehensive AI-powered toolkit for WordPress plugin development. This project provides commands, skills, and agents that help AI assistants generate high-quality WordPress plugin code following best practices.

## 🎯 Overview

Everything WP is designed to work with AI coding assistants (like Claude, Cursor, etc.) to accelerate WordPress plugin development while maintaining code quality and WordPress coding standards.

### Key Features

- **16 Commands** - Interactive workflows for common plugin development tasks
- **3 Skill Areas** - Deep knowledge bases for backend, frontend, and plugin initialization
- **1 Agent** - Unified code quality agent for testing and analysis
- **WordPress.org Ready** - Built-in submission review and compliance checks

## 📦 Installation

### For Cursor / Claude

Copy the `everything-wp` directory to your AI assistant's configuration folder:

```bash
# For Cursor
cp -r everything-wp/* ~/.cursor/

# For Claude Code
cp -r everything-wp/* ~/.claude/
```

### For Gemini / Antigravity

Add the skills path to your configuration.

## 🚀 Commands

### Code Generation Commands

| Command | Description |
|---------|-------------|
| `/init-plugin` | Initialize plugin development environment with testing suite, GitHub Actions, and build scripts |
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
| `/verify` | Run all code quality checks (PHPStan + PHPUnit + PHPCS) |
| `/test` | Execute PHPUnit tests and analyze failures |
| `/test-generate` | Generate PHPUnit tests for existing code |
| `/analyse` | Run PHPStan static analysis |
| `/lint` | Run PHPCS code style check with auto-fix |

### Planning & Review Commands

| Command | Description |
|---------|-------------|
| `/plan` | Create implementation plan before coding |
| `/todo` | Execute development tasks from spec file with progress tracking |
| `/submit-review` | Review plugin for WordPress.org submission compliance |

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

### code-quality
Unified agent for all quality checks:
- **generate** mode: Generate tests for existing code
- **test** mode: Execute and analyze PHPUnit tests
- **analyse** mode: Run PHPStan static analysis
- **lint** mode: Run PHPCS code style check
- **verify** mode: Execute all checks in sequence

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

### Executing Tasks from Spec

```
User: /todo spec/booking-system/user-registration.md

AI: Reading spec file...

    📋 Found 4 tasks in user-registration.md

    Scanning src/ folder for current architecture...
    ✅ Found existing patterns: Repository, Service, Controller

    Task 1/4: Create User entity class
    [Implements src/Entity/User.php]
    ✅ Task 1 completed - Updated spec checkbox

    Task 2/4: Create UserRepository class
    [Implements src/Repository/UserRepository.php]
    ✅ Task 2 completed - Updated spec checkbox

    ...

    ╔═══════════════════════════════════════╗
    ║      Task Execution Complete          ║
    ╠═══════════════════════════════════════╣
    ║ Completed │ 4/4 tasks                 ║
    ║ Spec File │ Updated with progress     ║
    ╚═══════════════════════════════════════╝
```

## 📁 Directory Structure

```
everything-wp/
├── commands/           # Interactive command workflows
│   ├── init-plugin.md
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
│   ├── analyse.md
│   ├── lint.md
│   ├── plan.md
│   ├── todo.md
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
│   └── wp-plugin-dev-init/  # Initialization
│       ├── SKILL.md
│       ├── templates/
│       └── scripts/
│
├── agents/             # AI agents
│   └── code-quality.md
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
