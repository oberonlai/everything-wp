---
description: Generate custom database table with Repository class for CRUD operations, version management, and multisite support
required_skills:
  - wp-backend
---

# Custom Table Command

This command generates a complete custom database table class along with a Repository class for data operations by collecting table structure through interactive questions.

## What This Command Does

1. **Collect Table Information** - Ask user for table name, columns, and indexes
2. **Configure Options** - Set up version management, multisite support, and caching
3. **Generate Table Class** - Create database table class with dbDelta()
4. **Generate Repository Class** - Create Repository class with CRUD methods
5. **Provide Integration Instructions** - Show how to hook the classes into the plugin

## When to Use

Use `/custom-table` when:
- Creating a new custom database table for a WordPress plugin
- Storing structured data that doesn't fit the post/meta model
- Need complex queries with JOINs and custom indexes
- Require atomic transactions for data integrity
- Building features like orders, transactions, logs, or custom entities

**Do NOT use for:**
- Simple key-value data (use post meta instead)
- Small amounts of data per post
- Data that needs WordPress revision system

## How It Works

### Step 1: Collect Table Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Table Name** (e.g., "orders", "transactions", "logs")
2. **Plugin Prefix** (e.g., "myplugin", used for table naming and options)
3. **Column Definitions** (name, type, nullable, default value)
4. **Index Definitions** (columns to index for performance)

**Configuration Options:**
5. **Version Management** - Track table version in wp_options for schema updates
6. **Multisite Support** - Create tables for each site in multisite installations
7. **Repository Methods** - Select which CRUD methods to include
8. **Object Caching** - Enable wp_cache for expensive queries

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (Table Identity):**

```json
{
  "questions": [
    {
      "question": "What is the table name? (e.g., 'orders', 'transactions', 'logs')",
      "header": "Table Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter table name",
          "description": "Provide a lowercase name using underscores (e.g., order_items, user_logs)"
        }
      ]
    },
    {
      "question": "What is the plugin prefix for this table?",
      "header": "Plugin Prefix",
      "multiSelect": false,
      "options": [
        {
          "label": "Auto-detect from plugin (Recommended)",
          "description": "Use the plugin slug from the current directory"
        },
        {
          "label": "Enter custom prefix",
          "description": "Specify a custom prefix (e.g., 'myplugin' for wp_myplugin_orders)"
        }
      ]
    }
  ]
}
```

**Second Question Set (Columns):**

```json
{
  "questions": [
    {
      "question": "What columns should the table have?",
      "header": "Columns",
      "multiSelect": true,
      "options": [
        {
          "label": "id (bigint, auto-increment) - Recommended",
          "description": "Primary key: bigint(20) unsigned NOT NULL AUTO_INCREMENT"
        },
        {
          "label": "user_id (bigint, foreign key)",
          "description": "Reference to wp_users: bigint(20) unsigned NOT NULL"
        },
        {
          "label": "post_id (bigint, foreign key)",
          "description": "Reference to wp_posts: bigint(20) unsigned NOT NULL"
        },
        {
          "label": "title (varchar 200)",
          "description": "Short text: varchar(200) NOT NULL"
        },
        {
          "label": "content (longtext)",
          "description": "Long text content: longtext NOT NULL"
        },
        {
          "label": "status (varchar 20)",
          "description": "Status field: varchar(20) NOT NULL DEFAULT 'pending'"
        },
        {
          "label": "amount (decimal)",
          "description": "Currency/decimal: decimal(10,2) NOT NULL DEFAULT 0.00"
        },
        {
          "label": "count (int)",
          "description": "Integer count: int(11) NOT NULL DEFAULT 0"
        },
        {
          "label": "is_active (tinyint)",
          "description": "Boolean flag: tinyint(1) NOT NULL DEFAULT 1"
        },
        {
          "label": "metadata (json)",
          "description": "JSON data (MySQL 5.7+): json"
        },
        {
          "label": "created_at (datetime)",
          "description": "Creation timestamp: datetime NOT NULL DEFAULT CURRENT_TIMESTAMP"
        },
        {
          "label": "updated_at (datetime)",
          "description": "Update timestamp: datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
        }
      ]
    }
  ]
}
```

**Third Question Set (Indexes):**

```json
{
  "questions": [
    {
      "question": "Which columns should be indexed for performance?",
      "header": "Indexes",
      "multiSelect": true,
      "options": [
        {
          "label": "user_id",
          "description": "Index for queries filtering by user"
        },
        {
          "label": "post_id",
          "description": "Index for queries filtering by post"
        },
        {
          "label": "status",
          "description": "Index for queries filtering by status"
        },
        {
          "label": "created_at",
          "description": "Index for date range queries and sorting"
        },
        {
          "label": "No additional indexes",
          "description": "Only use PRIMARY KEY"
        }
      ]
    }
  ]
}
```

**Fourth Question Set (Configuration):**

```json
{
  "questions": [
    {
      "question": "Should the table use version management for schema updates?",
      "header": "Version Mgmt",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Track table version in wp_options, automatically run dbDelta() when version changes"
        },
        {
          "label": "No",
          "description": "Only create table on activation, no automatic schema updates"
        }
      ]
    },
    {
      "question": "Should the table support WordPress multisite?",
      "header": "Multisite",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Create separate tables for each site, handle network activation"
        },
        {
          "label": "No",
          "description": "Single table, no multisite-specific handling"
        }
      ]
    }
  ]
}
```

**Fifth Question Set (Repository Options):**

```json
{
  "questions": [
    {
      "question": "Which Repository methods do you need?",
      "header": "Methods",
      "multiSelect": true,
      "options": [
        {
          "label": "get (single by ID) - Recommended",
          "description": "Get a single row by primary key"
        },
        {
          "label": "find (single by conditions)",
          "description": "Find a single row matching conditions"
        },
        {
          "label": "get_all (multiple with filters)",
          "description": "Get multiple rows with WHERE, ORDER BY, LIMIT"
        },
        {
          "label": "create (insert)",
          "description": "Insert a new row"
        },
        {
          "label": "update",
          "description": "Update existing rows"
        },
        {
          "label": "delete",
          "description": "Delete rows"
        },
        {
          "label": "count",
          "description": "Count rows matching conditions"
        }
      ]
    },
    {
      "question": "Should the Repository use object caching?",
      "header": "Caching",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended for read-heavy)",
          "description": "Use wp_cache for get() and find() methods"
        },
        {
          "label": "No",
          "description": "Always query database directly"
        }
      ]
    }
  ]
}
```

### Step 3: Process Templates

After collecting information, generate the PHP classes using templates at:
- `@everything-wp/skills/wp-backend/templates/custom-table.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace (e.g., "MyPlugin\\Database") |
| `{{CLASS_NAME}}` | Class name (e.g., "Orders_Table") |
| `{{REPOSITORY_CLASS}}` | Repository class name (e.g., "Orders_Repository") |
| `{{TABLE_NAME}}` | Table name without prefix (e.g., "orders") |
| `{{PLUGIN_PREFIX}}` | Plugin prefix (e.g., "myplugin") |
| `{{TABLE_VERSION}}` | Initial version (e.g., "1.0.0") |
| `{{VERSION_OPTION_NAME}}` | Option name for version (e.g., "myplugin_orders_db_version") |
| `{{COLUMN_DEFINITIONS}}` | Generated column SQL |
| `{{INDEX_DEFINITIONS}}` | Generated index SQL |
| `{{INT_COLUMNS}}` | Array of integer column names |
| `{{FLOAT_COLUMNS}}` | Array of float/decimal column names |
| `{{ALLOWED_COLUMNS}}` | Array of all column names |

### Step 4: Generate Files

Create the following files:

1. **src/Database/{TableName}_Table.php** - Table creation class
2. **src/Repository/{TableName}_Repository.php** - Repository class

### Step 5: Provide Integration Instructions

After generating the classes, provide instructions for:

1. **Hook into plugin activation:**
   ```php
   register_activation_hook( __FILE__, array( 'Namespace\\Database\\Orders_Table', 'create_table' ) );
   ```

2. **Hook into plugins_loaded for version updates:**
   ```php
   add_action( 'plugins_loaded', array( 'Namespace\\Database\\Orders_Table', 'maybe_update_table' ) );
   ```

3. **For multisite, hook into wpmu_new_blog:**
   ```php
   add_action( 'wpmu_new_blog', array( 'Namespace\\Database\\Orders_Table', 'create_table_for_new_site' ) );
   ```

4. **Add to uninstall.php:**
   ```php
   Namespace\Database\Orders_Table::drop_table();
   ```

5. **Using the Repository:**
   ```php
   use Namespace\Repository\Orders_Repository;

   $repository = new Orders_Repository();

   // Create.
   $id = $repository->create( array(
       'user_id' => get_current_user_id(),
       'title'   => 'My Order',
       'status'  => 'pending',
   ) );

   // Read.
   $order = $repository->get( $id );

   // Update.
   $repository->update( $id, array( 'status' => 'completed' ) );

   // Delete.
   $repository->delete( $id );

   // List with filters.
   $orders = $repository->get_all(
       array( 'status' => 'pending' ),
       'created_at',
       'DESC',
       10,
       0
   );
   ```

## dbDelta() Formatting Rules

**CRITICAL**: The generated SQL must follow strict dbDelta() formatting:

1. **TWO spaces after PRIMARY KEY** (not one):
   ```sql
   PRIMARY KEY  (id)
   ```

2. **Space after KEY name before parenthesis**:
   ```sql
   KEY user_id (user_id)
   ```

3. **Each column on its own line**

4. **No trailing comma before closing parenthesis**

## Example Interaction

```
User: /custom-table

Claude: I'll help you create a custom WordPress database table with Repository class.

[Uses AskUserQuestion to ask about table details]

User: [Answers questions]
- Table name: orders
- Plugin prefix: myplugin
- Columns: id, user_id, title, amount, status, created_at, updated_at
- Indexes: user_id, status, created_at
- Version management: Yes
- Multisite support: Yes
- Repository methods: All
- Caching: Yes

Claude: Great! I have all the information needed:

**Table Configuration:**
- Full table name: `wp_myplugin_orders`
- Table class: `MyPlugin\Database\Orders_Table`
- Repository class: `MyPlugin\Repository\Orders_Repository`

**Columns:**
- id (bigint, primary key, auto-increment)
- user_id (bigint, indexed)
- title (varchar 200)
- amount (decimal 10,2)
- status (varchar 20, default 'pending', indexed)
- created_at (datetime, indexed)
- updated_at (datetime with auto-update)

**Features:**
- Version management via wp_options
- Multisite support enabled
- Object caching enabled

Let me generate the classes...

[Creates src/Database/Orders_Table.php]
[Creates src/Repository/Orders_Repository.php]
```

## Requirements

- WordPress 6.0+
- PHP 8.0+
- MySQL 5.7+ or MariaDB 10.3+ (for JSON column support)

## Templates Location

Template files:
```
@everything-wp/skills/wp-backend/templates/custom-table.php.template
```

## Related Commands

- `/init-plugin` - Initialize plugin development environment
- `/list-table` - Create WP_List_Table for displaying data
- `/wp-ajax` - Create AJAX handlers for data operations

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
  - [Custom Tables](@everything-wp/skills/wp-backend/custom-tables.md)
