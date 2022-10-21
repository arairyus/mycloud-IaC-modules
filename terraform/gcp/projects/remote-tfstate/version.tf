terraform {
  required_version = "v1.1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }
}