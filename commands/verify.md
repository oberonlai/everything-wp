---
description: Run all code quality checks (PHPStan, PHPUnit, PHPCS) and generate comprehensive report
required_skills:
  - wp-backend
  - wp-phpstan
invokes_agent: code-quality
agent_mode: verify
---

# Verify Command

This command runs all code quality checks in sequence and generates a comprehensive quality report. This is the recommended command to run before committing, merging, or releasing.

## What This Command Does

1. **PHPStan** - Static analysis for type errors and bugs
2. **PHPUnit** - Execute unit tests
3. **PHPCS** - Check code style
4. **Generate Report** - Summarize all results

## When to Use

Use `/verify` when:
- Before committing to main branch
- Before creating a pull request
- Before releasing a new version
- After completing a feature

## How It Works

### Execution Order

```
┌───────────┐
│  PHPStan  │ ← Static analysis (find type errors first)
└─────┬─────┘
      ↓ (pass or continue)
┌───────────┐
│  PHPUnit  │ ← Unit tests (verify logic)
└─────┬─────┘
      ↓ (pass or continue)
┌───────────┐
│   PHPCS   │ ← Code style
└─────┬─────┘
      ↓
┌───────────┐
│  Report   │
└───────────┘
```

### Failure Handling

At each step, if errors occur:
1. Show error summary
2. Ask: "Fix now or continue to next check?"
3. Options:
   - **Fix**: Apply fixes and re-run this step
   - **Continue**: Move to next check
   - **Stop**: Exit and show current results

## Example Interaction

```
User: /verify

Claude:
Starting full quality check...

═══════════════════════════════════════
Step 1/3: PHPStan Static Analysis
═══════════════════════════════════════

$ composer phpstan

✅ PHPStan Level 6: 0 errors

═══════════════════════════════════════
Step 2/3: PHPUnit Unit Tests
═══════════════════════════════════════

$ composer test

PHPUnit 9.6.13

....F.........

❌ 1 test failed, 14 passed

Failure: OrdersRepositoryTest::test_create_order
Cause: Expected 'pending', got null

Continue to PHPCS anyway? [Y/n]

User: Y

═══════════════════════════════════════
Step 3/3: PHPCS Code Style
═══════════════════════════════════════

$ composer phpcs

✅ PHPCS: 0 errors, 2 warnings (auto-fixable)

Run phpcbf to fix? [Y/n]

User: Y

Fixed 2 warnings.

═══════════════════════════════════════
            Full Report
═══════════════════════════════════════

╔══════════════════════════════════════════════════╗
║           Code Quality Report                    ║
╠══════════════════════════════════════════════════╣
║ PHPStan   │ ✅ Level 6  │ 0 errors              ║
║ PHPUnit   │ ❌ Failed   │ 14/15 passed          ║
║ PHPCS     │ ✅ Clean    │ 0 errors              ║
╠══════════════════════════════════════════════════╣
║ Overall   │ ⚠️ Fix failing PHPUnit tests        ║
╚══════════════════════════════════════════════════╝

Suggestions:
1. Fix test_create_order test failure
2. Add default status in create() method

Should I fix this issue? [Y/n]
```

## Output Format

### All Pass

```
╔══════════════════════════════════════════════════╗
║           Code Quality Report                    ║
╠══════════════════════════════════════════════════╣
║ PHPStan   │ ✅ Level 6  │ 0 errors              ║
║ PHPUnit   │ ✅ Passed   │ 23 tests, 92% coverage║
║ PHPCS     │ ✅ Clean    │ 0 errors              ║
╠══════════════════════════════════════════════════╣
║ Overall   │ ✅ Ready for release!               ║
╚══════════════════════════════════════════════════╝
```

### Some Issues

```
╔══════════════════════════════════════════════════╗
║           Code Quality Report                    ║
╠══════════════════════════════════════════════════╣
║ PHPStan   │ ✅ Level 6  │ 0 errors              ║
║ PHPUnit   │ ❌ Failed   │ 21/23 tests           ║
║ PHPCS     │ ⚠️ Warnings │ 0 errors, 3 warnings  ║
╠══════════════════════════════════════════════════╣
║ Overall   │ ⚠️ Needs attention                  ║
╚══════════════════════════════════════════════════╝
```

## Skip Options

You can skip specific checks:

```
/verify --skip-phpstan    # Skip PHPStan
/verify --skip-tests      # Skip PHPUnit
/verify --skip-phpcs      # Skip PHPCS
```

## Quick Mode

For faster checks (less strict):

```
/verify --quick
```

This runs:
- PHPStan Level 5 (instead of 6)
- Only unit tests (skip integration)
- PHPCS errors only (ignore warnings)

## Requirements

Ensure these Composer scripts exist:

```json
{
  "scripts": {
    "phpstan": "phpstan analyse",
    "test": "phpunit",
    "phpcs": "phpcs",
    "phpcbf": "phpcbf"
  }
}
```

## CI/CD Integration

Run `/verify` in GitHub Actions:

```yaml
- name: Run Quality Checks
  run: |
    composer phpstan
    composer test
    composer phpcs
```

## Related Commands

- `/analyse` - Run only PHPStan
- `/test` - Run only PHPUnit
- `/lint` - Run only PHPCS
- `/init-plugin` - Set up testing environment

## Related Agent

This command invokes the `code-quality` agent in `verify` mode.
Located at: `@everything-wp/agents/code-quality.md`
