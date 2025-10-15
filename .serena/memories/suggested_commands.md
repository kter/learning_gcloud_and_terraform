# Suggested Commands
- `cd dev && make` — show Terraform workflow targets (`init`, `plan`, `apply`, `destroy`, `destroy-check`, `destroy-force`).
- `cd dev/<module> && terraform init|plan|apply|destroy` — operate on individual Terraform modules when iterating quickly.
- `cd dev && terraform fmt` — format Terraform code before review.
- `cd dev/container && docker-compose up -d` — launch the local Flask TODO stack; follow with `docker-compose exec web flask db upgrade` style commands if migrations are needed.
- `cd dev/container && make buildpush` — build and push the Cloud Run image to Artifact Registry (linux/x86_64 target).
- `gcloud run jobs execute db-migrate --region asia-northeast1` — run the Cloud Run migration job after deploying updates.
- Everyday tooling on macOS sandbox: `git status`, `rg <pattern>`, `ls`, `sed`, `python3`, `terraform`, `gcloud`, `docker`, `docker-compose`.