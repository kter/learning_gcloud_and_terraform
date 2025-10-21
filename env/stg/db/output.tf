output "instance_connection_name" {
  value       = module.database.instance_connection_name
  description = "Cloud SQL instance connection name"
}

output "private_ip_address" {
  value       = module.database.private_ip_address
  description = "Cloud SQL private IP address"
}

output "bastion_internal_ip" {
  value       = module.database.bastion_internal_ip
  description = "Bastion host internal IP address"
}

output "bastion_ssh_command" {
  value       = module.database.bastion_ssh_command
  description = "Command to SSH into bastion host via IAP"
}

output "postgres_password" {
  value       = module.database.postgres_password
  description = "PostgreSQL admin password"
  sensitive   = true
}
