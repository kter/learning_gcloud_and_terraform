terraform {
  // terraformのバージョンを現在の最新のバージョン以降で指定
  required_version = "~> 1.13.1"

  // GCSバックエンド設定
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "dev/terraform.tfstate"
  }

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
    "managed-by"  = "terraform"
    "environment" = "dev"
    "repository"  = "learning_gcloud_and_terraform"
  }
}
