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
