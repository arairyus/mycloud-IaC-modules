resource "google_compute_network" "vpc" {
  name = "${var.project_name}-vpc"
  # custom subnet mode 
  auto_create_subnetworks = false
}