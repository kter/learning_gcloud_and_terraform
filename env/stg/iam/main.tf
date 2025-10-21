terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "stg/iam/terraform.tfstate"
  }
}

module "cloudrun_service_account" {
  source = "../../../modules/iam"

  project_id = var.project_id

  service_account = {
    account_id   = "cloudrun"
    display_name = "Cloud Run Service Account"
  }

  roles = [
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
  ]
}
