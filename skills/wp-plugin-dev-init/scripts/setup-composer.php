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

// Add autoload
$composer['autoload'] = [
    'psr-4' => [
        $namespace . '\\' => $autoloadDir . '/'
    ]
];

// Add require-dev
$composer['require-dev'] = array_merge(
    $composer['require-dev'] ?? [],
    [
        'wp-phpunit/wp-phpunit' => '^6.3',
        'yoast/phpunit-polyfills' => '^1.0'
    ]
);

// Add scripts
$testInstallCmd = "bash bin/install-wp-tests.sh $dbName $dbUser '$dbPass' $dbHost latest";

$composer['scripts'] = array_merge(
    $composer['scripts'] ?? [],
    [
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
    ]
);

// Add script descriptions
$composer['scripts-descriptions'] = array_merge(
    $composer['scripts-descriptions'] ?? [],
    [
        'test' => 'Run PHPUnit tests',
        'test:install' => 'Install WordPress testing environment (run once)',
        'build' => 'Build release version with production dependencies',
        'build:prod' => 'Install production dependencies only',
        'build:dev' => 'Install all dependencies including dev tools',
        'build:clean' => 'Clean build files and vendor directory'
    ]
);

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
