output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.django_service.uri
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.django_service.name
}

output "service_location" {
  description = "Location of the Cloud Run service"
  value       = google_cloud_run_v2_service.django_service.location
}
