---
description: Generate WP_List_Table class for displaying data records with sorting, pagination, bulk actions, and search functionality
required_skills:
  - wp-backend
---

# List Table Command

This command generates a complete WP_List_Table implementation for displaying data records in the WordPress admin by collecting table configuration through interactive questions.

## What This Command Does

1. **Collect Table Information** - Ask user for table name, columns, and features
2. **Configure Features** - Set up sorting, pagination, bulk actions, and search
3. **Generate List Table Class** - Create a class extending WP_List_Table
4. **Generate Edit Page** (optional) - Create add/edit form page
5. **Register Admin Menu** - Create menu registration class
6. **Provide Integration Instructions** - Show how to display the table

## When to Use

Use `/list-table` when:
- Displaying multiple records in WordPress admin
- Need sorting, pagination, and search functionality
- Want consistent WordPress admin UI
- Managing custom table data or custom post types

**Do NOT use for:**
- Single settings page (use `/option-page`)
- Frontend data display (use `/frontend-page`)
- Simple data without admin UI

## How It Works

### Step 1: Collect Table Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Table Name** (e.g., "Orders", "Transactions")
2. **Data Source** (Repository class or custom query)
3. **Columns** (column key => column label)
4. **Sortable Columns** (which columns can be sorted)

**Feature Options:**
5. **Bulk Actions** (delete, export, change status)
6. **Search** (enable search box)
7. **Filters** (status filters, date filters)
8. **Edit Page** (create add/edit form)

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (Table Identity):**

```json
{
  "questions": [
    {
      "question": "What is the list table name? (e.g., 'Orders', 'Transactions')",
      "header": "Table Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter table name",
          "description": "The name used in page title and class name"
        }
      ]
    },
    {
      "question": "What is the data source?",
      "header": "Data Source",
      "multiSelect": false,
      "options": [
        {
          "label": "Repository class (Recommended)",
          "description": "Use a Repository class created with /custom-table"
        },
        {
          "label": "Custom post type",
          "description": "Display posts from a custom post type"
        },
        {
          "label": "Custom query",
          "description": "Write custom database query"
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
      "question": "What columns should be displayed?",
      "header": "Columns",
      "multiSelect": true,
      "options": [
        {
          "label": "ID",
          "description": "Primary key column"
        },
        {
          "label": "Title/Name",
          "description": "Main title column with row actions"
        },
        {
          "label": "Author/User",
          "description": "User who created the record"
        },
        {
          "label": "Status",
          "description": "Record status (pending, active, etc.)"
        },
        {
          "label": "Date",
          "description": "Creation or modification date"
        },
        {
          "label": "Amount/Count",
          "description": "Numeric value column"
        }
      ]
    },
    {
      "question": "Which columns should be sortable?",
      "header": "Sortable",
      "multiSelect": true,
      "options": [
        {
          "label": "ID",
          "description": "Sort by ID"
        },
        {
          "label": "Title/Name",
          "description": "Sort alphabetically"
        },
        {
          "label": "Date",
          "description": "Sort by date"
        },
        {
          "label": "Amount/Count",
          "description": "Sort by numeric value"
        }
      ]
    }
  ]
}
```

**Third Question Set (Features):**

```json
{
  "questions": [
    {
      "question": "What bulk actions do you need?",
      "header": "Bulk Actions",
      "multiSelect": true,
      "options": [
        {
          "label": "Delete",
          "description": "Bulk delete selected items"
        },
        {
          "label": "Change Status",
          "description": "Change status of selected items"
        },
        {
          "label": "Export",
          "description": "Export selected items to CSV"
        },
        {
          "label": "None",
          "description": "No bulk actions"
        }
      ]
    },
    {
      "question": "What additional features do you need?",
      "header": "Features",
      "multiSelect": true,
      "options": [
        {
          "label": "Search box (Recommended)",
          "description": "Add search functionality"
        },
        {
          "label": "Status filters",
          "description": "Filter by status (All | Pending | Active)"
        },
        {
          "label": "Date filter",
          "description": "Filter by date range"
        },
        {
          "label": "Add/Edit page",
          "description": "Generate edit form page"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate the PHP classes using templates at:
- `@everything-wp/skills/wp-backend/templates/list-table.php.template`
- `@everything-wp/skills/wp-backend/templates/edit-page.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | List table class name |
| `{{SINGULAR}}` | Singular name (e.g., "order") |
| `{{PLURAL}}` | Plural name (e.g., "orders") |
| `{{REPOSITORY_CLASS}}` | Repository class for data |
| `{{COLUMNS}}` | Column definitions |
| `{{SORTABLE_COLUMNS}}` | Sortable column definitions |
| `{{BULK_ACTIONS}}` | Bulk action definitions |

### Step 4: Generate Files

Create the following files:

1. **src/Admin/{Name}_List_Table.php** - List table class
2. **src/Admin/{Name}_Edit_Page.php** - Edit form page (optional)
3. **src/Admin/Menu.php** - Menu registration class

### Step 5: Register Admin Menu

After generating the list table class, create the admin menu to display it:

1. **Create menu registration file** (if not exists):
   - File: `src/Admin/Menu.php`
   - Register the menu using `add_menu_page()` or `add_submenu_page()`

2. **Menu registration code:**
   ```php
   <?php
   namespace {{NAMESPACE}}\Admin;

   class Menu {
       public static function register() {
           add_action( 'admin_menu', [ __CLASS__, 'add_menu_pages' ] );
       }

       public static function add_menu_pages() {
           add_menu_page(
               __( '{{PLURAL}}', 'text-domain' ),        // Page title
               __( '{{PLURAL}}', 'text-domain' ),        // Menu title
               'manage_options',                          // Capability
               '{{MENU_SLUG}}',                          // Menu slug
               [ '{{NAMESPACE}}\Admin\{{CLASS_NAME}}', 'render_page' ],  // Callback
               'dashicons-list-view',                     // Icon
               30                                         // Position
           );

           // If edit page is generated, add submenu
           if ( class_exists( '{{NAMESPACE}}\Admin\{{EDIT_CLASS_NAME}}' ) ) {
               add_submenu_page(
                   '{{MENU_SLUG}}',                      // Parent slug
                   __( 'Add New', 'text-domain' ),       // Page title
                   __( 'Add New', 'text-domain' ),       // Menu title
                   'manage_options',                      // Capability
                   '{{MENU_SLUG}}-add',                  // Menu slug
                   [ '{{NAMESPACE}}\Admin\{{EDIT_CLASS_NAME}}', 'render_page' ]
               );
           }
       }
   }
   ```

3. **Initialize menu in main plugin file or Bootstrap:**
   ```php
   {{NAMESPACE}}\Admin\Menu::register();
   ```

### Step 6: Provide Integration Instructions

After generating the classes and menu, provide instructions for:

1. **Register menu and display table:**
   ```php
   add_action( 'admin_menu', function() {
       add_menu_page(
           __( 'Orders', 'myplugin' ),
           __( 'Orders', 'myplugin' ),
           'manage_options',
           'myplugin-orders',
           array( 'Namespace\\Admin\\Orders_List_Table', 'render_page' ),
           'dashicons-list-view',
           30
       );
   } );
   ```

2. **Load table class before headers:**
   ```php
   add_action( 'admin_init', function() {
       if ( isset( $_GET['page'] ) && 'myplugin-orders' === $_GET['page'] ) {
           require_once plugin_dir_path( __FILE__ ) . 'src/Admin/Orders_List_Table.php';
       }
   } );
   ```

## Example Interaction

```
User: /list-table

Claude: I'll help you create a WP_List_Table for displaying records.

[Uses AskUserQuestion to ask about table details]

User: [Answers questions]
- Table name: Orders
- Data source: Repository class (Orders_Repository)
- Columns: ID, Title, User, Status, Amount, Date
- Sortable: ID, Date, Amount
- Bulk actions: Delete, Change Status
- Features: Search, Status filters, Edit page

Claude: Great! I have all the information needed:

**List Table Configuration:**
- Class: `MyPlugin\Admin\Orders_List_Table`
- Menu: Top-level "Orders" menu
- Columns: 6 columns with 3 sortable

**Features:**
- Search functionality
- Status filters (All | Pending | Active | Completed)
- Bulk delete and status change
- Add/Edit page

Let me generate the classes...

[Creates src/Admin/Orders_List_Table.php]
[Creates src/Admin/Orders_Edit_Page.php]
```

## Generated Class Features

The list table class includes:

1. **`get_columns()`** - Define table columns
2. **`get_sortable_columns()`** - Define sortable columns
3. **`prepare_items()`** - Fetch and prepare data
4. **`column_default()`** - Default column rendering
5. **`column_{name}()`** - Custom column rendering
6. **`get_bulk_actions()`** - Define bulk actions
7. **`process_bulk_action()`** - Handle bulk actions
8. **`get_views()`** - Status filter tabs
9. **`search_box()`** - Search functionality
10. **Row actions** (Edit, Delete, View)

## Requirements

- WordPress 6.0+
- PHP 8.0+

## Templates Location

Template files:
```
@everything-wp/skills/wp-backend/templates/list-table.php.template
@everything-wp/skills/wp-backend/templates/edit-page.php.template
```

## Related Commands

- `/custom-table` - Create custom table and Repository for data
- `/option-page` - Create settings page
- `/wp-ajax` - Create AJAX handlers for inline editing

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
