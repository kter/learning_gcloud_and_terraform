terraform {
  required_version = "~> 1.5.0"

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
    "managed-by"  = "terraform"
    "environment" = "deploy"
    "repository"  = "learning_gcloud_and_terraform"
  }
}

resource "google_artifact_registry_repository" "app_repository" {
  project       = var.project_id
  location      = var.region
  repository_id = "app"
  description   = "Shared container repository for application"
  format        = "DOCKER"

  cleanup_policies {
    id     = "cleanup-policy"
    action = "DELETE"
    condition {
      older_than = "30d"
    }
  }
}

# Grant Artifact Registry Reader role to dev environment service account
resource "google_artifact_registry_repository_iam_member" "dev_cloudrun_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.app_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:cloudrun@gcloud-and-terraform.iam.gserviceaccount.com"
}

# Grant Artifact Registry Reader role to stg environment service account
resource "google_artifact_registry_repository_iam_member" "stg_cloudrun_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.app_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:cloudrun@gcloud-and-terraform-stg.iam.gserviceaccount.com"
}

# Grant Artifact Registry Reader role to stg Cloud Run Service Agent
# This is required for Cloud Run to pull images from a different project
# GCPが自動で作成するが、Artifact RegistryとCloud Runが別プロジェクトであれば手動で作成する必要がある
resource "google_artifact_registry_repository_iam_member" "stg_service_agent_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.app_repository.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-550365073229@serverless-robot-prod.iam.gserviceaccount.com"
}
