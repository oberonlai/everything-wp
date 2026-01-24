# WordPress Plugin Development Initialization Skill

A complete automation skill for setting up WordPress plugin development environment.

## Features

- ✅ Automatic plugin information detection
- ✅ PHPUnit testing suite setup
- ✅ PSR-4 autoload configuration
- ✅ GitHub Actions CI/CD workflow
- ✅ Build scripts for release packaging
- ✅ Comprehensive documentation generation
- ✅ **Automated test environment installation**
- ✅ **Automated test execution**
- ✅ **Automated build verification**

## Installation

This skill is located at:
```
.agent/skills/wp-plugin-dev-init/
```

## Usage

### Automatic Trigger

Simply say to the AI assistant:
```
Initialize WordPress plugin development
```

Or in Chinese:
```
請幫我初始化 WordPress 外掛開發
```

### Manual Execution

```bash
bash .agent/skills/wp-plugin-dev-init/scripts/init.sh
```

## What It Does

1. **Detects Plugin Information**
   - Reads main plugin file
   - Extracts plugin name, slug, and version
   - Formats version with v prefix

2. **Configures Composer**
   - Sets up PSR-4 autoload
   - Installs PHPUnit and testing dependencies
   - Creates test and build scripts

3. **Sets Up Testing**
   - Uses WP-CLI scaffold for test files
   - Configures test database (wordpress_test)
   - Creates sample tests
   - **Automatically installs test environment**
   - **Automatically runs tests**

4. **Creates CI/CD**
   - GitHub Actions workflow
   - Automated testing on multiple PHP versions
   - Automatic release creation

5. **Verifies Everything Works**
   - **Automatically runs composer build**
   - Ensures all components are working

## Requirements

- WP-CLI
- Composer
- MySQL/MariaDB
- Git
- Subversion (svn)
- PHP >= 8.1 (or >= 7.4 with PHPUnit 9.3-9.5)

## Configuration

The skill will prompt for:
- PHP Namespace (default: plugin name)
- Autoload directory (default: src)
- Database credentials

## Output Files

After running, you'll have:
- `composer.json` - With autoload and scripts
- `bin/install-wp-tests.sh` - Test environment installer
- `tests/` - Test files directory
- `phpunit.xml.dist` - PHPUnit configuration
- `.github/workflows/release.yml` - CI/CD workflow
- `scripts/build.php` - Build script

## File Structure

```
.agent/skills/wp-plugin-dev-init/
├── SKILL.md                    # Skill documentation
├── README.md                   # This file
├── scripts/
│   ├── init.sh                 # Main initialization script
│   ├── detect-plugin.php       # Plugin information detector
│   └── setup-composer.php      # Composer configuration
└── templates/
    ├── bootstrap-addon.php     # Bootstrap additions for PHPUnit
    ├── build.php.template      # Build script template
    ├── release-workflow.yml.template  # GitHub Actions template
    ├── Bootstrap.php.template  # OOP Bootstrap class template
    ├── Activator.php.template  # Plugin activation class template
    └── Deactivator.php.template # Plugin deactivation class template
```

## Testing the Skill

To test this skill on a new plugin:

1. Navigate to your plugin directory
2. Run: `bash .agent/skills/wp-plugin-dev-init/scripts/init.sh`
3. Follow the prompts
4. **The skill will automatically:**
   - Install test environment
   - Run tests
   - Build the plugin
5. Everything is ready to use!

**Note**: All plugins use the same test database `wordpress_test`. Test data is automatically cleaned up after each test run.

## Customization

You can customize templates in the `templates/` directory to match your preferences.

## PHP Version Compatibility

**Default Setup**: PHP 8.1+ (due to PHPUnit 9.6+ dependencies)

**To Support PHP 7.4-8.0**: Limit PHPUnit to version 9.3-9.5 in `composer.json`

See SKILL.md for detailed instructions.

## Troubleshooting

### WP-CLI not found
Install WP-CLI: https://wp-cli.org/

### Composer not found
Install Composer: https://getcomposer.org/

### Database connection failed
Check MySQL is running and credentials are correct

### SVN not found
Install Subversion:
- macOS: `brew install svn`
- Linux: `sudo apt-get install subversion`

### PHP version mismatch errors
Either upgrade to PHP 8.1+ or limit PHPUnit version (see SKILL.md)

### GitHub Actions permission errors
Ensure `permissions: contents: write` is in the workflow file

## License

This skill is part of the WordPress plugin development toolkit.
