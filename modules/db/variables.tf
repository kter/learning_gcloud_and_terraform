variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "cloudrun_service_account_id" {
  type    = string
  default = "cloudrun"
}

variable "database_instance_name_prefix" {
  type    = string
  default = "database"
}

variable "database_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "database_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "database_edition" {
  type    = string
  default = "ENTERPRISE"
}

variable "database_availability_type" {
  type    = string
  default = "ZONAL"
}

variable "database_flags" {
  type = list(object({
    name  = string
    value = string
  }))

  default = [
    {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  ]
}

variable "backup_enabled" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "nat_router_name_prefix" {
  type    = string
  default = "nat-router"
}

variable "nat_name_prefix" {
  type    = string
  default = "nat"
}

variable "bastion_name_prefix" {
  type    = string
  default = "bastion"
}

variable "bastion_account_id" {
  type    = string
  default = "bastion"
}

variable "bastion_display_name" {
  type    = string
  default = "Bastion Host Service Account"
}

variable "bastion_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "bastion_zone_suffix" {
  type    = string
  default = "a"
}

variable "bastion_boot_image" {
  type    = string
  default = "debian-cloud/debian-12"
}

variable "bastion_boot_disk_size_gb" {
  type    = number
  default = 10
}

variable "bastion_tags" {
  type    = list(string)
  default = ["bastion"]
}

variable "bastion_firewall_name" {
  type    = string
  default = "allow-bastion-iap-ssh"
}
