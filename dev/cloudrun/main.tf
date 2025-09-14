terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "cloudrun/terraform.tfstate"
  }
}

resource "google_cloud_run_v2_service" "django_service" {
  name     = "django-service"
  location = var.region
  project  = var.project_id
  deletion_protection = false

  template {
    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${data.google_compute_subnetwork.subnetwork.name}"
      }
    }
    containers {
        image = "${data.google_artifact_registry_repository.django_app_repository.registry_uri}/app:latest"

        ports {
            container_port = 8000
        }
        resources {
          limits = {
            "cpu" = "1"
            "memory" = "0.5Gi"
          }
        }
        env {
            name = "ENV"
            value = "dev"
        }
    }
  }
}

data "google_compute_subnetwork" "subnetwork" {
  name = "subnetwork"
  project = var.project_id
  region = var.region
}

data "google_artifact_registry_repository" "django_app_repository" {
  repository_id = "django-app"
  project = var.project_id
  location = var.region
}