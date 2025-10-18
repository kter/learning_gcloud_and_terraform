data "google_cloud_run_v2_service" "service" {
  name     = var.cloudrun_service_name
  location = var.region
  project  = var.project_id
}

data "google_dns_managed_zone" "dns_zone" {
  count   = var.dns_zone_name != "" ? 1 : 0
  name    = var.dns_zone_name
  project = var.project_id
}

# Network Endpoint Group (Serverless製品向け)
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = var.neg_name
  project               = var.project_id
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = data.google_cloud_run_v2_service.service.name
  }
}

# Backend Service
resource "google_compute_backend_service" "backend_service" {
  name                  = var.backend_service_name
  project               = var.project_id
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.neg.self_link
  }
}

# URL Map (https)
resource "google_compute_url_map" "https_url_map" {
  name            = var.https_url_map_name
  project         = var.project_id
  default_service = google_compute_backend_service.backend_service.self_link
}

# URL Map (http)
resource "google_compute_url_map" "http_url_map" {
  name    = var.http_url_map_name
  project = var.project_id

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# Certificate
resource "google_compute_managed_ssl_certificate" "certificate" {
  name    = var.certificate_name
  project = var.project_id

  managed {
    domains = var.domains
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "target_https_proxy" {
  name             = var.target_https_proxy_name
  project          = var.project_id
  url_map          = google_compute_url_map.https_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.self_link]
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = var.target_http_proxy_name
  project = var.project_id
  url_map = google_compute_url_map.http_url_map.self_link
}

# Global Address
resource "google_compute_global_address" "address" {
  name    = var.global_address_name
  project = var.project_id
}

# Forwarding Rule (https)
resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = var.https_forwarding_rule_name
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.address.address
  target                = google_compute_target_https_proxy.target_https_proxy.self_link
  port_range            = "443"
}

# Forwarding Rule (http)
resource "google_compute_global_forwarding_rule" "http_rule" {
  name                  = var.http_forwarding_rule_name
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol           = "TCP"
  ip_address            = google_compute_global_address.address.address
  target                = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range            = "80"
}

# Authorize access LoadBalancer to Cloud Run
resource "google_cloud_run_service_iam_member" "member" {
  service  = data.google_cloud_run_v2_service.service.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# DNS record to associate domain with load balancer
resource "google_dns_record_set" "domain" {
  count = var.dns_zone_name != "" && var.dns_record_name != "" ? 1 : 0

  name         = var.dns_record_name
  type         = "A"
  ttl          = var.dns_ttl
  managed_zone = data.google_dns_managed_zone.dns_zone[0].name
  project      = var.project_id
  rrdatas      = [google_compute_global_address.address.address]
}
