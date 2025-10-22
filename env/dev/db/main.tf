terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "dev/db/terraform.tfstate"
  }
}

module "database" {
  source = "../../../modules/db"

  project_id = var.project_id
  region     = var.region

  vpc_network_name = "vpc-network"
  subnetwork_name  = "subnetwork"
}
