---
description: Generate WordPress settings page using Settings API with sanitization, nonce verification, and proper menu integration
required_skills:
  - wp-backend
---

# Option Page Command

This command generates a complete WordPress settings page class using the Settings API by collecting page configuration through interactive questions.

## What This Command Does

1. **Collect Page Information** - Ask user for page title, menu location, and fields
2. **Configure Settings** - Set up option group, sections, and field definitions
3. **Generate Settings Class** - Create a class with proper Settings API integration
4. **Provide Integration Instructions** - Show how to hook the class into the plugin

## When to Use

Use `/option-page` when:
- Creating a plugin settings page
- Storing global configuration in wp_options
- Need a single page for API keys, site-wide settings, etc.
- Want to use WordPress Settings API best practices

**Do NOT use for:**
- Per-post or per-user settings (use meta instead)
- Multiple records with CRUD operations (use `/list-table`)
- Settings that need version control (use files)

## How It Works

### Step 1: Collect Page Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Page Title** (e.g., "My Plugin Settings")
2. **Menu Location** (top-level, under Settings, or under another menu)
3. **Option Group Name** (e.g., "myplugin_settings")
4. **Capability** (e.g., "manage_options")

**Field Configuration:**
5. **Field Definitions** (name, type, label, default value)

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (Page Identity):**

```json
{
  "questions": [
    {
      "question": "What is the page title?",
      "header": "Page Title",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter page title",
          "description": "The title shown in the admin page header (e.g., 'My Plugin Settings')"
        }
      ]
    },
    {
      "question": "Where should the settings page appear in the admin menu?",
      "header": "Menu Location",
      "multiSelect": false,
      "options": [
        {
          "label": "Under Settings (Recommended)",
          "description": "Add as submenu under Settings menu (add_options_page)"
        },
        {
          "label": "Top-level menu",
          "description": "Add as a new top-level menu item (add_menu_page)"
        },
        {
          "label": "Under Tools",
          "description": "Add as submenu under Tools menu (add_submenu_page)"
        },
        {
          "label": "Under custom parent",
          "description": "Add under an existing plugin menu"
        }
      ]
    }
  ]
}
```

**Second Question Set (Configuration):**

```json
{
  "questions": [
    {
      "question": "What option group name should be used?",
      "header": "Option Group",
      "multiSelect": false,
      "options": [
        {
          "label": "Auto-generate from plugin prefix (Recommended)",
          "description": "Use {plugin_prefix}_settings as the option group name"
        },
        {
          "label": "Enter custom name",
          "description": "Specify a custom option group name"
        }
      ]
    },
    {
      "question": "What capability is required to access this page?",
      "header": "Capability",
      "multiSelect": false,
      "options": [
        {
          "label": "manage_options (Recommended)",
          "description": "Only administrators can access"
        },
        {
          "label": "edit_posts",
          "description": "Editors and above can access"
        },
        {
          "label": "read",
          "description": "All logged-in users can access"
        },
        {
          "label": "Enter custom capability",
          "description": "Specify a custom capability"
        }
      ]
    }
  ]
}
```

**Third Question Set (Fields):**

```json
{
  "questions": [
    {
      "question": "What types of settings fields do you need?",
      "header": "Field Types",
      "multiSelect": true,
      "options": [
        {
          "label": "Text field",
          "description": "Single line text input for API keys, names, etc."
        },
        {
          "label": "Textarea",
          "description": "Multi-line text input for descriptions, custom code"
        },
        {
          "label": "Checkbox",
          "description": "Boolean on/off toggle"
        },
        {
          "label": "Select dropdown",
          "description": "Dropdown with predefined options"
        },
        {
          "label": "Number field",
          "description": "Numeric input with optional min/max"
        },
        {
          "label": "URL field",
          "description": "URL input with validation"
        },
        {
          "label": "Email field",
          "description": "Email input with validation"
        },
        {
          "label": "Color picker",
          "description": "Color selection with preview"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate the PHP class using the template at:
`@everything-wp/skills/wp-backend/templates/option-page.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | Class name (e.g., "Settings_Page") |
| `{{PAGE_TITLE}}` | Page title |
| `{{MENU_TITLE}}` | Menu title |
| `{{MENU_SLUG}}` | Menu slug |
| `{{CAPABILITY}}` | Required capability |
| `{{OPTION_GROUP}}` | Option group name |
| `{{OPTION_NAME}}` | Option name in wp_options |
| `{{TEXT_DOMAIN}}` | Text domain for translations |
| `{{PLUGIN_PREFIX}}` | Plugin prefix |
| `{{FIELD_DEFINITIONS}}` | Generated field registration code |
| `{{FIELD_CALLBACKS}}` | Generated field callback methods |
| `{{SANITIZE_CALLBACK}}` | Sanitization method |

### Step 4: Generate Files

Create the following file:

1. **src/Admin/{Name}_Settings.php** - Settings page class

### Step 5: Provide Integration Instructions

After generating the class, provide instructions for:

1. **Initialize the settings page:**
   ```php
   add_action( 'admin_menu', array( 'Namespace\\Admin\\Settings_Page', 'add_menu' ) );
   add_action( 'admin_init', array( 'Namespace\\Admin\\Settings_Page', 'register_settings' ) );
   ```

2. **Get option values:**
   ```php
   $options = get_option( 'myplugin_settings', array() );
   $api_key = isset( $options['api_key'] ) ? $options['api_key'] : '';
   ```

## Example Interaction

```
User: /option-page

Claude: I'll help you create a WordPress settings page.

[Uses AskUserQuestion to ask about page details]

User: [Answers questions]
- Page title: My Plugin Settings
- Menu location: Under Settings
- Option group: myplugin_settings
- Capability: manage_options
- Fields: text (API Key), checkbox (Enable Feature), select (Mode)

Claude: Great! I have all the information needed:

**Page Configuration:**
- Title: My Plugin Settings
- Menu: Settings > My Plugin
- Slug: myplugin-settings
- Capability: manage_options

**Fields:**
- api_key (text) - API Key
- enable_feature (checkbox) - Enable Feature
- mode (select) - Mode [basic, advanced]

Let me generate the settings class...

[Creates src/Admin/Settings_Page.php]
```

## Generated Class Features

The generated class includes:

1. **`add_menu()`** - Registers the menu page
2. **`register_settings()`** - Registers settings with Settings API
3. **`render_page()`** - Renders the settings page HTML
4. **`render_{field}_field()`** - Individual field render callbacks
5. **`sanitize_settings()`** - Sanitization callback for all fields
6. **`enqueue_assets()`** - Enqueues required scripts (color picker, etc.)

## Requirements

- WordPress 6.0+
- PHP 8.0+

## Templates Location

Template file:
```
@everything-wp/skills/wp-backend/templates/option-page.php.template
```

## Related Commands

- `/init-plugin` - Initialize plugin development environment
- `/custom-table` - Create custom table for complex data storage
- `/list-table` - Create admin list table for multiple records

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
