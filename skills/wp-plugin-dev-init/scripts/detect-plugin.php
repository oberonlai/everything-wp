<?php
/**
 * WordPress Plugin Information Detector
 * 
 * Detects plugin information from the main plugin file
 */

if ($argc < 2) {
    fwrite(STDERR, "Usage: php detect-plugin.php <plugin-directory>\n");
    exit(1);
}

$pluginDir = $argc > 1 ? $argv[1] : getcwd();

// Find all main plugin files (files with `Plugin Name:` header).
$pluginFiles = findPluginFiles($pluginDir);

if (count($pluginFiles) === 0) {
    fwrite(STDERR, "Error: Could not find main plugin file\n");
    fwrite(STDERR, "Looking for PHP file with 'Plugin Name:' header in: $pluginDir\n");
    exit(1);
}

if (count($pluginFiles) > 1) {
    fwrite(STDERR, "Error: Found multiple PHP files with 'Plugin Name:' header. Please specify which is the main file:\n");
    foreach ($pluginFiles as $f) {
        fwrite(STDERR, "  - " . basename($f) . "\n");
    }
    fwrite(STDERR, "Re-run with the main file path as a second argument, or rename/remove the duplicates.\n");
    exit(2);
}

$pluginFile = $pluginFiles[0];

// Extract plugin information
$pluginInfo = extractPluginInfo($pluginFile);

if (!$pluginInfo) {
    fwrite(STDERR, "Error: Could not extract plugin information from: $pluginFile\n");
    exit(1);
}

// Output as JSON
echo json_encode($pluginInfo, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
exit(0);

/**
 * Find all PHP files with `Plugin Name:` header (only the directory root, not recursive).
 *
 * Returns an array of absolute file paths (possibly empty).
 */
function findPluginFiles($dir) {
    $files = glob($dir . '/*.php');
    $matches = [];

    foreach ($files as $file) {
        $content = file_get_contents($file);
        if (preg_match('/Plugin Name:/i', $content)) {
            $matches[] = $file;
        }
    }

    return $matches;
}

/**
 * Extract plugin information from file
 */
function extractPluginInfo($file) {
    $content = file_get_contents($file);
    $info = [];
    
    // Extract Plugin Name
    if (preg_match('/Plugin Name:\s*(.+)/i', $content, $matches)) {
        $info['name'] = trim($matches[1]);
    }
    
    // Extract Version
    if (preg_match('/Version:\s*(.+)/i', $content, $matches)) {
        $version = trim($matches[1]);
        // Add v prefix if not present
        $info['version'] = (strpos($version, 'v') === 0) ? $version : 'v' . $version;
    }
    
    // Extract Text Domain (use as slug)
    if (preg_match('/Text Domain:\s*(.+)/i', $content, $matches)) {
        $info['slug'] = trim($matches[1]);
    } else {
        // Fallback: use filename as slug
        $info['slug'] = basename($file, '.php');
    }
    
    // Store file path
    $info['file'] = basename($file);
    
    // Validate required fields
    if (empty($info['name']) || empty($info['version']) || empty($info['slug'])) {
        return null;
    }
    
    return $info;
}
