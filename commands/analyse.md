---
description: Run PHPStan static analysis to find type errors and potential bugs
required_skills:
  - wp-backend
  - wp-phpstan
invokes_agent: code-quality
agent_mode: analyse
---

# Analyse Command

This command runs PHPStan static analysis to find type errors, potential bugs, and code quality issues without executing the code.

## What This Command Does

1. **Execute PHPStan** - Run `composer phpstan`
2. **Parse Errors** - Categorize and group errors by severity and file
3. **Suggest Fixes** - Provide specific fix recommendations
4. **Optional Auto-Fix** - Apply fixes and re-run analysis

## When to Use

Use `/analyse` when:
- Before committing code
- After major refactoring
- To find hidden bugs
- To improve type safety

## How It Works

### Step 1: Execute PHPStan

```bash
composer phpstan
```

### Step 2: Parse Output

The agent categorizes errors:
- **Critical**: Type mismatches, undefined methods
- **Warning**: Missing return types, unused parameters
- **Info**: PHPDoc inconsistencies

### Step 3: Suggest Fixes

For each error:
- Explain what's wrong
- Show the problematic code
- Provide the fix

### Step 4: Fix Loop

1. Present errors with fixes
2. Ask: "Should I fix these issues?"
3. Apply fixes
4. Re-run PHPStan
5. Repeat until 0 errors

## Example Interaction

```
User: /analyse

Claude:
Running PHPStan static analysis...
$ composer phpstan

 ------ ------------------------------------------------
  Line   src/Repository/Orders_Repository.php
 ------ ------------------------------------------------
  45     Parameter #1 $id of method get() expects int,
         string given.
  78     Method get_all() should return array but
         returns void.
  102    Access to undefined property $this->cache
 ------ ------------------------------------------------

PHPStan Level 6: 3 errors found

────────────────────────────────────────
🔴 Error 1: Type Mismatch (Line 45)

Issue: Parameter $id expects int, string given

Code:
```php
public function get( int $id ) {
    return $this->find_by_id( $_GET['id'] ); // ← Problem here
}
```

Suggested fix:
```php
public function get( int $id ) {
    return $this->find_by_id( (int) $_GET['id'] );
}
```
────────────────────────────────────────
🔴 Error 2: Return Type (Line 78)

Issue: Should return array but returns void

Code:
```php
public function get_all(): array {
    $results = $this->query();
    // Missing return statement
}
```

Suggested fix:
```php
public function get_all(): array {
    $results = $this->query();
    return $results;
}
```
────────────────────────────────────────

Should I fix these 3 issues? [Y/n]
```

## PHPStan Levels

| Level | Description |
|-------|-------------|
| 0 | Basic checks |
| 1 | Undefined variables |
| 2 | Undefined methods |
| 3 | Return types |
| 4 | Type hints |
| 5 | Dead code |
| 6 | Nullability (Recommended) |
| 7 | Union types |
| 8 | Method signatures |
| 9 | Maximum strictness |

## Output Format

### No Errors

```
PHPStan Level 6 Analysis Results

✅ 0 errors
📂 Analyzed 15 files
⏱️ Duration: 1.2s

Code quality is good!
```

### With Errors

```
PHPStan Level 6 Analysis Results

🔴 3 errors
🟡 2 warnings
📂 Analyzed 15 files

[See details above]
```

## Configuration

Ensure `phpstan.neon` exists in project root:

```neon
includes:
    - vendor/szepeviktor/phpstan-wordpress/extension.neon
parameters:
    level: 6
    paths:
        - .
    excludePaths:
        - vendor
        - tests
```

## Related Commands

- `/test` - Run tests after fixing PHPStan errors
- `/verify` - Run all checks including PHPStan
- `/lint` - Check code style

## Related Agent

This command invokes the `code-quality` agent in `analyse` mode.
Located at: `@everything-wp/agents/code-quality.md`
