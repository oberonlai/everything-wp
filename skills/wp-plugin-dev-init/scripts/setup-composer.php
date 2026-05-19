<?php
/**
 * Composer Configuration Setup Script
 * 
 * Sets up composer.json with autoload and scripts
 */

if ($argc < 8) {
    fwrite(STDERR, "Usage: php setup-composer.php <project-dir> <namespace> <autoload-dir> <db-name> <db-user> <db-pass> <db-host>\n");
    exit(1);
}

$projectDir = $argv[1];
$namespace = $argv[2];
$autoloadDir = $argv[3];
$dbName = $argv[4];
$dbUser = $argv[5];
$dbPass = $argv[6];
$dbHost = $argv[7];

$composerFile = $projectDir . '/composer.json';

// Read existing composer.json or create new one
$composer = file_exists($composerFile) 
    ? json_decode(file_get_contents($composerFile), true)
    : [];

// Ensure basic structure
if (!isset($composer['require'])) {
    $composer['require'] = ['php' => '>=8.0'];
}

// Add autoload — deep-merge psr-4 instead of replacing entire autoload block.
// Existing namespaces (e.g. test fixtures, second namespace) are preserved.
$composer['autoload'] = $composer['autoload'] ?? [];
$composer['autoload']['psr-4'] = $composer['autoload']['psr-4'] ?? [];
$psr4Key = $namespace . '\\';
if ( isset( $composer['autoload']['psr-4'][ $psr4Key ] ) && $composer['autoload']['psr-4'][ $psr4Key ] !== $autoloadDir . '/' ) {
    fwrite( STDERR, "⚠️  autoload.psr-4['$psr4Key'] 已存在且指向不同路徑 ('{$composer['autoload']['psr-4'][$psr4Key]}'); 保留原值，未覆蓋。\n" );
} else {
    $composer['autoload']['psr-4'][ $psr4Key ] = $autoloadDir . '/';
}

// Add require-dev — array_merge keeps later values, safe to add/update package versions.
$composer['require-dev'] = array_merge(
    $composer['require-dev'] ?? [],
    [
        'wp-phpunit/wp-phpunit' => '^6.3',
        'yoast/phpunit-polyfills' => '^1.0'
    ]
);

// Add scripts — conflict-aware merge: existing keys with different values trigger a warning
// and are left untouched. Caller can re-run with the old composer.json modified by hand.
$testInstallCmd = "bash bin/install-wp-tests.sh $dbName $dbUser '$dbPass' $dbHost latest";
$desiredScripts = [
    'test' => 'phpunit',
    'test:install' => $testInstallCmd,
    'build' => [
        '@build:clean',
        '@build:prod',
        'php scripts/build.php'
    ],
    'build:prod' => 'composer install --no-dev --optimize-autoloader',
    'build:dev' => 'composer install',
    'build:clean' => 'rm -rf build vendor',
    'post-build' => ['@build:dev']
];

$composer['scripts'] = $composer['scripts'] ?? [];
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

// Same conflict-aware merge for scripts-descriptions.
$desiredDescriptions = [
    'test' => 'Run PHPUnit tests',
    'test:install' => 'Install WordPress testing environment (run once)',
    'build' => 'Build release version with production dependencies',
    'build:prod' => 'Install production dependencies only',
    'build:dev' => 'Install all dependencies including dev tools',
    'build:clean' => 'Clean build files and vendor directory'
];
$composer['scripts-descriptions'] = $composer['scripts-descriptions'] ?? [];
foreach ( $desiredDescriptions as $key => $value ) {
    if ( ! isset( $composer['scripts-descriptions'][ $key ] ) ) {
        $composer['scripts-descriptions'][ $key ] = $value;
    }
}

// Add config
$composer['config'] = array_merge(
    $composer['config'] ?? [],
    [
        'optimize-autoloader' => true,
        'sort-packages' => true
    ]
);

// Write composer.json
file_put_contents(
    $composerFile,
    json_encode($composer, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n"
);

echo "✓ Composer configuration updated\n";
exit(0);
