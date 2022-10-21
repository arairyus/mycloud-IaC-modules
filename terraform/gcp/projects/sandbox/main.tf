module "network" {
  source = "../../modules/network"
  project_name = var.project_name
  region = var.default_region
  ip_cidr_range = var.ip_cidr_range
}