data "google_compute_network" "vpc_network" {
  name    = var.vpc_network_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork_name
  project = var.project_id
  region  = var.region
}

data "google_service_account" "cloudrun_service_account" {
  account_id = var.cloudrun_service_account_id
  project    = var.project_id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  deletion_policy = "ABANDON"

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true
  }
}

resource "google_sql_database_instance" "database" {
  name             = "${var.database_instance_name_prefix}-${terraform.workspace}"
  region           = var.region
  project          = var.project_id
  database_version = var.database_version

  settings {
    tier              = var.database_tier
    edition           = var.database_edition
    availability_type = var.database_availability_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc_network.id
    }

    dynamic "database_flags" {
      for_each = var.database_flags

      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    backup_configuration {
      enabled = var.backup_enabled
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true

    create_before_destroy = false
  }
}

resource "google_sql_database" "database" {
  name     = google_sql_database_instance.database.name
  instance = google_sql_database_instance.database.name
  project  = var.project_id
}

resource "google_sql_user" "iam_service_account_user" {
  name     = trimsuffix(data.google_service_account.cloudrun_service_account.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.database.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

resource "google_service_account" "bastion" {
  account_id   = var.bastion_account_id
  display_name = var.bastion_display_name
  project      = var.project_id
}

resource "google_sql_user" "bastion_iam_user" {
  name     = trimsuffix(google_service_account.bastion.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.database.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

resource "google_project_iam_member" "bastion_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "bastion_sql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_compute_router" "router" {
  name    = "${var.nat_router_name_prefix}-${terraform.workspace}"
  network = data.google_compute_network.vpc_network.name
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.nat_name_prefix}-${terraform.workspace}"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance" "bastion" {
  name         = "${var.bastion_name_prefix}-${terraform.workspace}"
  machine_type = var.bastion_machine_type
  zone         = "${var.region}-${var.bastion_zone_suffix}"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = var.bastion_boot_image
      size  = var.bastion_boot_disk_size_gb
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnetwork.self_link
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    GRANTS_MARKER="/var/tmp/db_grants_applied"

    if [ -f "$GRANTS_MARKER" ]; then
      exit 0
    fi

    apt-get update
    apt-get install -y postgresql-client curl

    if [ ! -x /usr/local/bin/cloud-sql-proxy ]; then
      curl -sSfL -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.2/cloud-sql-proxy.linux.amd64
      chmod +x /usr/local/bin/cloud-sql-proxy
    fi

    INSTANCE_CONNECTION_NAME="${var.project_id}:${var.region}:${google_sql_database_instance.database.name}"
    DB_NAME="${google_sql_database.database.name}"
    CLOUDRUN_USER="${google_sql_user.iam_service_account_user.name}"
    BASTION_USER="${google_sql_user.bastion_iam_user.name}"
    POSTGRES_PASSWORD='${replace(random_password.admin_password.result, "'", "'\"'\"'")}'

    echo "Starting Cloud SQL Proxy for permission grants..."
    cloud-sql-proxy --private-ip "$INSTANCE_CONNECTION_NAME" --port 5432 --address 127.0.0.1 &
    PROXY_PID=$!

    cleanup() {
      kill "$PROXY_PID" 2>/dev/null || true
    }
    trap cleanup EXIT

    for _ in $(seq 1 30); do
      if pg_isready -h 127.0.0.1 -p 5432 -U postgres >/dev/null 2>&1; then
        break
      fi
      sleep 2
    done

    echo "Granting permissions to IAM users..."
    PGPASSWORD="$POSTGRES_PASSWORD" psql \
      -h 127.0.0.1 \
      -p 5432 \
      -U postgres \
      -d "$DB_NAME" <<SQL
    \\set ON_ERROR_STOP on

    ALTER ROLE "$CLOUDRUN_USER" WITH LOGIN;
    GRANT CONNECT ON DATABASE "$DB_NAME" TO "$CLOUDRUN_USER";
    GRANT USAGE ON SCHEMA public TO "$CLOUDRUN_USER";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "$CLOUDRUN_USER";

    ALTER ROLE "$BASTION_USER" WITH LOGIN;
    GRANT CONNECT ON DATABASE "$DB_NAME" TO "$BASTION_USER";
    GRANT USAGE ON SCHEMA public TO "$BASTION_USER";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "$BASTION_USER";

    GRANT pg_write_all_data TO "$CLOUDRUN_USER";
    GRANT pg_write_all_data TO "$BASTION_USER";
    GRANT pg_read_all_data TO "$BASTION_USER";
    SQL

    touch "$GRANTS_MARKER"
    echo "Bastion host setup completed" > /tmp/setup_complete
  EOT

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = var.bastion_tags
}

resource "google_compute_firewall" "bastion_iap_ssh" {
  name    = var.bastion_firewall_name
  network = data.google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = var.bastion_tags
  description   = "Allow SSH from IAP"
}

resource "random_password" "admin_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "admin_user" {
  project  = var.project_id
  name     = "postgres"
  instance = google_sql_database_instance.database.name
  password = random_password.admin_password.result
}
