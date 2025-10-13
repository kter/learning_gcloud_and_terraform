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

  # Cloud SQL Proxyとpsqlをインストール
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    
    # パッケージ更新
    apt-get update
    
    # PostgreSQLクライアントをインストール
    apt-get install -y postgresql-client
    
    # Cloud SQL Proxyをインストール
    curl -o /usr/local/bin/cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.2/cloud-sql-proxy.linux.amd64
    chmod +x /usr/local/bin/cloud-sql-proxy
    
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

# 踏み台サーバー上で実行する権限付与スクリプト
resource "local_file" "grant_permissions_on_bastion" {
  filename = "${path.module}/grant_permissions_on_bastion.sh"
  content = <<-EOT
#!/bin/bash
set -e

echo "Starting Cloud SQL Proxy (Private IP)..."
cloud-sql-proxy --private-ip ${var.project_id}:${var.region}:${google_sql_database_instance.database.name} &
PROXY_PID=$!

# エラー時の後処理用トラップ
trap "kill $PROXY_PID 2>/dev/null" EXIT

# Proxyの起動を待つ
echo "Waiting for Cloud SQL Proxy to be ready..."
sleep 5

# PostgreSQLに接続して権限を付与
echo "Granting permissions to IAM user: ${google_sql_user.iam_service_account_user.name}"
PGPASSWORD='${random_password.admin_password.result}' psql \
  -h 127.0.0.1 \
  -p 5432 \
  -U postgres \
  -d ${google_sql_database.database.name} \
  <<'SQL'
GRANT ALL PRIVILEGES ON SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO "${google_sql_user.iam_service_account_user.name}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO "${google_sql_user.iam_service_account_user.name}";
SQL

echo "Permissions granted successfully!"
echo "Cleaning up..."
  EOT
  
  file_permission = "0755"
}

# 管理用ユーザーを使用してIAM認証ユーザーにDB作成権限を付与
resource "local_file" "grant_permissions_script" {
  filename = "${path.module}/grant_permissions.sh"
  content = <<-EOT
#!/bin/bash
set -e

# 現在のgcloudプロジェクト設定を保存
ORIGINAL_PROJECT=$(gcloud config get-value project 2>/dev/null)

# 一時的にプロジェクトを切り替え
echo "Setting gcloud project to ${var.project_id}..."
gcloud config set project ${var.project_id} --quiet

echo "Starting Cloud SQL Proxy..."
# Cloud SQL Proxyをバックグラウンドで起動（Private IP対応）
# CLOUDSDK_CORE_PROJECTでデフォルトプロジェクトを明示的に設定
CLOUDSDK_CORE_PROJECT=${var.project_id} cloud-sql-proxy --private-ip ${var.project_id}:${var.region}:${google_sql_database_instance.database.name} &
PROXY_PID=$!

# エラー時の後処理用トラップ
trap "kill $PROXY_PID 2>/dev/null; gcloud config set project $ORIGINAL_PROJECT --quiet" EXIT

# Proxyの起動を待つ
echo "Waiting for Cloud SQL Proxy to be ready..."
sleep 5

# PostgreSQLに接続して権限を付与
echo "Granting permissions to IAM user: ${google_sql_user.iam_service_account_user.name}"
PGPASSWORD='${random_password.admin_password.result}' psql \
  -h 127.0.0.1 \
  -p 5432 \
  -U postgres \
  -d ${google_sql_database.database.name} \
  <<'SQL'
GRANT ALL PRIVILEGES ON SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${google_sql_user.iam_service_account_user.name}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO "${google_sql_user.iam_service_account_user.name}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO "${google_sql_user.iam_service_account_user.name}";
SQL

echo "Permissions granted successfully!"
echo "Cleaning up (Cloud SQL Proxy will be stopped and gcloud project restored)..."
  EOT
  
  file_permission = "0755"
}

output "grant_permissions_command" {
  value = "Run: ${local_file.grant_permissions_script.filename}"
  description = "Command to grant permissions to IAM user"
}
