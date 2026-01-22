# WordPress.org Plugin Submission Rules

These rules are specific to WordPress.org plugin directory submissions and must be followed in addition to other WordPress development rules.

## 1. License Requirements

**Rule**: All code, data, and images must use GPL-compatible licenses

- ✅ **Required**: GPL v2 or later
  ```php
  /**
   * License: GPL-2.0+
   * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
   */
  ```

- ✅ **Check Third-Party Libraries**
  - Verify all included libraries are GPL-compatible
  - Document library licenses in readme.txt
  - Reference: [GPL-Compatible Licenses](https://www.gnu.org/philosophy/license-list.html#GPLCompatibleLicenses)

## 2. Trademark and Branding

**Rule**: Respect trademarks and use original brand names

- ❌ **Forbidden**: Using others' trademarks without authorization
  ```
  Plugin Slug: woocommerce-addon (unless authorized by WooCommerce)
  Plugin Slug: wordpress-helper (don't start with "wordpress")
  ```

- ✅ **Correct**: Use original brand names
  ```
  Plugin Slug: mycompany-shop-addon
  Plugin Slug: mycompany-helper
  ```

## 3. Plugin Completeness

**Rule**: Plugin must be complete and functional at submission

- ❌ **Forbidden**:
  - Trialware (limited trial period)
  - Locked features requiring payment
  - Sandbox-only API access
  - "Coming soon" features

- ✅ **Required**:
  - Fully functional free version
  - All advertised features work
  - Production-ready code

## 4. Third-Party Services

**Rule**: Clearly document all third-party service usage in readme.txt

### Required Documentation

If your plugin uses external services, you MUST include in readme.txt:

```markdown
## Third-Party Services

This plugin connects to the following external services:

### Service Name (e.g., Google Analytics)
- **Purpose**: Track website visitor statistics
- **Data Sent**: Page views, user location (anonymized), browser type
- **When**: On every page load (if tracking enabled)
- **Terms of Service**: https://policies.google.com/terms
- **Privacy Policy**: https://policies.google.com/privacy
```

### Examples

```php
// ❌ Wrong: No documentation for external API call
wp_remote_get( 'https://api.example.com/data' );

// ✅ Correct: Documented in readme.txt
// Service usage clearly explained
wp_remote_get( 'https://api.example.com/data' );
```

## 5. User Tracking and Privacy

**Rule**: Must not track users without explicit consent

- ❌ **Forbidden**: Automatic tracking without consent
  ```php
  // Tracking without asking
  wp_remote_post( 'https://tracking.example.com', array(
      'body' => array(
          'site_url' => get_site_url(),
          'email' => get_option( 'admin_email' )
      )
  ) );
  ```

- ✅ **Required**: Opt-in mechanism
  ```php
  // Only track if user opted in
  if ( get_option( 'myplugin_allow_tracking' ) ) {
      wp_remote_post( 'https://tracking.example.com', array(
          'body' => array(
              'site_url' => get_site_url()
          )
      ) );
  }
  ```

### Privacy Requirements

- Provide clear opt-in checkbox (default: unchecked)
- Explain what data is collected
- Explain why data is collected
- Provide opt-out mechanism
- Document in readme.txt

## 6. Admin Interface Behavior

**Rule**: Do not hijack the WordPress admin dashboard

### Forbidden Behaviors

- ❌ Persistent admin notices that cannot be dismissed
- ❌ Redirecting to plugin page on every admin page load
- ❌ Excessive upgrade prompts
- ❌ Admin advertisements
- ❌ Forcing plugin settings page as default admin page

### Correct Approach

```php
// ✅ Dismissible admin notice
add_action( 'admin_notices', 'myplugin_admin_notice' );
function myplugin_admin_notice() {
    // Only show if not dismissed
    if ( get_option( 'myplugin_notice_dismissed' ) ) {
        return;
    }
    
    ?>
    <div class="notice notice-info is-dismissible">
        <p><?php esc_html_e( 'Thank you for installing My Plugin!', 'myplugin' ); ?></p>
    </div>
    <?php
}

// Handle dismiss action
add_action( 'wp_ajax_myplugin_dismiss_notice', 'myplugin_dismiss_notice' );
function myplugin_dismiss_notice() {
    check_ajax_referer( 'myplugin_dismiss_notice', 'nonce' );
    update_option( 'myplugin_notice_dismissed', true );
    wp_send_json_success();
}
```

## 7. Public Site Behavior

**Rule**: Do not embed external links or credits without user permission

- ❌ **Forbidden**: Default-enabled "Powered by" links
  ```php
  // Automatically adding link to footer
  add_action( 'wp_footer', 'myplugin_add_credit' );
  function myplugin_add_credit() {
      echo '<p>Powered by <a href="https://myplugin.com">My Plugin</a></p>';
  }
  ```

- ✅ **Correct**: Opt-in credit links
  ```php
  // Only if user enables it
  add_action( 'wp_footer', 'myplugin_add_credit' );
  function myplugin_add_credit() {
      if ( ! get_option( 'myplugin_show_credit' ) ) {
          return;
      }
      
      echo '<p>Powered by <a href="https://myplugin.com">My Plugin</a></p>';
  }
  ```

## 8. README.txt Requirements

**Rule**: readme.txt must be accurate and not contain spam

### Required Sections

```
=== Plugin Name ===
Contributors: yourusername
Tags: tag1, tag2, tag3 (maximum 5 tags)
Requires at least: 6.0
Tested up to: 6.4
Stable tag: 1.0.0
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

Short description (maximum 150 characters)

== Description ==

Detailed description of your plugin.

== Installation ==

Installation instructions.

== Frequently Asked Questions ==

= Question 1 =
Answer 1

== Screenshots ==

1. Screenshot description

== Changelog ==

= 1.0.0 =
* Initial release
```

### Tag Rules

- ❌ **Forbidden**:
  - More than 5 tags
  - Competitor plugin names as tags
  - Spam keywords

- ✅ **Correct**:
  - Maximum 5 relevant tags
  - Descriptive, accurate tags
  - No competitor names

### Affiliate Links

- Must be disclosed
- Must be direct (not cloaked)
- Must not be excessive
- Must be relevant to plugin functionality

## 9. Version Management

**Rule**: Increment version numbers for each release

```php
// Main plugin file header
/**
 * Version: 1.0.1
 */

// readme.txt
Stable tag: 1.0.1

// Changelog in readme.txt
== Changelog ==

= 1.0.1 =
* Fixed: Bug description
* Added: New feature

= 1.0.0 =
* Initial release
```

**Important**: trunk/readme.txt must always reflect the current stable version.

## 10. Forbidden File Types

**Rule**: Do not include executable or development files in plugin

### Forbidden File Types

**Executable Files**:
- `.exe`, `.bin`, `.sh`, `.bat`, `.cmd`
- `.dmg`, `.pkg`, `.deb`, `.rpm`
- `.iso`, `.img`
- `.so`, `.dll`, `.dylib`

**Archive Files** (compiled):
- `.phar` (PHP Archive)

**Development Files**:
- `.DS_Store` (macOS)
- `.git/`, `.svn/`, `.hg/` (version control)
- `Thumbs.db` (Windows)
- `.idea/`, `.vscode/` (IDE configs)

**Build Artifacts**:
- `.o`, `.obj` (object files)
- `.a`, `.lib` (static libraries)
- `.deploy`, `.dist`, `.distz`

### Allowed Files

- `.php`, `.js`, `.css`, `.html`
- `.jpg`, `.png`, `.gif`, `.svg`, `.webp` (images)
- `.woff`, `.woff2`, `.ttf`, `.eot` (fonts)
- `.json`, `.xml`, `.txt`, `.md`
- `.pot`, `.po`, `.mo` (translations)

### Check Your Plugin

```bash
# Find forbidden file types
find . -type f \( -name "*.exe" -o -name "*.phar" -o -name "*.dmg" -o -name ".DS_Store" \)

# List all file types in plugin
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
```

### .gitignore Example

```gitignore
# Development files
.DS_Store
Thumbs.db
.idea/
.vscode/
*.log

# Build artifacts
node_modules/
vendor/
*.map

# Version control
.git/
.svn/
```

## 11. No Custom Updaters

**Rule**: Do not include custom plugin update mechanisms

- ❌ **Forbidden**: Custom updater code
  ```php
  // Custom update checker
  function myplugin_check_for_updates() {
      $response = wp_remote_get( 'https://myplugin.com/updates.json' );
      // Custom update logic...
  }
  add_action( 'admin_init', 'myplugin_check_for_updates' );
  ```

- ✅ **Correct**: Use WordPress.org update system
  ```php
  // WordPress.org handles updates automatically
  // No custom update code needed
  ```

**Why it's forbidden**: 
- WordPress.org plugins use the official WordPress update system
- Custom updaters can bypass security checks
- May conflict with WordPress.org update mechanism

**Exception**: If your plugin is NOT hosted on WordPress.org, you may use custom updaters for premium versions, but:
- Free version on WordPress.org must not include updater code
- Premium updater must be in separate files/package
- Must not interfere with WordPress.org updates

## WordPress.org Submission Checklist

Before submitting to WordPress.org, verify:

### Legal & Licensing
- [ ] All code uses GPL v2 or later
- [ ] Third-party libraries are GPL-compatible
- [ ] No trademark violations in plugin slug or name

### Functionality
- [ ] Plugin is complete and functional
- [ ] No trialware or locked features
- [ ] All features work in production

### Third-Party Services
- [ ] All external services documented in readme.txt
- [ ] Service purpose, data sent, and timing explained
- [ ] Terms of service and privacy policy links provided

### Privacy & Tracking
- [ ] No user tracking without consent
- [ ] Clear opt-in mechanism for tracking
- [ ] Privacy policy documented

### User Experience
- [ ] No admin dashboard hijacking
- [ ] Admin notices are dismissible
- [ ] No default-enabled external links
- [ ] Upgrade prompts are moderate

### Documentation
- [ ] readme.txt is complete and accurate
- [ ] Maximum 5 tags
- [ ] No spam or competitor names in tags
- [ ] Affiliate links are disclosed and direct
- [ ] Version numbers are consistent

### Code Quality
- [ ] Code is human-readable (not obfuscated)
- [ ] Minified code has source files or repository link
- [ ] No remote resource loading (except fonts)
- [ ] All security and coding standards met
- [ ] No forbidden file types (.exe, .phar, .DS_Store, etc.)
- [ ] No custom update mechanisms
- [ ] No .git, .svn, or other version control directories
- [ ] No IDE configuration files (.idea, .vscode)

## Handling Review Feedback

### When You Receive Feedback

1. **Read Carefully**
   - Distinguish required fixes from suggestions
   - Understand the root cause of each issue

2. **Fix Issues**
   - Address all required fixes
   - Test each fix thoroughly
   - Update plugin files on WordPress.org

3. **Reply to Review Email**
   - Confirm you've read and understood guidelines
   - Explain what you fixed
   - Ask polite questions if needed

4. **Timeline**
   - Respond within 3 months or submission will be rejected
   - Reviews are manual and may take time
   - Be patient and polite

## References

- [WordPress.org Plugin Guidelines](https://developer.wordpress.org/plugins/wordpress-org/detailed-plugin-guidelines/)
- [Plugin Handbook](https://developer.wordpress.org/plugins/)
- [GPL License](https://www.gnu.org/licenses/gpl-2.0.html)
