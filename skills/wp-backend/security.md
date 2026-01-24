# WordPress Security Rules

These security rules must be followed in all WordPress plugin development.

## 1. Nonces + Permission Checks (CSRF Protection)

**Rule**: All operations handling user input must use both nonces and permission checks

- ❌ **Wrong**: Only using nonce
  ```php
  if ( ! wp_verify_nonce( $_POST['_wpnonce'], 'my_action' ) ) {
      wp_die( 'Invalid nonce' );
  }
  // Missing permission check!
  ```

- ✅ **Correct**: nonce + permission check
  ```php
  if ( ! wp_verify_nonce( $_POST['_wpnonce'], 'my_action' ) ) {
      wp_die( 'Invalid nonce' );
  }
  if ( ! current_user_can( 'manage_options' ) ) {
      wp_die( 'Insufficient permissions' );
  }
  ```

**Important**: Nonces only prevent CSRF, they don't provide authorization. Must be used with `current_user_can()`.

## 2. Input Validation & Sanitization

**Rule**: Sanitize on input, escape on output

### Input Handling

- ❌ **Forbidden**: Processing entire `$_POST` / `$_GET` arrays
  ```php
  foreach ( $_POST as $key => $value ) {
      update_option( $key, $value ); // Dangerous!
  }
  ```

- ✅ **Required**: Explicitly specify keys and sanitize
  ```php
  $email = isset( $_POST['user_email'] ) ? sanitize_email( wp_unslash( $_POST['user_email'] ) ) : '';
  $text  = isset( $_POST['user_text'] ) ? sanitize_text_field( wp_unslash( $_POST['user_text'] ) ) : '';
  ```

### Output Escaping

- ✅ **Required**: Use correct escaping functions based on context
  ```php
  echo esc_html( $user_input );           // HTML content
  echo esc_attr( $user_input );           // HTML attributes
  echo esc_url( $user_input );            // URLs
  echo esc_js( $user_input );             // JavaScript
  echo wp_kses_post( $user_input );       // Allow some HTML
  ```

## 3. SQL Safety (Prepared Statements)

**Rule**: All SQL queries must use prepared statements

- ❌ **Forbidden**: String concatenation
  ```php
  $wpdb->query( "DELETE FROM {$wpdb->prefix}table WHERE id = {$_GET['id']}" );
  ```

- ✅ **Required**: Use `$wpdb->prepare()`
  ```php
  $wpdb->query(
      $wpdb->prepare(
          "DELETE FROM {$wpdb->prefix}table WHERE id = %d",
          absint( $_GET['id'] )
      )
  );
  ```

**WordPress 6.2+ Note**: `$wpdb->prepare()` now requires all placeholders to have corresponding values.

## 4. File Upload Security

**Rule**: Validate file types and sizes

```php
// Check file type
$allowed_types = array( 'image/jpeg', 'image/png', 'image/gif' );
if ( ! in_array( $_FILES['file']['type'], $allowed_types, true ) ) {
    wp_die( 'Invalid file type' );
}

// Use WordPress built-in function for uploads
$upload = wp_handle_upload( $_FILES['file'], array( 'test_form' => false ) );
```

## 5. API Endpoint Security

**Rule**: REST API endpoints must implement permission checks and parameter validation

```php
register_rest_route( 'myplugin/v1', '/data', array(
    'methods'             => 'POST',
    'callback'            => 'my_callback',
    'permission_callback' => function() {
        return current_user_can( 'edit_posts' );
    },
    'args'                => array(
        'id' => array(
            'required'          => true,
            'validate_callback' => function( $param ) {
                return is_numeric( $param );
            },
            'sanitize_callback' => 'absint',
        ),
    ),
) );
```

## 6. Direct File Access Protection

**Rule**: All PHP files must prevent direct file access

- ❌ **Wrong**: No protection
  ```php
  <?php
  function myplugin_helper() {
      // No protection against direct access
  }
  ```

- ✅ **Correct**: Add ABSPATH check
  ```php
  <?php
  if ( ! defined( 'ABSPATH' ) ) {
      exit;
  }
  
  function myplugin_helper() {
      // Safe from direct access
  }
  ```

**Alternative Patterns**:
```php
// Pattern 1: Short syntax
defined( 'ABSPATH' ) || exit;

// Pattern 2: Using WPINC
if ( ! defined( 'WPINC' ) ) {
    die;
}

// Pattern 3: With message
if ( ! defined( 'ABSPATH' ) ) {
    exit( 'Direct access not allowed' );
}
```

**Exceptions**: Files containing only class definitions are generally safe, but protection is still recommended.

## 7. Safe Redirect

**Rule**: Use `wp_safe_redirect()` instead of `wp_redirect()` for user-controlled URLs

- ❌ **Wrong**: Using wp_redirect() with user input
  ```php
  // Unsafe - can redirect to external sites
  wp_redirect( $_GET['redirect_url'] );
  exit;
  ```

- ✅ **Correct**: Use wp_safe_redirect()
  ```php
  // Safe - only allows redirects to same domain
  wp_safe_redirect( $_GET['redirect_url'] );
  exit;
  ```

**When to use each**:
```php
// Use wp_safe_redirect() for user input
wp_safe_redirect( sanitize_text_field( wp_unslash( $_GET['redirect'] ) ) );

// Use wp_redirect() only for hardcoded, trusted URLs
wp_redirect( admin_url( 'options-general.php?page=myplugin' ) );
```

## 8. No Unfiltered Uploads

**Rule**: Never use `ALLOW_UNFILTERED_UPLOADS` constant

- ❌ **Forbidden**: Allowing unfiltered uploads
  ```php
  // Extremely dangerous - allows any file type
  define( 'ALLOW_UNFILTERED_UPLOADS', true );
  ```

- ✅ **Correct**: Use WordPress file upload functions with validation
  ```php
  // Validate file type
  $allowed_types = array( 'image/jpeg', 'image/png', 'image/gif' );
  if ( ! in_array( $_FILES['file']['type'], $allowed_types, true ) ) {
      wp_die( 'Invalid file type' );
  }
  
  // Use WordPress upload handler
  $upload = wp_handle_upload( $_FILES['file'], array( 'test_form' => false ) );
  ```

**Why it's dangerous**: `ALLOW_UNFILTERED_UPLOADS` bypasses all WordPress file type restrictions, allowing malicious files to be uploaded.

## Checklist

Before committing code, verify:

- [ ] All user input is sanitized
- [ ] All output is escaped
- [ ] All forms have nonce and permission checks
- [ ] All SQL queries use prepared statements
- [ ] All REST API endpoints have permission checks
- [ ] No direct use of `$_POST` / `$_GET` / `$_REQUEST`
- [ ] All PHP files have direct access protection (ABSPATH check)
- [ ] Use `wp_safe_redirect()` for user-controlled redirects
- [ ] Never use `ALLOW_UNFILTERED_UPLOADS`

## References

- [WordPress Plugin Security Guidelines](https://developer.wordpress.org/plugins/wordpress-org/detailed-plugin-guidelines/)
- [WordPress Nonces](https://developer.wordpress.org/apis/security/nonces/)
- [Data Validation](https://developer.wordpress.org/apis/security/data-validation/)
