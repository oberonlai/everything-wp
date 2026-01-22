# WordPress Coding Standards

## 1. Plugin Architecture Rules

### Single Entry Point

**Rule**: Each plugin must have only one main file (bootstrap file)

```
my-plugin/
├── my-plugin.php          # Single main file with plugin header
├── src/                   # Core functionality
│   ├── class-loader.php
│   └── class-admin.php
└── vendor/                # Composer dependencies
```

### Lazy Loading

**Rule**: Avoid heavy operations at file load time, use hooks for lazy loading

- ❌ **Wrong**: Execute immediately on file load
  ```php
  // my-plugin.php
  require_once 'src/class-heavy-class.php';
  $heavy = new MyPlugin_Heavy_Class();
  $heavy->init(); // Immediate execution
  ```

- ✅ **Correct**: Use Init class with autoloader
  ```php
  // my-plugin.php
  <?php
  /**
   * Plugin Name: My Plugin
   */
  
  if ( ! defined( 'ABSPATH' ) ) {
      exit;
  }
  
  // Define plugin constants
  define( 'MYPLUGIN_VERSION', '1.0.0' );
  define( 'MYPLUGIN_PATH', plugin_dir_path( __FILE__ ) );
  
  // Load Composer autoloader
  require_once MYPLUGIN_PATH . 'vendor/autoload.php'
  
  // Initialize plugin
  add_action( 'plugins_loaded', array( 'MyPlugin_Init', 'instance' ) );
  ```
  
  ```php
  // src/class-init.php
  <?php
  /**
   * Main initialization class
   */
  class MyPlugin_Init {
      
      /**
       * Single instance
       */
      private static $instance = null;
      
      /**
       * Get singleton instance
       */
      public static function instance() {
          if ( null === self::$instance ) {
              self::$instance = new self();
          }
          return self::$instance;
      }
      
      /**
       * Constructor - initialize all components
       */
      private function __construct() {
          $this->init_hooks();
      }
      
      /**
       * Initialize hooks and components
       */
      private function init_hooks() {
          // Admin components
          if ( is_admin() ) {
              MyPlugin_Admin::instance();
          }
          
          // Frontend components
          MyPlugin_Frontend::instance();
          
          // Common components
          MyPlugin_Assets::instance();
      }
  }
  ```
  
  ```json
  // composer.json
  {
    "name": "vendor/my-plugin",
    "autoload": {
      "classmap": ["src/"]
    },
    "require": {
      "php": ">=7.4"
    }
  }
  ```
  
  **Setup**:
  ```bash
  # Run once to generate autoloader
  composer dump-autoload
  ```
  
  **Benefits**:
  - Composer handles all class loading automatically
  - No manual require statements needed
  - Works with WordPress naming convention (classmap)
  - Better performance with optimized autoloader

### Admin Code Isolation

**Rule**: Admin interface code must be initialized behind `is_admin()` check

```php
// In src/class-init.php
private function init_hooks() {
    // Only initialize admin components in admin area
    if ( is_admin() ) {
        MyPlugin_Admin::instance();
    }
    
    // Frontend components
    MyPlugin_Frontend::instance();
}
```

**Note**: With Composer autoloader, classes load automatically. No `require` needed.

## 2. Naming Conventions

### Function and Class Prefixes

**Rule**: All global functions and classes must use unique prefix or namespace

- ✅ **Using prefix**:
  ```php
  function myplugin_get_data() { }
  class MyPlugin_Admin { }
  ```

- ✅ **Using namespace** (recommended):
  ```php
  namespace MyPlugin;
  
  function get_data() { }
  class Admin { }
  ```

### Hook Naming

**Rule**: Custom hooks must use plugin prefix

```php
// Actions
do_action( 'myplugin_before_save', $data );

// Filters
apply_filters( 'myplugin_data', $data );
```

## 3. File Organization

### Class Files

**Rule**: One class per file, filename uses `class-` prefix and lowercase with dashes

**WordPress Coding Standards (WPCS)**:
- **Class Name**: `Class_Name_With_Underscores` (PascalCase with underscores)
- **File Name**: `class-name-with-dashes.php` (lowercase with dashes)

**Examples**:
```php
// File: src/class-loader.php
class MyPlugin_Loader {
    // ...
}

// File: src/class-admin.php
class MyPlugin_Admin {
    // ...
}

// File: src/class-settings-page.php
class MyPlugin_Settings_Page {
    // ...
}
```

**Directory Structure**:
```
src/
├── class-loader.php           # MyPlugin_Loader
├── class-admin.php            # MyPlugin_Admin
├── class-settings-page.php    # MyPlugin_Settings_Page
└── class-post-type.php        # MyPlugin_Post_Type
```

### PSR-4 Autoloading

**Rule**: Use Composer PSR-4 autoloading for new code (allows namespaces and different naming)

```json
{
  "autoload": {
    "psr-4": {
      "MyPlugin\\": "src/"
    }
  }
}
```

**Note**: For PSR-4 autoloading with namespaces, you can use standard PHP naming:
```php
// composer.json
{
  "autoload": {
    "psr-4": {
      "MyPlugin\\Namespaced\\": "lib/"
    }
  }
}

// File: lib/Admin/SettingsPage.php
namespace MyPlugin\Namespaced\Admin;

class Settings_Page { 
    // ...
}
```

**Summary**:
- **WordPress Standard** (src/): Use `Class_Name_With_Underscores` and `class-name-with-dashes.php`
- **PSR-4 Namespaced** (lib/): Use standard `ClassName` (PascalCase) and `ClassName.php`

## 4. WordPress Coding Standards (WPCS)

**Rule**: All code must comply with WordPress Coding Standards

### Install PHPCS + WPCS

```bash
composer require --dev squizlabs/php_codesniffer
composer require --dev wp-coding-standards/wpcs
```

### Configure `phpcs.xml.dist`

```xml
<?xml version="1.0"?>
<ruleset name="MyPlugin">
    <description>WordPress Coding Standards for MyPlugin</description>
    
    <file>.</file>
    
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/tests/*</exclude-pattern>
    
    <rule ref="WordPress-Core"/>
    <rule ref="WordPress-Docs"/>
    <rule ref="WordPress.WP.I18n"/>
    
    <config name="minimum_supported_wp_version" value="6.0"/>
    <config name="testVersion" value="7.4-"/>
</ruleset>
```

### Run Checks

```bash
composer exec phpcs
```

## 5. Documentation Rules

**Rule**: All public functions and classes must have PHPDoc

```php
/**
 * Get plugin option value
 *
 * @param string $key     Option key
 * @param mixed  $default Default value
 * @return mixed Option value or default
 */
function myplugin_get_option( $key, $default = null ) {
    return get_option( 'myplugin_' . $key, $default );
}
```

## 6. Internationalization (i18n)

**Rule**: All user-facing strings must be translatable

```php
// Correct
__( 'Hello World', 'myplugin' );
_e( 'Hello World', 'myplugin' );
esc_html__( 'Hello World', 'myplugin' );

// With variables
printf(
    /* translators: %s: user name */
    __( 'Hello %s', 'myplugin' ),
    esc_html( $name )
);
```

**WordPress 4.6+ Note**: `load_plugin_textdomain()` is no longer required as WordPress automatically loads translations.

## 7. Remote Resource Loading (WordPress.org Requirement)

**Rule**: Do not load JavaScript, CSS, or images from remote CDNs (except fonts)

- ❌ **Forbidden**: Loading libraries from CDN
  ```php
  // Loading from CDN
  wp_enqueue_script( 'alpine', 'https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js' );
  wp_enqueue_style( 'bootstrap', 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' );
  
  // Loading images from external site
  echo '<img src="https://mywebsite.com/logo.png">';
  ```

- ✅ **Correct**: Include all resources in plugin
  ```php
  // Include library in plugin
  wp_enqueue_script(
      'myplugin-alpine',
      plugins_url( 'js/alpine.min.js', __FILE__ ),
      array(),
      '3.0.0',
      true
  );
  
  // Images also in plugin
  echo '<img src="' . esc_url( plugins_url( 'images/logo.png', __FILE__ ) ) . '">';
  ```

**Exceptions**: Fonts are allowed from CDNs
```php
// Google Fonts are allowed
wp_enqueue_style(
    'myplugin-google-fonts',
    'https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap',
    array(),
    null
);
```

## 8. Code Readability (WordPress.org Requirement)

**Rule**: Code must be human-readable and not obfuscated

- ❌ **Forbidden**: Obfuscated or minified code without source
  ```php
  // Obfuscated variable names
  function a($b){$c=$b*2;return $c;}
  $z12sdf813d = a($x);
  
  // Minified code without source files
  eval(gzinflate(base64_decode('...')));
  ```

- ✅ **Correct**: Readable code or provide source
  ```php
  // Clear, readable code
  function calculate_total( $amount ) {
      $total = $amount * 2;
      return $total;
  }
  $final_price = calculate_total( $price );
  ```

**For Compiled/Minified Code**:
- Include source files in plugin, OR
- Provide link to development repository in readme.txt
- Document build process

## 9. Localhost URL Check

**Rule**: Do not hardcode localhost URLs in code

- ❌ **Wrong**: Hardcoded localhost URLs
  ```php
  $api_url = 'http://localhost:8000/api';
  $dev_url = 'http://mysite.local/test';
  $test_url = 'http://127.0.0.1/endpoint';
  ```

- ✅ **Correct**: Use options or constants
  ```php
  // Store in options
  $api_url = get_option( 'myplugin_api_url', 'https://api.example.com' );
  
  // Use constants (defined elsewhere)
  $api_url = defined( 'MYPLUGIN_API_URL' ) ? MYPLUGIN_API_URL : 'https://api.example.com';
  
  // Use WordPress functions
  $admin_url = admin_url( 'admin-ajax.php' );
  $site_url = get_site_url();
  ```

**Why it's important**: Hardcoded localhost URLs will break in production and indicate the plugin wasn't properly tested.

## 10. Plugin Uninstall

**Rule**: Implement proper uninstall mechanism to clean up plugin data

### Create uninstall.php

```php
<?php
/**
 * Uninstall script for My Plugin
 */

// If uninstall not called from WordPress, exit
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
    exit;
}

// Delete options
delete_option( 'myplugin_settings' );
delete_option( 'myplugin_version' );

// For multisite
if ( is_multisite() ) {
    global $wpdb;
    $blog_ids = $wpdb->get_col( "SELECT blog_id FROM $wpdb->blogs" );
    
    foreach ( $blog_ids as $blog_id ) {
        switch_to_blog( $blog_id );
        delete_option( 'myplugin_settings' );
        restore_current_blog();
    }
}

// Delete custom tables
global $wpdb;
$table_name = $wpdb->prefix . 'myplugin_data';
$wpdb->query( "DROP TABLE IF EXISTS $table_name" );

// Delete user meta
$wpdb->query( "DELETE FROM $wpdb->usermeta WHERE meta_key LIKE 'myplugin_%'" );

// Delete transients
$wpdb->query( "DELETE FROM $wpdb->options WHERE option_name LIKE '_transient_myplugin_%'" );
$wpdb->query( "DELETE FROM $wpdb->options WHERE option_name LIKE '_transient_timeout_myplugin_%'" );
```

### Alternative: Use uninstall hook

```php
// In main plugin file
register_uninstall_hook( __FILE__, 'myplugin_uninstall' );

function myplugin_uninstall() {
    // Clean up code here
    delete_option( 'myplugin_settings' );
}
```

**Important**: 
- Use `uninstall.php` for complex cleanup (recommended)
- Use `register_uninstall_hook()` for simple cleanup
- Never use `register_deactivation_hook()` for data cleanup
- Always check `WP_UNINSTALL_PLUGIN` in uninstall.php

## Checklist

- [ ] Use unique prefix or namespace
- [ ] Admin code loaded behind `is_admin()`
- [ ] Pass PHPCS checks
- [ ] All public APIs have PHPDoc
- [ ] All strings are translatable
- [ ] Use WordPress core functions instead of PHP native (e.g., `wp_remote_get()` instead of `file_get_contents()`)
- [ ] No remote resources loaded (except fonts)
- [ ] Code is human-readable (not obfuscated)
- [ ] Minified/compiled code has source files or repository link
- [ ] No hardcoded localhost URLs
- [ ] Proper uninstall mechanism implemented (uninstall.php or uninstall hook)
