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

resource "google_vpc_access_connector" "connector" {
  name = "vpc-connector"
  project = var.project_id
  region = var.region
  network = data.google_compute_network.vpc_network.self_link
  // subnetworkと重複しないCIDRを指定
  ip_cidr_range = "10.0.1.0/28"
  max_instances = 3
  min_instances = 2
}

data "google_compute_network" "vpc_network" {
  name = "vpc-network"
  project = var.project_id
}