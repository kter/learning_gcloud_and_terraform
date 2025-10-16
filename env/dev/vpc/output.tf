output "vpc_network" {
  value = google_compute_network.vpc_network.self_link
}

output "subnetwork" {
  value = google_compute_subnetwork.subnetwork.self_link
}