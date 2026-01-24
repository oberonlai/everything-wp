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

// Find the main plugin file
$pluginFile = findPluginFile($pluginDir);

if (!$pluginFile) {
    fwrite(STDERR, "Error: Could not find main plugin file\n");
    fwrite(STDERR, "Looking for PHP file with 'Plugin Name:' header in: $pluginDir\n");
    exit(1);
}

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
 * Find the main plugin file
 */
function findPluginFile($dir) {
    $files = glob($dir . '/*.php');
    
    foreach ($files as $file) {
        $content = file_get_contents($file);
        if (preg_match('/Plugin Name:/i', $content)) {
            return $file;
        }
    }
    
    return null;
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
