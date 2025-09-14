resource "google_artifact_registry_repository" "django_app_repository" {
  project = var.project_id
  location = var.region
  repository_id = "django-app"
  description = "My repository"
  format = "DOCKER"

  cleanup_policies {
    id = "cleanup-policy"
    action = "DELETE"
    condition {
        older_than = "30d"
    }
  }
}