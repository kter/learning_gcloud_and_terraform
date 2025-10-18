output "service_account_email" {
  value       = google_service_account.this.email
  description = "Email address of the managed service account."
}

output "service_account_name" {
  value       = google_service_account.this.name
  description = "Fully qualified resource name of the managed service account."
}
