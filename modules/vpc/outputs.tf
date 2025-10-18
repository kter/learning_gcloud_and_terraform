output "vpc_network_self_link" {
  value       = google_compute_network.vpc_network.self_link
  description = "Self link of the VPC network"
}

output "vpc_network_id" {
  value       = google_compute_network.vpc_network.id
  description = "ID of the VPC network"
}

output "vpc_network_name" {
  value       = google_compute_network.vpc_network.name
  description = "Name of the VPC network"
}

output "subnetwork_self_link" {
  value       = google_compute_subnetwork.subnetwork.self_link
  description = "Self link of the subnetwork"
}

output "subnetwork_id" {
  value       = google_compute_subnetwork.subnetwork.id
  description = "ID of the subnetwork"
}

output "subnetwork_name" {
  value       = google_compute_subnetwork.subnetwork.name
  description = "Name of the subnetwork"
}
