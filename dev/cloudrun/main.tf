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
        env {
          name = "DB_NAME"
          value = data.google_sql_database.database.name
        }
        env {
          name = "DB_USER"
          // google_sql_userはdataソースが存在しないので、google_service_accountを使用
          value = trimsuffix(data.google_service_account.cloudrun_service_account.email, ".gserviceaccount.com")

        }
        env {
          name = "DB_HOST"
          value = data.google_sql_database_instance.database.private_ip_address
        }
        env {
          name = "DB_PORT"
          value = "5432"
        }
        env {
          name = "ALLOWED_HOSTS"
          value = "dev.gcp.tomohiko.io"
        }
        env {
          name = "INSTANCE_CONNECTION_NAME"
          value = "${var.project_id}:${var.region}:${data.google_sql_database_instance.database.name}"
        }
    }
    service_account = data.google_service_account.cloudrun_service_account.email
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

data "google_sql_database" "database" {
  name = "database-${terraform.workspace}"
  instance = data.google_sql_database_instance.database.name
  project = var.project_id
}


data "google_sql_database_instance" "database" {
  name = "database-${terraform.workspace}"
  project = var.project_id
}

data "google_service_account" "cloudrun_service_account" {
  account_id = "cloudrun"
  project = var.project_id
}