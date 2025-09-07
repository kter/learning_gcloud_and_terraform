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
    containers {
        image = "nginx:1.28.0-alpine3.21"
        ports {
            container_port = 80
        }
        resources {
          limits = {
            "cpu" = "0.5"
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