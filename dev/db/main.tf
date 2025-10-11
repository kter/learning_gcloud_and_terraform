# VPCネットワークのデータソース
data "google_compute_network" "vpc_network" {
  name = "vpc-network"
  project = var.project_id
}

# Private Service Connectionのためのグローバルアドレス予約
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc_network.id
  project       = var.project_id
}

# Private Service Connection（VPC Peering）
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "database" {
    name = "database-${terraform.workspace}"
    region = var.region
    project = var.project_id
    database_version = "POSTGRES_16"

    settings {
        tier = "db-f1-micro"
        edition = "ENTERPRISE"
        availability_type = "ZONAL"
        ip_configuration {
            ipv4_enabled = false
            private_network = data.google_compute_network.vpc_network.id
        }
        database_flags {
          name = "cloudsql.iam_authentication"
          value = "on"
        }
        backup_configuration {
          enabled = false
        }
    }
    deletion_protection = false
    
    depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "database" {
    name = "database-${terraform.workspace}"
    instance = google_sql_database_instance.database.name
    project = var.project_id
}

resource "google_sql_user" "iam_service_account_user" {
  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(data.google_service_account.cloudrun_service_account.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.database.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project = var.project_id
}

data "google_service_account" "cloudrun_service_account" {
  account_id = "cloudrun"
  project = var.project_id
}
