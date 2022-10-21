resource "google_compute_subnetwork" "subnet" {
  name = "${var.project_name}-subnet"
  ip_cidr_range = var.ip_cidr_range
  region = var.region
  network = google_compute_network.vpc.id

  private_ip_google_access = true
}