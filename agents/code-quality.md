---
description: Unified agent for code quality checks including test generation, PHPUnit execution, and full quality verification (PHPStan + PHPUnit + PHPCS)
required_skills:
  - wp-backend
  - wp-phpstan
---

# Code Quality Agent

This agent handles all code quality and testing operations for WordPress plugins.

## Modes

This agent operates in different modes based on the invoking command:

| Mode | Command | Description |
|------|---------|-------------|
| `generate` | `/test-generate` | Generate PHPUnit tests for existing code |
| `test` | `/test` | Execute PHPUnit tests and analyze results |
| `verify` | `/verify` | Execute all checks (PHPStan → PHPUnit → PHPCS) |

For one-off PHPStan or PHPCS runs, call `composer phpstan` / `composer phpcs` directly — no dedicated command exists, since this project's workflow handles them via task-executor (scoped) and `/verify` (full).

---

## Mode: Generate (`/test-generate`)

### Workflow

1. **Analyse target file**
   - Parse PHP class/file
   - Identify public methods
   - Extract method signatures (parameters, return types)

2. **Generate test class**
   - Create test file in `tests/Unit/` or `tests/Integration/`
   - Generate test methods for each public method
   - Include edge cases and error scenarios

3. **Validate generated tests**
   - Run `composer test` on the generated file
   - Ensure tests are syntactically correct
   - Report results

### Output Structure

```
tests/
├── Unit/
│   └── Repository/
│       └── {ClassName}_Test.php
└── Integration/
    └── ...
```

---

## Mode: Test (`/test`)

### Workflow

1. **Execute PHPUnit**
   ```bash
   composer test
   ```

2. **Parse output**
   - Count passed/failed tests
   - Extract failure details
   - Calculate coverage (if available)

3. **If tests fail**
   - Identify failing test
   - Locate source of failure
   - Analyze error message
   - Suggest fix
   - Ask user: "Should I fix this?"

4. **Loop until all tests pass or user stops**

### Output Format

```
PHPUnit Test Results

✅ Passed: 15 tests
❌ Failed: 2 tests
📊 Coverage: 87%

Failure analysis:
1. OrdersRepositoryTest::test_create_order
   Cause: ...
   Suggested fix: ...
```

---

## Mode: Verify (`/verify`)

### Workflow

Execute all checks in sequence:

1. **PHPStan** (Static Analysis)
   - If errors: Ask to fix or continue
   
2. **PHPUnit** (Tests)
   - If failures: Ask to fix or continue
   
3. **PHPCS** (Code Style)
   - If issues: Offer auto-fix

4. **Generate report**

### Output Format

```
╔══════════════════════════════════════════════════╗
║           Code Quality Report                    ║
╠══════════════════════════════════════════════════╣
║ PHPStan   │ ✅ Level 6  │ 0 errors              ║
║ PHPUnit   │ ✅ Passed   │ 23 tests, 92% coverage║
║ PHPCS     │ ✅ Clean    │ 0 issues              ║
╠══════════════════════════════════════════════════╣
║ Overall   │ ✅ Ready for release                ║
╚══════════════════════════════════════════════════╝
```

---

## Required Composer Scripts

The agent expects these scripts in `composer.json`:

```json
{
  "scripts": {
    "test": "phpunit",
    "test:install": "bash bin/install-wp-tests.sh wordpress_test root '' localhost latest",
    "phpstan": "phpstan analyse",
    "phpcs": "phpcs",
    "phpcbf": "phpcbf"
  }
}
```

---

## Error Handling

- If tool is not installed, suggest installation command
- If configuration file is missing, offer to create it
- If tests are not set up, suggest running `/init-plugin`
