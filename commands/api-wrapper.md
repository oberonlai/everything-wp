---
description: Generate external API wrapper class with authentication, error handling, retry mechanism, and logging support
required_skills:
  - wp-backend
---

# API Wrapper Command

This command generates a complete external API wrapper class for integrating with third-party services by collecting API configuration through interactive questions.

## What This Command Does

1. **Collect API Information** - Ask user for API name, base URL, and authentication
2. **Configure Endpoints** - Set up main API endpoints and their methods
3. **Generate Wrapper Class** - Create a class with proper HTTP handling
4. **Provide Integration Instructions** - Show how to use the wrapper in the plugin

## When to Use

Use `/api-wrapper` when:
- Integrating with third-party APIs (payment gateways, shipping, etc.)
- Need centralized API request handling
- Want consistent error handling and logging
- Need retry mechanism for unreliable APIs

**Do NOT use for:**
- Internal WordPress AJAX (use `/wp-ajax`)
- REST API endpoints for your plugin (use `/rest-api`)
- Simple one-off HTTP requests

## How It Works

### Step 1: Collect API Information

Use the AskUserQuestion tool to gather the following information:

**Required Information:**
1. **API Name** (e.g., "Stripe", "PayPal", "Shippo")
2. **Base URL** (e.g., "https://api.stripe.com/v1")
3. **Authentication Method** (API Key, OAuth, Basic Auth)
4. **Main Endpoints** (method, path, description)

**Configuration Options:**
5. **Error Handling** - Custom error messages and logging
6. **Retry Mechanism** - Automatic retry for failed requests
7. **Logging** - Debug logging for development

### Step 2: Questions to Ask

Use the AskUserQuestion tool with the following structure:

**First Question Set (API Identity):**

```json
{
  "questions": [
    {
      "question": "What is the API name?",
      "header": "API Name",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter API name",
          "description": "The service name (e.g., 'Stripe', 'PayPal', 'Custom API')"
        }
      ]
    },
    {
      "question": "What is the API base URL?",
      "header": "Base URL",
      "multiSelect": false,
      "options": [
        {
          "label": "Enter base URL",
          "description": "The API base URL (e.g., 'https://api.example.com/v1')"
        }
      ]
    }
  ]
}
```

**Second Question Set (Authentication):**

```json
{
  "questions": [
    {
      "question": "What authentication method does the API use?",
      "header": "Auth Method",
      "multiSelect": false,
      "options": [
        {
          "label": "API Key in Header (Recommended)",
          "description": "Send API key in Authorization header (Bearer token or custom header)"
        },
        {
          "label": "API Key in Query String",
          "description": "Send API key as URL parameter"
        },
        {
          "label": "Basic Auth",
          "description": "HTTP Basic Authentication (username:password)"
        },
        {
          "label": "OAuth 2.0",
          "description": "OAuth 2.0 with access token refresh"
        },
        {
          "label": "No Authentication",
          "description": "Public API without authentication"
        }
      ]
    }
  ]
}
```

**Third Question Set (Configuration):**

```json
{
  "questions": [
    {
      "question": "Should the wrapper include retry mechanism?",
      "header": "Retry",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Automatically retry failed requests up to 3 times"
        },
        {
          "label": "No",
          "description": "Fail immediately on error"
        }
      ]
    },
    {
      "question": "Should the wrapper include debug logging?",
      "header": "Logging",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes (Recommended)",
          "description": "Log requests and responses when WP_DEBUG is enabled"
        },
        {
          "label": "No",
          "description": "No debug logging"
        }
      ]
    }
  ]
}
```

### Step 3: Process Template

After collecting information, generate the PHP class using the template at:
`@everything-wp/skills/wp-backend/templates/api-wrapper.php.template`

Replace placeholders with collected values:

| Placeholder | Description |
|-------------|-------------|
| `{{NAMESPACE}}` | PHP namespace |
| `{{CLASS_NAME}}` | Class name (e.g., "Stripe_Api") |
| `{{API_NAME}}` | API name for comments |
| `{{BASE_URL}}` | API base URL |
| `{{AUTH_METHOD}}` | Authentication method code |
| `{{PLUGIN_PREFIX}}` | Plugin prefix |
| `{{TEXT_DOMAIN}}` | Text domain |

### Step 4: Generate Files

Create the following file:

1. **src/Api/{ApiName}_Api.php** - API wrapper class

### Step 5: Provide Integration Instructions

After generating the class, provide instructions for:

1. **Store API credentials:**
   ```php
   // In settings page or wp-config.php.
   define( 'MYPLUGIN_API_KEY', 'your-api-key-here' );
   ```

2. **Initialize and use the API:**
   ```php
   use Namespace\Api\Stripe_Api;

   $api = new Stripe_Api( MYPLUGIN_API_KEY );

   // GET request.
   $response = $api->get( '/customers' );

   // POST request.
   $response = $api->post( '/charges', array(
       'amount'   => 1000,
       'currency' => 'usd',
   ) );

   // Check for errors.
   if ( is_wp_error( $response ) ) {
       $error_message = $response->get_error_message();
   }
   ```

## Example Interaction

```
User: /api-wrapper

Claude: I'll help you create an API wrapper class.

[Uses AskUserQuestion to ask about API details]

User: [Answers questions]
- API name: Stripe
- Base URL: https://api.stripe.com/v1
- Auth: API Key in Header
- Retry: Yes
- Logging: Yes

Claude: Great! I have all the information needed:

**API Configuration:**
- Class: `MyPlugin\Api\Stripe_Api`
- Base URL: https://api.stripe.com/v1
- Auth: Bearer token in Authorization header

**Features:**
- Retry mechanism (3 attempts)
- Debug logging enabled

Let me generate the wrapper class...

[Creates src/Api/Stripe_Api.php]
```

## Generated Class Features

The generated class includes:

1. **`get()`** - HTTP GET request
2. **`post()`** - HTTP POST request
3. **`put()`** - HTTP PUT request
4. **`patch()`** - HTTP PATCH request
5. **`delete()`** - HTTP DELETE request
6. **`request()`** - Generic request method
7. **`set_api_key()`** - Update API key
8. **`get_last_response()`** - Get raw last response
9. **Error handling with WP_Error**
10. **Optional retry mechanism**
11. **Optional debug logging**

## Requirements

- WordPress 6.0+
- PHP 8.0+

## Templates Location

Template file:
```
@everything-wp/skills/wp-backend/templates/api-wrapper.php.template
```

## Related Commands

- `/option-page` - Create settings page for API credentials
- `/wp-ajax` - Create AJAX handlers that use the API
- `/rest-api` - Create REST endpoints that proxy API calls

## Related Skills

- `do-skill` - Execute based on Skill knowledge base
- `wp-backend` - WordPress backend development standards
  - [PHP Coding Standards](@everything-wp/skills/wp-backend/coding-standards-php.md)
  - [OOP Patterns](@everything-wp/skills/wp-backend/oop-patterns.md)
  - [Performance](@everything-wp/skills/wp-backend/performance.md)
  - [PHPStan](@everything-wp/skills/wp-backend/phpstan.md)
  - [Security](@everything-wp/skills/wp-backend/security.md)
