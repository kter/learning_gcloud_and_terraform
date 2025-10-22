terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "stg/loadbalancer/terraform.tfstate"
  }
}

module "loadbalancer" {
  source = "../../../modules/loadbalancer"

  project_id            = var.project_id
  region                = var.region
  cloudrun_service_name = "django-service"
  domains               = ["stg.gcp.tomohiko.io"]
  dns_zone_name         = "stg-gcp-tomohiko-io"
  dns_record_name       = "stg.gcp.tomohiko.io."
  dns_ttl               = 300
}
