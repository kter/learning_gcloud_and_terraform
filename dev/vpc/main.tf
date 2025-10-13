# VPCネットワーク
# 注意: このVPCを削除する前に、以下のリソースを先に削除する必要があります：
# - Cloud Run services/jobs
# - Cloud SQL instances
# - Service Networking Connection (VPC Peering)
# - サーバーレスVPCアクセスコネクタ
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true

    # 削除時に依存リソースがないことを確認
    # 依存リソースが残っている場合は削除に失敗します
  }
}

# サブネットワーク
# 注意: Cloud Runなどのサーバーレスサービスが使用する場合、
# サーバーレスIPアドレスが自動的に割り当てられます
# これらのIPアドレスがクリーンアップされるまでサブネットを削除できません
resource "google_compute_subnetwork" "subnetwork" {
  name          = "subnetwork"
  project       = var.project_id
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region

  lifecycle {
    # 本番環境では以下をコメント解除
    # prevent_destroy = true
  }
}
