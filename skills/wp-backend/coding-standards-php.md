# WordPress PHP Coding Standards

This document defines the PHP coding standards that MUST be followed when developing WordPress plugins. These standards are based on the [WordPress Official PHP Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/php/).

## 1. General Rules

### PHP Tags

**Rule**: Always use full PHP tags, never use shorthand tags

- ✅ **Correct**:
  ```php
  <?php ... ?>
  <?php echo esc_html( $var ); ?>
  ```

- ❌ **Incorrect**:
  ```php
  <? ... ?>
  <?= esc_html( $var ) ?>
  ```

**Multiline PHP embedded in HTML**:
```php
function foo() {
?>
    <div>
        <?php echo esc_html( bar( $baz, $bat ) ); ?>
    </div>
<?php
}
```

### Single and Double Quotes

**Rule**: Use single quotes when there are no variables in the string, use double quotes when there are variables

```php
// Correct
echo '<a href="/static/link" class="button button-primary">Link name</a>';
echo "<a href='{$escaped_link}'>text with a ' single quote</a>";

// Avoid excessive escaping
echo 'She said, "Hello"';  // Correct
echo "She said, \"Hello\"";  // Not recommended
```

### require/include Statements

**Rule**: Use `require_once` instead of `include_once`, paths do not need parentheses

```php
// Correct
require_once ABSPATH . 'file-name.php';
require_once __DIR__ . '/file-name.php';

// Incorrect
include_once ( ABSPATH . 'file-name.php' );  // Don't use parentheses
include_once ABSPATH . 'file-name.php';      // Should use require_once
```

**Reason**: `require_once` throws a Fatal Error when the file doesn't exist, while `include_once` only produces a Warning and continues execution, which may lead to security issues.

---

## 2. Naming Conventions

### Variables and Functions

**Rule**: Use lowercase letters and underscores, never use camelCase

```php
// Correct
function some_name( $some_variable ) {
    $user_count = 10;
}

// Incorrect
function someName( $someVariable ) {  // Don't use camelCase
    $userCount = 10;
}
```

### Classes, Interfaces, Traits, Enums

**Rule**: Use capitalized words separated by underscores

```php
// Correct
class Walker_Category extends Walker {}
class WP_HTTP {}
interface Mailer_Interface {}
trait Forbid_Dynamic_Properties {}
enum Post_Status {}

// Incorrect
class walkerCategory {}  // Should be capitalized
class WpHttp {}          // Acronyms should be all uppercase
```

### Constants

**Rule**: All uppercase with underscores separating words

```php
// Correct
define( 'DOING_AJAX', true );
define( 'MYPLUGIN_VERSION', '1.0.0' );

// Incorrect
define( 'doingAjax', true );
define( 'MyPlugin_Version', '1.0.0' );
```

### File Naming

**Rule**: 
- General files: lowercase letters, words separated by hyphens (`my-plugin-name.php`)
- Class files: `class-` prefix + class name converted to lowercase with hyphens

```php
// Class name: MyPlugin_Settings_Page
// File name: class-myplugin-settings-page.php

// Class name: WP_Error
// File name: class-wp-error.php
```

### Hook Naming

**Rule**: Use plugin prefix, use curly braces for interpolation in dynamic hooks

```php
// Static hooks
do_action( 'myplugin_before_save', $data );
apply_filters( 'myplugin_data', $data );

// Dynamic hooks - use curly braces and double quotes
do_action( "{$new_status}_{$post->post_type}", $post->ID, $post );
apply_filters( "myplugin_{$type}_data", $data );

// Incorrect - don't use string concatenation
do_action( $new_status . '_' . $post->post_type, $post->ID, $post );
```

---

## 3. Whitespace and Indentation

### Indentation

**Rule**: Use tabs for indentation, not spaces

```php
function my_function() {
→   if ( $condition ) {
→   →   do_something();
→   }
}
```

### Space Usage

**Rule**: Add spaces after commas, on both sides of operators, and inside control structure parentheses

```php
// Operators
$result = $a + $b;
$check = $foo === $bar;
$combined = $baz . '-5';

// Function definition
function my_function( $param1 = 'foo', $param2 = 'bar' ) {
    // ...
}

// Function calls
my_function( $param1, func_param( $param2 ) );

// Control structures
if ( ! $foo ) {
    // ...
}

foreach ( $items as $item ) {
    // ...
}

// Array access
$x = $foo['bar'];      // String index - no spaces
$x = $foo[0];          // Numeric index - no spaces
$x = $foo[ $bar ];     // Variable index - with spaces
```

### Type Casts

**Rule**: Use lowercase, short form, with space after

```php
// Correct
$foo = (int) $bar;
$foo = (bool) $bar;
$foo = (float) $bar;

// Incorrect
$foo = (integer) $bar;
$foo = (boolean) $bar;
$foo=(int)$bar;  // Missing space
```

### Remove Trailing Whitespace

**Rule**: All lines should not have trailing whitespace characters

---

## 4. Formatting

### Brace Style

**Rule**: Opening brace on same line, closing brace on separate line, always use braces

```php
// Correct
if ( $condition ) {
    action1();
    action2();
} elseif ( $condition2 && $condition3 ) {
    action3();
    action4();
} else {
    defaultaction();
}

// Always use braces even for single statements
if ( $condition ) {
    action0();
}

// Incorrect - missing braces
if ( $condition )
    action0();
```

**Alternative syntax** (for template files):
```php
<?php if ( have_posts() ) : ?>
    <div class="hfeed">
        <?php while ( have_posts() ) : the_post(); ?>
            <article>
                <!-- ... -->
            </article>
        <?php endwhile; ?>
    </div>
<?php endif; ?>
```

### Array Declaration

**Rule**: Use long array syntax `array()`, not short array syntax `[]`

```php
// Correct
$args = array(
    'post_type'   => 'post',
    'post_status' => 'publish',
    'numberposts' => 10,
);

// Incorrect
$args = [
    'post_type'   => 'post',
    'post_status' => 'publish',
];
```

### Multiline Function Calls

**Rule**: Each parameter on separate line, multi-line parameter values should be assigned to variable first

```php
// Correct
$bar = array(
    'use_this' => true,
    'meta_key' => 'field_name',
);

$baz = sprintf(
    /* translators: %s: Friend's name */
    __( 'Hello, %s!', 'yourtextdomain' ),
    $friend_name
);

$result = foo(
    $bar,
    $baz,
    $another_param
);

// Incorrect - parameters on same line
$result = foo( $bar, $baz, $another_param );
```

---

## 5. Control Structures

### Use elseif, not else if

**Rule**: Use `elseif` instead of `else if`

```php
// Correct
if ( $condition ) {
    // ...
} elseif ( $condition2 ) {
    // ...
}

// Incorrect
if ( $condition ) {
    // ...
} else if ( $condition2 ) {
    // ...
}
```

### Yoda Conditions

**Rule**: Put constants, literals, or function calls on the left, variables on the right in comparisons

```php
// Correct
if ( true === $the_force ) {
    // ...
}

if ( 10 === $count ) {
    // ...
}

if ( 'publish' === $post->post_status ) {
    // ...
}

// Incorrect
if ( $the_force === true ) {
    // ...
}

if ( $count === 10 ) {
    // ...
}
```

**Reason**: If you accidentally omit an equals sign, it will produce a parse error instead of an assignment error:
```php
// Will produce parse error, easy to catch
if ( true = $the_force ) {  // ❌

// Will assign successfully and return true, hard-to-find bug
if ( $the_force = true ) {  // ❌
```

**Note**: Yoda Conditions are not recommended for `<`, `>`, `<=`, `>=` as they are much harder to read

---

## 6. Operators

### Ternary Operator

**Rule**: Use ternary operator for simple conditions, use if/else for complex conditions

```php
// Correct - simple condition
$status = ( $is_active ) ? 'active' : 'inactive';

// Complex conditions should use if/else
if ( $condition1 && $condition2 ) {
    $result = do_something_complex();
} else {
    $result = do_something_else();
}
```

### Error Control Operator @

**Rule**: Avoid using `@` to suppress errors, handle errors properly instead

```php
// Incorrect
$content = @file_get_contents( $file );

// Correct
if ( file_exists( $file ) && is_readable( $file ) ) {
    $content = file_get_contents( $file );
} else {
    // Handle error
}
```

### Increment/Decrement Operators

**Rule**: No space between operator and variable

```php
// Correct
for ( $i = 0; $i < 10; $i++ ) {
    // ...
}

++$b;
$a--;

// Incorrect
for ( $i = 0; $i < 10; $i ++ ) {  // Don't add space
    // ...
}
```

---

## 7. Database Queries

### Prefer WordPress Functions

**Rule**: Use WordPress built-in functions whenever possible, avoid direct database queries

```php
// Correct - use WordPress functions
$post = get_post( $post_id );
$user = get_user_by( 'id', $user_id );
$option = get_option( 'my_option' );

// Avoid - direct database query
global $wpdb;
$post = $wpdb->get_row( "SELECT * FROM $wpdb->posts WHERE ID = $post_id" );
```

### Use $wpdb->prepare()

**Rule**: All database queries MUST use `$wpdb->prepare()` for parameterization

```php
global $wpdb;

// Correct
$var = "dangerous'";
$id = some_foo_number();

$wpdb->query(
    $wpdb->prepare(
        "UPDATE $wpdb->posts SET post_title = %s WHERE ID = %d",
        $var,
        $id
    )
);

// Incorrect - SQL injection risk
$wpdb->query( "UPDATE $wpdb->posts SET post_title = '$var' WHERE ID = $id" );
```

**Available placeholders**:
- `%d` - integer
- `%f` - float
- `%s` - string
- `%i` - identifier (table/field names)

**Important**: Don't quote placeholders, `$wpdb->prepare()` handles that automatically

### SQL Statement Formatting

**Rule**: SQL keywords should be uppercase

```php
// Correct
$wpdb->query(
    $wpdb->prepare(
        "SELECT * FROM $wpdb->posts WHERE post_status = %s AND post_type = %s",
        'publish',
        'post'
    )
);

// Incorrect - keywords should be uppercase
$wpdb->query(
    $wpdb->prepare(
        "select * from $wpdb->posts where post_status = %s",
        'publish'
    )
);
```

---

## 8. Object-Oriented Programming

### One Object Structure Per File

**Rule**: One file should only define one class/interface/trait/enum

```php
// Correct - class-my-class.php
class My_Class {
    // ...
}

// Incorrect - multiple classes in same file
class My_Class {
    // ...
}

class Another_Class {  // ❌ Should be in another file
    // ...
}
```

### Visibility Must Be Declared

**Rule**: All properties and methods MUST explicitly declare visibility (public/protected/private)

```php
// Correct
class My_Class {
    private $private_var;
    protected $protected_var;
    public $public_var;
    
    public function public_method() {
        // ...
    }
    
    private function private_method() {
        // ...
    }
}

// Incorrect - missing visibility declaration
class My_Class {
    var $some_var;  // ❌ Should use public/protected/private
    
    function some_method() {  // ❌ Missing visibility
        // ...
    }
}
```

### Trait Use Statements

**Rule**: `use` statements should be at the beginning of the class, first line after opening brace

```php
// Correct
class My_Class {
    use My_Trait;
    use Another_Trait;
    
    private $property;
    
    public function method() {
        // ...
    }
}
```

### Object Instantiation

**Rule**: Always use parentheses when instantiating objects, even without parameters

```php
// Correct
$object = new My_Class();
$object = new My_Class( $param );

// Incorrect
$object = new My_Class;  // ❌ Missing parentheses
```

---

## 9. Documentation (PHPDoc)

**Rule**: All public classes, methods, and functions MUST have PHPDoc comments

### Function Documentation

```php
/**
 * Get plugin option value
 *
 * Retrieves a plugin-specific option from the database.
 * Returns the default value if the option doesn't exist.
 *
 * @since 1.0.0
 *
 * @param string $key     Option key to retrieve.
 * @param mixed  $default Default value if option doesn't exist. Default null.
 * @return mixed Option value or default value.
 */
function myplugin_get_option( $key, $default = null ) {
    return get_option( 'myplugin_' . $key, $default );
}
```

### Class Documentation

```php
/**
 * Main plugin initialization class
 *
 * Handles plugin initialization, hook registration,
 * and component loading.
 *
 * @since 1.0.0
 */
class MyPlugin_Init {
    
    /**
     * Single instance of the class
     *
     * @since 1.0.0
     * @var MyPlugin_Init|null
     */
    private static $instance = null;
    
    /**
     * Get singleton instance
     *
     * @since 1.0.0
     * @return MyPlugin_Init Single instance.
     */
    public static function instance() {
        if ( null === self::$instance ) {
            self::$instance = new self();
        }
        return self::$instance;
    }
}
```

### Hook Documentation

```php
/**
 * Fires before saving plugin data
 *
 * @since 1.0.0
 *
 * @param array $data Data to be saved.
 * @param int   $id   Post ID.
 */
do_action( 'myplugin_before_save', $data, $id );

/**
 * Filters the plugin data before display
 *
 * @since 1.0.0
 *
 * @param array $data Original data.
 * @param int   $id   Post ID.
 * @return array Modified data.
 */
$data = apply_filters( 'myplugin_data', $data, $id );
```

---

## 10. Internationalization (i18n)

**Rule**: All user-facing strings MUST be translatable

### Basic Translation Functions

```php
// Return translated string
__( 'Hello World', 'myplugin' );

// Echo translated string
_e( 'Hello World', 'myplugin' );

// Return and escape HTML
esc_html__( 'Hello World', 'myplugin' );

// Echo and escape HTML
esc_html_e( 'Hello World', 'myplugin' );

// Return and escape attribute
esc_attr__( 'Hello World', 'myplugin' );

// Echo and escape attribute
esc_attr_e( 'Hello World', 'myplugin' );
```

### Translation with Variables

```php
// Correct - use printf with translator comments
printf(
    /* translators: %s: user name */
    __( 'Hello %s', 'myplugin' ),
    esc_html( $name )
);

// Correct - multiple variables
printf(
    /* translators: 1: post title, 2: author name */
    __( '%1$s was written by %2$s', 'myplugin' ),
    esc_html( $title ),
    esc_html( $author )
);

// Incorrect - don't split sentences
echo __( 'Hello', 'myplugin' ) . ' ' . $name;  // ❌
```

### Plural Forms

```php
// Correct
printf(
    /* translators: %d: number of posts */
    _n(
        'You have %d post',
        'You have %d posts',
        $count,
        'myplugin'
    ),
    number_format_i18n( $count )
);
```

### Text Domain

**Rule**: Text domain MUST be a string constant, not a variable

```php
// Correct
__( 'Hello', 'myplugin' );

// Incorrect
$domain = 'myplugin';
__( 'Hello', $domain );  // ❌ Can't use variable
```

---

## 11. Security

### Data Validation and Sanitization

**Rule**: Always validate and sanitize user input

```php
// Sanitize text input
$title = sanitize_text_field( $_POST['title'] );

// Sanitize HTML
$content = wp_kses_post( $_POST['content'] );

// Sanitize URL
$url = esc_url_raw( $_POST['url'] );

// Sanitize email
$email = sanitize_email( $_POST['email'] );

// Validate integer
$id = absint( $_POST['id'] );
```

### Data Output Escaping

**Rule**: Escape data before outputting to HTML

```php
// HTML content
echo esc_html( $text );

// HTML attribute
echo '<input value="' . esc_attr( $value ) . '">';

// URL
echo '<a href="' . esc_url( $url ) . '">Link</a>';

// JavaScript
echo '<script>var name = "' . esc_js( $name ) . '";</script>';

// Known safe HTML
echo wp_kses_post( $content );
```

### Nonce Verification

**Rule**: All form submissions and AJAX requests MUST use nonce verification

```php
// Generate nonce
wp_nonce_field( 'myplugin_save_action', 'myplugin_nonce' );

// Verify nonce
if ( ! isset( $_POST['myplugin_nonce'] ) ||
     ! wp_verify_nonce( $_POST['myplugin_nonce'], 'myplugin_save_action' ) ) {
    wp_die( 'Security check failed' );
}

// AJAX nonce
wp_localize_script( 'myplugin-script', 'myplugin', array(
    'ajax_url' => admin_url( 'admin-ajax.php' ),
    'nonce'    => wp_create_nonce( 'myplugin_ajax_nonce' ),
) );

// Verify AJAX nonce
check_ajax_referer( 'myplugin_ajax_nonce', 'nonce' );
```

### Permission Checks

**Rule**: Check user permissions before performing operations

```php
// Check capability
if ( ! current_user_can( 'manage_options' ) ) {
    wp_die( 'You do not have permission to access this page.' );
}

// Check post-specific permission
if ( ! current_user_can( 'edit_post', $post_id ) ) {
    wp_die( 'You do not have permission to edit this post.' );
}
```

---

## 12. WordPress Core Functions Priority

**Rule**: Prefer WordPress core functions over PHP native functions

```php
// HTTP requests
// ✅ Correct
$response = wp_remote_get( $url );
// ❌ Incorrect
$response = file_get_contents( $url );

// File system operations
// ✅ Correct
global $wp_filesystem;
WP_Filesystem();
$content = $wp_filesystem->get_contents( $file );
// ❌ Incorrect
$content = file_get_contents( $file );

// JSON handling
// ✅ Correct
$data = wp_json_encode( $array );
// ❌ Incorrect
$data = json_encode( $array );

// Safe redirect
// ✅ Correct
wp_safe_redirect( $url );
// ❌ Incorrect
header( 'Location: ' . $url );
```

---

## Checklist

Before submitting code, verify:

- [ ] Use full PHP tags `<?php`
- [ ] Variables and functions use lowercase with underscores
- [ ] Classes use capitalized words with underscores
- [ ] Use tabs for indentation
- [ ] Spaces on both sides of operators
- [ ] Spaces inside control structure parentheses
- [ ] Always use braces, even for single statements
- [ ] Use long array syntax `array()`
- [ ] Use `elseif` instead of `else if`
- [ ] Use Yoda Conditions (constants on left)
- [ ] Database queries use `$wpdb->prepare()`
- [ ] All properties and methods explicitly declare visibility
- [ ] All public APIs have PHPDoc comments
- [ ] All user-facing strings are translatable
- [ ] All user input is validated and sanitized
- [ ] All output is escaped
- [ ] All forms use nonce verification
- [ ] All operations check user permissions
- [ ] Prefer WordPress core functions
- [ ] Pass PHPCS WordPress-Core checks
