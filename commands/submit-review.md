---
description: Review plugin for WordPress.org submission compliance including license, readme.txt, forbidden files, and privacy checks
required_skills:
  - wp-backend
---

# Submit Review Command

This command performs a comprehensive review of your plugin before submitting to WordPress.org, checking for common rejection reasons.

## What This Command Does

1. **Check License** - Verify GPL-compatible license in main plugin file
2. **Validate readme.txt** - Check required sections and formatting
3. **Scan Forbidden Files** - Find .DS_Store, .git, .exe, .phar, etc.
4. **Check Third-Party Services** - Verify documentation in readme.txt
5. **Review Privacy** - Check for tracking code and opt-in mechanisms
6. **Audit Admin Notices** - Verify notices are dismissible
7. **Generate Report** - Comprehensive submission readiness report

## When to Use

Use `/submit-review` when:
- Preparing to submit a new plugin to WordPress.org
- Before submitting an update
- After receiving reviewer feedback
- As a final check before packaging

## How It Works

### Check 1: License Verification

Scans main plugin file for GPL-compatible license:

```php
// Required in plugin header
/**
 * License: GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 */
```

### Check 2: readme.txt Validation

Verifies required sections:
- Plugin header (Contributors, Tags, Requires, Tested up to, Stable tag)
- Description
- Installation
- Changelog
- Maximum 5 tags
- No competitor names in tags

### Check 3: Forbidden Files Scan

Searches for files that will cause rejection:

```bash
# Forbidden file types
.DS_Store, Thumbs.db
.git/, .svn/, .hg/
.idea/, .vscode/
*.exe, *.phar, *.dmg
*.log, *.sql
node_modules/, vendor/ (if not needed)
```

### Check 4: Third-Party Services

Scans for external API calls and verifies documentation:

```php
// Detects calls like:
wp_remote_get( 'https://api.example.com' )
wp_remote_post( 'https://external-service.com' )
file_get_contents( 'https://...' )
```

### Check 5: Privacy Review

Checks for tracking code and opt-in mechanisms:

```php
// Looks for patterns like:
get_option( 'admin_email' )
get_site_url()
// Sent to external services without opt-in
```

### Check 6: Admin Notice Audit

Verifies admin notices are dismissible:

```php
// Required: is-dismissible class
<div class="notice notice-info is-dismissible">
```

## Example Interaction

```
User: /submit-review

Claude:
Running WordPress.org submission review...

═══════════════════════════════════════════════════
                 Submission Review
═══════════════════════════════════════════════════

📋 Plugin: My Awesome Plugin (my-awesome-plugin)
📁 Version: 1.0.0

───────────────────────────────────────────────────
Check 1/6: License
───────────────────────────────────────────────────
✅ GPL-2.0+ license found in main plugin file
✅ License URI present

───────────────────────────────────────────────────
Check 2/6: readme.txt
───────────────────────────────────────────────────
✅ Plugin header complete
✅ Description section present
✅ Installation section present
✅ Changelog section present
⚠️ "Tested up to" is 6.3, latest is 6.4
✅ 4 tags (maximum 5)

───────────────────────────────────────────────────
Check 3/6: Forbidden Files
───────────────────────────────────────────────────
❌ Found 3 forbidden files:
   - .DS_Store
   - .git/
   - node_modules/

Action required:
   Add to .gitignore and remove before packaging

───────────────────────────────────────────────────
Check 4/6: Third-Party Services
───────────────────────────────────────────────────
⚠️ Found 2 external API calls:
   - https://api.stripe.com (line 145)
   - https://fonts.googleapis.com (line 23)

Checking readme.txt for documentation...
✅ Stripe API documented in readme.txt
⚠️ Google Fonts not documented

Action required:
   Add Google Fonts documentation to readme.txt:
   
   ## Third-Party Services
   
   ### Google Fonts
   - **Purpose**: Load custom fonts
   - **Data Sent**: None (CSS only)
   - **Privacy Policy**: https://policies.google.com/privacy

───────────────────────────────────────────────────
Check 5/6: Privacy
───────────────────────────────────────────────────
✅ No tracking code found without opt-in
✅ Admin email not sent externally

───────────────────────────────────────────────────
Check 6/6: Admin Notices
───────────────────────────────────────────────────
✅ 2 admin notices found, all dismissible

═══════════════════════════════════════════════════
                    Summary
═══════════════════════════════════════════════════

╔══════════════════════════════════════════════════╗
║       WordPress.org Submission Review           ║
╠══════════════════════════════════════════════════╣
║ License        │ ✅ Pass                        ║
║ readme.txt     │ ⚠️ Minor issues                ║
║ Forbidden Files│ ❌ 3 files to remove           ║
║ Third-Party    │ ⚠️ 1 service undocumented      ║
║ Privacy        │ ✅ Pass                        ║
║ Admin Notices  │ ✅ Pass                        ║
╠══════════════════════════════════════════════════╣
║ Overall        │ ❌ Not ready for submission    ║
╚══════════════════════════════════════════════════╝

📝 Action Items:
1. Remove .DS_Store, .git/, node_modules/
2. Update "Tested up to" to 6.4
3. Add Google Fonts to Third-Party Services in readme.txt

Fix these issues and run /submit-review again.
```

## Output Report Levels

### ✅ Pass
No issues found, ready for submission.

### ⚠️ Warning
Minor issues that may not cause rejection but should be fixed.

### ❌ Fail
Critical issues that will likely cause rejection.

## Automated Fixes

Some issues can be auto-fixed:

```
Would you like me to:
1. Update "Tested up to" to 6.4? [Y/n]
2. Add Google Fonts to readme.txt? [Y/n]
3. Create .distignore file for forbidden files? [Y/n]
```

## .distignore File

Creates a `.distignore` file for build scripts:

```
# Development files
.git
.gitignore
.DS_Store
Thumbs.db
.idea
.vscode

# Build tools
node_modules
package.json
package-lock.json
composer.json
composer.lock

# Tests
tests
phpunit.xml
phpunit.xml.dist

# Documentation
docs
README.md
```

## Submission Checklist

After passing all checks, the command provides a final checklist:

```
✅ Pre-Submission Checklist

□ Create ZIP file (without forbidden files)
□ Test plugin in fresh WordPress install
□ Verify all features work
□ Check screenshots are up to date
□ Review plugin description
□ Submit at: https://wordpress.org/plugins/developers/add/
```

## Related Commands

- `/verify` - Run code quality checks (PHPStan, PHPUnit, PHPCS)
- `/lint` - Check code style
- `/init-plugin` - Set up plugin development environment

## Related Skills

This command uses the knowledge from:
`@everything-wp/skills/wp-backend/org-submission.md`

## References

- [WordPress.org Plugin Guidelines](https://developer.wordpress.org/plugins/wordpress-org/detailed-plugin-guidelines/)
- [Plugin Handbook](https://developer.wordpress.org/plugins/)
- [readme.txt Validator](https://wordpress.org/plugins/developers/readme-validator/)
