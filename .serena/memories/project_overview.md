# Project Overview
- Infrastructure-as-code sandbox for learning Google Cloud; provisions IAM, VPC, Cloud SQL, Cloud Run, Load Balancer, and DNS resources, plus supporting Artifact Registry.
- Terraform 1.13.x with the HashiCorp Google provider (≈7.1.x); state stored in a shared GCS bucket (`gcloud-and-terraform-state`).
- `dev/` holds the active environment with top-level Terraform entrypoints (`main.tf`, `variables.tf`, `Makefile`) and subdirectories for each module (`iam`, `vpc`, `db`, `cloudrun`, `loadbalancer`, `artifact`).
- `dev/container/` contains the Cloud Run application source: a Flask + SQLAlchemy TODO app that can also run locally via Docker Compose.
- Repository currently commits generated Terraform state files inside each module; be cautious when editing or cleaning them up.
