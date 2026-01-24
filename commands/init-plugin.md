---
description: Initialize WordPress plugin development environment with testing suite, GitHub Actions, and build scripts
---

# Init Plugin Command

This command initializes a complete WordPress plugin development environment by collecting plugin information through interactive questions.

## What This Command Does

1. **Collect Plugin Information** - Ask user for plugin details
2. **Configure Development Environment** - Set up testing, CI/CD, and build tools
3. **Generate Files** - Create all necessary configuration files from templates
4. **Verify Setup** - Run tests and build to ensure everything works

## When to Use

Use `/init-plugin` when:
- Starting a new WordPress plugin project
- Adding testing infrastructure to an existing plugin
- Setting up CI/CD for a plugin

## How It Works

### Step 1: Collect Plugin Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Plugin Name** (e.g., "My Awesome Plugin")
2. **Plugin Slug** (e.g., "my-awesome-plugin")
3. **Plugin Version** (e.g., "1.0.0")

**Optional Configuration:**
4. **PHP Namespace** (default: derived from plugin name)
5. **Autoload Directory** (default: "src")
6. **Database User** (default: "root")
7. **Database Password** (default: empty)
8. **Database Host** (default: "localhost")

**Development Tools (multi-select):**
9. **PHPUnit** - Unit testing framework
10. **PHPStan** - Static analysis tool
11. **PHP_CodeSniffer + WPCS** - Code style checker

**Build Options:**
12. **Local Build Script** - Create release ZIP with `composer build`

**OOP Structure:**
13. **Bootstrap Structure** - Create src/Bootstrap.php, src/Activator.php, src/Deactivator.php

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure. Ask multiple questions in a single call for efficiency:

**First Question Set (Plugin Identity):**

```json
{
  "questions": [
    {
      "question": "What is the plugin name? (e.g., 'My Awesome Plugin')",
      "header": "Plugin Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Use current directory name (Recommended)",
          "description": "Automatically derive plugin name from the current folder name"
        },
        {
          "label": "Enter custom name",
          "description": "Specify a custom plugin name manually"
        }
      ]
    },
    {
      "question": "What PHP namespace should be used for autoloading?",
      "header": "Namespace",
      "multiSelect": false,
      "options": [
        {
          "label": "Auto-generate from plugin name (Recommended)",
          "description": "Convert plugin name to PascalCase (e.g., MyAwesomePlugin)"
        },
        {
          "label": "Enter custom namespace",
          "description": "Specify a custom PHP namespace manually"
        }
      ]
    }
  ]
}
```

**Second Question Set (Configuration):**

```json
{
  "questions": [
    {
      "question": "What is the initial version number for this plugin?",
      "header": "Version",
      "multiSelect": false,
      "options": [
        {
          "label": "1.0.0 (Recommended)",
          "description": "Start with standard initial version"
        },
        {
          "label": "0.1.0",
          "description": "Start with pre-release version for early development"
        },
        {
          "label": "Enter custom version",
          "description": "Specify a custom version number"
        }
      ]
    },
    {
      "question": "Which database configuration should be used for testing?",
      "header": "Database",
      "multiSelect": false,
      "options": [
        {
          "label": "Default: root@localhost (Recommended)",
          "description": "Use root user with no password on localhost"
        },
        {
          "label": "Enter custom credentials",
          "description": "Specify custom database user, password, and host"
        }
      ]
    }
  ]
}
```

**Third Question Set (Development Tools):**

```json
{
  "questions": [
    {
      "question": "Which development tools do you want to install?",
      "header": "Dev Tools",
      "multiSelect": true,
      "options": [
        {
          "label": "PHPUnit (Recommended)",
          "description": "Unit testing framework for PHP with WordPress integration"
        },
        {
          "label": "PHPStan",
          "description": "Static analysis tool to find bugs without running the code"
        },
        {
          "label": "PHP_CodeSniffer + WPCS",
          "description": "Code style checker with WordPress Coding Standards"
        },
        {
          "label": "None",
          "description": "Skip installing development tools"
        }
      ]
    },
    {
      "question": "Do you want to add local build script for packaging?",
      "header": "Build Script",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Add scripts/build.php and composer build command for creating release ZIP"
        },
        {
          "label": "No",
          "description": "Skip local build script setup"
        }
      ]
    },
    {
      "question": "Do you want to add OOP bootstrap structure with Activator/Deactivator classes?",
      "header": "OOP Structure",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Create src/Bootstrap.php, src/Activator.php, src/Deactivator.php with PSR-4 autoloading"
        },
        {
          "label": "No",
          "description": "Keep simple procedural structure in main plugin file"
        }
      ]
    }
  ]
}
```

**Tool Installation Commands:**

Based on user selection, install the corresponding packages:

| Tool | Composer Command |
|------|------------------|
| PHPUnit | `composer require --dev phpunit/phpunit wp-phpunit/wp-phpunit yoast/phpunit-polyfills` |
| PHPStan | `composer require --dev phpstan/phpstan szepeviktor/phpstan-wordpress` |
| PHP_CodeSniffer + WPCS | `composer require --dev squizlabs/php_codesniffer wp-coding-standards/wpcs phpcompatibility/phpcompatibility-wp dealerdirect/phpcodesniffer-composer-installer` |

**Build Script Setup:**

If "Yes" selected for build script:
1. Create `scripts/build.php` from template
2. Add `"build": "php scripts/build.php"` to composer.json scripts
3. The build script will create a release ZIP file excluding dev files

**OOP Structure Setup:**

If "Yes" selected for OOP structure:
1. Create `src/` directory
2. Create `src/Bootstrap.php` from `Bootstrap.php.template`
3. Create `src/Activator.php` from `Activator.php.template`
4. Create `src/Deactivator.php` from `Deactivator.php.template`
5. Update main plugin file to use OOP structure:
   - Add autoloader require
   - Replace procedural hooks with class calls
   - Use `Bootstrap::get_instance()` for initialization
   - Use `Activator::activate()` for activation hook
   - Use `Deactivator::deactivate()` for deactivation hook
6. Configure PSR-4 autoload in composer.json:
   ```json
   {
     "autoload": {
       "psr-4": {
         "{{NAMESPACE}}\\": "src/"
       }
     }
   }
   ```

**If custom database selected, follow up with:**

```json
{
  "questions": [
    {
      "question": "What is your database username?",
      "header": "DB User",
      "multiSelect": false,
      "options": [
        {
          "label": "root (Recommended)",
          "description": "Standard root user for local development"
        },
        {
          "label": "Enter custom username",
          "description": "Specify a different database user"
        }
      ]
    },
    {
      "question": "What is your database host?",
      "header": "DB Host",
      "multiSelect": false,
      "options": [
        {
          "label": "localhost (Recommended)",
          "description": "Standard localhost connection"
        },
        {
          "label": "127.0.0.1",
          "description": "Use IP address instead of hostname"
        },
        {
          "label": "Enter custom host",
          "description": "Specify a different database host"
        }
      ]
    }
  ]
}
```

**Execution Flow:**

1. Call AskUserQuestion with first question set (Plugin Identity)
2. Call AskUserQuestion with second question set (Configuration)
3. If "Enter custom credentials" selected, ask follow-up database questions
4. Call AskUserQuestion with third question set (Development Tools)
5. Collect all information and proceed with template processing
6. Install selected development tools and create corresponding configuration files

### Step 3: Process Templates

After collecting information, replace placeholders in templates:

| Placeholder | Description |
|-------------|-------------|
| `{{PLUGIN_NAME}}` | The plugin name (e.g., "my-awesome-plugin") |
| `{{PLUGIN_SLUG}}` | The plugin slug (same as PLUGIN_NAME) |
| `{{PLUGIN_VERSION}}` | Version number (e.g., "1.0.0") |
| `{{DB_NAME}}` | Test database name (default: "wordpress_test") |
| `{{NAMESPACE}}` | PHP namespace (e.g., "MyAwesomePlugin") |
| `{{TEXT_DOMAIN}}` | Text domain for i18n (e.g., "my-awesome-plugin") |
| `{{PLUGIN_PREFIX}}` | Plugin prefix for constants (e.g., "MY_AWESOME_PLUGIN") |

### Step 4: Files to Generate

Using templates from `@everything-wp/skills/wp-plugin-dev-init/templates/`:

1. **scripts/build.php** - From `build.php.template` (if local build script selected)
2. **.github/workflows/release.yml** - From `release-workflow.yml.template`
3. **tests/bootstrap.php** - Append content from `bootstrap-addon.php` (if PHPUnit selected)
4. **src/Bootstrap.php** - From `Bootstrap.php.template` (if OOP structure selected)
5. **src/Activator.php** - From `Activator.php.template` (if OOP structure selected)
6. **src/Deactivator.php** - From `Deactivator.php.template` (if OOP structure selected)

### Step 5: Additional Setup

After generating files:

1. **Initialize Composer** (if not exists):
   ```bash
   composer init --no-interaction
   ```

2. **Install selected development tools** (based on user selection):

   If PHPUnit selected:
   ```bash
   composer require --dev phpunit/phpunit wp-phpunit/wp-phpunit yoast/phpunit-polyfills
   ```

   If PHPStan selected:
   ```bash
   composer require --dev phpstan/phpstan szepeviktor/phpstan-wordpress
   ```

   If PHP_CodeSniffer + WPCS selected:
   ```bash
   composer require --dev squizlabs/php_codesniffer wp-coding-standards/wpcs phpcompatibility/phpcompatibility-wp dealerdirect/phpcodesniffer-composer-installer
   ```

3. **Setup scripts in composer.json** (based on installed tools):
   ```json
   {
     "scripts": {
       "test": "phpunit",                    // if PHPUnit selected
       "test:install": "bash bin/install-wp-tests.sh wordpress_test root '' localhost latest",  // if PHPUnit selected
       "phpstan": "phpstan analyse",         // if PHPStan selected
       "phpcs": "phpcs",                     // if PHPCS selected
       "phpcbf": "phpcbf",                   // if PHPCS selected
       "build": "php scripts/build.php"     // if local build script selected
     }
   }
   ```

4. **Run WP-CLI scaffold** (if PHPUnit selected and WP-CLI available):
   ```bash
   wp scaffold plugin-tests {{PLUGIN_SLUG}}
   ```

5. **Create configuration files** (based on installed tools):

   If PHPStan selected, create `phpstan.neon`:
   ```neon
   includes:
       - vendor/szepeviktor/phpstan-wordpress/extension.neon
   parameters:
       level: 5
       paths:
           - .
       excludePaths:
           - vendor
           - tests
   ```

   If PHPCS selected, create `.phpcs.xml.dist`:
   ```xml
   <?xml version="1.0"?>
   <ruleset name="WordPress Plugin Coding Standards">
       <rule ref="WordPress"/>
       <file>.</file>
       <exclude-pattern>/vendor/*</exclude-pattern>
       <exclude-pattern>/tests/*</exclude-pattern>
   </ruleset>
   ```

6. **Verify installation** (if PHPUnit selected):
   ```bash
   composer test:install
   composer test
   ```

7. **Build to verify** (if local build script selected):
   ```bash
   composer build
   ```

## Example Interaction

```
User: /init-plugin

Claude: I'll help you initialize a WordPress plugin development environment.

[Uses AskUserQuestion to ask about plugin details]

User: [Answers questions - selects PHPUnit, PHPStan, and local build script]

Claude: Great! I have all the information needed:
- Plugin Name: my-awesome-plugin
- Plugin Slug: my-awesome-plugin
- Namespace: MyAwesomePlugin
- Database: root@localhost (no password)
- Development Tools: PHPUnit, PHPStan
- Local Build Script: Yes

Let me set up your development environment...

[Installs PHPUnit and PHPStan packages]
[Creates phpstan.neon configuration]
[Creates scripts/build.php]
[Runs WP-CLI scaffold for tests]
[Verifies test environment]
[Runs composer build to verify]
```

## Requirements

- WP-CLI (recommended)
- Composer
- MySQL/MariaDB
- Git
- Subversion (svn) - For WordPress test suite

## Templates Location

All templates are located at:
```
@everything-wp/skills/wp-plugin-dev-init/templates/
```

## Related Commands

- `/plan` - Create implementation plan before coding
- Use `do-skill` skill for executing based on skill knowledge

## Related Skills

- `wp-plugin-dev-init` - The underlying skill with full documentation
- `wp-backend` - WordPress backend development patterns
