---
description: Generate WordPress REST API controller with authentication, parameter validation, and proper response formatting
required_skills:
  - wp-backend
---

# REST API Command

This command generates a complete WordPress REST API controller for creating public endpoints by collecting API configuration through interactive questions.

## What This Command Does

1. **Collect API Information** - Ask user for namespace, routes, and methods
2. **Configure Authentication** - Set up permission callbacks
3. **Generate Controller Class** - Create a class extending WP_REST_Controller
4. **Provide Integration Instructions** - Show how to register and use the API

## When to Use

Use `/rest-api` when:
- Building headless/decoupled WordPress sites
- Creating public APIs for mobile apps
- Exposing data to external services
- Building JavaScript-heavy frontend applications

**Do NOT use for:**
- Internal WordPress admin AJAX (use `/wp-ajax`)
- External third-party API integration (use `/api-wrapper`)
- Simple form submissions

## How It Works

### Step 1: Collect API Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **Namespace** (e.g., "myplugin/v1")
2. **Resource Name** (e.g., "orders", "products")
3. **Endpoints** (routes and HTTP methods)
4. **Authentication** (public, logged-in, custom)

**Schema Options:**
5. **Request Parameters** (with validation)
6. **Response Schema** (data structure)

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (API Identity):**

```json
{
  "questions": [
    {
      "question": "What is the REST API namespace?",
      "header": "Namespace",
      "multiSelect": false,
      "options": [
        {
          "label": "Auto-generate from plugin (Recommended)",
          "description": "Use {plugin_slug}/v1 as the namespace"
        },
        {
          "label": "Enter custom namespace",
          "description": "Specify a custom namespace (e.g., 'myapp/v1')"
        }
      ]
    },
    {
      "question": "What is the resource name for the routes?",
      "header": "Resource",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter resource name",
          "description": "The resource name in plural (e.g., 'orders', 'products', 'items')"
        }
      ]
    }
  ]
}
```

**Second Question Set (Endpoints):**

```json
{
  "questions": [
    {
      "question": "What endpoints do you need?",
      "header": "Endpoints",
      "multiSelect": true,
      "options": [
        {
          "label": "GET /items - List all items",
          "description": "Get collection of items with pagination"
        },
        {
          "label": "GET /items/{id} - Get single item",
          "description": "Get a single item by ID"
        },
        {
          "label": "POST /items - Create item",
          "description": "Create a new item"
        },
        {
          "label": "PUT /items/{id} - Update item",
          "description": "Update an existing item (full replacement)"
        },
        {
          "label": "PATCH /items/{id} - Partial update",
          "description": "Partially update an existing item"
        },
        {
          "label": "DELETE /items/{id} - Delete item",
          "description": "Delete an existing item"
        }
      ]
    }
  ]
}
```

**Third Question Set (Authentication):**

```json
{
  "questions": [
    {
      "question": "What authentication is required for read operations (GET)?",
      "header": "Read Auth",
      "multiSelect": false,
      "options": [
        {
          "label": "Public - no authentication",
          "description": "Anyone can read data"
        },
        {
          "label": "Logged-in users only",
          "description": "Require WordPress login"
        },
        {
          "label": "Specific capability",
          "description": "Require specific capability (e.g., edit_posts)"
        }
      ]
    },
    {
      "question": "What authentication is required for write operations (POST/PUT/DELETE)?",
      "header": "Write Auth",
      "multiSelect": false,
      "options": [
        {
          "label": "Logged-in with edit capability (Recommended)",
          "description": "Require login and edit_posts capability"
        },
        {
          "label": "Admin only",
          "description": "Require manage_options capability"
        },
        {
          "label": "Custom capability",
          "description": "Specify a custom capability"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate the PHP class using the template at:
`@everything-wp/skills/wp-backend/templates/rest-controller.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | Controller class name |
| `{{REST_NAMESPACE}}` | REST API namespace (e.g., "myplugin/v1") |
| `{{REST_BASE}}` | Resource base (e.g., "orders") |
| `{{REPOSITORY_CLASS}}` | Repository class for data |
| `{{READ_PERMISSION}}` | Read permission callback |
| `{{WRITE_PERMISSION}}` | Write permission callback |

### Step 4: Generate Files

Create the following file:

1. **src/Api/{Resource}_Rest_Controller.php** - REST controller class

### Step 5: Provide Integration Instructions

After generating the class, provide instructions for:

1. **Register the REST routes:**
   ```php
   add_action( 'rest_api_init', function() {
       $controller = new Namespace\Api\Orders_Rest_Controller();
       $controller->register_routes();
   } );
   ```

2. **Test endpoints:**
   ```bash
   # List items.
   curl https://example.com/wp-json/myplugin/v1/orders

   # Get single item.
   curl https://example.com/wp-json/myplugin/v1/orders/1

   # Create item (with authentication).
   curl -X POST https://example.com/wp-json/myplugin/v1/orders \
     -H "X-WP-Nonce: {nonce}" \
     -d '{"title":"New Order"}'
   ```

3. **JavaScript fetch example:**
   ```javascript
   // Using wp.apiFetch (recommended for authenticated requests).
   wp.apiFetch({
       path: '/myplugin/v1/orders',
       method: 'POST',
       data: { title: 'New Order' }
   }).then(response => console.log(response));
   ```

## Example Interaction

```
User: /rest-api

Claude: I'll help you create a WordPress REST API controller.

[Uses AskUserQuestion to ask about API details]

User: [Answers questions]
- Namespace: myplugin/v1
- Resource: orders
- Endpoints: GET list, GET single, POST create, PUT update, DELETE
- Read auth: Public
- Write auth: Logged-in with edit capability

Claude: Great! I have all the information needed:

**REST API Configuration:**
- Namespace: myplugin/v1
- Base: /orders
- Controller: `MyPlugin\Api\Orders_Rest_Controller`

**Endpoints:**
- GET /orders - List orders (public)
- GET /orders/{id} - Get order (public)
- POST /orders - Create order (authenticated)
- PUT /orders/{id} - Update order (authenticated)
- DELETE /orders/{id} - Delete order (authenticated)

Let me generate the controller class...

[Creates src/Api/Orders_Rest_Controller.php]
```

## Generated Class Features

The generated class includes:

1. **`register_routes()`** - Register all REST routes
2. **`get_items()`** - GET collection handler
3. **`get_item()`** - GET single item handler
4. **`create_item()`** - POST create handler
5. **`update_item()`** - PUT/PATCH update handler
6. **`delete_item()`** - DELETE handler
7. **`get_items_permissions_check()`** - Read permission
8. **`create_item_permissions_check()`** - Write permission
9. **`get_item_schema()`** - Response schema
10. **`prepare_item_for_response()`** - Format response
11. **`prepare_item_for_database()`** - Prepare data for save

## Requirements

- WordPress 6.0+
- PHP 8.0+

## Templates Location

Template file:
```
@everything-wp/skills/wp-backend/templates/rest-controller.php.template
```

## Related Commands

- `/custom-table` - Create data storage for API
- `/wp-ajax` - Create internal AJAX handlers
- `/api-wrapper` - Integrate external APIs

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
