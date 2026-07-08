<?php
/**
 * WordPress Theme Information Detector.
 *
 * Detects theme information from the style.css header in the given directory.
 * Outputs JSON on success; writes errors to STDERR.
 */

if ( $argc < 2 ) {
	fwrite( STDERR, "Usage: php detect-theme.php <theme-directory>\n" );
	exit( 1 );
}

$themeDir  = $argv[1];
$styleFile = $themeDir . '/style.css';

if ( ! file_exists( $styleFile ) ) {
	fwrite( STDERR, "Error: No style.css found in: $themeDir\n" );
	exit( 1 );
}

$content = file_get_contents( $styleFile );

// A stylesheet must carry a Theme Name header to count as a theme root.
if ( ! preg_match( '/Theme Name:/i', $content ) ) {
	fwrite( STDERR, "Error: style.css found but it has no 'Theme Name:' header.\n" );
	exit( 1 );
}

$info = array();

// Extract Theme Name.
if ( preg_match( '/Theme Name:\s*(.+)/i', $content, $matches ) ) {
	$info['name'] = trim( $matches[1] );
}

// Extract Version and normalize with a v prefix.
if ( preg_match( '/Version:\s*(.+)/i', $content, $matches ) ) {
	$version           = trim( $matches[1] );
	$info['version']   = ( strpos( $version, 'v' ) === 0 ) ? $version : 'v' . $version;
} else {
	$info['version'] = 'v1.0.0';
}

// Extract Text Domain, falling back to the directory name as the slug.
if ( preg_match( '/Text Domain:\s*(.+)/i', $content, $matches ) ) {
	$info['slug'] = trim( $matches[1] );
} else {
	$info['slug'] = basename( rtrim( $themeDir, '/' ) );
}

$info['textdomain'] = $info['slug'];
$info['file']       = 'style.css';

// Detect the theme type: a block theme ships templates/index.html (theme.json alone is not enough).
if ( file_exists( $themeDir . '/templates/index.html' ) ) {
	$info['type'] = 'block';
} else {
	$info['type'] = 'classic';
}

// Validate the required field.
if ( empty( $info['name'] ) ) {
	fwrite( STDERR, "Error: Could not extract Theme Name from style.css\n" );
	exit( 1 );
}

echo json_encode( $info, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES );
exit( 0 );
