# WordPress Custom Database Tables

Best practices for creating and managing custom database tables in WordPress plugins.

## 1. When to Use Custom Tables

### Use Custom Tables When:
- ✅ Storing large amounts of structured data (thousands of rows)
- ✅ Need complex queries with JOINs
- ✅ Require custom indexing for performance
- ✅ Data doesn't fit the post/meta model
- ✅ Need atomic transactions

### Use Post Meta When:
- ❌ Small amount of data per post
- ❌ Simple key-value storage
- ❌ Leverage WordPress's built-in caching
- ❌ Need WordPress's revision system

## 2. Table Creation with dbDelta()

### Basic Example

**Rule**: Always use `dbDelta()` for table creation and updates

```php
function myplugin_create_table() {
    global $wpdb;
    
    $table_name = $wpdb->prefix . 'myplugin_data';
    $charset_collate = $wpdb->get_charset_collate();
    
    $sql = "CREATE TABLE $table_name (
        id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
        user_id bigint(20) unsigned NOT NULL,
        title varchar(200) NOT NULL,
        content longtext NOT NULL,
        status varchar(20) NOT NULL DEFAULT 'pending',
        created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY  (id),
        KEY user_id (user_id),
        KEY status (status),
        KEY created_at (created_at)
    ) $charset_collate;";
    
    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta( $sql );
}

register_activation_hook( __FILE__, 'myplugin_create_table' );
```

### dbDelta() Formatting Rules (CRITICAL)

**`dbDelta()` is VERY strict about SQL formatting**:

```sql
-- ✅ Correct - TWO spaces after PRIMARY KEY
PRIMARY KEY  (id)

-- ❌ Wrong - One space
PRIMARY KEY (id)

-- ✅ Correct - Spaces around parentheses in KEY
KEY user_id (user_id)

-- ❌ Wrong - No spaces
KEY user_id(user_id)

-- ✅ Correct - Each field on its own line
CREATE TABLE $table_name (
    id bigint(20) NOT NULL,
    name varchar(100) NOT NULL
)

-- ❌ Wrong - Multiple fields on one line
CREATE TABLE $table_name (id bigint(20), name varchar(100))
```

## 3. Naming Conventions

### Table Names

```php
// ✅ Correct - Use $wpdb->prefix + plugin_slug + table_name
$table_name = $wpdb->prefix . 'myplugin_orders';
$table_name = $wpdb->prefix . 'myplugin_order_items';

// ❌ Wrong - No prefix
$table_name = 'orders';

// ❌ Wrong - Hardcoded prefix
$table_name = 'wp_myplugin_orders';
```

### Column Names

```php
// ✅ Correct - lowercase_with_underscores
user_id, created_at, order_total, is_active

// ❌ Wrong - camelCase
userId, createdAt

// ❌ Wrong - Unclear abbreviations
uid, ct
```

## 4. Column Types

### Common Types

```php
// Primary Key
id bigint(20) unsigned NOT NULL AUTO_INCREMENT

// Foreign Keys
user_id bigint(20) unsigned NOT NULL
post_id bigint(20) unsigned NOT NULL

// Text
title varchar(200) NOT NULL
slug varchar(200) NOT NULL
content longtext NOT NULL
description text

// Numbers
count int(11) NOT NULL DEFAULT 0
price decimal(10,2) NOT NULL DEFAULT 0.00
is_active tinyint(1) NOT NULL DEFAULT 1

// Dates
created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
updated_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

// JSON (MySQL 5.7+)
metadata json
```

### Indexes

**Rule**: Add indexes for columns used in WHERE, JOIN, ORDER BY

```sql
PRIMARY KEY  (id),
KEY user_id (user_id),              -- Single column
KEY status (status),
KEY created_at (created_at),
KEY user_status (user_id, status)   -- Composite index
```

## 5. Version Management

**Rule**: Track table version in options and update when schema changes

```php
function myplugin_create_or_update_table() {
    $current_version = '1.1.0';
    $installed_version = get_option( 'myplugin_db_version', '0' );
    
    if ( version_compare( $installed_version, $current_version, '<' ) ) {
        // Create/update table with dbDelta()
        myplugin_create_table();
        
        update_option( 'myplugin_db_version', $current_version );
    }
}

// Run on activation
register_activation_hook( __FILE__, 'myplugin_create_or_update_table' );

// Also run on plugins_loaded for updates
add_action( 'plugins_loaded', 'myplugin_create_or_update_table' );
```

## 6. CRUD Operations

### Insert

```php
$result = $wpdb->insert(
    $table_name,
    array(
        'user_id' => $user_id,
        'title'   => $title,
        'content' => $content,
    ),
    array( '%d', '%s', '%s' )  // %d=int, %s=string, %f=float
);

if ( false !== $result ) {
    $insert_id = $wpdb->insert_id;
}
```

### Update

```php
$wpdb->update(
    $table_name,
    array( 'status' => 'active' ),     // Data
    array( 'id' => $id ),               // WHERE
    array( '%s' ),                      // Data format
    array( '%d' )                       // WHERE format
);
```

### Select

```php
// Single row
$row = $wpdb->get_row(
    $wpdb->prepare( "SELECT * FROM $table_name WHERE id = %d", $id )
);

// Multiple rows
$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM $table_name WHERE user_id = %d ORDER BY created_at DESC LIMIT %d",
        $user_id,
        $limit
    )
);
```

### Delete

```php
$wpdb->delete(
    $table_name,
    array( 'id' => $id ),
    array( '%d' )
);
```

## 7. Transactions (InnoDB Only)

**Rule**: Use transactions for bulk operations

```php
$wpdb->query( 'START TRANSACTION' );

foreach ( $records as $record ) {
    $result = $wpdb->insert( $table_name, $record, $formats );
    if ( false === $result ) {
        $wpdb->query( 'ROLLBACK' );
        return false;
    }
}

$wpdb->query( 'COMMIT' );
return true;
```

## 8. Uninstall Cleanup

**Rule**: Drop tables in `uninstall.php`, NOT on deactivation

```php
// uninstall.php
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
    exit;
}

global $wpdb;

$table_name = $wpdb->prefix . 'myplugin_data';
$wpdb->query( "DROP TABLE IF EXISTS $table_name" );
delete_option( 'myplugin_db_version' );

// Multisite support
if ( is_multisite() ) {
    $blog_ids = $wpdb->get_col( "SELECT blog_id FROM $wpdb->blogs" );
    foreach ( $blog_ids as $blog_id ) {
        switch_to_blog( $blog_id );
        $table_name = $wpdb->prefix . 'myplugin_data';
        $wpdb->query( "DROP TABLE IF EXISTS $table_name" );
        delete_option( 'myplugin_db_version' );
        restore_current_blog();
    }
}
```

## 9. Performance Tips

### Use Indexes Wisely

```sql
-- ✅ Good - Indexed columns in WHERE
SELECT * FROM {$table} WHERE user_id = 123 AND status = 'active'

-- ❌ Bad - Function on indexed column breaks index
SELECT * FROM {$table} WHERE DATE(created_at) = '2024-01-24'

-- ✅ Good - Use range instead
SELECT * FROM {$table} 
WHERE created_at >= '2024-01-24 00:00:00' 
AND created_at < '2024-01-25 00:00:00'
```

### Pagination

```php
$offset = ( $page - 1 ) * $per_page;

$results = $wpdb->get_results(
    $wpdb->prepare(
        "SELECT * FROM $table_name ORDER BY created_at DESC LIMIT %d OFFSET %d",
        $per_page,
        $offset
    )
);
```

## 10. Multisite Support

**Rule**: Create table for each new site

```php
function myplugin_create_table_for_new_site( $blog_id ) {
    if ( is_plugin_active_for_network( 'myplugin/myplugin.php' ) ) {
        switch_to_blog( $blog_id );
        myplugin_create_table();
        restore_current_blog();
    }
}
add_action( 'wpmu_new_blog', 'myplugin_create_table_for_new_site' );
```

## Checklist

Before deploying custom tables:
- [ ] Use `dbDelta()` for table creation
- [ ] Follow `dbDelta()` formatting rules (TWO spaces after PRIMARY KEY)
- [ ] Use `$wpdb->prefix` for table names
- [ ] Add indexes for frequently queried columns
- [ ] Track table version in options
- [ ] Use `$wpdb->prepare()` for all queries with variables
- [ ] Specify data types (%d, %s, %f) in insert/update
- [ ] Handle errors and log failures
- [ ] Drop tables in `uninstall.php`
- [ ] Test with multisite
- [ ] Document table schema
- [ ] Plan for data migration
