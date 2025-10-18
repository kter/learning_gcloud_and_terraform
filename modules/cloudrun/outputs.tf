output "service_url" {
  value       = google_cloud_run_v2_service.service.uri
  description = "URL of the Cloud Run service"
}

output "service_name" {
  value       = google_cloud_run_v2_service.service.name
  description = "Name of the Cloud Run service"
}

output "service_location" {
  value       = google_cloud_run_v2_service.service.location
  description = "Location of the Cloud Run service"
}

output "service_id" {
  value       = google_cloud_run_v2_service.service.id
  description = "ID of the Cloud Run service"
}
