# WordPress Testing Rules

## 1. Test Coverage Requirements

**Rule**: All new features must have unit tests with coverage ≥ 70%

### Run Tests

```bash
composer test           # Run tests
composer test:coverage  # Check coverage
```

## 2. Test Structure

**Rule**: Test files must mirror source code structure

```
src/
└── Admin/
    └── Settings.php

tests/
└── Admin/
    └── SettingsTest.php
```

## 3. Test Naming

**Rule**: Test method names must describe what is being tested

```php
class Settings_Test extends WP_UnitTestCase {
    /**
     * @test
     */
    public function it_saves_settings_with_valid_nonce() {
        // ...
    }
    
    /**
     * @test
     */
    public function it_rejects_settings_without_capability() {
        // ...
    }
}
```

## 4. Test Isolation

**Rule**: Each test must be independent and not rely on other tests

```php
public function setUp(): void {
    parent::setUp();
    // Reset state before each test
    delete_option( 'myplugin_settings' );
}

public function tearDown(): void {
    // Cleanup
    delete_option( 'myplugin_settings' );
    parent::tearDown();
}
```

## 5. Critical Features Must Be Tested

**Rule**: The following features must have tests

- [ ] Plugin activation/deactivation
- [ ] Settings save and read
- [ ] Database operations (CRUD)
- [ ] REST API endpoints
- [ ] Shortcodes
- [ ] Widgets
- [ ] Security (nonces, capabilities)

## Checklist

- [ ] Test coverage ≥ 70%
- [ ] All tests pass
- [ ] Tests are independent
- [ ] Critical features have tests
