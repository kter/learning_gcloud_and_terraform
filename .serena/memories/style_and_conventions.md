# Style and Conventions
- Terraform modules live in separate folders; resource names use snake_case and include descriptive comments (often bilingual JP/EN) to capture operational caveats.
- `terraform { backend ... }` blocks exist in both the root and module scopes; keep provider versions aligned with `dev/.terraform-version` (1.13.1) and the `required_providers` constraints.
- Python app follows a lightweight Flask factory (`create_app`) with Blueprints; configuration is selected via `ENV` env var and classes in `config.py` (local vs Cloud Run IAM/Cloud SQL connector).
- Python files use docstrings for module/class/function descriptions and rely on SQLAlchemy ORM (`models.py`) and Blueprints (`routes.py`); prefer idiomatic Flask patterns and keep environment-driven settings in `config.py`.
- Docker/Compose files assume linux/x86_64 builds and Cloud Run-compatible images; update the Artifact Registry path consistently when renaming resources.