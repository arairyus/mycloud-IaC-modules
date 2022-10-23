output "private_ip_address" {
  value = google_sql_database_instance.db.private_ip_address
}

output "connection_name" {
  value = google_sql_database_instance.db.connection_name
}
