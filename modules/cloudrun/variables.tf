variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "service_name" {
  type        = string
  description = "Name of the Cloud Run service"
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = false
}

variable "subnetwork_name" {
  type        = string
  description = "Name of the subnetwork for VPC access"
}

variable "vpc_egress" {
  type        = string
  description = "VPC egress setting"
  default     = "PRIVATE_RANGES_ONLY"
}

variable "artifact_repository_id" {
  type        = string
  description = "ID of the Artifact Registry repository"
}

variable "container_image" {
  type        = string
  description = "Container image name with tag (e.g., 'app:latest')"
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 8000
}

variable "resource_limits" {
  type        = map(string)
  description = "Resource limits for the container"
  default = {
    cpu    = "1"
    memory = "0.5Gi"
  }
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables for the container"
  default     = []
}

variable "database_name" {
  type        = string
  description = "Name of the Cloud SQL database"
}

variable "database_instance_name" {
  type        = string
  description = "Name of the Cloud SQL instance"
}

variable "service_account_id" {
  type        = string
  description = "Service account ID for Cloud Run"
}
