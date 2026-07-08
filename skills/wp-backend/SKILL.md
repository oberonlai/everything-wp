---
name: wp-backend
description: Use when writing WordPress backend/server-side code - PHP development, database queries, REST API endpoints, admin interfaces, settings pages, custom post types, taxonomies, cron jobs, WP-CLI commands, plugin architecture, hooks system, OOP patterns, security (nonce, sanitization, SQL injection), performance optimization, and WordPress.org submission
---

# WordPress Backend Development

Backend/server-side WordPress development including PHP coding standards, architecture patterns, security, and performance.

## Available Resources

### PHP Development
- **[PHP Coding Standards](./coding-standards-php.md)** - Complete WordPress PHP coding standards
- **[Custom Database Tables](./custom-tables.md)** - Creating and managing custom tables
- **[OOP Patterns](./oop-patterns.md)** - Object-oriented programming patterns for WordPress
- **[Security Guidelines](./security.md)** - Security best practices for backend code
- **[Performance Optimization](./performance.md)** - Backend performance optimization

### Development Workflow
- **[Testing Guide](./testing.md)** - Unit testing, coverage requirements, and best practices
- **[PHPStan Setup](./phpstan.md)** - Static analysis configuration and usage

### Deployment
- **[WordPress.org Submission](./org-submission.md)** - Plugin submission process and requirements

### Templates
- **[Custom Post Type](./templates/cpt.php.template)** - CPT registration class locking in project conventions (i18n labels, activation-only rewrite flush, `show_in_rest`). No dedicated command — use this template directly when a task involves registering a post type.

## When to Use

Use this skill when working on:
- **PHP Files**: Writing or reviewing `.php` files
- **Database Operations**: Custom queries, table creation, migrations
- **Custom Tables**: Creating and managing custom database tables with `dbDelta()`
- **REST API**: Creating custom endpoints, authentication
- **Admin Interface**: Settings pages, meta boxes, admin menus
- **Custom Post Types/Taxonomies**: Registering and managing
- **Hooks**: Creating actions and filters
- **Cron Jobs**: Scheduled tasks
- **WP-CLI**: Custom commands
- **Security**: Nonce verification, input sanitization, output escaping
- **Performance**: Query optimization, caching strategies

## Quick Reference

### Common Backend Tasks
- Creating settings page → PHP Coding Standards + Security
- Building REST API → PHP Coding Standards + Security
- Database queries → PHP Coding Standards + Performance
- OOP architecture → OOP Patterns
- Plugin submission → WordPress.org Submission
