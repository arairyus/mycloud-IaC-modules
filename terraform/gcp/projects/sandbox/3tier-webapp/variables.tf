variable "default_region" {
  type    = string
  default = "asia-northeast1"
}

variable "zone" {
  type    = string
  default = "asia-northeast1-a"
}

variable "project_id" {
  type = string
}

variable "project_num" {
  type = string
}

variable "project_name" {
  type    = string
  default = "sandbox"
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "cloudapis.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudbuild.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "redis.googleapis.com"
  ]
}

variable "build_roles_list" {
  description = "The list of roles that build needs for"
  type        = list(string)
  default = [
    "roles/run.developer",
    "roles/vpaccess.user",
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.admin",
  ]
}

variable "ip_cidr_range" {
  type    = string
  default = "10.100.0.0/24"
}

variable "connector_ip_cidr_range" {
  type    = string
  default = "10.110.0.0/28"
}

variable "reserved_ip_range" {
  type    = string
  default = "10.137.125.88/29"
}

variable "repo_name" {
  type = string
}
