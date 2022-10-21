resource "google_storage_bucket" "tfstate" {
  name     = "tfstate-${var.project_id}"
  location = var.default_region

  uniform_bucket_level_access = true

  # TODO: google-storage-bucket-encryption-customer-key
  versioning {
    enabled = true
  }
}
