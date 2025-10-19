variable "project_id" {
  type        = string
  description = "Project ID where Artifact Registry repository is managed"
  default     = "gcloud-and-terraform"
}

variable "region" {
  type        = string
  description = "Region for Artifact Registry repository"
  default     = "asia-northeast1"
}

variable "grant_dev_access" {
  type        = bool
  description = "Grant access to dev environment service account"
  default     = true
}

variable "grant_stg_access" {
  type        = bool
  description = "Grant access to stg environment service account"
  default     = false
}

variable "stg_project_number" {
  type        = string
  description = "Project number of the staging environment (for Cloud Run Service Agent)"
  default     = ""
}
