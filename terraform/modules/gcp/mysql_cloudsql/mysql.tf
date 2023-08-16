resource "random_id" "id" {
  byte_length = 2
}

resource "google_sql_database_instance" "db" {
  name             = "${var.project_name}-db-${random_id.id.hex}"
  database_version = "MYSQL_5_7"
  region           = var.region

  settings {
    tier                  = "db-g1-small"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
      require_ssl     = true
    }
    location_preference {
      zone = var.zone
    }
    backup_configuration {
      enabled = true
    }
  }
  deletion_protection = false
  provisioner "local-exec" {
    working_dir = "${path.cwd}/code/database"
    command     = "./load_schema.sh ${var.project_id} ${google_sql_database_instance.db.name}"
  }

  depends_on = [
    google_service_networking_connection.private_db_connection
  ]

}
