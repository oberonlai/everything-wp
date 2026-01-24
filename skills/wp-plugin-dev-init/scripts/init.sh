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
PLUGIN_INFO=$(php "$SCRIPT_DIR/detect-plugin.php" "$PROJECT_DIR")

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 無法偵測外掛資訊${NC}"
    echo "$PLUGIN_INFO"
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
echo -e "${BLUE}📝 執行 WP-CLI scaffold...${NC}"
wp scaffold plugin-tests "$PLUGIN_SLUG" --ci=github --force

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
composer install

# 9. 調整 bootstrap.php
echo -e "${BLUE}🔧 調整測試啟動檔案...${NC}"
if [ -f "tests/bootstrap.php" ]; then
    # 在檔案開頭加入 Polyfills 載入
    cat "$TEMPLATES_DIR/bootstrap-addon.php" | cat - tests/bootstrap.php > temp && mv temp tests/bootstrap.php
fi

# 10. 建立打包腳本
echo -e "${BLUE}📦 建立打包腳本...${NC}"
mkdir -p scripts
sed -e "s/{{PLUGIN_SLUG}}/$PLUGIN_SLUG/g" \
    -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
    "$TEMPLATES_DIR/build.php.template" > scripts/build.php

# 11. 建立 GitHub Actions workflow
echo -e "${BLUE}⚙️  建立 GitHub Actions workflow...${NC}"
mkdir -p .github/workflows
sed -e "s/{{PLUGIN_SLUG}}/$PLUGIN_SLUG/g" \
    -e "s/{{PLUGIN_NAME}}/$PLUGIN_NAME/g" \
    "$TEMPLATES_DIR/release-workflow.yml.template" > .github/workflows/release.yml

# 12. 更新 .gitignore
echo -e "${BLUE}📝 更新 .gitignore...${NC}"
if [ ! -f ".gitignore" ]; then
    touch .gitignore
fi

# 追加內容(如果不存在)
grep -qxF '/vendor/' .gitignore || echo '/vendor/' >> .gitignore
grep -qxF '/build/' .gitignore || echo '/build/' >> .gitignore
grep -qxF 'phpunit.xml' .gitignore || echo 'phpunit.xml' >> .gitignore

# 14. 安裝測試環境
echo -e "${BLUE}🧪 安裝測試環境...${NC}"
composer test:install

# 15. 執行測試
echo -e "${BLUE}✅ 執行測試...${NC}"
composer test

# 16. 執行建置
echo -e "${BLUE}📦 執行建置測試...${NC}"
composer build

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
