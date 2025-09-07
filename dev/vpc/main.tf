resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network"
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "subnetwork"
  project       = var.project_id
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
}
