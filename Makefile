# Desktop App Manager - Makefile
# macOSアプリケーション配置自動化ツール

# ビルドディレクトリ
BUILD_DIR = build
EXECUTABLE = $(BUILD_DIR)/desktop-app-manager

# デフォルトターゲット（ヘルプを表示）
.PHONY: help
help:
	@echo "🚀 Desktop App Manager - Make Commands"
	@echo "========================================"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build         - アプリケーションをビルド"
	@echo "  make clean         - ビルドディレクトリをクリーン"
	@echo "  make rebuild       - クリーン後に再ビルド"
	@echo ""
	@echo "Execution Commands:"
	@echo "  make space1        - Space 1: Slack (メインディスプレイ)"
	@echo "  make space2        - Space 2: TablePlus + Postman (外部モニター)"
	@echo "  make space3        - Space 3: iTerm + Cursor (外部モニター)"
	@echo "  make space4        - Space 4: Google Chrome (外部モニター)"
	@echo "  make space-all     - Space 1-4を順次配置 (space1→space2→space3→space4)"
	@echo "  make all           - 全スペースを一括配置"
	@echo ""
	@echo "Shortcuts:"
	@echo "  make slack         - Space 1 (Slack) のエイリアス"
	@echo "  make db            - Space 2 (Database tools) のエイリアス"
	@echo "  make dev           - Space 3 (Development) のエイリアス"
	@echo "  make browser       - Space 4 (Browser) のエイリアス"
	@echo ""
	@echo "Other Commands:"
	@echo "  make test          - アプリケーションのヘルプを表示"
	@echo "  make check         - アクセシビリティ権限を確認"

# ビルドコマンド
.PHONY: build
build:
	@echo "🔨 Building Desktop App Manager..."
	@make clean
	@./build.sh
	@echo "✅ Build completed"

# クリーンコマンド
.PHONY: clean
clean:
	@echo "🧹 Cleaning build directory..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Clean completed"

# 再ビルドコマンド
.PHONY: rebuild
rebuild: clean build

# Space 1: Slack（メインディスプレイ）
.PHONY: space1
space1: build
	@echo "📱 Arranging Space 1: Slack on Main Display..."
	@$(EXECUTABLE) --external-space1

# Space 2: TablePlus + Postman（外部モニター）
.PHONY: space2
space2: build
	@echo "🗄️ Arranging Space 2: TablePlus + Postman on External Monitor..."
	@$(EXECUTABLE) --external-space2

# Space 3: iTerm + Cursor（外部モニター）
.PHONY: space3
space3: build
	@echo "💻 Arranging Space 3: iTerm + Cursor on External Monitor..."
	@$(EXECUTABLE) --external-space3

# Space 4: Google Chrome（外部モニター）
.PHONY: space4
space4: build
	@echo "🌐 Arranging Space 4: Google Chrome on External Monitor..."
	@$(EXECUTABLE) --external-space4

# 全スペース1-4を順次配置
.PHONY: space-all
space-all: space1 space2 space3 space4
	@echo "🎉 All spaces arranged successfully!"

# 全スペース一括配置
.PHONY: all
all: build
	@echo "🚀 Arranging ALL spaces..."
	@$(EXECUTABLE) --organize-all


# エイリアスコマンド
.PHONY: slack
slack: space1

.PHONY: db
db: space2

.PHONY: dev
dev: space3

.PHONY: browser
browser: space4

# テストコマンド（ヘルプ表示）
.PHONY: test
test: build
	@$(EXECUTABLE) --help

# アクセシビリティ権限確認
.PHONY: check
check:
	@echo "🔍 Checking accessibility permissions..."
	@echo ""
	@echo "To grant accessibility permission:"
	@echo "1. Open System Preferences > Security & Privacy > Privacy"
	@echo "2. Select 'Accessibility' from the left panel"
	@echo "3. Add Terminal (or desktop-app-manager) and check the box"
	@echo ""
	@echo "Current permission status:"
	@if [ -x $(EXECUTABLE) ]; then \
		echo "  ✅ Executable found at $(EXECUTABLE)"; \
	else \
		echo "  ❌ Executable not found. Run 'make build' first"; \
	fi

# デフォルトで実行（Space 2）
.PHONY: default
default: space2

# watchモード（ファイル変更を監視して自動再ビルド）
# 注: fswatch がインストールされている必要があります
# brew install fswatch
.PHONY: watch
watch:
	@echo "👁️ Watching for file changes..."
	@echo "Press Ctrl+C to stop"
	@which fswatch > /dev/null || (echo "❌ fswatch not found. Install with: brew install fswatch" && exit 1)
	@fswatch -o *.swift | xargs -n1 -I{} make build

# インストール（/usr/local/binにコピー）
.PHONY: install
install: build
	@echo "📦 Installing to /usr/local/bin..."
	@sudo cp $(EXECUTABLE) /usr/local/bin/
	@echo "✅ Installed successfully"
	@echo "You can now run 'desktop-app-manager' from anywhere"

# アンインストール
.PHONY: uninstall
uninstall:
	@echo "🗑️ Uninstalling from /usr/local/bin..."
	@sudo rm -f /usr/local/bin/desktop-app-manager
	@echo "✅ Uninstalled successfully"