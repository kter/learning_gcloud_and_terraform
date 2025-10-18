module "loadbalancer" {
  source = "../../../modules/loadbalancer"

  project_id            = var.project_id
  region                = var.region
  cloudrun_service_name = "django-service"
  domains               = ["dev.gcp.tomohiko.io"]
  dns_zone_name         = "dev-gcp-tomohiko-io"
  dns_record_name       = "dev.gcp.tomohiko.io."
  dns_ttl               = 300
}
