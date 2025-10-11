output "cloudrun_service_account_email" {
  value = google_service_account.cloudrun_service_account.email
}

output "cloudrun_service_account_name" {
  value = google_service_account.cloudrun_service_account.name
}