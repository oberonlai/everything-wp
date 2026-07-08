<?php
/**
 * Composer Configuration Setup Script (classic theme).
 *
 * Configures composer.json with PHP_CodeSniffer, PHPStan and PHPUnit dev tools
 * plus helper scripts. Uses a conflict-aware merge: existing user values are
 * preserved, not overwritten.
 */

if ( $argc < 3 ) {
	fwrite( STDERR, "Usage: php setup-composer.php <project-dir> <theme-slug> [db-name] [db-user] [db-pass] [db-host]\n" );
	exit( 1 );
}

$projectDir = $argv[1];
$themeSlug  = $argv[2];
// Optional test-database parameters, used to build the test:install script.
$dbName = ( isset( $argv[3] ) && '' !== $argv[3] ) ? $argv[3] : 'wordpress_test';
$dbUser = ( isset( $argv[4] ) && '' !== $argv[4] ) ? $argv[4] : 'root';
$dbPass = $argv[5] ?? ''; // Empty password is a valid, common local default.
$dbHost = ( isset( $argv[6] ) && '' !== $argv[6] ) ? $argv[6] : 'localhost';

$composerFile = $projectDir . '/composer.json';

// Read existing composer.json or start fresh.
// Guard against malformed JSON — refuse to proceed rather than blindly overwrite.
$composer = array();
if ( file_exists( $composerFile ) ) {
	$rawContent = file_get_contents( $composerFile );
	$composer   = json_decode( $rawContent, true );
	if ( $composer === null && json_last_error() !== JSON_ERROR_NONE ) {
		fwrite( STDERR, "❌ 既有 composer.json 解析失敗: " . json_last_error_msg() . "\n" );
		fwrite( STDERR, "   為避免破壞檔案，請先手動修復 composer.json 再重跑。\n" );
		exit( 1 );
	}
	if ( ! is_array( $composer ) ) {
		fwrite( STDERR, "❌ 既有 composer.json 內容不是 JSON 物件。\n" );
		exit( 1 );
	}

	// Back up before any modification so the user can recover even without git.
	$backupFile = $composerFile . '.bak.' . time();
	if ( ! copy( $composerFile, $backupFile ) ) {
		fwrite( STDERR, "❌ 無法建立備份: $backupFile\n" );
		exit( 1 );
	}
	fwrite( STDERR, "ℹ️  已備份原 composer.json 至: " . basename( $backupFile ) . "\n" );
}

// Ensure a basic require block exists.
if ( ! isset( $composer['require'] ) ) {
	$composer['require'] = array( 'php' => '>=8.0' );
}

// Add require-dev — only add if not already present. Existing user constraints win.
// PHPUnit is pinned to ^9.6 because the WordPress test suite is not compatible
// with PHPUnit 10/11.
$desiredRequireDev = array(
	'squizlabs/php_codesniffer'                      => '^3.9',
	'wp-coding-standards/wpcs'                        => '^3.1',
	'phpcompatibility/phpcompatibility-wp'           => '^2.1',
	'dealerdirect/phpcodesniffer-composer-installer' => '^1.0',
	'phpstan/phpstan'                                 => '^2.0',
	'szepeviktor/phpstan-wordpress'                   => '^2.0',
	'phpunit/phpunit'                                 => '^9.6',
	'wp-phpunit/wp-phpunit'                           => '^6.9',
	'yoast/phpunit-polyfills'                         => '^2.0',
);
$composer['require-dev'] = $composer['require-dev'] ?? array();
foreach ( $desiredRequireDev as $package => $version ) {
	if ( ! isset( $composer['require-dev'][ $package ] ) ) {
		$composer['require-dev'][ $package ] = $version;
	} elseif ( $composer['require-dev'][ $package ] !== $version ) {
		fwrite( STDERR, "ℹ️  require-dev['$package'] 已存在 ({$composer['require-dev'][$package]}); 保留原值，未改為 $version。\n" );
	}
}

// Add scripts — conflict-aware merge: keys with different values are left untouched.
$testInstallCmd = "bash bin/install-wp-tests.sh $dbName $dbUser '$dbPass' $dbHost latest";
$desiredScripts = array(
	'phpcs'        => 'phpcs',
	'phpcbf'       => 'phpcbf',
	'phpstan'      => 'phpstan analyse',
	'test'         => 'phpunit',
	'test:install' => $testInstallCmd,
	'build'        => 'php scripts/build.php',
	'make-pot'     => "wp i18n make-pot . languages/{$themeSlug}.pot --domain={$themeSlug}",
);
$composer['scripts'] = $composer['scripts'] ?? array();
foreach ( $desiredScripts as $key => $value ) {
	if ( ! isset( $composer['scripts'][ $key ] ) ) {
		$composer['scripts'][ $key ] = $value;
		continue;
	}
	if ( $composer['scripts'][ $key ] !== $value ) {
		fwrite( STDERR, "⚠️  composer.json scripts['$key'] 已存在且內容不同; 保留原值，未覆蓋。\n" );
		fwrite( STDERR, "    若要採用新值，請手動編輯 composer.json 或刪除該 key 後重跑。\n" );
	}
}

// Add script descriptions with the same conflict-aware merge.
$desiredDescriptions = array(
	'phpcs'        => 'Check coding standards with PHP_CodeSniffer',
	'phpcbf'       => 'Auto-fix coding standard violations',
	'phpstan'      => 'Run static analysis with PHPStan',
	'test'         => 'Run PHPUnit tests',
	'test:install' => 'Install WordPress testing environment (drops & recreates test DB; run once)',
	'build'        => 'Build a distributable theme ZIP',
	'make-pot'     => 'Generate the translation template (.pot) with WP-CLI',
);
$composer['scripts-descriptions'] = $composer['scripts-descriptions'] ?? array();
foreach ( $desiredDescriptions as $key => $value ) {
	if ( ! isset( $composer['scripts-descriptions'][ $key ] ) ) {
		$composer['scripts-descriptions'][ $key ] = $value;
	}
}

// Configure Composer. The dealerdirect installer must be allowed as a plugin.
$composer['config']                  = $composer['config'] ?? array();
$composer['config']['allow-plugins'] = array_merge(
	$composer['config']['allow-plugins'] ?? array(),
	array( 'dealerdirect/phpcodesniffer-composer-installer' => true )
);
$composer['config']['sort-packages'] = true;

// Write composer.json back out.
file_put_contents(
	$composerFile,
	json_encode( $composer, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES ) . "\n"
);

echo "✓ Composer configuration updated\n";
exit( 0 );
