provider "google" {
  region  = var.default_region
  project = var.project_id
}

provider "google-beta" {
  region  = var.default_region
  project = var.project_id
}

provider "random" {}

provider "null" {}
