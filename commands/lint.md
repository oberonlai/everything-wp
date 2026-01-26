---
description: Run PHPCS code style check and offer auto-fix with PHPCBF
required_skills:
  - wp-backend
---

# Lint Command

This command runs PHP_CodeSniffer (PHPCS) to check code style against WordPress Coding Standards and offers auto-fix with PHPCBF.

## What This Command Does

1. **Execute PHPCS** - Run `composer phpcs`
2. **Parse Issues** - List style violations by file
3. **Categorize** - Separate auto-fixable vs manual fixes
4. **Offer Auto-Fix** - Run PHPCBF if user agrees
5. **Verify** - Re-run PHPCS to confirm fixes

## When to Use

Use `/lint` when:
- Before committing code
- After finishing a feature
- Preparing for code review
- Submitting to WordPress.org

## How It Works

### Step 1: Execute PHPCS

```bash
composer phpcs
```

### Step 2: Parse Output

Categorize issues:
- **ERROR**: Must fix (incorrect syntax, security issues)
- **WARNING**: Should fix (style preferences)
- **Auto-fixable**: Can be fixed by PHPCBF

### Step 3: Offer Auto-Fix

If auto-fixable issues exist:
```bash
composer phpcbf
```

### Step 4: Re-verify

Run PHPCS again to show remaining issues.

## Example Interaction

```
User: /lint

Claude:
Running PHPCS code style check...
$ composer phpcs

FILE: src/Repository/Orders_Repository.php
----------------------------------------------------------------------
FOUND 8 ERRORS AND 3 WARNINGS AFFECTING 7 LINES
----------------------------------------------------------------------
  15 | ERROR   | Spaces must be used to indent lines
  23 | WARNING | Missing short description in doc comment
  45 | ERROR   | Function closing brace must be on a line by itself
  52 | ERROR   | Expected 1 space after comma, 0 found
  67 | ERROR   | Array double arrow not aligned correctly
  ...
----------------------------------------------------------------------

FILE: src/Admin/Orders_List_Table.php
----------------------------------------------------------------------
FOUND 4 ERRORS AFFECTING 3 LINES
----------------------------------------------------------------------
  10 | ERROR   | Missing file doc comment
  ...
----------------------------------------------------------------------

PHPCS Results:
🔴 12 errors
🟡 3 warnings
📁 2 files with issues

✨ 10/15 issues are auto-fixable

Run `composer phpcbf` to auto-fix? [Y/n]

User: Y

Claude:
Running auto-fix...
$ composer phpcbf

Fixed 10 violations, 5 remain.

Re-checking...
$ composer phpcs

PHPCS Results:
🔴 3 errors
🟡 2 warnings

5 remaining issues require manual fix:

1. src/Repository/Orders_Repository.php:23
   WARNING: Missing short description in doc comment
   
   Add PHPDoc description manually:
   /**
    * Find orders by conditions.  ← Add this line
    *
    * @param array $conditions
    */

2. ...

Should I help fix these issues? [Y/n]
```

## Output Format

### No Issues

```
PHPCS Code Style Check

✅ 0 errors, 0 warnings
📂 Checked 15 files
⏱️ Duration: 0.8s

Code style is perfect!
```

### With Issues

```
PHPCS Code Style Check

🔴 12 errors
🟡 3 warnings
📂 2 files with issues
✨ 10 auto-fixable

[See details above]
```

## Configuration

Ensure `.phpcs.xml.dist` exists in project root:

```xml
<?xml version="1.0"?>
<ruleset name="WordPress Plugin Coding Standards">
    <description>PHPCS configuration for WordPress plugin</description>
    
    <rule ref="WordPress"/>
    
    <file>.</file>
    
    <exclude-pattern>/vendor/*</exclude-pattern>
    <exclude-pattern>/tests/*</exclude-pattern>
    <exclude-pattern>/node_modules/*</exclude-pattern>
    
    <arg name="extensions" value="php"/>
    <arg name="colors"/>
    <arg value="sp"/>
</ruleset>
```

## Common Fixes

| Issue | Fix |
|-------|-----|
| Spaces for indentation | Use tabs (WordPress standard) |
| Missing doc comment | Add PHPDoc block |
| Yoda conditions | Put variable first: `$var === true` → `true === $var` |
| Short array syntax | Use `array()` instead of `[]` |
| Missing space | Add spaces around operators |

## Related Commands

- `/analyse` - Run PHPStan before linting
- `/test` - Run tests after fixing style
- `/verify` - Run all checks including lint

## Note

This command does NOT use an agent. It directly executes PHPCS/PHPCBF.
