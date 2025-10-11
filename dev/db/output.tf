output "instance_connection_name" {
  value = google_sql_database_instance.database.connection_name
  description = "Cloud SQL instance connection name"
}

output "private_ip_address" {
  value = google_sql_database_instance.database.private_ip_address
  description = "Cloud SQL private IP address"
}
