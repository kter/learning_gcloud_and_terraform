output "instance_connection_name" {
  value = google_sql_database_instance.database.connection_name
  description = "Cloud SQL instance connection name"
}

output "private_ip_address" {
  value = google_sql_database_instance.database.private_ip_address
  description = "Cloud SQL private IP address"
}

output "bastion_internal_ip" {
  value = google_compute_instance.bastion.network_interface[0].network_ip
  description = "Bastion host internal IP address"
}

output "bastion_ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.bastion.name} --zone=${google_compute_instance.bastion.zone} --project=${var.project_id} --tunnel-through-iap"
  description = "Command to SSH into bastion host via IAP"
}

output "postgres_password" {
  value = random_password.admin_password.result
  description = "PostgreSQL admin password"
  sensitive = true
}
