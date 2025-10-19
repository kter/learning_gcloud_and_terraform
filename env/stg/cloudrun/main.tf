terraform {
  backend "gcs" {
    bucket = "gcloud-and-terraform-state"
    prefix = "stg/cloudrun/terraform.tfstate"
  }
}

module "cloudrun" {
  source = "../../../modules/cloudrun"

  project_id                    = var.project_id
  region                        = var.region
  service_name                  = "django-service"
  deletion_protection           = false
  subnetwork_name               = "subnetwork"
  vpc_egress                    = "PRIVATE_RANGES_ONLY"
  artifact_repository_id        = "django-app"
  artifact_registry_project_id  = "gcloud-and-terraform"
  container_image               = "app:latest"
  container_port                = 8000
  database_name                 = "database-${terraform.workspace}"
  database_instance_name        = "database-${terraform.workspace}"
  service_account_id            = "cloudrun"

  resource_limits = {
    cpu    = "1"
    memory = "0.5Gi"
  }

  environment_variables = [
    {
      name  = "ENV"
      value = "stg"
    },
    {
      name  = "ALLOWED_HOSTS"
      value = "stg.gcp.tomohiko.io"
    }
  ]
}
