# WordPress CSS Coding Standards

This document defines the CSS coding standards for WordPress plugin and theme development. These standards are based on the [WordPress Official CSS Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/css/).

## 1. Structure

### Indentation

**Rule**: Use tabs, not spaces, to indent each property.

### Spacing Between Sections

- **Two blank lines** between sections
- **One blank line** between blocks in a section

### Selector and Property Formatting

**Rule**: Each selector on its own line, properties on their own line with one tab indentation:

```css
/* ✅ Correct */
#selector-1,
#selector-2,
#selector-3 {
    background: #fff;
    color: #000;
}

/* ❌ Wrong */
#selector-1, #selector-2, #selector-3 {
    background: #fff; color: #000;
}

/* ❌ Wrong */
#selector-1 { background: #fff; color: #000; }
```

## 2. Selectors

### Naming Convention

**Rule**: Use lowercase and separate words with hyphens (similar to PHP file naming):

```css
/* ✅ Correct */
#comment-form {
    margin: 1em 0;
}

.site-header {
    padding: 20px;
}

/* ❌ Wrong */
#commentForm {  /* Avoid camelCase */
    margin: 0;
}

#comment_form {  /* Avoid underscores */
    margin: 0;
}
```

### Human Readable Names

**Rule**: Use descriptive names that explain what element(s) they style:

```css
/* ✅ Correct */
.site-navigation { }
.entry-title { }
.comment-list { }

/* ❌ Wrong */
.nav1 { }
.t1 { }
.c-list { }
```

### Attribute Selectors

**Rule**: Use double quotes around values:

```css
/* ✅ Correct */
input[type="text"] {
    line-height: 1.1;
}

/* ❌ Wrong */
input[type=text] {
    line-height: 1.1;
}
```

### Avoid Over-Qualification

**Rule**: Don't over-qualify selectors:

```css
/* ✅ Correct */
.container {
    width: 100%;
}

/* ❌ Wrong */
div.container {  /* Unnecessary element qualifier */
    width: 100%;
}
```

## 3. Properties

### Property Ordering

**Rule**: Group like properties together in logical order:

1. **Display**
2. **Positioning**
3. **Box model**
4. **Colors and Typography**
5. **Other**

```css
/* ✅ Correct - Logical ordering */
#overlay {
    /* Positioning */
    position: absolute;
    z-index: 1;
    top: 0;
    left: 0;
    
    /* Box model */
    padding: 10px;
    
    /* Colors and Typography */
    background: #fff;
    color: #777;
}
```

**Alternative**: Alphabetical ordering is also acceptable:

```css
/* ✅ Also correct - Alphabetical ordering */
#overlay {
    background: #fff;
    color: #777;
    left: 0;
    padding: 10px;
    position: absolute;
    top: 0;
    z-index: 1;
}
```

### TRBL Order

**Rule**: Use Top/Right/Bottom/Left order for directional properties:

```css
/* ✅ Correct */
.box {
    margin-top: 10px;
    margin-right: 20px;
    margin-bottom: 10px;
    margin-left: 20px;
    
    /* Or use shorthand */
    margin: 10px 20px 10px 20px;
}
```

### Vendor Prefixes

**Rule**: Order from longest to shortest (WordPress uses Autoprefixer):

```css
/* ✅ Correct */
.sample-output {
    -webkit-box-shadow: inset 0 0 1px 1px #eee;
    -moz-box-shadow: inset 0 0 1px 1px #eee;
    box-shadow: inset 0 0 1px 1px #eee;
}
```

## 4. Values

### Spacing

**Rule**: Space after colon, no space before:

```css
/* ✅ Correct */
color: #000;
margin: 10px 20px;

/* ❌ Wrong */
color:#000;
margin:10px 20px;
color : #000;
```

### Units

**Rule**: Omit unit for zero values:

```css
/* ✅ Correct */
margin: 0;
padding: 0;

/* ❌ Wrong */
margin: 0px;
padding: 0em;
```

**Rule**: Use lowercase for hex values and shorthand when possible:

```css
/* ✅ Correct */
color: #fff;
background: #f5f5f5;

/* ❌ Wrong */
color: #FFF;
color: #FFFFFF;  /* Use #fff instead */
background: #F5F5F5;
```

### Quotes

**Rule**: Use single or double quotes consistently. WordPress core uses single quotes:

```css
/* ✅ Correct */
background-image: url('images/bg.png');
font-family: 'Helvetica Neue', Arial, sans-serif;

/* ❌ Wrong */
background-image: url(images/bg.png);  /* Missing quotes */
```

## 5. Media Queries

**Rule**: Place media queries close to their relevant rule sets when possible:

```css
.site-header {
    padding: 20px;
}

@media screen and (min-width: 768px) {
    .site-header {
        padding: 40px;
    }
}
```

**Rule**: Use meaningful breakpoint names:

```css
/* ✅ Correct */
@media screen and (min-width: 768px) { }  /* Tablet */
@media screen and (min-width: 1024px) { }  /* Desktop */

/* ❌ Wrong */
@media screen and (min-width: 768px) { }  /* No context */
```

## 6. Commenting

### Section Comments

```css
/**
 * #.# Section Title
 *
 * Description of section, whether or not it has media queries, etc.
 */

.selector {
    property: value;
}
```

### Inline Comments

```css
/* This is a comment */
.selector {
    property: value; /* This is an inline comment */
}
```

### Long Comments

```css
/**
 * Long comments should be formatted like this:
 *
 * This is a long comment that spans multiple lines.
 * It provides detailed information about the following
 * CSS rules and why they exist.
 */
```

## 7. Best Practices

### Avoid !important

**Rule**: Avoid using `!important` unless absolutely necessary:

```css
/* ✅ Correct - Use specificity */
.site-header .nav-menu {
    color: #000;
}

/* ❌ Wrong - Avoid !important */
.nav-menu {
    color: #000 !important;
}
```

### Use Shorthand Properties

**Rule**: Use shorthand properties when possible:

```css
/* ✅ Correct */
margin: 10px 20px;
background: #fff url('bg.png') no-repeat center;

/* ❌ Wrong - Unnecessarily verbose */
margin-top: 10px;
margin-right: 20px;
margin-bottom: 10px;
margin-left: 20px;
```

### Avoid Units on Line-Height

**Rule**: Use unitless line-height:

```css
/* ✅ Correct */
line-height: 1.5;

/* ❌ Wrong */
line-height: 1.5em;
line-height: 150%;
```

### Use Relative Units

**Rule**: Prefer relative units (em, rem, %) over absolute units (px) when appropriate:

```css
/* ✅ Correct */
font-size: 1.2rem;
padding: 1em;
width: 80%;

/* Consider context */
border: 1px solid #ccc;  /* px is OK for borders */
```

## 8. WP Admin CSS

### Targeting Admin Screens

**Rule**: Use WordPress admin classes for targeting:

```css
/* Target specific admin pages */
.post-type-page .editor-styles-wrapper {
    /* Styles for page editor */
}

.wp-admin .my-plugin-settings {
    /* Styles for plugin settings */
}
```

### RTL Support

**Rule**: Consider RTL (Right-to-Left) languages:

```css
/* Use logical properties when possible */
.element {
    margin-inline-start: 20px;  /* Adapts to RTL */
}

/* Or provide RTL overrides */
.element {
    margin-left: 20px;
}

.rtl .element {
    margin-left: 0;
    margin-right: 20px;
}
```

## 9. File Organization

### Separate Concerns

```
styles/
├── base/
│   ├── reset.css
│   └── typography.css
├── components/
│   ├── buttons.css
│   └── forms.css
├── layout/
│   ├── header.css
│   └── footer.css
└── admin/
    └── settings.css
```

### Import Order

```css
/* Base */
@import url('base/reset.css');
@import url('base/typography.css');

/* Layout */
@import url('layout/header.css');
@import url('layout/footer.css');

/* Components */
@import url('components/buttons.css');
@import url('components/forms.css');
```

## Checklist

Before committing CSS code:
- [ ] Use tabs for indentation
- [ ] Selectors use lowercase with hyphens
- [ ] Properties are logically ordered
- [ ] No trailing whitespace
- [ ] Zero values have no units
- [ ] Hex colors are lowercase and shorthand
- [ ] Quotes around attribute selector values
- [ ] No over-qualified selectors
- [ ] Avoid `!important`
- [ ] Comments explain complex rules
- [ ] RTL support considered
- [ ] Passes CSS validation
