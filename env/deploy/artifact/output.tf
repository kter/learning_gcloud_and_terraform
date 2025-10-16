output "registry_url" {
  value       = google_artifact_registry_repository.django_app_repository.registry_uri
  description = "Base registry URI for Django application images"
}
