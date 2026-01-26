---
description: Generate WordPress AJAX handler class with nonce verification, permission checks, and proper parameter sanitization
required_skills:
  - wp-backend
---

# WP AJAX Command

This command generates a complete WordPress AJAX handler class for internal frontend-backend communication by collecting handler configuration through interactive questions.

## What This Command Does

1. **Collect Handler Information** - Ask user for action name and parameters
2. **Configure Security** - Set up nonce verification and permission checks
3. **Generate AJAX Class** - Create a class with proper WordPress AJAX integration
4. **Generate JavaScript** - Provide JavaScript example code
5. **Provide Integration Instructions** - Show how to hook and use the handler

## When to Use

Use `/wp-ajax` when:
- Building frontend forms that submit via AJAX
- Creating admin panel interactions
- Need real-time data updates without page refresh
- Internal WordPress site communication

**Do NOT use for:**
- External API integrations (use `/api-wrapper`)
- Headless/decoupled sites (use `/rest-api`)
- Public APIs consumed by external services

## How It Works

### Step 1: Collect Handler Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Action Name** (e.g., "submit_form", "load_items")
2. **Authentication** (logged-in only, or public)
3. **Request Parameters** (name, type, required)
4. **Response Format** (success/error data structure)

**Security Options:**
5. **Nonce Action** (for CSRF protection)
6. **Required Capability** (for permission check)

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (Handler Identity):**

```json
{
  "questions": [
    {
      "question": "What is the AJAX action name? (without 'wp_ajax_' prefix)",
      "header": "Action Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter action name",
          "description": "The action name (e.g., 'submit_form', 'load_items', 'save_settings')"
        }
      ]
    },
    {
      "question": "Who can access this AJAX endpoint?",
      "header": "Authentication",
      "multiSelect": false,
      "options": [
        {
          "label": "Logged-in users only (Recommended)",
          "description": "Register with wp_ajax_{action} only"
        },
        {
          "label": "Both logged-in and guests",
          "description": "Register with both wp_ajax_{action} and wp_ajax_nopriv_{action}"
        },
        {
          "label": "Guests only",
          "description": "Register with wp_ajax_nopriv_{action} only"
        }
      ]
    }
  ]
}
```

**Second Question Set (Security):**

```json
{
  "questions": [
    {
      "question": "What capability is required? (for logged-in users)",
      "header": "Capability",
      "multiSelect": false,
      "options": [
        {
          "label": "None - any logged-in user",
          "description": "Only check if user is logged in"
        },
        {
          "label": "edit_posts",
          "description": "Authors and above"
        },
        {
          "label": "manage_options",
          "description": "Administrators only"
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

**Third Question Set (Parameters):**

```json
{
  "questions": [
    {
      "question": "What parameters will this handler receive?",
      "header": "Parameters",
      "multiSelect": true,
      "options": [
        {
          "label": "ID (integer)",
          "description": "Record ID parameter"
        },
        {
          "label": "Title/Name (string)",
          "description": "Text input parameter"
        },
        {
          "label": "Content (HTML)",
          "description": "Rich text content parameter"
        },
        {
          "label": "Email",
          "description": "Email address parameter"
        },
        {
          "label": "URL",
          "description": "URL parameter"
        },
        {
          "label": "Status (select)",
          "description": "Status selection parameter"
        },
        {
          "label": "Checkbox (boolean)",
          "description": "Boolean checkbox parameter"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate the PHP class using the template at:
`@everything-wp/skills/wp-backend/templates/ajax-handler.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | Class name (e.g., "Submit_Form_Ajax") |
| `{{ACTION_NAME}}` | AJAX action name |
| `{{NONCE_ACTION}}` | Nonce action string |
| `{{CAPABILITY}}` | Required capability |
| `{{PLUGIN_PREFIX}}` | Plugin prefix |
| `{{TEXT_DOMAIN}}` | Text domain |
| `{{PARAMETER_SANITIZATION}}` | Parameter sanitization code |

### Step 4: Generate Files

Create the following file:

1. **src/Ajax/{ActionName}_Ajax.php** - AJAX handler class

### Step 5: Provide Integration Instructions

After generating the class, provide instructions for:

1. **Register the AJAX hooks:**
   ```php
   add_action( 'wp_ajax_myplugin_submit_form', array( 'Namespace\\Ajax\\Submit_Form_Ajax', 'handle' ) );
   add_action( 'wp_ajax_nopriv_myplugin_submit_form', array( 'Namespace\\Ajax\\Submit_Form_Ajax', 'handle' ) );
   ```

2. **Enqueue scripts with localized data:**
   ```php
   wp_enqueue_script( 'myplugin-frontend', ... );
   wp_localize_script( 'myplugin-frontend', 'myplugin_ajax', array(
       'ajax_url' => admin_url( 'admin-ajax.php' ),
       'nonce'    => wp_create_nonce( 'myplugin_submit_form_nonce' ),
   ) );
   ```

3. **JavaScript AJAX call:**
   ```javascript
   jQuery.ajax({
       url: myplugin_ajax.ajax_url,
       type: 'POST',
       data: {
           action: 'myplugin_submit_form',
           nonce: myplugin_ajax.nonce,
           title: jQuery('#title').val()
       },
       success: function(response) {
           if (response.success) {
               console.log(response.data);
           } else {
               console.error(response.data);
           }
       }
   });
   ```

## Example Interaction

```
User: /wp-ajax

Claude: I'll help you create a WordPress AJAX handler.

[Uses AskUserQuestion to ask about handler details]

User: [Answers questions]
- Action name: submit_contact_form
- Authentication: Both logged-in and guests
- Capability: None
- Parameters: name (string), email, message (HTML)

Claude: Great! I have all the information needed:

**AJAX Configuration:**
- Action: myplugin_submit_contact_form
- Class: `MyPlugin\Ajax\Submit_Contact_Form_Ajax`
- Access: Public (guests allowed)

**Parameters:**
- name (sanitize_text_field)
- email (sanitize_email)
- message (wp_kses_post)

**Security:**
- Nonce verification
- No capability check (public form)

Let me generate the handler class...

[Creates src/Ajax/Submit_Contact_Form_Ajax.php]
```

## Generated Class Features

The generated class includes:

1. **`handle()`** - Main handler method
2. **`verify_nonce()`** - Nonce verification
3. **`check_permissions()`** - Capability check
4. **`get_parameters()`** - Parameter extraction and sanitization
5. **`validate()`** - Parameter validation
6. **`process()`** - Business logic
7. **`send_success()`** - Success response
8. **`send_error()`** - Error response

## Parameter Sanitization

Parameters are sanitized according to type:

| Type | Sanitization Function |
|------|----------------------|
| integer | `absint()` |
| string | `sanitize_text_field( wp_unslash() )` |
| HTML | `wp_kses_post( wp_unslash() )` |
| email | `sanitize_email()` |
| URL | `esc_url_raw()` |
| boolean | `(bool)` |

**IMPORTANT**: Always use the pattern:
```php
$param = ( isset( $_POST['param'] ) ) ? sanitize_text_field( wp_unslash( $_POST['param'] ) ) : '';
```

## Requirements

- WordPress 6.0+
- PHP 8.0+

## Templates Location

Template file:
```
@everything-wp/skills/wp-backend/templates/ajax-handler.php.template
```

## Related Commands

- `/frontend-page` - Create frontend forms that use AJAX
- `/rest-api` - Create REST API for external access
- `/custom-table` - Create data storage for AJAX operations

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
