data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork_name
  project = var.project_id
  region  = var.region
}

data "google_artifact_registry_repository" "repository" {
  repository_id = var.artifact_repository_id
  project       = var.project_id
  location      = var.region
}

data "google_sql_database" "database" {
  name     = var.database_name
  instance = var.database_instance_name
  project  = var.project_id
}

data "google_sql_database_instance" "database" {
  name    = var.database_instance_name
  project = var.project_id
}

data "google_service_account" "service_account" {
  account_id = var.service_account_id
  project    = var.project_id
}

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  deletion_protection = var.deletion_protection

  depends_on = [
    data.google_compute_subnetwork.subnetwork,
    data.google_sql_database_instance.database
  ]

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true

    # リソース再作成時は古いリソースを削除してから新しいリソースを作成
    create_before_destroy = false
  }

  template {
    vpc_access {
      egress = var.vpc_egress
      network_interfaces {
        subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${data.google_compute_subnetwork.subnetwork.name}"
      }
    }

    containers {
      image = "${data.google_artifact_registry_repository.repository.registry_uri}/${var.container_image}"

      ports {
        container_port = var.container_port
      }

      resources {
        limits = var.resource_limits
      }

      dynamic "env" {
        for_each = var.environment_variables

        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      # DB接続用の環境変数
      env {
        name  = "DB_NAME"
        value = data.google_sql_database.database.name
      }

      env {
        name  = "DB_USER"
        value = trimsuffix(data.google_service_account.service_account.email, ".gserviceaccount.com")
      }

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = "${var.project_id}:${var.region}:${data.google_sql_database_instance.database.name}"
      }
    }

    service_account = data.google_service_account.service_account.email
  }
}
