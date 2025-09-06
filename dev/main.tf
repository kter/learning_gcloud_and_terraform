terraform {
  // terraformのバージョンを現在の最新のバージョン以降で指定
  required_version = "~> 1.13.1"
  // Google Providerの現在の最新のバージョン以降で指定
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.1.1"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    "Managed by" = "Terraform"
    "Environment" = "dev"
    "Repository" = "learning_gcloud_and_terraform"
  }
}