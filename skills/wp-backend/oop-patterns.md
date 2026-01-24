# WordPress OOP Development Rules

These Object-Oriented Programming rules must be followed when developing WordPress plugins and themes.

## 1. SOLID Principles

### Single Responsibility Principle (SRP)

**Rule**: Each class must have only one reason to change

- ❌ **Wrong**: God class handling everything
  ```php
  class Plugin {
      public function __construct() {
          add_action( 'init', [ $this, 'register_cpt' ] );
          add_action( 'admin_menu', [ $this, 'add_menu' ] );
          add_filter( 'the_content', [ $this, 'filter_content' ] );
      }
      
      public function register_cpt() { /* ... */ }
      public function add_menu() { /* ... */ }
      public function filter_content( $content ) { /* ... */ }
  }
  ```

- ✅ **Correct**: Separate classes with single responsibilities
  ```php
  class Post_Type_Registrar {
      public function register() { /* Only CPT registration */ }
  }
  
  class Settings_Page {
      public function render() { /* Only admin UI */ }
  }
  
  class Content_Filter {
      public function filter( $content ) { /* Only content filtering */ }
  }
  ```

### Open/Closed Principle (OCP)

**Rule**: Classes should be open for extension but closed for modification

```php
// Base class
abstract class Admin_Page {
    abstract protected function get_page_title();
    abstract protected function render_content();
    
    public function render() {
        echo '<h1>' . esc_html( $this->get_page_title() ) . '</h1>';
        $this->render_content();
    }
}

// Extension (not modification)
class Settings_Page extends Admin_Page {
    protected function get_page_title() {
        return __( 'Settings', 'myplugin' );
    }
    
    protected function render_content() {
        // Settings form
    }
}
```

### Liskov Substitution Principle (LSP)

**Rule**: Subclasses must be substitutable for their base classes

```php
interface Element {
    public function render();
}

class Text_Element implements Element {
    public function render() {
        return '<input type="text" />';
    }
}

class Checkbox_Element implements Element {
    public function render() {
        return '<input type="checkbox" />';
    }
}

// Can iterate and call render() on any Element
foreach ( $elements as $element ) {
    echo $element->render();
}
```

### Interface Segregation Principle (ISP)

**Rule**: Don't force classes to implement methods they don't use

- ❌ **Wrong**: Fat interface
  ```php
  interface Hooks {
      public function get_actions();
      public function get_filters();
  }
  
  // Forced to implement unused method
  class My_Class implements Hooks {
      public function get_actions() {
          return [ 'init' => ['init_method', 10, 1] ];
      }
      
      public function get_filters() {
          return []; // Empty, not needed!
      }
  }
  ```

- ✅ **Correct**: Segregated interfaces
  ```php
  interface Actions {
      public function get_actions();
  }
  
  interface Filters {
      public function get_filters();
  }
  
  // Only implement what's needed
  class My_Class implements Actions {
      public function get_actions() {
          return [ 'init' => ['init_method', 10, 1] ];
      }
  }
  ```

### Dependency Inversion Principle (DIP)

**Rule**: Depend on abstractions, not concretions

- ❌ **Wrong**: Direct dependency on WordPress functions
  ```php
  class Feature {
      public function run() {
          $value = get_option( 'my_setting' ); // Tight coupling
      }
  }
  ```

- ✅ **Correct**: Inject abstraction
  ```php
  interface Options_Wrapper {
      public function get( $key, $default = false );
  }
  
  class WP_Options implements Options_Wrapper {
      public function get( $key, $default = false ) {
          return get_option( $key, $default );
      }
  }
  
  class Feature {
      private $options;
      
      public function __construct( Options_Wrapper $options ) {
          $this->options = $options;
      }
      
      public function run() {
          $value = $this->options->get( 'my_setting' );
      }
  }
  ```

## 2. Hooks Manager Pattern

**Rule**: Separate hook registration from business logic

### Define Interfaces

```php
namespace MyPlugin\Interfaces;

interface Actions {
    /**
     * @return array [ 'action_name' => ['method_name', priority, args] ]
     */
    public function get_actions();
}

interface Filters {
    /**
     * @return array [ 'filter_name' => ['method_name', priority, args] ]
     */
    public function get_filters();
}
```

### Implement Business Logic

- ❌ **Wrong**: Calling add_action in constructor
  ```php
  class Login_Handler {
      public function __construct() {
          add_action( 'wp_login_failed', [ $this, 'handle_fail' ] );
      }
  }
  ```

- ✅ **Correct**: Return hooks via interface
  ```php
  namespace MyPlugin\Admin;
  
  use MyPlugin\Interfaces\Actions;
  
  class Login_Handler implements Actions {
      public function get_actions() {
          return [
              'wp_login_failed' => ['handle_fail', 10, 1]
          ];
      }
      
      public function handle_fail( $username ) {
          // Business logic only
      }
  }
  ```

### Create Hooks Manager

```php
namespace MyPlugin\Core;

use MyPlugin\Interfaces\Actions;
use MyPlugin\Interfaces\Filters;

class Hooks_Manager {
    public function register( $object ) {
        if ( $object instanceof Actions ) {
            $this->register_actions( $object );
        }
        if ( $object instanceof Filters ) {
            $this->register_filters( $object );
        }
    }
    
    private function register_actions( Actions $object ) {
        foreach ( $object->get_actions() as $action => $params ) {
            add_action( $action, [ $object, $params[0] ], $params[1], $params[2] );
        }
    }
    
    private function register_filters( Filters $object ) {
        foreach ( $object->get_filters() as $filter => $params ) {
            add_filter( $filter, [ $object, $params[0] ], $params[1], $params[2] );
        }
    }
}
```

## 3. Namespacing

**Rule**: All classes must use proper namespacing

```php
namespace Vendor\PluginName\Admin;
namespace Vendor\PluginName\Frontend;
namespace Vendor\PluginName\Core;
namespace Vendor\PluginName\Interfaces;
```

**Benefits**:
- Prevents naming collisions
- Enables PSR-4 autoloading
- Improves code organization

## 4. Dependency Injection

**Rule**: Inject dependencies via constructor, avoid global state

- ❌ **Wrong**: Using globals
  ```php
  class Feature {
      public function run() {
          global $wpdb;
          $wpdb->query( /* ... */ );
      }
  }
  ```

- ✅ **Correct**: Inject dependencies
  ```php
  class Feature {
      private $db;
      
      public function __construct( wpdb $db ) {
          $this->db = $db;
      }
      
      public function run() {
          $this->db->query( /* ... */ );
      }
  }
  
  // Bootstrap
  $feature = new Feature( $wpdb );
  ```

## 5. Directory Structure

**Rule**: Follow standard OOP directory structure

```
my-plugin/
├── src/
│   ├── Core/
│   │   ├── Hooks_Manager.php
│   │   └── Plugin.php
│   ├── Admin/
│   │   ├── Settings_Page.php
│   │   └── Menu_Handler.php
│   ├── Frontend/
│   │   └── Shortcode_Handler.php
│   └── Interfaces/
│       ├── Actions.php
│       └── Filters.php
├── tests/
├── vendor/
├── composer.json
└── my-plugin.php
```

## 6. Autoloading

**Rule**: Use Composer PSR-4 autoloading

### composer.json

```json
{
  "autoload": {
    "psr-4": {
      "Vendor\\PluginName\\": "src/"
    }
  }
}
```

### Main Plugin File

```php
<?php
/**
 * Plugin Name: My Plugin
 */

require_once __DIR__ . '/vendor/autoload.php';

use Vendor\PluginName\Core\Plugin;

$plugin = new Plugin();
$plugin->run();
```

## 7. Testability

**Rule**: Design for testability from the start

### Make Classes Testable

```php
// Testable: Dependencies are injected
class Post_Creator {
    private $db;
    private $validator;
    
    public function __construct( Database $db, Validator $validator ) {
        $this->db = $db;
        $this->validator = $validator;
    }
    
    public function create( array $data ) {
        if ( ! $this->validator->validate( $data ) ) {
            return false;
        }
        
        return $this->db->insert( $data );
    }
}

// Test with mocks
$mock_db = $this->createMock( Database::class );
$mock_validator = $this->createMock( Validator::class );

$creator = new Post_Creator( $mock_db, $mock_validator );
```

## 8. Avoid Static Methods

**Rule**: Prefer instance methods over static methods

- ❌ **Wrong**: Static methods (hard to test)
  ```php
  class Helper {
      public static function format_date( $date ) {
          return date( 'Y-m-d', strtotime( $date ) );
      }
  }
  
  // Hard to mock in tests
  $formatted = Helper::format_date( $date );
  ```

- ✅ **Correct**: Instance methods (easy to test)
  ```php
  class Date_Formatter {
      public function format( $date ) {
          return date( 'Y-m-d', strtotime( $date ) );
      }
  }
  
  // Easy to mock in tests
  $formatter = new Date_Formatter();
  $formatted = $formatter->format( $date );
  ```

## 9. Type Hinting

**Rule**: Use type hints for all method parameters and return types

```php
class User_Repository {
    private wpdb $db;
    
    public function __construct( wpdb $db ) {
        $this->db = $db;
    }
    
    public function find( int $id ): ?array {
        $result = $this->db->get_row(
            $this->db->prepare( "SELECT * FROM users WHERE id = %d", $id ),
            ARRAY_A
        );
        
        return $result ?: null;
    }
    
    public function save( array $data ): bool {
        return (bool) $this->db->insert( 'users', $data );
    }
}
```

## Checklist

Before committing OOP code, verify:

- [ ] Each class has single responsibility
- [ ] Dependencies are injected, not hardcoded
- [ ] Hooks are registered via Hooks Manager pattern
- [ ] Proper namespacing is used
- [ ] PSR-4 autoloading is configured
- [ ] Classes are testable (no static methods, no globals)
- [ ] Type hints are used for parameters and return types
- [ ] Interfaces are segregated (ISP)
- [ ] Code follows SOLID principles

## References

- [Pressidium WordPress OOP Series](https://pressidium.com/blog/wordpress-and-object-oriented-programming/)
- [PSR-4 Autoloading](https://www.php-fig.org/psr/psr-4/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
