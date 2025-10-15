# Task Completion Checklist
- Format Terraform files with `terraform fmt` (run from `dev/` or the touched module directory).
- Run `terraform plan` for each affected module (or `make plan` from `dev/`) to confirm desired changes before delivery.
- For application changes under `dev/container`, rebuild locally via `docker-compose up --build` and sanity-check the Flask UI/API; rebuild/push images with `make buildpush` when preparing for Cloud Run.
- Update docs/READMEs and `.env.example` when altering environment variables or deployment steps.
- Ensure `git status` shows only intentional changes (state files are present but avoid modifying them unless required).