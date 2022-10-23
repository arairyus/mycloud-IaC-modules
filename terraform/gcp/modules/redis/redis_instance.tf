resource "google_redis_instance" "chace" {
  authorized_network      = var.redis_network_id
  connect_mode            = "DIRECT_PEERING"
  location_id             = var.zone
  memory_size_gb          = 1
  name                    = "${var.project_name}-chace"
  redis_version           = "REDIS_6_X"
  region                  = var.region
  tier                    = "BASIC"
  transit_encryption_mode = "DISABLED"
  reserved_ip_range       = var.reserved_ip_range
}
