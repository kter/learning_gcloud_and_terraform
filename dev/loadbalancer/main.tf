// Network Endpoint Group (Serverless製品向け)
resource "google_compute_region_network_endpoint_group" "neg" {
  name = "neg"
  project = var.project_id
  region = var.region
  network_endpoint_type = "SERVERLESS"
  // SERVERLESSの場合は指定不可
  // network = data.google_compute_network.vpc_network.self_link
  // subnetwork = data.google_compute_subnetwork.subnetwork.self_link
  cloud_run {
    service = data.google_cloud_run_v2_service.service.name
  }
}

// Backend Service
resource "google_compute_backend_service" "backend_service" {
  name = "backend-service"
  project = var.project_id
  // バックエンドがHTTPなのでHTTPを指定
  protocol = "HTTP"
  // インターネット向きLB (EXTERNALはレガシーで非推奨)
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.neg.self_link
  }
}

// URL Map (https)
resource "google_compute_url_map" "https_url_map" {
  name = "https-url-map"
  project = var.project_id
  default_service = google_compute_backend_service.backend_service.self_link
}

// URL Map (http)
resource "google_compute_url_map" "http_url_map" {
    name = "http-url-map"
    project = var.project_id
    default_url_redirect {
        https_redirect = true
        strip_query = false
    }
}

// Certificate
resource "google_compute_managed_ssl_certificate" "certificate" {
  name = "certificate"
  project = var.project_id
  managed {
    domains = ["test.gcp.tomohiko.io"]
  }
}

// Target HTTPS Proxy
resource "google_compute_target_https_proxy" "target_https_proxy" {
  name = "target-https-proxy"
  project = var.project_id
  url_map = google_compute_url_map.https_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.self_link]
}

// Target HTTP Proxy
resource "google_compute_target_http_proxy" "target_http_proxy" {
    name = "target-http-proxy"
    project = var.project_id
    url_map = google_compute_url_map.http_url_map.self_link
}

// Global Address (AWSとは違いIPで設定)
resource "google_compute_global_address" "address" {
  name = "address"
  project = var.project_id
}

// Forwarding Rule (https)
resource "google_compute_global_forwarding_rule" "https_rule" {
  name = "https-rule"
  project = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol = "TCP"
  ip_address = google_compute_global_address.address.address
  target = google_compute_target_https_proxy.target_https_proxy.self_link
  port_range = "443"
}

// Forwarding Rule (http)
resource "google_compute_global_forwarding_rule" "http_rule" {
  name = "http-rule"
  project = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol = "TCP"
  ip_address = google_compute_global_address.address.address
  target = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range = "80"
}

// Authorize access LoadBalancer to Cloud Run
resource "google_cloud_run_service_iam_member" "member" {
    service = data.google_cloud_run_v2_service.service.name
    location = var.region
    project = var.project_id
    // ロールはroles/run.invokerを指定
    role = "roles/run.invoker"
    member = "allUsers"
}

data "google_compute_network" "vpc_network" {
  name = "vpc-network"
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name = "subnetwork"
  project = var.project_id
  region = var.region
}

data "google_cloud_run_v2_service" "service" {
  name = "django-service"
  location = var.region
  project = var.project_id
}