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
# 注意: このリソースの削除には時間がかかる場合があります
# また、Cloud SQLなどの依存リソースが完全に削除されるまで削除できません
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  # 削除時にピアリング接続も自動削除
  deletion_policy = "ABANDON"

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true
  }
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

    # 削除保護を無効化（開発環境用）
    # 本番環境では true に設定することを推奨
    deletion_protection = false

    depends_on = [google_service_networking_connection.private_vpc_connection]

    lifecycle {
      # 本番環境では以下をコメント解除
      # prevent_destroy = true

      # データベースの削除には時間がかかるため、タイムアウトを考慮
      # インスタンス名が変更された場合は新しいインスタンスを先に作成
      create_before_destroy = false
    }
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

# Bastion用のIAMユーザー
resource "google_sql_user" "bastion_iam_user" {
  # Note: for Postgres only, GCP requires omitting the ".gserviceaccount.com" suffix
  # from the service account email due to length limits on database usernames.
  name     = trimsuffix(google_service_account.bastion.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.database.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

data "google_service_account" "cloudrun_service_account" {
  account_id = "cloudrun"
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name    = "subnetwork"
  project = var.project_id
  region  = var.region
}

# Cloud Router（Cloud NATに必要）
resource "google_compute_router" "router" {
  name    = "nat-router-${terraform.workspace}"
  network = data.google_compute_network.vpc_network.name
  region  = var.region
  project = var.project_id
}

# Cloud NAT（外部IPなしでインターネットアクセス）
resource "google_compute_router_nat" "nat" {
  name                               = "nat-${terraform.workspace}"
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

# 踏み台サーバー用のサービスアカウント
resource "google_service_account" "bastion" {
  account_id   = "bastion"
  display_name = "Bastion Host Service Account"
  project      = var.project_id
}

# Cloud SQL Client権限を付与
resource "google_project_iam_member" "bastion_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# Bastion用サービスアカウントにIAM認証に必要なinstanceUser権限を付与
resource "google_project_iam_member" "bastion_sql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# 踏み台GCEインスタンス
resource "google_compute_instance" "bastion" {
  name         = "bastion-${terraform.workspace}"
  machine_type = "e2-micro"  # 最小構成
  zone         = "${var.region}-a"
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnetwork.self_link
    
    # 外部IPは不要（IAP経由でアクセス）
    # access_config {}
  }

  # Cloud SQL Proxyとpsqlをインストールし、IAMユーザー権限を自動付与
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    GRANTS_MARKER="/var/tmp/db_grants_applied"

    if [ -f "$GRANTS_MARKER" ]; then
      exit 0
    fi

    # パッケージ更新と必要パッケージのインストール
    apt-get update
    apt-get install -y postgresql-client curl

    # Cloud SQL Proxyをインストール（存在しない場合のみ）
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

    -- Cloud Run用IAMユーザーにLOGIN権限と権限を付与
    ALTER ROLE "$CLOUDRUN_USER" WITH LOGIN;
    GRANT CONNECT ON DATABASE "$DB_NAME" TO "$CLOUDRUN_USER";
    GRANT USAGE ON SCHEMA public TO "$CLOUDRUN_USER";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "$CLOUDRUN_USER";

    -- Bastion用IAMユーザーにLOGIN権限と権限を付与
    ALTER ROLE "$BASTION_USER" WITH LOGIN;
    GRANT CONNECT ON DATABASE "$DB_NAME" TO "$BASTION_USER";
    GRANT USAGE ON SCHEMA public TO "$BASTION_USER";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "$BASTION_USER";

    -- 組み込みロールを付与して既存テーブル/シーケンスにもアクセスできるようにする
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

  # IAP経由でSSH接続できるようにメタデータを設定
  metadata = {
    enable-oslogin = "TRUE"
  }

  tags = ["bastion"]
}

# IAP経由のSSH接続を許可するファイアウォールルール
resource "google_compute_firewall" "bastion_iap_ssh" {
  name    = "allow-bastion-iap-ssh"
  network = data.google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP用の固定IPレンジ
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]
  
  description = "Allow SSH from IAP"
}

# 管理用ユーザー
resource "random_password" "admin_password" {
  length = 32
  special = true
}

resource "google_sql_user" "admin_user" {
  project = var.project_id
  name = "postgres"
  instance = google_sql_database_instance.database.name
  password = random_password.admin_password.result
}
