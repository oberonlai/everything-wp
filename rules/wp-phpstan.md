# WordPress PHPStan Rules

## 1. PHPStan Level Requirements

**Rule**: New projects must achieve PHPStan Level 5 or higher

```bash
composer require --dev phpstan/phpstan
composer require --dev szepeviktor/phpstan-wordpress
```

### phpstan.neon

```neon
parameters:
    level: 5
    paths:
        - src
    excludePaths:
        - vendor
        - node_modules
    bootstrapFiles:
        - vendor/php-stubs/wordpress-stubs/wordpress-stubs.php
```

## 2. WordPress Type Annotations

**Rule**: Use WordPress-specific type annotations

```php
/**
 * @param WP_REST_Request<array{id: int, name: string}> $request
 * @return WP_REST_Response|WP_Error
 */
function my_rest_callback( $request ) {
    // PHPStan now knows the structure of $request
}
```

## 3. Baseline Management

**Rule**: Do not add new errors to baseline

```bash
# Only generate baseline during initialization
vendor/bin/phpstan analyse --generate-baseline

# Daily development must pass PHPStan
vendor/bin/phpstan analyse
```

## Checklist

- [ ] PHPStan Level ≥ 5
- [ ] WordPress stubs loaded
- [ ] Baseline hasn't grown
- [ ] All public APIs have type annotations
