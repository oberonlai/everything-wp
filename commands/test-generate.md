---
description: Generate PHPUnit tests for existing PHP code by analyzing classes and methods
required_skills:
  - wp-backend
invokes_agent: code-quality
agent_mode: generate
---

# Test Generate Command

This command generates PHPUnit tests for existing PHP code by analyzing the target file and creating comprehensive test cases.

## What This Command Does

1. **Analyze Target File** - Parse PHP class and identify testable methods
2. **Generate Test Class** - Create PHPUnit test file with test methods
3. **Include Edge Cases** - Generate tests for normal, edge, and error cases
4. **Validate Tests** - Run the generated tests to ensure they're valid

## When to Use

Use `/test-generate` when:
- You have existing code that needs tests
- You want to add test coverage to a class
- You're retrofitting tests to legacy code

**Do NOT use for:**
- New features (consider TDD approach)
- Simple utility functions (may be overkill)

## How It Works

### Step 1: Specify Target

You can specify:
- A single file: `/test-generate src/Repository/Orders_Repository.php`
- A directory: `/test-generate src/Repository/`
- Current context: `/test-generate` (analyzes open file)

### Step 2: Analysis

The agent will analyze:
- Class name and namespace
- Public methods
- Method parameters and types
- Return types
- Dependencies (for mocking)

### Step 3: Generation

Creates test file at:
```
tests/Unit/{Path}/{ClassName}_Test.php
```

### Step 4: Validation

Runs the generated tests to ensure:
- No syntax errors
- Tests are executable
- Basic assertions work

## Example Interaction

```
User: /test-generate src/Repository/Orders_Repository.php

Claude: 
Analyzing Orders_Repository class...

Found 6 public methods:
- get( int $id ): ?array
- find( array $conditions ): ?array
- get_all( array $args ): array
- create( array $data ): int|false
- update( int $id, array $data ): bool
- delete( int $id ): bool

Generating test file: tests/Unit/Repository/Orders_Repository_Test.php

Test cases:
├── test_get_returns_order_by_id
├── test_get_returns_null_for_invalid_id
├── test_find_returns_order_matching_conditions
├── test_find_returns_null_when_not_found
├── test_get_all_returns_array
├── test_get_all_with_pagination
├── test_create_inserts_and_returns_id
├── test_create_returns_false_on_failure
├── test_update_modifies_record
├── test_update_returns_false_for_invalid_id
├── test_delete_removes_record
└── test_delete_returns_false_for_invalid_id

Running validation...
$ composer test tests/Unit/Repository/Orders_Repository_Test.php

✅ 12 tests generated and validated
```

## Generated Test Structure

```php
<?php
namespace MyPlugin\Tests\Unit\Repository;

use PHPUnit\Framework\TestCase;
use MyPlugin\Repository\Orders_Repository;

class Orders_Repository_Test extends TestCase {
    
    private Orders_Repository $repository;
    
    protected function setUp(): void {
        parent::setUp();
        $this->repository = new Orders_Repository();
    }
    
    public function test_get_returns_order_by_id(): void {
        // Arrange
        $expected_id = 1;
        
        // Act
        $result = $this->repository->get( $expected_id );
        
        // Assert
        $this->assertIsArray( $result );
        $this->assertEquals( $expected_id, $result['id'] );
    }
    
    // ... more tests
}
```

## Related Commands

- `/test` - Execute generated tests
- `/verify` - Run all quality checks
- `/custom-table` - Generate code that can then be tested

## Related Agent

This command invokes the `code-quality` agent in `generate` mode.
Located at: `@everything-wp/agents/code-quality.md`
