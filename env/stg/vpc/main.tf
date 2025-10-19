module "vpc" {
  source = "../../../modules/vpc"

  project_id              = var.project_id
  region                  = var.region
  network_name            = "vpc-network"
  subnetwork_name         = "subnetwork"
  ip_cidr_range           = "10.0.0.0/24"
  auto_create_subnetworks = false
}
