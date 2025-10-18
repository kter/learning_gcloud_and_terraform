output "global_address" {
  value       = google_compute_global_address.address.address
  description = "The global IP address of the load balancer"
}

output "backend_service_id" {
  value       = google_compute_backend_service.backend_service.id
  description = "ID of the backend service"
}

output "ssl_certificate_id" {
  value       = google_compute_managed_ssl_certificate.certificate.id
  description = "ID of the SSL certificate"
}

output "https_forwarding_rule_id" {
  value       = google_compute_global_forwarding_rule.https_rule.id
  description = "ID of the HTTPS forwarding rule"
}

output "http_forwarding_rule_id" {
  value       = google_compute_global_forwarding_rule.http_rule.id
  description = "ID of the HTTP forwarding rule"
}
