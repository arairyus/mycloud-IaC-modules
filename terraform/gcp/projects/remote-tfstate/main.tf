resource "google_storage_bucket" "tfstate" {
  name     = "tfstate-${var.project_id}"
  location = var.default_region

  versioning {
    enabled = true
  }
}