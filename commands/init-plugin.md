---
description: Initialize WordPress plugin development environment with testing suite, GitHub Actions, and build scripts
required_skills:
  - wp-plugin-dev-init
  - wp-backend
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
4. **Plugin Description** (brief description of what the plugin does)
5. **Author Name** (e.g., "Your Name")
6. **Author URI** (e.g., "https://example.com")

**Plugin Header Configuration:**
7. **Plugin URI** (default: empty)
8. **Requires WordPress** (default: "6.4")
9. **Requires PHP** (default: "8.0")
10. **Requires Plugins** (default: empty, comma-separated plugin slugs)
11. **License** (default: "GPL v2 or later")
12. **Update URI** (default: false - set to plugin URL for update checking)
13. **Network** (default: false - set to true for multisite-only plugins)

**Development Configuration:**
14. **PHP Namespace** (default: derived from plugin name)
15. **Autoload Directory** (default: "src")
16. **Database User** (default: "root")
17. **Database Password** (default: empty)
18. **Database Host** (default: "localhost")

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

**Fourth Question Set (Plugin Header):**

```json
{
  "questions": [
    {
      "question": "What is the plugin description?",
      "header": "Description",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter description",
          "description": "Provide a brief description of what your plugin does"
        }
      ]
    },
    {
      "question": "Who is the plugin author?",
      "header": "Author",
      "multiSelect": false,
      "options": [
        {
          "label": "Use default (Your Name)",
          "description": "Use placeholder author name"
        },
        {
          "label": "Enter custom author",
          "description": "Specify author name and website URL"
        }
      ]
    },
    {
      "question": "Does this plugin require other plugins to be installed?",
      "header": "Requires Plugins",
      "multiSelect": false,
      "options": [
        {
          "label": "No (Recommended)",
          "description": "This plugin works standalone without dependencies"
        },
        {
          "label": "Yes",
          "description": "Specify comma-separated plugin slugs (e.g., woocommerce,advanced-custom-fields)"
        }
      ]
    },
    {
      "question": "What license should be used?",
      "header": "License",
      "multiSelect": false,
      "options": [
        {
          "label": "GPL v2 or later (Recommended)",
          "description": "Standard WordPress-compatible license"
        },
        {
          "label": "GPL v3 or later",
          "description": "Newer GPL version"
        },
        {
          "label": "Enter custom license",
          "description": "Specify a different license"
        }
      ]
    },
    {
      "question": "Is this a multisite-only plugin?",
      "header": "Network",
      "multiSelect": false,
      "options": [
        {
          "label": "No (Recommended)",
          "description": "Plugin works on single site and multisite installations"
        },
        {
          "label": "Yes",
          "description": "Plugin only works when network activated on multisite"
        }
      ]
    },
    {
      "question": "Do you want to configure custom Update URI for self-hosted updates?",
      "header": "Update URI",
      "multiSelect": false,
      "options": [
        {
          "label": "No (Recommended)",
          "description": "Use WordPress.org for updates or no automatic updates"
        },
        {
          "label": "Yes",
          "description": "Specify a custom Update URI for self-hosted plugin updates"
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
| PHPUnit | `composer require --dev phpunit/phpunit:^9.6 wp-phpunit/wp-phpunit:^6.9 yoast/phpunit-polyfills:^2.0` |
| PHPStan | `composer require --dev phpstan/phpstan szepeviktor/phpstan-wordpress` |
| PHP_CodeSniffer + WPCS | `composer require --dev squizlabs/php_codesniffer wp-coding-standards/wpcs phpcompatibility/phpcompatibility-wp dealerdirect/phpcodesniffer-composer-installer` |

**Note**: PHPUnit 9.6 is recommended for WordPress compatibility. PHPUnit 10/11 have compatibility issues with the WordPress test suite.

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
   - Use anonymous function wrapper for `plugins_loaded` hook (PHPStan compatibility):
     ```php
     add_action(
         'plugins_loaded',
         function (): void {
             Bootstrap::get_instance();
         }
     );
     ```
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
| `{{PLUGIN_NAME}}` | The plugin name (e.g., "My Awesome Plugin") |
| `{{PLUGIN_SLUG}}` | The plugin slug (e.g., "my-awesome-plugin") |
| `{{PLUGIN_VERSION}}` | Version number (e.g., "1.0.0") |
| `{{PLUGIN_DESCRIPTION}}` | Brief description of the plugin |
| `{{PLUGIN_URI}}` | Plugin homepage URL (default: empty) |
| `{{AUTHOR_NAME}}` | Author name (e.g., "Your Name") |
| `{{AUTHOR_URI}}` | Author website URL |
| `{{REQUIRES_WP}}` | Minimum WordPress version (default: "6.4") |
| `{{REQUIRES_PHP}}` | Minimum PHP version (default: "8.0") |
| `{{REQUIRES_PLUGINS}}` | Required plugin slugs, comma-separated (default: empty) |
| `{{LICENSE}}` | License name (default: "GPL v2 or later") |
| `{{LICENSE_URI}}` | License URL (default: "https://www.gnu.org/licenses/gpl-2.0.html") |
| `{{TEXT_DOMAIN}}` | Text domain for i18n (same as PLUGIN_SLUG) |
| `{{UPDATE_URI}}` | Update URI for custom update checking (default: false) |
| `{{NETWORK}}` | Multisite-only plugin flag (default: false) |
| `{{DB_NAME}}` | Test database name (default: "wordpress_test") |
| `{{NAMESPACE}}` | PHP namespace (e.g., "MyAwesomePlugin") |
| `{{PLUGIN_PREFIX}}` | Plugin prefix for constants (e.g., "MY_AWESOME_PLUGIN") |
| `{{PLUGIN_CONST_PREFIX}}` | Plugin constant prefix in UPPER_CASE |
| `{{PLUGIN_FUNCTION_PREFIX}}` | Plugin function prefix in snake_case |

### Step 4: Files to Generate

Using templates from `@everything-wp/skills/wp-plugin-dev-init/templates/`:

1. **{{PLUGIN_SLUG}}.php** - From `plugin-main.php.template` (main plugin file with complete header)
2. **scripts/build.php** - From `build.php.template` (if local build script selected)
3. **.github/workflows/release.yml** - From `release-workflow.yml.template`
4. **tests/bootstrap.php** - Append content from `bootstrap-addon.php` (if PHPUnit selected)
5. **src/Bootstrap.php** - From `Bootstrap.php.template` (if OOP structure selected)
6. **src/Activator.php** - From `Activator.php.template` (if OOP structure selected)
7. **src/Deactivator.php** - From `Deactivator.php.template` (if OOP structure selected)

### Step 5: Additional Setup

After generating files:

1. **Initialize Composer** (if not exists):
   ```bash
   composer init --no-interaction
   ```

2. **Install selected development tools** (based on user selection):

   If PHPUnit selected:
   ```bash
   composer require --dev phpunit/phpunit:^9.6 wp-phpunit/wp-phpunit:^6.9 yoast/phpunit-polyfills:^2.0
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

   **Note on local environment compatibility (wp-env / DDEV):**

   The default `test:install` connects to `root@localhost` (native MySQL). If the user runs tests against a containerized environment, they must execute the install / test commands inside the container so the MySQL credentials resolve correctly:

   ```bash
   # wp-env
   wp-env run cli composer test:install
   wp-env run cli composer test

   # DDEV
   ddev exec composer test:install
   ddev exec composer test
   ```

   Alternatively, override the credentials inline:
   ```bash
   # wp-env (uses 'root'/'password' on the host-mapped port)
   bash bin/install-wp-tests.sh wordpress_test root password 127.0.0.1:<port> latest

   # DDEV (from host; check `ddev describe` for the port)
   bash bin/install-wp-tests.sh wordpress_test db db 127.0.0.1:<port> latest
   ```

   The scaffold itself does not generate `.wp-env.json` or `.ddev/` configs — those are the user's choice. Build script and PHPCS configs already exclude these folders so they won't leak into release zips or trigger style violations.

4. **Run WP-CLI scaffold** (if PHPUnit selected and WP-CLI available):
   ```bash
   wp scaffold plugin-tests {{PLUGIN_SLUG}}
   ```

5. **Clean up redundant CI configs** (WP-CLI scaffold creates these, but we use GitHub Actions):
   ```bash
   rm -rf .circleci
   rm -f .travis.yml
   ```

6. **Create configuration files** (based on installed tools):

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
       <description>A custom set of rules to check for a WordPress plugin.</description>
       <file>.</file>
       <exclude-pattern>/vendor/*</exclude-pattern>
       <exclude-pattern>/tests/*</exclude-pattern>
       <exclude-pattern>/node_modules/*</exclude-pattern>
       <exclude-pattern>/.claude/*</exclude-pattern>
       <exclude-pattern>/scripts/*</exclude-pattern>
       <exclude-pattern>/build/*</exclude-pattern>
       <exclude-pattern>/bin/*</exclude-pattern>
       <!-- Local env configs (wp-env / DDEV) — not part of plugin source. -->
       <exclude-pattern>/.wp-env/*</exclude-pattern>
       <exclude-pattern>/.ddev/*</exclude-pattern>

       <arg value="sp"/>
       <arg name="basepath" value="."/>
       <arg name="colors"/>
       <arg name="extensions" value="php"/>
       <arg name="parallel" value="8"/>

       <config name="testVersion" value="8.0-"/>
       <rule ref="PHPCompatibilityWP"/>

       <config name="minimum_wp_version" value="6.4"/>
       <rule ref="WordPress"/>

       <!-- Exclude file naming rules for PSR-4 autoloaded classes in src directory -->
       <rule ref="WordPress.Files.FileName">
           <exclude-pattern>/src/*</exclude-pattern>
       </rule>

       <rule ref="WordPress.WP.I18n">
           <properties>
               <property name="text_domain" type="array">
                   <element value="{{TEXT_DOMAIN}}"/>
               </property>
           </properties>
       </rule>

       <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
           <properties>
               <property name="prefixes" type="array">
                   <element value="{{PLUGIN_FUNCTION_PREFIX}}"/>
                   <element value="{{NAMESPACE}}"/>
                   <element value="{{PLUGIN_PREFIX}}"/>
               </property>
           </properties>
       </rule>
   </ruleset>
   ```

7. **Verify installation** (if PHPUnit selected):
   ```bash
   composer test:install
   composer test
   ```

8. **Build to verify** (if local build script selected):
   ```bash
   composer build
   ```

9. **Setup Internationalization (i18n)**:
   ```bash
   # Create languages directory
   mkdir -p languages
   
   # Generate .pot file using WP-CLI
   wp i18n make-pot . languages/{{TEXT_DOMAIN}}.pot --domain={{TEXT_DOMAIN}}
   ```
   
   This creates:
   - `languages/` directory for translation files
   - `languages/{{TEXT_DOMAIN}}.pot` - Template file for translations

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
