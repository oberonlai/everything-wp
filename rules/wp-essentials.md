# WordPress Essentials

Core WordPress-specific rules that must ALWAYS be followed. These are the most critical and commonly violated standards.

## 1. WordPress-Specific PHP Rules

### Yoda Conditions (CRITICAL)
Put constants/literals on LEFT, variables on RIGHT:

```php
// ✅ CORRECT
if ( true === $the_force ) { }
if ( 10 === $count ) { }
if ( 'publish' === $post->post_status ) { }

// ❌ WRONG
if ( $the_force === true ) { }
if ( $count === 10 ) { }
```

**Why**: Prevents accidental assignment bugs (`=` instead of `==`)

### Long Array Syntax (CRITICAL)
Use `array()`, NOT `[]`:

```php
// ✅ CORRECT
$args = array( 'post_type' => 'post' );

// ❌ WRONG
$args = [ 'post_type' => 'post' ];
```

### WordPress Functions Priority
Always use WordPress functions over PHP native:

```php
// ✅ CORRECT
wp_remote_get( $url );
wp_json_encode( $data );
wp_safe_redirect( $url );

// ❌ WRONG
file_get_contents( $url );
json_encode( $data );
header( 'Location: ' . $url );
```

### Hook Naming with Interpolation
Use curly braces and double quotes for dynamic hooks:

```php
// ✅ CORRECT
do_action( "{$new_status}_{$post->post_type}", $post );

// ❌ WRONG
do_action( $new_status . '_' . $post->post_type, $post );
```

### Text Domain Must Be String Constant

```php
// ✅ CORRECT
__( 'Hello', 'myplugin' );

// ❌ WRONG
__( 'Hello', $domain );  // Can't use variable
```

---

## 2. Security (CRITICAL)

### Nonce Verification (ALWAYS Required)

```php
// Generate nonce
wp_nonce_field( 'myplugin_action', 'myplugin_nonce' );

// Verify nonce (REQUIRED before processing)
if ( ! wp_verify_nonce( $_POST['myplugin_nonce'], 'myplugin_action' ) ) {
    wp_die( 'Security check failed' );
}
```

### Sanitize Input, Escape Output

```php
// INPUT: Sanitize
$title = sanitize_text_field( $_POST['title'] );
$content = wp_kses_post( $_POST['content'] );
$url = esc_url_raw( $_POST['url'] );
$id = absint( $_POST['id'] );

// OUTPUT: Escape
echo esc_html( $text );
echo '<input value="' . esc_attr( $value ) . '">';
echo '<a href="' . esc_url( $url ) . '">Link</a>';
```

### Database Queries (ALWAYS use prepare)

```php
// ✅ CORRECT
$wpdb->query(
    $wpdb->prepare(
        "UPDATE $wpdb->posts SET post_title = %s WHERE ID = %d",
        $title,
        $id
    )
);

// ❌ WRONG - SQL Injection Risk
$wpdb->query( "UPDATE $wpdb->posts SET post_title = '$title' WHERE ID = $id" );
```

### Permission Checks

```php
// Check capability before operations
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( 'Permission denied' );
}

// Check post-specific permission
if ( ! current_user_can( 'edit_post', $post_id ) ) {
    wp_die( 'Permission denied' );
}
```

---

## 3. Code Quality

### Visibility Declaration (REQUIRED)
All class properties and methods MUST declare visibility:

```php
// ✅ CORRECT
class My_Class {
    private $private_var;
    protected $protected_var;
    public $public_var;
    
    public function public_method() { }
    private function private_method() { }
}

// ❌ WRONG
class My_Class {
    var $some_var;  // Missing visibility
    function some_method() { }  // Missing visibility
}
```

### File Naming Convention

```php
// Class: MyPlugin_Settings_Page
// File:  class-myplugin-settings-page.php

// Class: WP_Error
// File:  class-wp-error.php
```

---

## 4. Testing Requirements

### TDD Workflow (REQUIRED)
1. Write failing test first (RED)
2. Write minimal code to pass (GREEN)
3. Refactor and improve (REFACTOR)

### Coverage Requirement
- Minimum 80% code coverage
- All public methods must have tests
- Critical paths must have integration tests

### PHPUnit Setup
```bash
# Install dependencies
composer require --dev phpunit/phpunit
composer require --dev yoast/phpunit-polyfills

# Run tests
composer test
```

---

## 5. PHPStan Configuration

### Minimum Level: 6

```neon
# phpstan.neon.dist
parameters:
    level: 6
    paths:
        - src
    bootstrapFiles:
        - tests/bootstrap.php
```

### Run Analysis
```bash
composer exec phpstan analyse
```

---

---

## 11. Testing Requirements

**Rule**: Minimum 70% code coverage for new features

```bash
composer test           # Run tests
composer test:coverage  # Check coverage
```

**Critical features that must have tests**:
- Plugin activation/deactivation
- Settings save and read
- Database operations (CRUD)
- REST API endpoints
- Security (nonces, capabilities)

**For complete testing guide**: See `@wp-backend/testing.md`

---

## 12. Static Analysis

**Rule**: PHPStan level ≥ 5

```bash
composer require --dev phpstan/phpstan
composer require --dev szepeviktor/phpstan-wordpress

vendor/bin/phpstan analyse
```

**Requirements**:
- PHPStan level 5 or higher
- WordPress stubs loaded
- No new baseline errors

**For complete PHPStan setup**: See `@wp-backend/phpstan.md`

---

## Quick Checklist

Before committing code:
- [ ] Yoda Conditions used (constants on left)
- [ ] Long array syntax `array()` used
- [ ] All nonces verified
- [ ] All input sanitized
- [ ] All output escaped
- [ ] Database queries use `$wpdb->prepare()`
- [ ] Permission checks in place
- [ ] Visibility declared on all class members
- [ ] Tests written and passing (≥70% coverage)
- [ ] PHPStan level 5 passes

---

## For Complete Standards

See detailed documentation in Skills:
- **PHP Full Standards**: `@wp-development/coding-standards/php.md`
- **Security Guide**: `@wp-development/security.md`
- **OOP Patterns**: `@wp-development/oop-patterns.md`
- **Performance**: `@wp-development/performance.md`
