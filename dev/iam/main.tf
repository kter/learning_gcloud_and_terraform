terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "iam/terraform.tfstate"
  }
}

resource "google_service_account" "cloudrun_service_account" {
  account_id = "cloudrun"
  display_name = "Cloud Run Service Account"
  project = var.project_id
}

resource "google_project_iam_member" "cloudrun_sql_client" {
  project = var.project_id
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.cloudrun_service_account.email}"
}

# Cloud Run用サービスアカウントにIAM認証に必要なinstanceUser権限を付与
resource "google_project_iam_member" "cloudrun_sql_instance_user" {
  project = var.project_id
  role = "roles/cloudsql.instanceUser"
  member = "serviceAccount:${google_service_account.cloudrun_service_account.email}"
}
