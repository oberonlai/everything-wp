---
description: Initialize WordPress plugin development environment with testing suite, GitHub Actions, and build scripts
---

# WordPress Plugin Development Initialization Skill

This skill automatically sets up a complete WordPress plugin development environment.

## Trigger Keywords

This skill is triggered when the user says any of the following:
- "Initialize WordPress plugin development"
- "Set up WordPress plugin development environment"
- "Initialize WP plugin testing"
- "Create WordPress plugin development environment"
- "請幫我初始化 WordPress 外掛開發"
- "設定 WordPress 外掛開發環境"

## Features

This skill automatically performs the following operations:

1. **Detect Plugin Information**
   - Automatically reads the main plugin file
   - Extracts plugin slug, name, and version
   - Formats version number (adds v prefix)

2. **Configure Composer**
   - Installs PHPUnit testing suite
   - Sets up PSR-4 autoload
   - Creates testing and build scripts

3. **Create Testing Environment**
   - Uses WP-CLI scaffold to generate test files
   - Configures test database (wordpress_test)
   - Creates test examples
   - **Automatically installs test environment**
   - **Automatically removes redundant CI configs** (`.circleci/`, `.travis.yml`)

4. **Set Up GitHub Actions**
   - Integrated testing and release workflow
   - Automated CI/CD pipeline
   - Removes CircleCI and Travis CI configs created by WP-CLI scaffold

5. **Create Build Scripts**
   - Cross-platform PHP build script
   - Automatically excludes development files

6. **Automated Verification**
   - **Automatically runs composer test:install**
   - **Automatically runs composer test**
   - **Automatically runs composer build**
   - Ensures everything works before completion

## Usage

In your plugin directory, tell the AI assistant:

```
Initialize WordPress plugin development
```

The skill will automatically:
1. Detect plugin information
2. Ask for necessary configurations (namespace, database, etc.)
3. Execute all initialization steps
4. **Automatically install test environment**
5. **Automatically run tests**
6. **Automatically build plugin**
7. **Clean up redundant CI configs** (delete `.circleci/` and `.travis.yml`)
8. Display completion message and next steps

## Manual Execution

```bash
bash .agent/skills/wp-plugin-dev-init/scripts/init.sh
```

## Requirements

- WP-CLI
- Composer
- MySQL/MariaDB
- Git
- Subversion (svn) - Required for WordPress test suite installation

## Output

After completion, the following will be created:
- `composer.json` - Contains autoload and scripts
- `bin/install-wp-tests.sh` - Test environment installation script
- `tests/` - Test files directory
- `phpunit.xml.dist` - PHPUnit configuration
- `.github/workflows/release.yml` - CI/CD workflow
- `scripts/build.php` - Build script

## Configuration

The skill will ask for:
- **PHP Namespace**: Default is plugin name (e.g., OrderChatz)
- **Autoload Directory**: Default is `src`
- **Database User**: Default is `root`
- **Database Password**: Default is empty
- **Database Host**: Default is `localhost`

## Database Naming

Test database will be named: `wordpress_test`

**Note**: All plugins share the same test database name. Since test data is automatically cleaned up after each test run, there's no need for separate databases per plugin.

## PHP Version Compatibility

**Important**: The default setup uses PHPUnit 9.6 which is the recommended version for WordPress plugin testing.

### Recommended Package Versions (PHP 8.0+)

```json
"require-dev": {
  "phpunit/phpunit": "^9.6",
  "wp-phpunit/wp-phpunit": "^6.9",
  "yoast/phpunit-polyfills": "^2.0"
}
```

### To Support PHP 7.4

If you need to support PHP 7.4, you must:

1. **Limit PHPUnit version** in `composer.json`:
   ```json
   "require-dev": {
     "phpunit/phpunit": "^9.3",
     "wp-phpunit/wp-phpunit": "^6.3",
     "yoast/phpunit-polyfills": "^1.0"
   }
   ```

2. **Update PHP requirement** in `composer.json`:
   ```json
   "require": {
     "php": ">=7.4"
   }
   ```

3. **Rebuild dependencies**:
   ```bash
   rm -rf vendor composer.lock
   composer install
   ```

### PHPUnit Version Compatibility

| PHPUnit Version | PHP Version | yoast/phpunit-polyfills | WordPress Compatibility |
|-----------------|-------------|-------------------------|-------------------------|
| ^9.3 - ^9.5     | 7.4 - 8.0   | ^1.0                    | Full                    |
| ^9.6            | 8.0+        | ^2.0                    | Full (Recommended)      |
| ^10.x           | 8.1+        | Not supported           | Not compatible          |
| ^11.x           | 8.2+        | ^4.0                    | Partial issues          |

**Note**: PHPUnit 10.x is NOT supported by yoast/phpunit-polyfills. PHPUnit 11.x has compatibility issues with WordPress test suite (`parseTestMethodAnnotations` removed). Use PHPUnit 9.6 for best compatibility.

## GitHub Actions Configuration

The generated `.github/workflows/release.yml` includes:

### Required Permissions

The workflow automatically includes:
```yaml
permissions:
  contents: write
```

This allows GitHub Actions to create releases and upload assets.

### Required Dependencies

- **Subversion (svn)**: Automatically installed in the workflow for WordPress test suite
- **Composer cache**: Configured for faster dependency installation

### Version Extraction

The workflow extracts version numbers directly from Git tags (e.g., `v1.0.0`) rather than parsing plugin files, ensuring consistency.

## PHPCS Configuration for PSR-4

When using PSR-4 autoloading with the `src/` directory, WordPress file naming rules need to be excluded. Add this to `.phpcs.xml.dist`:

```xml
<!-- Exclude file naming rules for PSR-4 autoloaded classes in src directory -->
<rule ref="WordPress.Files.FileName">
    <exclude-pattern>/src/*</exclude-pattern>
</rule>
```

This allows PascalCase class file names (e.g., `Bootstrap.php`) required by PSR-4 instead of WordPress-style `class-bootstrap.php`.

## Troubleshooting

### Common Issues

1. **PHP Version Mismatch**
   - Error: `doctrine/instantiator is locked to version 2.0.0... requires php ^8.1`
   - Solution: Either upgrade to PHP 8.1+ or follow the "To Support PHP 7.4-8.0" instructions above

2. **SVN Command Not Found**
   - Error: `svn: command not found` during test installation
   - Solution: Install Subversion (`brew install svn` on macOS, `apt-get install subversion` on Linux)

3. **GitHub Actions Permission Denied (403)**
   - Error: `GitHub release failed with status: 403`
   - Solution: Ensure `permissions: contents: write` is set in the workflow file

4. **Composer Lock File Out of Sync**
   - Error: `composer.lock has some errors`
   - Solution: Run `composer update --lock` and commit the updated file

5. **Empty Changelog in Release**
   - For first release: Will show "Initial release"
   - For subsequent releases: Shows commits since previous tag
