variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "network_name" {
  type        = string
  description = "Name of the VPC network"
}

variable "subnetwork_name" {
  type        = string
  description = "Name of the subnetwork"
}

variable "ip_cidr_range" {
  type        = string
  description = "IP CIDR range for the subnetwork"
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "Whether to automatically create subnetworks"
  default     = false
}
