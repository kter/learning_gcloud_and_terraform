output "service_url" {
  description = "URL of the Cloud Run service"
  value       = module.cloudrun.service_url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = module.cloudrun.service_name
}

output "service_location" {
  description = "Location of the Cloud Run service"
  value       = module.cloudrun.service_location
}
