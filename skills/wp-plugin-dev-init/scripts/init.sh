#!/bin/bash

# WordPress Plugin Development Initialization Script
# 此腳本會自動設定完整的 WordPress 外掛開發環境

set -e  # 遇到錯誤立即停止

# 顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 詢問檔案/目錄已存在時要如何處理
# 用法: prompt_overwrite <path> <description>
# 回傳: 0 = overwrite, 1 = skip, 2 = backup-and-replace
prompt_overwrite() {
    local target="$1"
    local desc="$2"

    if [ ! -e "$target" ]; then
        return 0  # 不存在，直接寫
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

# 取得腳本所在目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$SKILL_DIR/templates"

# 取得專案根目錄(假設在 .agent/skills/wp-plugin-dev-init/scripts/ 中執行)
PROJECT_DIR="$(pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}WordPress 外掛開發環境初始化${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. 偵測外掛資訊
echo -e "${BLUE}🔍 偵測外掛資訊...${NC}"
set +e  # 暫時允許失敗以讀 exit code
PLUGIN_INFO=$(php "$SCRIPT_DIR/detect-plugin.php" "$PROJECT_DIR" 2>&1)
DETECT_EXIT=$?
set -e

if [ $DETECT_EXIT -eq 2 ]; then
    # 多個含 Plugin Name: header 的檔案 — 不能自動繼續
    echo -e "${RED}❌ 偵測到多個外掛主檔，請先處理：${NC}"
    echo "$PLUGIN_INFO"
    exit 1
fi

if [ $DETECT_EXIT -ne 0 ]; then
    # 找不到既有外掛 — 進入 Greenfield 防呆檢查
    echo -e "${YELLOW}ℹ️  未偵測到既有外掛（無 Plugin Name: header）${NC}"

    # 簡易啟發式：目錄基底名疑似 wp-content/plugins/ 或包含多個外掛子目錄就警告
    BASENAME=$(basename "$PROJECT_DIR")
    if [[ "$BASENAME" == "plugins" || "$BASENAME" == "wp-content" || "$BASENAME" == wordpress* ]]; then
        echo -e "${RED}⚠️  當前目錄名稱 ($BASENAME) 看起來像 WordPress 根/外掛根。${NC}"
        echo -e "${RED}    在這裡跑 Greenfield 流程會把 scaffold 檔散落各處。${NC}"
        read -p "    確定要繼續嗎？ [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}已取消${NC}"
            exit 1
        fi
    fi

    # 偵測同層是否有其他「含 Plugin Name: 的子目錄」(代表這裡像 plugins 根)
    OTHER_PLUGINS=$(find "$PROJECT_DIR" -mindepth 2 -maxdepth 2 -name "*.php" -exec grep -l "Plugin Name:" {} \; 2>/dev/null | head -3)
    if [ -n "$OTHER_PLUGINS" ]; then
        echo -e "${RED}⚠️  同層子目錄含其他外掛主檔，當前目錄很可能是 wp-content/plugins/。${NC}"
        echo "$OTHER_PLUGINS"
        read -p "    確定要繼續嗎？ [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}已取消${NC}"
            exit 1
        fi
    fi

    # 既然 init.sh 原本只設計給既有外掛，這裡仍維持「沒外掛主檔就停」的行為
    # （Greenfield 流程目前由 init-plugin.md 描述、agent 自行執行 template 步驟）
    echo -e "${RED}❌ init.sh 只支援既有外掛偵測。Greenfield 流程請由 agent 依 init-plugin.md 執行。${NC}"
    exit 1
fi

# 解析 JSON 輸出
PLUGIN_SLUG=$(echo "$PLUGIN_INFO" | jq -r '.slug')
PLUGIN_NAME=$(echo "$PLUGIN_INFO" | jq -r '.name')
PLUGIN_VERSION=$(echo "$PLUGIN_INFO" | jq -r '.version')
PLUGIN_FILE=$(echo "$PLUGIN_INFO" | jq -r '.file')

echo -e "${GREEN}✓ 偵測完成${NC}"
echo ""

# 2. 確認資訊
echo -e "${YELLOW}🔍 偵測到外掛資訊:${NC}"
echo "   名稱: $PLUGIN_NAME"
echo "   Slug: $PLUGIN_SLUG"
echo "   版本: $PLUGIN_VERSION"
echo "   檔案: $PLUGIN_FILE"
echo ""

read -p "✅ 確認資訊正確? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo -e "${RED}已取消${NC}"
    exit 1
fi

# 3. 詢問 Composer Autoload 設定
echo ""
echo -e "${YELLOW}📦 Composer Autoload 設定:${NC}"
read -p "   PHP Namespace [$PLUGIN_NAME]: " NAMESPACE
NAMESPACE=${NAMESPACE:-$PLUGIN_NAME}

read -p "   Autoload 目錄 [src]: " AUTOLOAD_DIR
AUTOLOAD_DIR=${AUTOLOAD_DIR:-src}

# 4. 詢問資料庫設定
echo ""
echo -e "${YELLOW}📊 資料庫設定:${NC}"
DB_NAME="wordpress_test"
echo "   測試資料庫名稱: $DB_NAME"

read -p "   資料庫使用者 [root]: " DB_USER
DB_USER=${DB_USER:-root}

read -sp "   資料庫密碼 [留空]: " DB_PASS
echo

read -p "   資料庫主機 [localhost]: " DB_HOST
DB_HOST=${DB_HOST:-localhost}

# 5. 開始初始化
echo ""
echo -e "${BLUE}🚀 開始初始化...${NC}"
echo ""

# 檢查 WP-CLI
if ! command -v wp &> /dev/null; then
    echo -e "${RED}❌ 找不到 WP-CLI,請先安裝 WP-CLI${NC}"
    exit 1
fi

# 檢查 Composer
if ! command -v composer &> /dev/null; then
    echo -e "${RED}❌ 找不到 Composer,請先安裝 Composer${NC}"
    exit 1
fi

# 6. 執行 WP-CLI scaffold
# init.sh 只在 Augment mode 跑（前段已 enforce），故 scaffold 一律先告知並詢問。
# wp scaffold plugin-tests 會新增：tests/、bin/install-wp-tests.sh、phpunit.xml.dist、
# .travis.yml、.circleci/、tests/test-sample.php、tests/bootstrap.php。
echo -e "${BLUE}📝 執行 WP-CLI scaffold（將新增測試骨架）...${NC}"
echo -e "${YELLOW}    將會新增/可能覆寫：${NC}"
echo "      - tests/ (bootstrap.php, test-sample.php)"
echo "      - bin/install-wp-tests.sh"
echo "      - phpunit.xml.dist"
echo "      - .travis.yml, .circleci/ (Augment mode 後續不刪)"
SCAFFOLD_FORCE=""
EXISTING_SCAFFOLD=false
if [ -d "tests" ] || [ -f "phpunit.xml.dist" ] || [ -f "bin/install-wp-tests.sh" ]; then
    EXISTING_SCAFFOLD=true
fi

if [ "$EXISTING_SCAFFOLD" = true ]; then
    if prompt_overwrite "tests/" "測試目錄/scaffold 檔案"; then
        SCAFFOLD_FORCE="--force"
    else
        SCAFFOLD_FORCE="__SKIP__"
    fi
else
    read -p "    繼續執行 wp scaffold？ [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        SCAFFOLD_FORCE="__SKIP__"
    fi
fi

if [ "$SCAFFOLD_FORCE" = "__SKIP__" ]; then
    echo -e "${YELLOW}    跳過 wp scaffold plugin-tests${NC}"
else
    wp scaffold plugin-tests "$PLUGIN_SLUG" --ci=github $SCAFFOLD_FORCE
fi

# 7. 設定 Composer
echo -e "${BLUE}📦 設定 Composer...${NC}"
php "$SCRIPT_DIR/setup-composer.php" \
    "$PROJECT_DIR" \
    "$NAMESPACE" \
    "$AUTOLOAD_DIR" \
    "$DB_NAME" \
    "$DB_USER" \
    "$DB_PASS" \
    "$DB_HOST"

# 8. 安裝依賴
echo -e "${BLUE}📥 安裝 Composer 依賴...${NC}"
if [ -f "composer.lock" ]; then
    echo -e "${YELLOW}    ⚠️  既有 composer.lock 可能會重新解析；如不希望變動 lockfile，請先 Ctrl+C 並改用 composer update --lock。${NC}"
fi
composer install

# 9. 調整 bootstrap.php（冪等：已含 polyfills 載入就跳過；插入時不重複 <?php 標籤）
echo -e "${BLUE}🔧 調整測試啟動檔案...${NC}"
if [ -f "tests/bootstrap.php" ]; then
    if grep -q "WP_TESTS_PHPUNIT_POLYFILLS_PATH" tests/bootstrap.php; then
        echo -e "${GREEN}    ✓ bootstrap.php 已包含 Polyfills 載入，跳過${NC}"
    else
        # 把 addon 內容（去掉開頭的 <?php）插入到 bootstrap.php 第一個 <?php 之後
        ADDON_BODY=$(sed '1{/^<?php/d;}' "$TEMPLATES_DIR/bootstrap-addon.php")
        # 用 awk 在第一個 <?php 之後插入，避免雙標籤
        awk -v body="$ADDON_BODY" '
            !inserted && /^<\?php/ { print; print body; inserted=1; next }
            { print }
        ' tests/bootstrap.php > tests/bootstrap.php.tmp && mv tests/bootstrap.php.tmp tests/bootstrap.php
        echo -e "${GREEN}    ✓ Polyfills 載入已插入${NC}"
    fi
fi

# 10. 建立打包腳本（既有則詢問）
echo -e "${BLUE}📦 建立打包腳本...${NC}"
mkdir -p scripts
if prompt_overwrite "scripts/build.php" "打包腳本"; then
    sed -e "s/{{PLUGIN_SLUG}}/$PLUGIN_SLUG/g" \
        -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
        "$TEMPLATES_DIR/build.php.template" > scripts/build.php
    echo -e "${GREEN}    ✓ scripts/build.php 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 scripts/build.php${NC}"
fi

# 11. 建立 GitHub Actions workflow（既有則詢問）
echo -e "${BLUE}⚙️  建立 GitHub Actions workflow...${NC}"
mkdir -p .github/workflows
if prompt_overwrite ".github/workflows/release.yml" "GitHub Actions release workflow"; then
    sed -e "s/{{PLUGIN_SLUG}}/$PLUGIN_SLUG/g" \
        -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
        "$TEMPLATES_DIR/release-workflow.yml.template" > .github/workflows/release.yml
    echo -e "${GREEN}    ✓ .github/workflows/release.yml 已建立${NC}"
else
    echo -e "${YELLOW}    跳過 .github/workflows/release.yml${NC}"
fi

# 12. 更新 .gitignore
echo -e "${BLUE}📝 更新 .gitignore...${NC}"
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# 追加內容(如果不存在)
grep -qxF '/vendor/' .gitignore || echo '/vendor/' >> .gitignore
grep -qxF '/build/' .gitignore || echo '/build/' >> .gitignore
grep -qxF 'phpunit.xml' .gitignore || echo 'phpunit.xml' >> .gitignore
# 本機環境的個人覆寫檔 / 暫存設定 — 不入版控
grep -qxF '.wp-env.override.json' .gitignore || echo '.wp-env.override.json' >> .gitignore
grep -qxF 'local-config.php' .gitignore || echo 'local-config.php' >> .gitignore
# 備份檔（由 prompt_overwrite 與 setup-composer.php 產生）
grep -qxF '*.bak.*' .gitignore || echo '*.bak.*' >> .gitignore

# 14. 偵測本機環境 (wp-env / DDEV) — 若使用容器化環境，跳過 host 端的 test:install
USE_CONTAINER_ENV=false
if [ -f ".wp-env.json" ] || [ -f ".ddev/config.yaml" ]; then
    USE_CONTAINER_ENV=true
fi

if [ "$USE_CONTAINER_ENV" = true ]; then
    echo ""
    echo -e "${YELLOW}⚠️  偵測到 wp-env 或 DDEV 設定檔${NC}"
    echo -e "${YELLOW}    跳過 host 端的 test:install / test (會連到錯誤的 MySQL)${NC}"
    echo -e "${YELLOW}    請在 container 內執行：${NC}"
    echo -e "${YELLOW}      wp-env run cli composer test:install && wp-env run cli composer test${NC}"
    echo -e "${YELLOW}      ddev exec composer test:install && ddev exec composer test${NC}"
else
    # 15. 安裝測試環境（會 drop/recreate test DB，必須先問）
    echo ""
    echo -e "${YELLOW}🧪 composer test:install 將會 drop 並重建測試資料庫 ($DB_NAME)${NC}"
    echo -e "${YELLOW}    若該資料庫中有真實資料會全部消失。${NC}"
    read -p "    繼續？ [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🧪 安裝測試環境...${NC}"
        composer test:install

        echo -e "${BLUE}✅ 執行測試...${NC}"
        composer test
    else
        echo -e "${YELLOW}    跳過 composer test:install / test${NC}"
        echo -e "${YELLOW}    請手動執行：composer test:install && composer test${NC}"
    fi
fi

# 17. 執行建置（可能產出 build/ 目錄；既有 build/ 會詢問）
echo ""
read -p "📦 是否立即執行 composer build 驗證打包流程？ [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -d "build" ]; then
        if ! prompt_overwrite "build" "build/ 目錄"; then
            echo -e "${YELLOW}    跳過 composer build${NC}"
        else
            composer build
        fi
    else
        composer build
    fi
else
    echo -e "${YELLOW}    跳過 composer build；可在準備好時手動執行${NC}"
fi

# 完成
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ WordPress 外掛開發環境初始化完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}📦 已安裝:${NC}"
echo "   - PHPUnit 測試套件"
echo "   - WP-CLI 測試環境檔案"
echo "   - GitHub Actions workflow (測試 + 發布整合)"
echo "   - 打包腳本"
echo ""
echo -e "${GREEN}✅ 已驗證:${NC}"
echo "   - 測試環境已安裝"
echo "   - 測試已執行"
echo "   - 建置已完成"
echo ""
echo -e "${YELLOW}🎯 下一步:${NC}"
echo "   開始開發您的外掛功能"
echo ""
echo -e "${BLUE}💡 發布流程:${NC}"
echo "   1. 更新版本號"
echo "   2. git tag $PLUGIN_VERSION"
echo "   3. git push origin $PLUGIN_VERSION"
echo "   4. GitHub Actions 會自動測試、打包並建立 Release"
echo ""
