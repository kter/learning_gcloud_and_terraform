terraform {
  required_version = "~> 1.13.1"

  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "deploy/artifact/terraform.tfstate"
  }

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
    "Managed by"  = "Terraform"
    "Environment" = "deploy"
    "Repository"  = "learning_gcloud_and_terraform"
  }
}

resource "google_artifact_registry_repository" "django_app_repository" {
  project       = var.project_id
  location      = var.region
  repository_id = "django-app"
  description   = "Shared container repository for Django application"
  format        = "DOCKER"

  cleanup_policies {
    id     = "cleanup-policy"
    action = "DELETE"
    condition {
      older_than = "30d"
    }
  }
}
