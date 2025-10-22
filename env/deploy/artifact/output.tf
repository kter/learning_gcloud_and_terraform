output "registry_url" {
  value       = google_artifact_registry_repository.app_repository.registry_uri
  description = "Base registry URI for application images"
}
