output "endpoint" {
  value       = google_cloud_run_service.fe.status[0].url
  description = "The url of the front end which we want to surface to the user"
}
