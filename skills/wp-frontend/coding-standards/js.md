# WordPress JavaScript Coding Standards

This document defines the JavaScript coding standards for WordPress plugin development. These standards are based on the [WordPress Official JavaScript Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/javascript/).

## 1. Spacing

Use spaces liberally throughout your code. "When in doubt, space it out."

### Rules

- **Indentation**: Use tabs, not spaces
- **Line length**: Usually no longer than 80 characters, should not exceed 100
- **No trailing whitespace**: At the end of line or on blank lines
- **Braces**: `if/else/for/while/try` blocks must always use braces and go on multiple lines
- **Unary operators**: `++`, `--` must not have space next to their operand
- **Commas and semicolons**: `,` and `;` must not have preceding space
- **Statement terminator**: `;` must be at the end of the line
- **Object properties**: `:` after property name must not have preceding space
- **Ternary conditional**: `?` and `:` must have space on both sides
- **Empty constructs**: No filler spaces in `{}`, `[]`, `fn()`
- **Negation operator**: `!` should have a following space
- **File ending**: New line at the end of each file

### Examples

```javascript
// ✅ Correct
if ( condition ) {
    doSomething();
}

for ( let i = 0; i < 10; i++ ) {
    // ...
}

const obj = {
    key: 'value',
    another: 'data'
};

const result = condition ? 'yes' : 'no';

// ❌ Wrong
if(condition){
    doSomething();
}

for(let i=0;i<10;i++){
    // ...
}

const obj={key:'value',another:'data'};
```

## 2. Semicolons

**Rule**: Always use semicolons. Never rely on Automatic Semicolon Insertion (ASI).

```javascript
// ✅ Correct
const name = 'WordPress';
doSomething();

// ❌ Wrong
const name = 'WordPress'
doSomething()
```

## 3. Indentation and Line Breaks

**Rule**: Use tabs for indentation. Even if the entire file is wrapped in a closure, indent by one tab:

```javascript
// ✅ Correct
( function( $ ) {
    // Expressions indented by one tab
    
    function doSomething() {
        // Expressions indented by one tab
    }
} )( jQuery );

// ❌ Wrong
( function( $ ) {
// No indentation
function doSomething() {
// No indentation
}
} )( jQuery );
```

## 4. Variable Declarations

### Using const and let (ES2015+)

**Rule**: Use `const` by default, `let` when reassignment is needed. Never use `var` in modern code.

```javascript
// ✅ Correct
const API_URL = 'https://example.com/api';
let count = 0;

count++;  // Reassignment is OK with let

// ❌ Wrong
var apiUrl = 'https://example.com/api';  // Don't use var
const count = 0;
count++;  // Can't reassign const
```

**Rule**: Declare variables at the point they are first used, not at the top of the function.

### Using var (Legacy Code)

**Rule**: If using `var`, declare all variables at the beginning of the function in a single comma-delimited statement:

```javascript
// ✅ Correct
function myFunction() {
    var k, m, length,
        value = 'WordPress';
    
    // Function body
}

// ❌ Wrong
function myFunction() {
    var foo = true;
    var bar = false;
    var a;
    var b;
}
```

## 5. Globals

**Rule**: Document all globals used within a file at the top:

```javascript
/* global passwordStrength:true */

// passwordStrength is defined in this file
```

**Rule**: Omit `:true` for read-only globals defined elsewhere:

```javascript
/* global wp, jQuery */

// wp and jQuery are defined elsewhere
```

### Common Libraries

- **jQuery**: Access through `$` by wrapping in IIFE:
  ```javascript
  ( function( $ ) {
      // Use $ here
  } )( jQuery );
  ```

- **wp object**: Safely access to avoid overwriting:
  ```javascript
  window.wp = window.wp || {};
  ```

## 6. Naming Conventions

**Rule**: Use camelCase with lowercase first letter (different from PHP standards):

```javascript
// ✅ Correct
const userName = 'John';
function getUserData() { }
const isActive = true;

// ❌ Wrong
const user_name = 'John';  // Don't use underscores
function get_user_data() { }  // Don't use underscores
const UserName = 'John';  // Don't capitalize first letter
```

**Exception**: Iterators can use single letters:

```javascript
for ( let i = 0; i < items.length; i++ ) {
    // 'i' is acceptable
}
```

### Classes

```javascript
// ✅ Correct
class UserProfile {
    constructor() { }
}

// ❌ Wrong
class userProfile { }  // Should be PascalCase
```

### Constants

```javascript
// ✅ Correct
const MAX_RETRIES = 3;
const API_ENDPOINT = 'https://api.example.com';

// ❌ Wrong
const maxRetries = 3;  // Should be UPPER_CASE
```

## 7. Blocks and Curly Braces

**Rule**: Always use braces, even for single-line statements:

```javascript
// ✅ Correct
if ( condition ) {
    doSomething();
}

// ❌ Wrong
if ( condition ) doSomething();

if ( condition )
    doSomething();
```

## 8. Multi-line Statements

**Rule**: Break long statements into multiple lines for readability:

```javascript
// ✅ Correct
const result = someFunction(
    parameter1,
    parameter2,
    parameter3
);

// ❌ Wrong
const result = someFunction( parameter1, parameter2, parameter3, parameter4, parameter5 );
```

## 9. Chained Method Calls

**Rule**: Each method in a chain should be on its own line:

```javascript
// ✅ Correct
elements
    .addClass( 'active' )
    .removeClass( 'hidden' )
    .fadeIn();

// ❌ Wrong
elements.addClass( 'active' ).removeClass( 'hidden' ).fadeIn();
```

## 10. Equality

**Rule**: Use strict equality (`===` and `!==`) instead of loose equality:

```javascript
// ✅ Correct
if ( value === 'test' ) { }
if ( count !== 0 ) { }

// ❌ Wrong
if ( value == 'test' ) { }
if ( count != 0 ) { }
```

## 11. Type Checks

```javascript
// String
typeof variable === 'string'

// Number
typeof variable === 'number'

// Boolean
typeof variable === 'boolean'

// Object
typeof variable === 'object'

// Array
Array.isArray( arrayLikeObject )

// null
variable === null

// undefined
typeof variable === 'undefined'
```

## 12. Strings

**Rule**: Use single quotes for strings:

```javascript
// ✅ Correct
const name = 'WordPress';
const message = 'Hello, world!';

// ❌ Wrong
const name = "WordPress";
```

**Exception**: Use double quotes to avoid escaping:

```javascript
// ✅ Correct
const message = "It's a beautiful day";

// ❌ Wrong
const message = 'It\'s a beautiful day';
```

## 13. Switch Statements

```javascript
// ✅ Correct
switch ( event ) {
    case 'click':
        handleClick();
        break;
        
    case 'keypress':
        handleKeypress();
        break;
        
    default:
        handleDefault();
}
```

## 14. Best Practices

### Arrays

```javascript
// Create array
const items = [];

// Add to array
items.push( newItem );

// Check length
if ( items.length ) { }
```

### Objects

```javascript
// Create object
const obj = {};

// Add property
obj.newProperty = value;

// Check property exists
if ( obj.hasOwnProperty( 'property' ) ) { }
```

### Iteration

```javascript
// Array iteration
for ( let i = 0; i < array.length; i++ ) {
    // Use array[i]
}

// Object iteration
for ( const key in object ) {
    if ( object.hasOwnProperty( key ) ) {
        // Use object[key]
    }
}
```

### jQuery Collections

```javascript
// ✅ Correct - use .each()
$( '.items' ).each( function() {
    $( this ).addClass( 'active' );
} );

// ❌ Wrong - don't use for loop
const items = $( '.items' );
for ( let i = 0; i < items.length; i++ ) {
    $( items[i] ).addClass( 'active' );
}
```

## 15. Comments

```javascript
// Single-line comment

/*
 * Multi-line comment
 * with proper formatting
 */

/**
 * JSDoc comment for functions
 *
 * @param {string} name - User name
 * @param {number} age - User age
 * @return {Object} User object
 */
function createUser( name, age ) {
    return {
        name: name,
        age: age
    };
}
```

## Checklist

Before committing JavaScript code:
- [ ] Use tabs for indentation
- [ ] Always use semicolons
- [ ] Use `const` and `let`, not `var`
- [ ] Use camelCase for variables and functions
- [ ] Use strict equality (`===`, `!==`)
- [ ] Always use braces for blocks
- [ ] Use single quotes for strings
- [ ] Document globals at top of file
- [ ] Wrap jQuery in IIFE
- [ ] No trailing whitespace
- [ ] Pass JSHint checks
