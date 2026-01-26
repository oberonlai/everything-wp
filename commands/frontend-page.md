---
description: Generate frontend page implementation using Shortcode, Gutenberg Block, or Page Template with forms, AJAX, and proper asset loading
required_skills:
  - wp-frontend
  - wp-backend
---

# Frontend Page Command

This command generates a complete frontend page implementation for user-facing features by collecting page configuration through interactive questions.

## What This Command Does

1. **Collect Page Information** - Ask user for page name and implementation type
2. **Configure Features** - Set up forms, AJAX, login requirements
3. **Generate PHP Class** - Create Shortcode, Block, or Template class
4. **Generate Assets** - Create CSS and JavaScript files
5. **Provide Integration Instructions** - Show how to use the frontend page

## When to Use

Use `/frontend-page` when:
- Creating user-facing forms (contact, registration, etc.)
- Building interactive frontend features
- Displaying custom data to site visitors
- Creating member-only pages

**Do NOT use for:**
- Admin-only features (use `/list-table` or `/option-page`)
- API endpoints (use `/rest-api`)
- Backend data processing (use `/wp-ajax`)

## How It Works

### Step 1: Collect Page Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Page Name** (e.g., "Contact Form", "Member Dashboard")
2. **Implementation Type** (Shortcode, Block, or Template)
3. **Features** (form, AJAX, login required)
4. **Assets** (CSS, JavaScript requirements)

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (Page Identity):**

```json
{
  "questions": [
    {
      "question": "What is the page/feature name?",
      "header": "Page Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter page name",
          "description": "The feature name (e.g., 'Contact Form', 'Member Dashboard', 'Product Listing')"
        }
      ]
    },
    {
      "question": "How should this page be implemented?",
      "header": "Implementation",
      "multiSelect": false,
      "options": [
        {
          "label": "Shortcode (Recommended)",
          "description": "Create a shortcode [myplugin_feature] that can be added to any page"
        },
        {
          "label": "Gutenberg Block",
          "description": "Create a custom Gutenberg block for the block editor"
        },
        {
          "label": "Page Template",
          "description": "Create a custom page template that can be selected in page attributes"
        }
      ]
    }
  ]
}
```

**Second Question Set (Features):**

```json
{
  "questions": [
    {
      "question": "What features does this page need?",
      "header": "Features",
      "multiSelect": true,
      "options": [
        {
          "label": "Form with fields",
          "description": "Include a form with input fields"
        },
        {
          "label": "AJAX submission",
          "description": "Submit form or load data via AJAX without page refresh"
        },
        {
          "label": "Login required",
          "description": "Only logged-in users can access this page"
        },
        {
          "label": "Pagination",
          "description": "Display paginated list of items"
        },
        {
          "label": "Search/Filter",
          "description": "Include search or filter functionality"
        }
      ]
    }
  ]
}
```

**Third Question Set (Assets):**

```json
{
  "questions": [
    {
      "question": "What assets does this page need?",
      "header": "Assets",
      "multiSelect": true,
      "options": [
        {
          "label": "Custom CSS",
          "description": "Create dedicated CSS file for styling"
        },
        {
          "label": "Custom JavaScript",
          "description": "Create dedicated JavaScript file for interactivity"
        },
        {
          "label": "jQuery dependency",
          "description": "Require jQuery for JavaScript functionality"
        },
        {
          "label": "No additional assets",
          "description": "Use only inline styles and scripts"
        }
      ]
    }
  ]
}
```

**Fourth Question Set (Form Fields - if form selected):**

```json
{
  "questions": [
    {
      "question": "What form fields do you need?",
      "header": "Form Fields",
      "multiSelect": true,
      "options": [
        {
          "label": "Text input",
          "description": "Single line text field (name, title, etc.)"
        },
        {
          "label": "Email input",
          "description": "Email field with validation"
        },
        {
          "label": "Textarea",
          "description": "Multi-line text field (message, description)"
        },
        {
          "label": "Select dropdown",
          "description": "Dropdown selection field"
        },
        {
          "label": "Checkbox",
          "description": "Single checkbox or checkbox group"
        },
        {
          "label": "File upload",
          "description": "File upload field"
        },
        {
          "label": "Hidden fields",
          "description": "Hidden fields for data passing"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate files using the template at:
`@everything-wp/skills/wp-frontend/templates/frontend-page.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | Class name |
| `{{SHORTCODE_TAG}}` | Shortcode tag (e.g., "myplugin_contact") |
| `{{PLUGIN_PREFIX}}` | Plugin prefix |
| `{{TEXT_DOMAIN}}` | Text domain |
| `{{NONCE_ACTION}}` | Nonce action for forms |
| `{{FORM_FIELDS}}` | Generated form HTML |
| `{{AJAX_ACTION}}` | AJAX action name |

### Step 4: Generate Files

Create the following files:

**For Shortcode:**
1. **src/Frontend/{Name}_Shortcode.php** - Shortcode class
2. **assets/css/{name}.css** - Styles (optional)
3. **assets/js/{name}.js** - Scripts (optional)

**For Gutenberg Block:**
1. **src/Blocks/{Name}/index.php** - Block registration
2. **src/Blocks/{Name}/block.json** - Block metadata
3. **src/Blocks/{Name}/edit.js** - Editor component
4. **src/Blocks/{Name}/render.php** - Frontend render
5. **src/Blocks/{Name}/style.css** - Block styles

**For Page Template:**
1. **templates/{name}-template.php** - Page template
2. **src/Frontend/{Name}_Template.php** - Template logic class

### Step 5: Provide Integration Instructions

After generating the files, provide instructions for:

1. **For Shortcode:**
   ```php
   // Register shortcode.
   add_shortcode( 'myplugin_contact', array( 'Namespace\\Frontend\\Contact_Shortcode', 'render' ) );

   // Use in content.
   [myplugin_contact]

   // With attributes.
   [myplugin_contact title="Contact Us" show_phone="true"]
   ```

2. **For Gutenberg Block:**
   ```php
   // Register block.
   add_action( 'init', function() {
       register_block_type( __DIR__ . '/src/Blocks/Contact' );
   } );
   ```

3. **For Page Template:**
   ```php
   // Register template.
   add_filter( 'theme_page_templates', function( $templates ) {
       $templates['myplugin-contact'] = __( 'Contact Page', 'myplugin' );
       return $templates;
   } );
   ```

## Example Interaction

```
User: /frontend-page

Claude: I'll help you create a frontend page for your plugin.

[Uses AskUserQuestion to ask about page details]

User: [Answers questions]
- Page name: Contact Form
- Implementation: Shortcode
- Features: Form, AJAX submission
- Assets: Custom CSS, Custom JavaScript, jQuery
- Form fields: Text (name), Email, Textarea (message), Checkbox (newsletter)

Claude: Great! I have all the information needed:

**Page Configuration:**
- Shortcode: [myplugin_contact]
- Class: `MyPlugin\Frontend\Contact_Shortcode`

**Features:**
- Contact form with 4 fields
- AJAX submission (no page refresh)
- Success/error message display

**Assets:**
- assets/css/contact-form.css
- assets/js/contact-form.js

Let me generate the files...

[Creates src/Frontend/Contact_Shortcode.php]
[Creates assets/css/contact-form.css]
[Creates assets/js/contact-form.js]
```

## Generated Class Features

The generated shortcode class includes:

1. **`render()`** - Main render method
2. **`enqueue_assets()`** - Conditional asset loading
3. **`render_form()`** - Form HTML generation
4. **`get_default_attributes()`** - Shortcode attribute defaults
5. **Login check** - If login required
6. **Nonce field** - CSRF protection
7. **Form validation** - Frontend and backend

## Mock Data Development

The template supports mock data mode for frontend development:

```php
// In development, use mock data.
if ( defined( 'WP_DEBUG' ) && WP_DEBUG ) {
    $items = self::get_mock_data();
} else {
    $items = $repository->get_all();
}
```

## Requirements

- WordPress 6.0+
- PHP 8.0+
- For Gutenberg blocks: Node.js and npm

## Templates Location

Template file:
```
@everything-wp/skills/wp-frontend/templates/frontend-page.php.template
```

## Related Commands

- `/wp-ajax` - Create AJAX handlers for form submission
- `/custom-table` - Create data storage for form submissions
- `/option-page` - Create settings for frontend features

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
- `wp-frontend` - WordPress frontend development standards
  - [CSS Coding Standards](@everything-wp/skills/wp-frontend/coding-standards/css.md)
  - [JavaScript Coding Standards](@everything-wp/skills/wp-frontend/coding-standards/js.md)
  - [HTML Coding Standards](@everything-wp/skills/wp-frontend/coding-standards/html.md)
