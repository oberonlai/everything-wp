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

// Read existing composer.json or create new one.
// Guard against malformed JSON — refuse to proceed rather than blindly overwrite.
$composer = [];
if (file_exists($composerFile)) {
    $rawContent = file_get_contents($composerFile);
    $composer = json_decode($rawContent, true);
    if ($composer === null && json_last_error() !== JSON_ERROR_NONE) {
        fwrite(STDERR, "❌ 既有 composer.json 解析失敗: " . json_last_error_msg() . "\n");
        fwrite(STDERR, "   為避免破壞檔案，請先手動修復 composer.json 再重跑。\n");
        exit(1);
    }
    if (!is_array($composer)) {
        fwrite(STDERR, "❌ 既有 composer.json 內容不是 JSON 物件。\n");
        exit(1);
    }

    // Backup before any modification so the user can recover even without git.
    $backupFile = $composerFile . '.bak.' . time();
    if (!copy($composerFile, $backupFile)) {
        fwrite(STDERR, "❌ 無法建立備份: $backupFile\n");
        exit(1);
    }
    fwrite(STDERR, "ℹ️  已備份原 composer.json 至: " . basename($backupFile) . "\n");
}

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

// Add require-dev — only add if not already present. Existing user constraints win.
// Versions kept in sync with init-plugin.md Step 5.2.
$desiredRequireDev = [
    'wp-phpunit/wp-phpunit' => '^6.9',
    'yoast/phpunit-polyfills' => '^2.0',
];
$composer['require-dev'] = $composer['require-dev'] ?? [];
foreach ( $desiredRequireDev as $package => $version ) {
    if ( ! isset( $composer['require-dev'][ $package ] ) ) {
        $composer['require-dev'][ $package ] = $version;
    } elseif ( $composer['require-dev'][ $package ] !== $version ) {
        fwrite( STDERR, "ℹ️  composer.json require-dev['$package'] 已存在 ({$composer['require-dev'][$package]}); 保留原值，未改為 $version。\n" );
    }
}

// Add scripts — conflict-aware merge: existing keys with different values trigger a warning
// and are left untouched. Caller can re-run with the old composer.json modified by hand.
$testInstallCmd = "bash bin/install-wp-tests.sh $dbName $dbUser '$dbPass' $dbHost latest";
// build flow: 只清 build/、安裝 production deps (本身不動 vendor，是 composer 自行管理)、
// 跑 build script。post-build 重灌完整 deps，回到開發狀態。
// 重要：build:clean 只刪 build/，**絕不刪 vendor/** — vendor 由 composer install --no-dev /
// composer install 切換，外部腳本動 vendor 太危險（被中斷就壞）。
$desiredScripts = [
    'test' => 'phpunit',
    'test:install' => $testInstallCmd,
    'build' => [
        '@build:clean',
        '@build:prod',
        'php scripts/build.php',
        '@build:dev'
    ],
    'build:prod' => 'composer install --no-dev --optimize-autoloader',
    'build:dev' => 'composer install',
    'build:clean' => 'rm -rf build'
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
    'test:install' => 'Install WordPress testing environment (drops & recreates test DB; run once)',
    'build' => 'Build release version with production dependencies',
    'build:prod' => 'Install production dependencies only',
    'build:dev' => 'Install all dependencies including dev tools',
    'build:clean' => 'Clean build/ directory (does NOT touch vendor/)'
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
