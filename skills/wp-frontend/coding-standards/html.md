# WordPress HTML Coding Standards

This document defines the HTML coding standards for WordPress plugin and theme development. These standards are based on the [WordPress Official HTML Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/html/).

## 1. Validation

**Rule**: All HTML pages should be verified against the [W3C validator](https://validator.w3.org/) to ensure markup is well-formed.

While validation alone doesn't guarantee good code, it helps identify problems that can be caught through automation. It's not a substitute for manual code review.

## 2. Self-closing Elements

**Rule**: Self-closing tags should have exactly one space before the forward slash:

```html
<!-- ✅ Correct -->
<br />
<img src="image.jpg" alt="Description" />
<input type="text" name="email" />

<!-- ❌ Wrong -->
<br/>
<img src="image.jpg" alt="Description"/>
<input type="text" name="email"/>
```

**Reason**: The W3C specifies that a single space should precede the self-closing slash.

## 3. Attributes and Tags

### Lowercase Tags and Attributes

**Rule**: All tags and attributes must be written in lowercase:

```html
<!-- ✅ Correct -->
<div class="container">
    <p>Content here</p>
</div>

<!-- ❌ Wrong -->
<DIV CLASS="container">
    <P>Content here</P>
</DIV>
```

### Attribute Values

**Rule**: Attribute values should be lowercase when interpreted by machines, proper title capitalization when human-readable:

```html
<!-- ✅ Correct - For machines -->
<meta http-equiv="content-type" content="text/html; charset=utf-8" />

<!-- ✅ Correct - For humans -->
<a href="http://example.com/" title="Description Here">Example.com</a>

<!-- ❌ Wrong -->
<meta HTTP-EQUIV="Content-Type" content="text/html; charset=utf-8" />
<a href="http://example.com/" title="description here">Example.com</a>
```

## 4. Quotes

**Rule**: All attributes must have values and use double quotes (preferred) or single quotes:

```html
<!-- ✅ Correct - Double quotes (preferred) -->
<input type="text" name="email" disabled="disabled" />

<!-- ✅ Also correct - Single quotes -->
<input type='text' name='email' disabled='disabled' />

<!-- ❌ Wrong - No quotes -->
<input type=text name=email disabled>
```

### Boolean Attributes

**Rule**: Boolean attributes can omit the value, but must still be quoted if a value is provided:

```html
<!-- ✅ Correct - Omit value -->
<input type="text" name="email" disabled />

<!-- ✅ Also correct - With value -->
<input type="text" name="email" disabled="disabled" />

<!-- ❌ Wrong - Invalid boolean values -->
<input type="text" name="email" disabled="true" />
<input type="text" name="email" disabled="false" />
```

**Note**: `true` and `false` are not valid values for boolean attributes in HTML5.

## 5. Indentation

**Rule**: Use tabs for indentation, not spaces:

```html
<!-- ✅ Correct -->
<div class="container">
    <header class="site-header">
        <h1>Site Title</h1>
        <nav class="main-navigation">
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/about">About</a></li>
            </ul>
        </nav>
    </header>
</div>

<!-- ❌ Wrong - Using spaces -->
<div class="container">
  <header class="site-header">
    <h1>Site Title</h1>
  </header>
</div>
```

### Nested Elements

**Rule**: Indent nested elements by one tab:

```html
<article class="post">
    <header class="entry-header">
        <h2 class="entry-title">Post Title</h2>
        <div class="entry-meta">
            <span class="author">By John Doe</span>
            <time datetime="2024-01-24">January 24, 2024</time>
        </div>
    </header>
    <div class="entry-content">
        <p>Post content here.</p>
    </div>
</article>
```

## 6. Semantic HTML

**Rule**: Use semantic HTML5 elements when appropriate:

```html
<!-- ✅ Correct - Semantic HTML5 -->
<header>
    <nav>
        <ul>
            <li><a href="/">Home</a></li>
        </ul>
    </nav>
</header>

<main>
    <article>
        <h1>Article Title</h1>
        <p>Article content</p>
    </article>
    
    <aside>
        <h2>Related Posts</h2>
    </aside>
</main>

<footer>
    <p>&copy; 2024 Site Name</p>
</footer>

<!-- ❌ Wrong - Non-semantic divs -->
<div class="header">
    <div class="nav">
        <ul>
            <li><a href="/">Home</a></li>
        </ul>
    </div>
</div>

<div class="main">
    <div class="article">
        <h1>Article Title</h1>
        <p>Article content</p>
    </div>
</div>
```

## 7. Accessibility

### Alt Text for Images

**Rule**: Always provide meaningful alt text for images:

```html
<!-- ✅ Correct -->
<img src="logo.png" alt="Company Logo" />
<img src="chart.png" alt="Sales chart showing 20% increase in Q4" />

<!-- Decorative images -->
<img src="decoration.png" alt="" />

<!-- ❌ Wrong -->
<img src="logo.png" />  <!-- Missing alt -->
<img src="chart.png" alt="image" />  <!-- Not descriptive -->
```

### Form Labels

**Rule**: Associate labels with form inputs:

```html
<!-- ✅ Correct - Using for/id -->
<label for="user-email">Email Address:</label>
<input type="email" id="user-email" name="email" />

<!-- ✅ Also correct - Wrapping -->
<label>
    Email Address:
    <input type="email" name="email" />
</label>

<!-- ❌ Wrong - No association -->
<label>Email Address:</label>
<input type="email" name="email" />
```

### ARIA Attributes

**Rule**: Use ARIA attributes when needed for accessibility:

```html
<!-- ✅ Correct -->
<button aria-label="Close dialog" aria-expanded="false">
    <span aria-hidden="true">&times;</span>
</button>

<nav aria-label="Main navigation">
    <ul>
        <li><a href="/">Home</a></li>
    </ul>
</nav>
```

## 8. WordPress-Specific HTML

### Template Tags

**Rule**: Use WordPress template tags properly:

```php
<!-- ✅ Correct -->
<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
    <h2><?php the_title(); ?></h2>
    <div class="entry-content">
        <?php the_content(); ?>
    </div>
</article>

<!-- ❌ Wrong - Not escaping output -->
<article id="post-<?php echo get_the_ID(); ?>">
    <h2><?php echo get_the_title(); ?></h2>
</article>
```

### Escaping Output

**Rule**: Always escape output in templates:

```php
<!-- ✅ Correct -->
<a href="<?php echo esc_url( get_permalink() ); ?>">
    <?php echo esc_html( get_the_title() ); ?>
</a>

<div class="<?php echo esc_attr( $custom_class ); ?>">
    <?php echo wp_kses_post( $content ); ?>
</div>

<!-- ❌ Wrong - Not escaped -->
<a href="<?php echo get_permalink(); ?>">
    <?php echo get_the_title(); ?>
</a>
```

## 9. Comments

**Rule**: Use HTML comments to mark sections:

```html
<!-- Header Section -->
<header class="site-header">
    <!-- Navigation -->
    <nav class="main-navigation">
        <!-- ... -->
    </nav>
    <!-- /Navigation -->
</header>
<!-- /Header Section -->
```

**Rule**: Don't leave commented-out code in production:

```html
<!-- ❌ Wrong - Remove commented code -->
<!-- <div class="old-layout">
    <p>This was the old design</p>
</div> -->
```

## 10. Best Practices

### Minimize Markup

**Rule**: Use the minimum amount of markup necessary:

```html
<!-- ✅ Correct - Minimal markup -->
<nav class="main-nav">
    <ul>
        <li><a href="/">Home</a></li>
    </ul>
</nav>

<!-- ❌ Wrong - Unnecessary wrappers -->
<div class="nav-wrapper">
    <div class="nav-container">
        <nav class="main-nav">
            <div class="nav-inner">
                <ul>
                    <li><a href="/">Home</a></li>
                </ul>
            </div>
        </nav>
    </div>
</div>
```

### Avoid Inline Styles

**Rule**: Avoid inline styles, use CSS classes:

```html
<!-- ✅ Correct -->
<div class="highlight-box">Content</div>

<!-- ❌ Wrong -->
<div style="background: yellow; padding: 10px;">Content</div>
```

### Avoid Inline JavaScript

**Rule**: Avoid inline JavaScript, use external files:

```html
<!-- ✅ Correct -->
<button class="submit-btn" data-action="submit">Submit</button>

<!-- ❌ Wrong -->
<button onclick="submitForm()">Submit</button>
```

## Checklist

Before committing HTML code:
- [ ] Passes W3C validation
- [ ] All tags and attributes in lowercase
- [ ] All attributes have quoted values
- [ ] Self-closing tags have space before `/>`
- [ ] Use tabs for indentation
- [ ] Semantic HTML5 elements used
- [ ] All images have alt text
- [ ] Form inputs have associated labels
- [ ] ARIA attributes used where needed
- [ ] WordPress template tags properly used
- [ ] All output is escaped
- [ ] No inline styles or scripts
- [ ] No commented-out code
- [ ] Minimal, clean markup
