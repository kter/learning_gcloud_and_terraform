.PHONY: help lint-tf lint-py lint fmt-tf fmt-py fmt setup-hooks

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# Setup
setup-hooks: ## Setup Git hooks (run this once after cloning)
	@echo "Setting up Git hooks..."
	@git config core.hooksPath .githooks
	@chmod +x .githooks/pre-push
	@echo "✅ Git hooks configured successfully"
	@echo ""
	@echo "Pre-push hook will now run 'make fmt' and 'make lint' before each push."
	@echo "To bypass the hook, use: git push --no-verify"

# Terraform commands
lint-tf: ## Run Terraform linting (format check + tflint)
	@echo "Running Terraform format check..."
	@terraform fmt -check -recursive
	@echo "Running TFLint..."
	@for dir in modules/*/ env/dev/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Linting $$dir"; \
			(cd "$$dir" && tflint --format compact); \
		fi \
	done
	@echo "✅ Terraform linting passed"

fmt-tf: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive
	@echo "✅ Terraform files formatted"

# Python commands
lint-py: ## Run Python linting (black, isort, flake8)
	@echo "Running Black check..."
	@black --check app/app/
	@echo "Running isort check..."
	@isort --check-only app/app/
	@echo "Running Flake8..."
	@flake8 app/app/
	@echo "✅ Python linting passed"

fmt-py: ## Format Python files
	@echo "Formatting Python files..."
	@black app/app/
	@isort app/app/
	@echo "✅ Python files formatted"

# Combined commands
lint: lint-tf lint-py ## Run all linters

fmt: fmt-tf fmt-py ## Format all code

# Docker commands
build: ## Build and push Docker image
	@cd app && $(MAKE) buildpush

# Git commands
check-hooks: ## Check if Git hooks are configured
	@if [ "$$(git config core.hooksPath)" = ".githooks" ]; then \
		echo "✅ Git hooks are configured"; \
	else \
		echo "❌ Git hooks are not configured"; \
		echo "Run 'make setup-hooks' to configure them"; \
	fi
