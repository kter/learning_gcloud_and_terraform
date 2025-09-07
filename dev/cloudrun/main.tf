terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "cloudrun/terraform.tfstate"
  }
}

resource "google_cloud_run_v2_service" "service" {
  name     = "nginx-service"
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
        image = "nginx:1.28.0-alpine3.21"
        ports {
            container_port = 80
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
