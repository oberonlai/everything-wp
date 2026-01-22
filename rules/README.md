# WordPress Rules - README

This directory contains WordPress-specific rules that must be followed in all WordPress plugin development.

## Rules Overview

### Core Rules (Must Implement) ⭐⭐⭐

1. **[wp-security.md](wp-security.md)** - Security rules
   - Nonces + permission checks
   - Input sanitization and output escaping
   - SQL prepared statements
   - File upload security
   - API endpoint security

2. **[wp-coding-standards.md](wp-coding-standards.md)** - Coding standards
   - Plugin architecture (single entry point, lazy loading)
   - Naming conventions (prefixes, namespaces)
   - File organization
   - WordPress Coding Standards (WPCS)
   - Documentation (PHPDoc)
   - Internationalization (i18n)

### Recommended Rules ⭐⭐

3. **[wp-oop.md](wp-oop.md)** - Object-Oriented Programming principles
   - SOLID principles (SRP, OCP, LSP, ISP, DIP)
   - Hooks Manager pattern
   - Dependency injection
   - Namespacing and autoloading
   - Testability

4. **[wp-performance.md](wp-performance.md)** - Performance rules
   - Database query optimization (avoid N+1)
   - Autoload options management
   - Object cache usage
   - HTTP API best practices
   - Cron task optimization
   - Asset loading optimization

5. **[wp-testing.md](wp-testing.md)** - Testing requirements
   - Test coverage ≥ 70%
   - Test structure and naming
   - Test isolation
   - Critical features testing

### Optional Rules ⭐

6. **[wp-phpstan.md](wp-phpstan.md)** - PHPStan static analysis
   - PHPStan Level ≥ 5
   - WordPress type annotations
   - Baseline management

7. **[wp-org-submission.md](wp-org-submission.md)** - WordPress.org submission requirements
   - GPL license requirements
   - Trademark and branding rules
   - Third-party services documentation
   - User tracking and privacy
   - Admin interface behavior
   - README.txt requirements

## Implementation Priority

### Phase 1: Core Rules (Immediate)
Start with security and coding standards - these are non-negotiable.

### Phase 2: Quality Rules (Short-term)
Add performance and testing rules to prevent common issues.

### Phase 3: Advanced Rules (Long-term)
Implement PHPStan for advanced static analysis.

## Usage

These rules are designed to work with Claude Code's rule system. Place them in your `~/.claude/rules/` directory or project-specific `.claude/rules/` directory.

## Related Resources

- [WordPress Plugin Handbook](https://developer.wordpress.org/plugins/)
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/)
- [WordPress Security Guidelines](https://developer.wordpress.org/plugins/wordpress-org/detailed-plugin-guidelines/)
