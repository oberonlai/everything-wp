# Everything WP

一套全方位、由 AI 驅動的 WordPress 外掛開發工具組。本專案提供 commands、skills 與 agents，協助 AI 助理依照最佳實踐產出高品質的 WordPress 外掛程式碼。

> 其他語言：[English](README.md)

## 🎯 概觀

Everything WP 設計用於搭配 AI 程式助理（如 Claude、Cursor 等），在維持程式碼品質與 WordPress 編碼規範的前提下，加速 WordPress 外掛開發。

### 主要特色

- **15 個 Commands** — 涵蓋常見外掛開發任務的互動式工作流程
- **3 大 Skill 領域** — 後端、前端與外掛初始化的深度知識庫
- **4 個 Agents** — Planner、Task Executor（支援 TDD）、Code Reviewer 與 Code Quality
- **端到端工作流程** — 從規劃到發佈，搭配 diff 範圍審查與品質檢核
- **WordPress.org Ready** — 內建提交審查與合規檢查

## 📦 安裝方式

### Claude Code（推薦）

以 Claude Code plugin 安裝：

```
/plugin marketplace add oberonlai/everything-wp
/plugin install everything-wp@everything-wp
```

安裝完成後，所有 commands、agents、skills 立即可用。

### 手動安裝（Cursor / 其他工具）

將目錄內容複製到你的 AI 助理設定資料夾：

```bash
# Cursor
cp -r everything-wp/* ~/.cursor/

# Claude Code（手動安裝，取代 plugin install）
cp -r everything-wp/* ~/.claude/
```

### Gemini / Antigravity

在你的設定中加入 skills 路徑即可。

## 🚀 Commands

### 程式碼產生指令

| 指令 | 說明 |
|------|------|
| `/init-plugin` | 初始化外掛開發環境，包含測試套件、GitHub Actions 與 build 腳本 |
| `/init-theme` | 初始化傳統或區塊佈景主題，含模板、PHPCS、PHPStan、PHPUnit、i18n、GitHub Actions 與 build 腳本 |
| `/make-block` | 把參考網址或設計稿圖片變成區塊主題設計系統 — theme.json token、動態區塊、UI 元件庫檢查頁 |
| `/custom-table` | 產生自訂資料表，附帶 Repository 類別處理 CRUD |
| `/list-table` | 產生 WP_List_Table 類別，用於後台資料顯示 |
| `/option-page` | 透過 Settings API 產生 WordPress 設定頁 |
| `/rest-api` | 產生 REST API controller，含驗證與權限檢查 |
| `/wp-ajax` | 產生 AJAX handler，含 nonce 驗證與權限檢查 |
| `/api-wrapper` | 產生對外 API 包裝類別，含 retry 與 logging |
| `/frontend-page` | 產生前端頁面（Shortcode、Block 或 Template） |

### 品質與測試指令

| 指令 | 說明 |
|------|------|
| `/verify` | 執行全部程式碼品質檢查（PHPStan + PHPUnit + PHPCS），重複出現的錯誤模式可提案為 `rules/wp-essentials.md` 規則 |
| `/test` | 執行 PHPUnit 測試並分析失敗原因（開發期快速迭代用） |
| `/test-generate` | 為既有程式碼產生 PHPUnit 測試（補測舊程式碼用，TDD 流程下不需要） |

> 想單獨跑 PHPStan 或 PHPCS，可直接執行 `composer phpstan` / `composer phpcs`。原本獨立的 `/analyse` 與 `/lint` 指令已移除，因為 task-executor 會做 scoped 檢查，`/verify` 則做全量檢查。

### 規劃與審查指令

| 指令 | 說明 |
|------|------|
| `/plan` | 產生實作計畫，存放於 `spec/<feature-name>/`，含 `overview.md` 索引與依開發順序編號的規格檔（`01-`、`02-`…） |
| `/todo` | 依 spec 檔執行開發任務。支援 `--tdd`、`--tdd=unit`、`--tdd=int` 進行 Red-Green-Refactor |
| `/review` | 對目前 diff 進行資深工程師等級的審查（Security、Performance、Simplification、Test gap、i18n），可將通用性缺失提案為 `rules/wp-essentials.md` 規則 |
| `/submit-review` | 檢查外掛是否符合 WordPress.org 提交規範 |
| `/release` | 同步所有檔案的版本號並 commit、tag、push，觸發 release workflow |

## 📚 Skills

### wp-backend
WordPress 後端開發核心知識：
- PHP 編碼規範
- OOP 模式
- 安全性最佳實踐
- 資料庫操作
- 效能優化
- PHPStan 設定
- WordPress.org 提交規則

### wp-frontend
前端開發規範：
- CSS 編碼規範
- JavaScript 編碼規範
- HTML 最佳實踐

### wp-plugin-dev-init
外掛初始化資源：
- Bootstrap 範本
- Activator/Deactivator 類別
- GitHub Actions workflow
- Build 腳本

## 🤖 Agents

### planner
三層次任務拆解（Operation Flow → User Stories → Development Tasks）。掃描程式碼，可選擇性抓取使用者提供的 URL 或 `@skill-name` 參考，並將結構化的 spec 存到 `spec/<feature-name>/`，依功能類型建議是否使用 `--tdd`。

### task-executor
依 spec 檔實作任務，逐項更新 checkbox。支援：
- **Standard 模式**：依專案慣例直接實作
- **TDD 模式**（`--tdd`、`--tdd=unit`、`--tdd=int`）：每個行為都走 Red-Green-Refactor
- **Scoped 品質檢查**：對變更檔案跑 PHPCS / PHPStan，加上完整 PHPUnit，並偵測既有失敗

### code-reviewer
針對 diff、唯讀的資深程式碼審查。報告涵蓋五大面向 — Security、Performance、Simplification、Test coverage gap、i18n — 並附上嚴重度（🔴 Must / 🟡 Should / 🔵 Nice）與具體修正建議。不會直接改動程式碼。

### code-quality
由品質指令呼叫的整合型 agent：
- **generate** 模式：為現有程式碼產生測試（`/test-generate`）
- **test** 模式：執行並分析 PHPUnit 測試（`/test`）
- **verify** 模式：依序執行所有檢查（`/verify`）

### submission-reviewer
針對整個外掛檢查 WordPress.org 提交合規性（license、readme.txt、禁用檔案、第三方服務說明、隱私、可關閉通知）。由 `/submit-review` 呼叫。

## 🔄 建議工作流程

```
/plan <功能描述>                            # → spec/<feature-name>/overview.md + 各 area 檔
       ↓
/todo spec/<feature-name>/<area>.md --tdd  # → 用 Red-Green-Refactor 實作
       ↓
/review                                    # → 對 diff 做五大面向審查
       ↓ 修掉 🔴 / 🟡 項目
/verify                                    # → 全專案品質檢核
       ↓
人類 commit + PR
       ↓ (準備發佈時)
/submit-review                             # → WordPress.org 合規檢查
```

每個指令的範圍不同：

| 指令 | 範圍 | 目的 |
|------|------|------|
| `/todo` Step 5 | 變更檔案（PHPCS/PHPStan）+ 完整測試（PHPUnit） | 確認新程式碼乾淨且沒打壞既有功能 |
| `/review` | 變更檔案（diff） | 抓自動化工具抓不到的問題（安全、效能、i18n 等） |
| `/verify` | 全專案 | 發佈前關卡 — 全量 PHPStan / PHPUnit / PHPCS |
| `/submit-review` | 整個外掛 | wp.org 提交合規性 |

## 📋 使用範例

### 建立新外掛

```
使用者：/init-plugin

AI：我會協助你初始化一個新的 WordPress 外掛。
    [詢問 namespace、autoload 目錄、開發工具]
    [建立 composer.json、phpunit.xml、GitHub Actions 等]
```

### 新增自訂資料表

```
使用者：/custom-table orders

AI：我會建立一個 orders 自訂資料表。
    [詢問欄位、索引、關聯]
    [產生 Orders_Table.php 與 Orders_Repository.php]
```

### 執行品質檢查

```
使用者：/verify

AI：開始完整品質檢查...

    Step 1/3: PHPStan 靜態分析
    ✅ PHPStan Level 6: 0 errors

    Step 2/3: PHPUnit 單元測試
    ✅ 23 tests passed, 92% coverage

    Step 3/3: PHPCS 程式碼風格
    ✅ 0 errors, 0 warnings

    ╔═══════════════════════════════════════╗
    ║      Code Quality Report              ║
    ╠═══════════════════════════════════════╣
    ║ Overall │ ✅ Ready for release!       ║
    ╚═══════════════════════════════════════╝
```

### 準備提交至 WordPress.org

```
使用者：/submit-review

AI：執行 WordPress.org 提交審查...

    ✅ License: 偵測到 GPL-2.0+
    ✅ readme.txt: 所有必要區塊齊備
    ❌ 禁用檔案: 找到 .DS_Store
    ✅ 第三方服務: 已說明
    ✅ 隱私: 無未經同意的追蹤

    需處理：提交前請移除 .DS_Store
```

### 規劃一個功能

```
使用者：/plan 建立一個含時段選擇與 email 確認的預約系統

AI：[Step 1] 掃描 src/ ...
    ## Codebase Analysis
    - Namespace：MyPlugin\ | 分層：Repository/Service/Admin/REST
    - 慣例：Snake_Case 類別、透過 Container DI
    - 可重用：Mailer service、Repository base
    - 衝突：無

    [Step 3] Operation Flow：
    - 顧客瀏覽可選時段
    - 顧客送出含聯絡資訊的預約
    - 管理員審核並確認
    - 寄出 email 確認

    [Step 5] 已儲存計畫至 spec/booking-system/
    - overview.md
    - customer-flow.md
    - admin-flow.md

    下一步：/todo spec/booking-system/customer-flow.md --tdd=int
    原因：REST endpoint + DB 寫入 → 適合 integration tests
```

### 以 TDD 執行任務

```
使用者：/todo spec/booking-system/customer-flow.md --tdd=int

AI：TDD 模式：int

    任務 1/4：建立 Booking entity

    🔴 Red：test_booking_can_be_created — FAILED ✓
    🟢 Green：PASSED ✓
    🔵 Refactor：抽出驗證邏輯 — PASSED ✓

    ✓ 已更新 spec checkbox

    [... 更多任務 ...]

    Step 5 — Scoped 品質檢查
    PHPCS（變更檔案）：✅ clean
    PHPStan（變更檔案）：✅ clean
    PHPUnit（完整）：✅ 47 passed, 0 failed
```

### 審查 Diff

```
使用者：/review

AI：📂 審查檔案：3 個
    📊 發現：🔴 1 Must · 🟡 2 Should · 🔵 1 Nice

    Security
    🔴 src/REST/Booking_Controller.php:58 — 缺少權限檢查
       Code：register_rest_route( ..., 'methods' => 'POST', 'callback' => ... )
       問題：POST endpoint 接受任何已登入使用者，沒有 permission_callback。
       建議：加上 'permission_callback' => fn() => current_user_can( 'edit_posts' )

    Performance
    本區塊未發現問題。

    i18n
    🟡 src/Admin/Booking_Page.php:34 — 字串未經 __() 包裝
       Code：echo '<h2>Booking Management</h2>';
       建議：echo esc_html__( 'Booking Management', 'myplugin' );

    建議：
    - 在 /verify 或開 PR 前先修掉 🔴 權限問題
```

## 📁 目錄結構

```
everything-wp/
├── commands/           # 互動式指令工作流程
│   ├── init-plugin.md
│   ├── init-theme.md
│   ├── custom-table.md
│   ├── list-table.md
│   ├── option-page.md
│   ├── rest-api.md
│   ├── wp-ajax.md
│   ├── api-wrapper.md
│   ├── frontend-page.md
│   ├── verify.md
│   ├── test.md
│   ├── test-generate.md
│   ├── plan.md
│   ├── todo.md
│   ├── review.md
│   └── submit-review.md
│
├── skills/             # 知識庫
│   ├── wp-backend/     # 後端開發
│   │   ├── coding-standards-php.md
│   │   ├── oop-patterns.md
│   │   ├── security.md
│   │   ├── custom-tables.md
│   │   ├── performance.md
│   │   ├── phpstan.md
│   │   └── org-submission.md
│   │
│   ├── wp-frontend/    # 前端開發
│   │   └── coding-standards/
│   │
│   ├── wp-plugin-dev-init/  # 外掛初始化
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   └── scripts/
│   │
│   ├── wp-theme-dev-init/   # 主題初始化（傳統與區塊）
│   └── wp-block-theme-pipeline/ # 網址 → 區塊主題設計系統產線
│       ├── SKILL.md
│       ├── templates/
│       └── scripts/
│
├── agents/             # AI agents
│   ├── planner.md
│   ├── task-executor.md
│   ├── code-reviewer.md
│   ├── code-quality.md
│   └── submission-reviewer.md
│
└── rules/              # 全域規則
    └── wp-essentials.md
```

## 🔧 環境需求

- WordPress 6.0+
- PHP 8.0+
- Composer
- WP-CLI（測試環境用）
- Node.js（前端 build 用）

## 📄 授權

GPL-2.0 or later

## 🙏 致謝

靈感來自 [everything-claude-code](https://github.com/affaan-m/everything-claude-code)。

獻給 WordPress 社群。
