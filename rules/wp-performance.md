# WordPress Performance Rules

## 1. Database Query Optimization

### Avoid Queries in Loops

**Rule**: Prohibit database queries inside loops (N+1 problem)

- ❌ **Wrong**: N+1 queries
  ```php
  $posts = get_posts( array( 'posts_per_page' => 100 ) );
  foreach ( $posts as $post ) {
      $meta = get_post_meta( $post->ID, 'my_meta', true ); // Query each time!
  }
  ```

- ✅ **Correct**: Batch query
  ```php
  $posts = get_posts( array( 'posts_per_page' => 100 ) );
  $post_ids = wp_list_pluck( $posts, 'ID' );
  
  // Query all meta at once
  update_meta_cache( 'post', $post_ids );
  
  foreach ( $posts as $post ) {
      $meta = get_post_meta( $post->ID, 'my_meta', true ); // Read from cache
  }
  ```

### Optimize WP_Query Parameters

**Rule**: Only query needed fields

```php
// Only need IDs
$query = new WP_Query( array(
    'fields'         => 'ids',
    'posts_per_page' => 100,
) );

// Only need ID and post_title
$query = new WP_Query( array(
    'fields'         => array( 'ID', 'post_title' ),
    'posts_per_page' => 100,
) );
```

## 2. Autoload Options Management

**Rule**: Large data should not be autoloaded

### Check Autoload Size

```bash
wp option list --autoload=on --format=total
```

### Proper Autoload Usage

```php
// Small settings (< 100KB) - autoload
update_option( 'myplugin_settings', $small_data, true );

// Large data (> 100KB) - no autoload
update_option( 'myplugin_cache', $large_data, false );

// Temporary data - use Transients
set_transient( 'myplugin_api_cache', $data, HOUR_IN_SECONDS );
```

## 3. Object Cache Usage

**Rule**: Expensive computation results must be cached

```php
// Check cache
$data = wp_cache_get( 'my_expensive_data', 'myplugin' );

if ( false === $data ) {
    // Perform expensive computation
    $data = expensive_calculation();
    
    // Cache result (1 hour)
    wp_cache_set( 'my_expensive_data', $data, 'myplugin', HOUR_IN_SECONDS );
}

return $data;
```

## 4. HTTP API Best Practices

**Rule**: All external HTTP requests must set timeout and error handling

```php
$response = wp_remote_get( 'https://api.example.com/data', array(
    'timeout' => 5, // Must set timeout
) );

if ( is_wp_error( $response ) ) {
    // Error handling
    error_log( 'API request failed: ' . $response->get_error_message() );
    return false;
}

$body = wp_remote_retrieve_body( $response );
$data = json_decode( $body );
```

## 5. Cron Task Optimization

**Rule**: Cron tasks must be idempotent

```php
add_action( 'myplugin_daily_task', 'myplugin_process_data' );

function myplugin_process_data() {
    // Prevent duplicate execution
    if ( get_transient( 'myplugin_task_running' ) ) {
        return;
    }
    
    set_transient( 'myplugin_task_running', true, 10 * MINUTE_IN_SECONDS );
    
    // Execute task
    // ...
    
    delete_transient( 'myplugin_task_running' );
}
```

## 6. Asset Loading Optimization

**Rule**: Only load assets on needed pages

```php
add_action( 'admin_enqueue_scripts', 'myplugin_admin_scripts' );

function myplugin_admin_scripts( $hook ) {
    // Only load on plugin settings page
    if ( 'settings_page_myplugin' !== $hook ) {
        return;
    }
    
    wp_enqueue_script( 'myplugin-admin', plugins_url( 'js/admin.js', __FILE__ ) );
}
```

## 7. Scripts in Footer

**Rule**: Load JavaScript files in footer when possible

- ❌ **Wrong**: Loading in header
  ```php
  wp_enqueue_script(
      'myplugin-script',
      plugins_url( 'js/script.js', __FILE__ ),
      array( 'jquery' ),
      '1.0.0',
      false  // Loads in header
  );
  ```

- ✅ **Correct**: Load in footer
  ```php
  wp_enqueue_script(
      'myplugin-script',
      plugins_url( 'js/script.js', __FILE__ ),
      array( 'jquery' ),
      '1.0.0',
      true  // Loads in footer
  );
  ```

**Benefits**:
- Improves page load performance
- Allows HTML to render before JavaScript executes
- Better user experience

**Exception**: Scripts that must run before page render (rare cases)

## 8. Non-Blocking Scripts

**Rule**: Use `defer` or `async` for scripts when appropriate (WordPress 6.3+)

```php
// Defer strategy (recommended for most scripts)
wp_enqueue_script(
    'myplugin-script',
    plugins_url( 'js/script.js', __FILE__ ),
    array(),
    '1.0.0',
    array(
        'in_footer' => true,
        'strategy'  => 'defer'  // Execute after HTML parsing
    )
);

// Async strategy (for independent scripts)
wp_enqueue_script(
    'myplugin-analytics',
    plugins_url( 'js/analytics.js', __FILE__ ),
    array(),
    '1.0.0',
    array(
        'in_footer' => true,
        'strategy'  => 'async'  // Execute as soon as loaded
    )
);
```

**When to use**:
- `defer`: Scripts that need DOM but don't need to run immediately
- `async`: Independent scripts (analytics, tracking)
- Neither: Scripts with dependencies or that modify DOM during load

## 9. Resource Size Limits

**Rule**: Keep JavaScript and CSS files reasonably sized

### Recommended Limits

- **JavaScript**: < 100KB per file (minified)
- **CSS**: < 50KB per file (minified)
- **Total page resources**: < 500KB

### Optimization Strategies

```php
// 1. Conditional loading
add_action( 'wp_enqueue_scripts', 'myplugin_conditional_assets' );
function myplugin_conditional_assets() {
    // Only load on specific pages
    if ( is_singular( 'product' ) ) {
        wp_enqueue_script( 'myplugin-product', ... );
    }
    
    // Only load when shortcode is present
    global $post;
    if ( is_a( $post, 'WP_Post' ) && has_shortcode( $post->post_content, 'myplugin' ) ) {
        wp_enqueue_script( 'myplugin-shortcode', ... );
    }
}

// 2. Code splitting
wp_enqueue_script( 'myplugin-core', ..., '1.0.0', true );      // 30KB
wp_enqueue_script( 'myplugin-advanced', ..., '1.0.0', true );  // 50KB (only when needed)

// 3. Minification and compression
// - Use build tools (webpack, gulp) to minify
// - Enable gzip compression on server
// - Provide source maps for debugging
```

### Check Resource Sizes

```bash
# Check file sizes
ls -lh js/*.js
ls -lh css/*.css

# Check minified sizes
du -h js/*.min.js
du -h css/*.min.css
```

## Checklist

- [ ] No N+1 query issues
- [ ] Autoload options total size < 1MB
- [ ] Expensive computations are cached
- [ ] HTTP requests have timeout
- [ ] Cron tasks are idempotent
- [ ] Assets only load when needed
- [ ] Scripts load in footer (when possible)
- [ ] Use defer/async for non-critical scripts (WordPress 6.3+)
- [ ] JavaScript files < 100KB each (minified)
- [ ] CSS files < 50KB each (minified)
