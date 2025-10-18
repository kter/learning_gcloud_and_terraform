# ==============================================================================
# 🚀 Learning GCloud and Terraform - Developer Experience Optimized Makefile
# ==============================================================================
#
# 新規開発者へ: 以下を実行するだけ！
#   $ make
#
# これだけで全て自動セットアップされます！
# ==============================================================================

.DEFAULT_GOAL := init
.PHONY: init setup auto-install-uv auto-install-tfenv auto-install-terraform auto-install-tflint auto-setup lint fmt check update clean reset build help

# ------------------------------------------------------------------------------
# 🎯 デフォルトターゲット - makeだけで全てセットアップ
# ------------------------------------------------------------------------------
init: banner auto-check auto-setup completion ## 🚀 初回セットアップ（makeだけでOK）

setup: init ## 🔧 セットアップ（make と同じ）

banner:
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  🚀 Learning GCloud and Terraform - Auto Setup           ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""

# ------------------------------------------------------------------------------
# 🤖 自動チェック・自動インストール
# ------------------------------------------------------------------------------
auto-check: auto-install-uv auto-install-tfenv auto-install-terraform auto-install-tflint ## すべての依存関係を自動チェック・インストール

auto-install-uv:
	@if ! command -v uv &> /dev/null; then \
		echo "📦 uv が見つかりません。自動インストールします..."; \
		echo ""; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo ""; \
		echo "✅ uv をインストールしました"; \
		echo "⚠️  シェルを再起動するか、以下を実行してください:"; \
		echo "   source $$HOME/.cargo/env"; \
		echo ""; \
		echo "その後、再度 'make' を実行してください"; \
		exit 1; \
	else \
		echo "✅ uv: $$(uv --version)"; \
	fi

auto-install-tfenv:
	@if ! command -v tfenv &> /dev/null; then \
		echo ""; \
		echo "📦 tfenv が見つかりません"; \
		echo ""; \
		if command -v brew &> /dev/null; then \
			echo "🍺 Homebrew経由で自動インストールします..."; \
			brew install tfenv; \
			echo "✅ tfenv をインストールしました"; \
		else \
			echo "❌ Homebrewが見つかりません"; \
			echo ""; \
			echo "以下のいずれかの方法でtfenvをインストールしてください:"; \
			echo ""; \
			echo "1. Homebrew経由（推奨）:"; \
			echo "   /bin/bash -c \"\$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
			echo "   brew install tfenv"; \
			echo ""; \
			echo "2. 手動インストール:"; \
			echo "   git clone https://github.com/tfutils/tfenv.git ~/.tfenv"; \
			echo "   echo 'export PATH=\"\$$HOME/.tfenv/bin:\$$PATH\"' >> ~/.bashrc"; \
			echo ""; \
			exit 1; \
		fi \
	else \
		echo "✅ tfenv: installed"; \
	fi

auto-install-terraform:
	@if [ -f .terraform-version ]; then \
		if ! command -v terraform &> /dev/null; then \
			echo ""; \
			echo "📦 Terraform をインストールします..."; \
			tfenv install; \
			echo "✅ Terraform をインストールしました"; \
		else \
			echo "✅ terraform: $$(terraform version -json 2>/dev/null | grep -o '\"terraform_version\":\"[^\"]*' | cut -d'\"' -f4)"; \
		fi \
	fi

auto-install-tflint:
	@if ! command -v tflint &> /dev/null; then \
		echo ""; \
		echo "📦 tflint が見つかりません"; \
		echo ""; \
		if command -v brew &> /dev/null; then \
			echo "🍺 Homebrew経由で自動インストールします..."; \
			brew install tflint; \
			echo "✅ tflint をインストールしました"; \
		else \
			echo "❌ Homebrewが見つかりません"; \
			echo ""; \
			echo "以下のコマンドでtflintをインストールしてください:"; \
			echo ""; \
			echo "macOS/Linux:"; \
			echo "  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"; \
			echo ""; \
			exit 1; \
		fi \
	else \
		echo "✅ tflint: $$(tflint --version | head -n1)"; \
	fi

# ------------------------------------------------------------------------------
# 🔧 自動セットアップ
# ------------------------------------------------------------------------------
auto-setup: ## 開発環境を自動セットアップ
	@echo ""
	@echo "🔧 開発環境をセットアップ中..."
	@echo ""
	@echo "📦 pre-commit をインストール中..."
	@uv tool install pre-commit 2>/dev/null || uv tool upgrade pre-commit 2>/dev/null || true
	@echo "✅ pre-commit インストール完了"
	@echo ""
	@echo "🪝 Git hooks をセットアップ中..."
	@pre-commit install --hook-type pre-commit --hook-type pre-push >/dev/null 2>&1
	@echo "✅ Git hooks セットアップ完了"
	@echo ""

completion:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  ✨ セットアップ完了！                                    ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "🎉 準備完了！あとは普通のgitコマンドを使うだけです："
	@echo ""
	@echo "  git commit -m \"fix\"   # 高速コミット（軽量チェックのみ）"
	@echo "  git push               # 自動でlint実行→プッシュ"
	@echo ""
	@echo "💡 その他のコマンド:"
	@echo "  make help              # 全コマンド表示"
	@echo "  make check             # 環境チェック"
	@echo "  make lint              # 手動でlint実行"
	@echo ""

# ------------------------------------------------------------------------------
# 🎨 開発コマンド
# ------------------------------------------------------------------------------
lint: auto-install-tflint ## ✨ 手動でLintチェック（通常は不要、git push時に自動実行）
	@echo "✨ コードをチェック中..."
	@pre-commit run --all-files || true
	@echo "✅ チェック完了"

fmt: lint ## 🎨 コード整形（lintと同じ）

# ------------------------------------------------------------------------------
# 🔍 環境チェック
# ------------------------------------------------------------------------------
check: ## 🔍 開発環境の状態を確認
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  🔍 開発環境チェック                                      ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@printf "%-20s " "uv:"
	@command -v uv >/dev/null 2>&1 && echo "✅ $$(uv --version)" || echo "❌ 未インストール"
	@printf "%-20s " "tfenv:"
	@command -v tfenv >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@printf "%-20s " "terraform:"
	@command -v terraform >/dev/null 2>&1 && echo "✅ $$(terraform version -json 2>/dev/null | grep -o '\"terraform_version\":\"[^\"]*' | cut -d'\"' -f4)" || echo "❌ 未インストール"
	@printf "%-20s " "pre-commit:"
	@command -v pre-commit >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@printf "%-20s " "tflint:"
	@command -v tflint >/dev/null 2>&1 && echo "✅ $$(tflint --version | head -n1)" || echo "❌ 未インストール"
	@printf "%-20s " "Git hooks:"
	@[ -f .git/hooks/pre-commit ] && echo "✅ セットアップ済み" || echo "❌ 未セットアップ"
	@echo ""
	@if command -v uv >/dev/null 2>&1 && command -v tfenv >/dev/null 2>&1 && command -v tflint >/dev/null 2>&1 && [ -f .git/hooks/pre-commit ]; then \
		echo "✅ 開発環境は正常です！"; \
	else \
		echo "⚠️  セットアップが必要です: make init"; \
	fi
	@echo ""

# ------------------------------------------------------------------------------
# 🛠️  メンテナンス
# ------------------------------------------------------------------------------
update: ## 🔄 全ツールを最新版に更新
	@echo "🔄 ツールを更新中..."
	@uv tool upgrade pre-commit 2>/dev/null || true
	@pre-commit autoupdate
	@echo "✅ 更新完了"

clean: ## 🧹 キャッシュをクリーンアップ
	@echo "🧹 クリーンアップ中..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -type d -name ".venv" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ クリーンアップ完了"

reset: clean ## 🔄 完全リセット（hooks含む）
	@echo "🔄 完全リセット中..."
	@pre-commit uninstall --hook-type pre-commit --hook-type pre-push 2>/dev/null || true
	@echo "✅ リセット完了"
	@echo ""
	@echo "再セットアップする場合: make init"

# ------------------------------------------------------------------------------
# 📦 デプロイ
# ------------------------------------------------------------------------------
build: ## 📦 Dockerイメージをビルド＆プッシュ
	@cd app && $(MAKE) buildpush

# ------------------------------------------------------------------------------
# 📚 ヘルプ
# ------------------------------------------------------------------------------
help: ## 📚 このヘルプを表示
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║  📚 使用可能なコマンド                                    ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "🚀 初回セットアップ:"
	@echo "  make (setup)      全自動セットアップ"
	@echo ""
	@echo "📝 日常的な開発:"
	@echo "  git commit        コミット（自動で軽量チェック実行）"
	@echo "  git push          プッシュ（自動でlint実行）"
	@echo ""
	@echo "🔧 便利コマンド:"
	@echo "  make lint         手動でlint実行"
	@echo "  make fmt          コード整形"
	@echo "  make check        環境チェック"
	@echo "  make update       ツール更新"
	@echo "  make clean        キャッシュ削除"
	@echo "  make reset        完全リセット"
	@echo "  make build        Dockerビルド＆プッシュ"
	@echo ""
	@echo "💡 Philosophy:"
	@echo "  - 初回に 'make' を一度実行するだけ"
	@echo "  - 以降は普通の git コマンドを使うだけ"
	@echo "  - git commit: 軽量チェック（高速）"
	@echo "  - git push: 全lintチェック（品質保証）"
	@echo "  - 究極の認知負荷ゼロ！"
	@echo ""

# ------------------------------------------------------------------------------
# 詳細ヘルプ（従来の形式）
# ------------------------------------------------------------------------------
help-detailed: ## 📚 詳細ヘルプ（全コマンド）
	@echo ""
	@echo "全コマンド一覧:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
