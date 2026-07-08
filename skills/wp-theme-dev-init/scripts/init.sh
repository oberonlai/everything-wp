#!/bin/bash

# WordPress Classic Theme Development Initialization Script.
# 此腳本針對「已有 style.css 主題」的 Augment 模式，補齊開發工具與 CI。
# Greenfield（全新主題）流程由 agent 依 init-theme.md 執行 template 步驟。

set -e  # 遇到錯誤立即停止。

# 顏色輸出。
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color.

# 詢問檔案/目錄已存在時要如何處理。
# 用法: prompt_overwrite <path> <description>
# 回傳: 0 = overwrite, 1 = skip。
prompt_overwrite() {
    local target="$1"
    local desc="$2"

    if [ ! -e "$target" ]; then
        return 0  # 不存在，直接寫。
    fi

    echo ""
    echo -e "${YELLOW}⚠️  $desc 已存在: $target${NC}"
    echo "    (o) overwrite — 直接覆蓋"
    echo "    (s) skip      — 保留現有，跳過 (預設)"
    echo "    (b) backup    — 備份為 .bak.<timestamp> 再覆蓋"
    read -p "    請選擇 [o/s/b] (預設 s): " -n 1 -r CHOICE
    echo

    case "$CHOICE" in
        o|O) return 0 ;;
        b|B)
            local backup="${target}.bak.$(date +%s)"
            cp -r "$target" "$backup"
            echo -e "${GREEN}    ✓ 已備份至: $backup${NC}"
            return 0
            ;;
        *) return 1 ;;
    esac
}

# 取得腳本所在目錄。
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"

# 取得專案根目錄。
PROJECT_DIR="$(pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}WordPress 傳統主題開發環境初始化${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. 偵測主題資訊。
echo -e "${BLUE}🔍 偵測主題資訊...${NC}"
set +e  # 暫時允許失敗以讀 exit code。
THEME_INFO=$(php "$SCRIPT_DIR/detect-theme.php" "$PROJECT_DIR" 2>&1)
DETECT_EXIT=$?
set -e

if [ $DETECT_EXIT -ne 0 ]; then
    echo -e "${RED}❌ 未偵測到既有主題（找不到含 'Theme Name:' 的 style.css）。${NC}"
    echo -e "${RED}    init.sh 只支援既有主題（Augment）。Greenfield 流程請由 agent 依 init-theme.md 執行。${NC}"
    echo "$THEME_INFO"
    exit 1
fi

# 解析 JSON 輸出。
THEME_NAME=$(echo "$THEME_INFO" | jq -r '.name')
THEME_SLUG=$(echo "$THEME_INFO" | jq -r '.slug')
THEME_VERSION=$(echo "$THEME_INFO" | jq -r '.version')
TEXT_DOMAIN=$(echo "$THEME_INFO" | jq -r '.textdomain')

echo -e "${GREEN}✓ 偵測完成${NC}"
echo ""

# 2. 確認資訊。
echo -e "${YELLOW}🔍 偵測到主題資訊:${NC}"
echo "   名稱: $THEME_NAME"
echo "   Slug: $THEME_SLUG"
echo "   版本: $THEME_VERSION"
echo "   Text Domain: $TEXT_DOMAIN"
echo ""

read -p "✅ 確認資訊正確? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo -e "${RED}已取消${NC}"
    exit 1
fi

# 3. 由 slug 推導前綴，並從 style.css 讀取相容性欄位（讀不到就用預設）。
FUNCTION_PREFIX=$(echo "$THEME_SLUG" | tr '-' '_')
CONST_PREFIX=$(echo "$FUNCTION_PREFIX" | tr '[:lower:]' '[:upper:]')

REQUIRES_PHP=$(grep -i "Requires PHP:" style.css 2>/dev/null | head -1 | awk -F: '{print $2}' | tr -d ' \r')
REQUIRES_PHP=${REQUIRES_PHP:-8.0}
REQUIRES_WP=$(grep -i "Requires at least:" style.css 2>/dev/null | head -1 | awk -F: '{print $2}' | tr -d ' \r')
REQUIRES_WP=${REQUIRES_WP:-6.4}

# 4. 詢問測試資料庫設定（供 PHPUnit test:install 使用）。
echo ""
echo -e "${YELLOW}📊 測試資料庫設定 (PHPUnit):${NC}"
DB_NAME="wordpress_test"
echo "   測試資料庫名稱: $DB_NAME"
read -p "   資料庫使用者 [root]: " DB_USER
DB_USER=${DB_USER:-root}
read -sp "   資料庫密碼 [留空]: " DB_PASS
echo
read -p "   資料庫主機 [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}

echo ""
echo -e "${BLUE}🚀 開始初始化...${NC}"
echo ""

# 檢查 Composer。
if ! command -v composer &> /dev/null; then
    echo -e "${RED}❌ 找不到 Composer,請先安裝 Composer${NC}"
    exit 1
fi

# 5. 設定 Composer（PHPCS + PHPStan + PHPUnit 工具 + scripts）。
echo -e "${BLUE}📦 設定 Composer...${NC}"
php "$SCRIPT_DIR/setup-composer.php" "$PROJECT_DIR" "$THEME_SLUG" "$DB_NAME" "$DB_USER" "$DB_PASS" "$DB_HOST"

# 6. 安裝依賴。
echo -e "${BLUE}📥 安裝 Composer 依賴...${NC}"
if [ -f "composer.lock" ]; then
    echo -e "${YELLOW}    ⚠️  既有 composer.lock 可能會重新解析；如不希望變動 lockfile，請先 Ctrl+C。${NC}"
fi
composer install

# 7. 建立 .phpcs.xml.dist（既有則詢問）。
echo -e "${BLUE}🔧 建立 PHPCS 設定...${NC}"
if prompt_overwrite ".phpcs.xml.dist" "PHPCS 設定"; then
    sed -e "s/{{THEME_NAME}}/$THEME_NAME/g" \
        -e "s/{{TEXT_DOMAIN}}/$TEXT_DOMAIN/g" \
        -e "s/{{FUNCTION_PREFIX}}/$FUNCTION_PREFIX/g" \
        -e "s/{{CONST_PREFIX}}/$CONST_PREFIX/g" \
        -e "s/{{REQUIRES_PHP}}/$REQUIRES_PHP/g" \
        -e "s/{{REQUIRES_WP}}/$REQUIRES_WP/g" \
        "$TEMPLATES_DIR/phpcs.xml.dist.template" > .phpcs.xml.dist
    echo -e "${GREEN}    ✓ .phpcs.xml.dist 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 .phpcs.xml.dist${NC}"
fi

# 8. 建立 phpstan.neon（既有則詢問，無佔位符直接複製）。
echo -e "${BLUE}🔬 建立 PHPStan 設定...${NC}"
if prompt_overwrite "phpstan.neon" "PHPStan 設定"; then
    cp "$TEMPLATES_DIR/phpstan.neon.template" phpstan.neon
    echo -e "${GREEN}    ✓ phpstan.neon 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 phpstan.neon${NC}"
fi

# 9. 建立 PHPUnit 測試骨架（phpunit.xml.dist + tests/ + bin/install-wp-tests.sh）。
echo -e "${BLUE}🧪 建立 PHPUnit 測試骨架...${NC}"
if prompt_overwrite "phpunit.xml.dist" "PHPUnit 設定"; then
    sed -e "s/{{THEME_NAME}}/$THEME_NAME/g" \
        "$TEMPLATES_DIR/phpunit.xml.dist.template" > phpunit.xml.dist
    echo -e "${GREEN}    ✓ phpunit.xml.dist 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 phpunit.xml.dist${NC}"
fi

mkdir -p tests
if prompt_overwrite "tests/bootstrap.php" "測試啟動檔"; then
    sed -e "s/{{THEME_NAME}}/$THEME_NAME/g" \
        "$TEMPLATES_DIR/tests/bootstrap.php.template" > tests/bootstrap.php
    echo -e "${GREEN}    ✓ tests/bootstrap.php 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 tests/bootstrap.php${NC}"
fi

if prompt_overwrite "tests/test-sample.php" "範例測試"; then
    sed -e "s/{{THEME_NAME}}/$THEME_NAME/g" \
        "$TEMPLATES_DIR/tests/test-sample.php.template" > tests/test-sample.php
    echo -e "${GREEN}    ✓ tests/test-sample.php 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 tests/test-sample.php${NC}"
fi

mkdir -p bin
if prompt_overwrite "bin/install-wp-tests.sh" "測試環境安裝腳本"; then
    cp "$TEMPLATES_DIR/bin/install-wp-tests.sh" bin/install-wp-tests.sh
    chmod +x bin/install-wp-tests.sh
    echo -e "${GREEN}    ✓ bin/install-wp-tests.sh 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 bin/install-wp-tests.sh${NC}"
fi

# 10. 建立打包腳本（既有則詢問）。
echo -e "${BLUE}📦 建立打包腳本...${NC}"
mkdir -p scripts
if prompt_overwrite "scripts/build.php" "打包腳本"; then
    sed -e "s/{{THEME_SLUG}}/$THEME_SLUG/g" \
        "$TEMPLATES_DIR/build.php.template" > scripts/build.php
    echo -e "${GREEN}    ✓ scripts/build.php 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 scripts/build.php${NC}"
fi

# 11. 建立 GitHub Actions workflow（既有則詢問）。
echo -e "${BLUE}⚙️  建立 GitHub Actions workflow...${NC}"
mkdir -p .github/workflows
if prompt_overwrite ".github/workflows/release.yml" "GitHub Actions release workflow"; then
    sed -e "s/{{THEME_SLUG}}/$THEME_SLUG/g" \
        "$TEMPLATES_DIR/release-workflow.yml.template" > .github/workflows/release.yml
    echo -e "${GREEN}    ✓ .github/workflows/release.yml 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 .github/workflows/release.yml${NC}"
fi

# 12. 建立 languages 目錄並產生 .pot（若有 WP-CLI）。
echo -e "${BLUE}🌐 設定 i18n...${NC}"
mkdir -p languages
if command -v wp &> /dev/null; then
    if prompt_overwrite "languages/${TEXT_DOMAIN}.pot" "翻譯範本 .pot"; then
        wp i18n make-pot . "languages/${TEXT_DOMAIN}.pot" --domain="$TEXT_DOMAIN"
        echo -e "${GREEN}    ✓ languages/${TEXT_DOMAIN}.pot 已產生${NC}"
    else
        echo -e "${YELLOW}    跳過 make-pot${NC}"
    fi
else
    echo -e "${YELLOW}    找不到 WP-CLI，跳過 make-pot；稍後可執行 composer make-pot${NC}"
fi

# 13. 更新 .gitignore。
echo -e "${BLUE}📝 更新 .gitignore...${NC}"
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi
grep -qxF '/vendor/' .gitignore || echo '/vendor/' >> .gitignore
grep -qxF '/build/' .gitignore || echo '/build/' >> .gitignore
grep -qxF '.phpcs.cache' .gitignore || echo '.phpcs.cache' >> .gitignore
grep -qxF 'phpunit.xml' .gitignore || echo 'phpunit.xml' >> .gitignore
grep -qxF '.phpunit.result.cache' .gitignore || echo '.phpunit.result.cache' >> .gitignore
grep -qxF '/node_modules/' .gitignore || echo '/node_modules/' >> .gitignore
grep -qxF '.wp-env.override.json' .gitignore || echo '.wp-env.override.json' >> .gitignore
grep -qxF 'local-config.php' .gitignore || echo 'local-config.php' >> .gitignore
grep -qxF '*.bak.*' .gitignore || echo '*.bak.*' >> .gitignore

# 14. 執行 PHPStan 驗證（可選）。
echo ""
read -p "🔬 是否立即執行 composer phpstan 靜態分析？ [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    set +e
    composer phpstan
    set -e
else
    echo -e "${YELLOW}    跳過 composer phpstan${NC}"
fi

# 15. 執行 PHPCS 驗證（可選）。
echo ""
read -p "🔎 是否立即執行 composer phpcs 驗證編碼規範？ [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    set +e
    composer phpcs
    set -e
else
    echo -e "${YELLOW}    跳過 composer phpcs${NC}"
fi

# 16. 偵測容器化環境（wp-env / DDEV）— 若使用容器，跳過 host 端 test:install。
USE_CONTAINER_ENV=false
if [ -f ".wp-env.json" ] || [ -f ".ddev/config.yaml" ]; then
    USE_CONTAINER_ENV=true
fi

if [ "$USE_CONTAINER_ENV" = true ]; then
    echo ""
    echo -e "${YELLOW}⚠️  偵測到 wp-env 或 DDEV 設定檔${NC}"
    echo -e "${YELLOW}    跳過 host 端的 test:install / test（會連到錯誤的 MySQL）${NC}"
    echo -e "${YELLOW}    請在 container 內執行：${NC}"
    echo -e "${YELLOW}      wp-env run cli composer test:install && wp-env run cli composer test${NC}"
    echo -e "${YELLOW}      ddev exec composer test:install && ddev exec composer test${NC}"
else
    # 17. 安裝測試環境（會 drop/recreate test DB，必須先問）。
    echo ""
    echo -e "${YELLOW}🧪 composer test:install 將會 drop 並重建測試資料庫 ($DB_NAME)${NC}"
    echo -e "${YELLOW}    若該資料庫中有真實資料會全部消失。${NC}"
    read -p "    繼續？ [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🧪 安裝測試環境...${NC}"
        composer test:install

        echo -e "${BLUE}✅ 執行測試...${NC}"
        set +e
        composer test
        set -e
    else
        echo -e "${YELLOW}    跳過 composer test:install / test${NC}"
        echo -e "${YELLOW}    請手動執行：composer test:install && composer test${NC}"
    fi
fi

# 18. 執行建置驗證（可選）。
echo ""
read -p "📦 是否立即執行 composer build 驗證打包流程？ [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "build" ]; then
        if prompt_overwrite "build" "build/ 目錄"; then
            composer build
        else
            echo -e "${YELLOW}    跳過 composer build${NC}"
        fi
    else
        composer build
    fi
else
    echo -e "${YELLOW}    跳過 composer build；可在準備好時手動執行${NC}"
fi

# 完成。
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ WordPress 傳統主題開發環境初始化完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}📦 已設定:${NC}"
echo "   - PHP_CodeSniffer + WPCS 編碼規範"
echo "   - PHPStan 靜態分析 (szepeviktor/phpstan-wordpress)"
echo "   - PHPUnit 測試骨架 (tests/ + bin/install-wp-tests.sh)"
echo "   - GitHub Actions workflow (qa + test + release)"
echo "   - 打包腳本 (scripts/build.php)"
echo "   - i18n (languages/ + .pot)"
echo ""
echo -e "${YELLOW}🎯 下一步:${NC}"
echo "   1. 準備 screenshot.png（建議 1200x900）放在主題根目錄"
echo "   2. 安裝 Theme Check 外掛，於後台檢查上架合規性"
echo "   3. 開始開發主題模板"
echo ""
echo -e "${BLUE}💡 發布流程:${NC}"
echo "   1. 更新 style.css 的 Version"
echo "   2. git tag $THEME_VERSION"
echo "   3. git push origin $THEME_VERSION"
echo "   4. GitHub Actions 會自動 qa、test、打包並建立 Release"
echo ""
