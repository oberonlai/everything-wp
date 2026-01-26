---
description: Execute PHPUnit tests, analyze failures, and suggest fixes
required_skills:
  - wp-backend
invokes_agent: code-quality
agent_mode: test
---

# Test Command

This command executes PHPUnit tests and provides detailed analysis of any failures with suggested fixes.

## What This Command Does

1. **Execute PHPUnit** - Run `composer test`
2. **Analyze Results** - Parse test output and identify failures
3. **Diagnose Failures** - Locate source of failure and analyze root cause
4. **Suggest Fixes** - Provide actionable fix recommendations
5. **Optional Auto-Fix** - Apply fixes and re-run tests

## When to Use

Use `/test` when:
- Running tests during development
- Debugging failing tests
- Verifying code changes

## How It Works

### Step 1: Execute Tests

```bash
composer test
```

Or run specific tests:
```bash
composer test tests/Unit/Repository/
```

### Step 2: Parse Results

The agent parses PHPUnit output to extract:
- Number of tests run
- Passed/Failed/Skipped counts
- Failure details
- Coverage percentage (if enabled)

### Step 3: Analyze Failures

For each failing test:
- Extract assertion that failed
- Identify expected vs actual values
- Locate the source code causing failure
- Determine root cause

### Step 4: Fix Loop

If failures exist:
1. Present analysis and fix suggestion
2. Ask user: "Should I apply this fix?"
3. If yes, apply fix and re-run tests
4. Repeat until all tests pass or user stops

## Example Interaction

```
User: /test

Claude:
Running PHPUnit tests...
$ composer test

PHPUnit 9.6.13 by Sebastian Bergmann and contributors.

.....F..F...

Time: 00:02.345

❌ 2 tests failed, 10 passed

────────────────────────────────────────
Failure 1: OrdersRepositoryTest::test_create_order

Expected: 'pending'
Actual: null

Analysis:
- Location: src/Repository/Orders_Repository.php:45
- Cause: create() method does not set default status
- Suggested fix: Add 'status' => 'pending' to $defaults array

Should I fix this issue? [Y/n]
────────────────────────────────────────
Failure 2: OrdersRepositoryTest::test_get_by_user

Error: Table 'wp_myplugin_orders' doesn't exist

Analysis:
- Location: tests/Unit/Repository/Orders_Repository_Test.php:15
- Cause: Table not created before test
- Suggested fix: Call Orders_Table::create_table() in setUp()

Should I fix this issue? [Y/n]
```

## Output Format

### All Tests Pass

```
PHPUnit Test Results

✅ 15 tests passed
📊 Coverage: 87%
⏱️ Duration: 2.3s

All tests passed!
```

### Some Tests Fail

```
PHPUnit Test Results

✅ Passed: 13 tests
❌ Failed: 2 tests
📊 Coverage: 75%

Failure analysis:
[See details above]
```

## Running Specific Tests

```
# Run all tests
/test

# Run specific file
/test tests/Unit/Repository/Orders_Repository_Test.php

# Run specific directory
/test tests/Unit/Repository/

# Run specific test method
/test OrdersRepositoryTest::test_create_order
```

## Related Commands

- `/test-generate` - Generate tests for existing code
- `/verify` - Run all quality checks including tests
- `/analyse` - Run PHPStan before tests

## Related Agent

This command invokes the `code-quality` agent in `test` mode.
Located at: `@everything-wp/agents/code-quality.md`
