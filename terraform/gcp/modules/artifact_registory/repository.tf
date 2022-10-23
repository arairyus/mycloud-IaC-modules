resource "google_artifact_registry_repository" "this" {
  format        = "DOCKER"
  location      = var.location
  repository_id = var.repo_name
}
