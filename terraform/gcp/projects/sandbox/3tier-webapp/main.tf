##################
# Enable Service API
##################
module "project_service" {
  source           = "../../../modules/project_service"
  gcp_service_list = var.gcp_service_list
  project_id       = var.project_id
}

##################
# IAM
##################
locals {
  sabuild   = "${var.project_num}@cloudbuild.gserviceaccount.com"
  sacompute = "${var.project_num}-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "allbuild" {
  for_each   = toset(var.build_roles_list)
  project    = var.project_id
  role       = each.key
  member     = "serviceAccount:${local.sabuild}"
  depends_on = [module.project_service]
}

resource "google_project_iam_member" "secretmanager_secretAccessor" {
  project    = var.project_id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${local.sacompute}"
  depends_on = [module.project_service]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}


##################
# VPC
##################
module "network" {
  source        = "../../../modules/network"
  project_name  = var.project_name
  ip_cidr_range = var.ip_cidr_range
  region        = var.default_region
}

##################
# Cache - Redis
##################
module "redis" {
  source            = "../../../modules/redis"
  redis_network_id  = module.network.vpc_id
  zone              = var.zone
  region            = var.default_region
  project_name      = var.project_name
  reserved_ip_range = var.reserved_ip_range
}

##################
# CloudSQL - MySQL
##################
module "mysql" {
  source       = "../../../modules/mysql_cloudsql"
  project_name = var.project_name
  region       = var.default_region
  zone         = var.zone
  vpc_id       = module.network.vpc_id
  project_id   = var.project_id
}

##################
# Artifact Registory
##################
module "registory" {
  source    = "../../../modules/artifact_registory"
  location  = var.default_region
  repo_name = "${var.project_name}-app"
}

##################
# Secret Manager
##################
resource "google_secret_manager_secret" "redishost" {
  secret_id = "redishost"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "redishost" {
  enabled     = true
  secret      = google_secret_manager_secret.redishost.id
  secret_data = module.redis.host
}

resource "google_secret_manager_secret" "sqlhost" {
  secret_id = "sqlhost"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "sqlhost" {
  enabled     = true
  secret      = google_secret_manager_secret.sqlhost.id
  secret_data = module.mysql.private_ip_address
}

##################
# Create middleware artifact
##################
resource "null_resource" "cloudbuild_api" {
  provisioner "local-exec" {
    working_dir = "${path.module}/code/middleware"
    command     = "gcloud builds submit . --substitutions=_REGION=${var.default_region},_BASENAME=${var.project_name}"
  }
  depends_on = [
    module.registory,
    google_secret_manager_secret_version.redishost,
    google_secret_manager_secret_version.sqlhost,
    module.project_service
  ]
}

##################
# Cloud Run
##################

# Serverless VPC Connector for CloudRun
resource "google_vpc_access_connector" "connector" {
  name          = "vpc-connector"
  ip_cidr_range = var.connector_ip_cidr_range
  network       = module.network.vpc_id
}

# Backend API
resource "google_cloud_run_service" "api" {
  name     = "${var.project_name}-api"
  location = var.default_region

  template {
    spec {
      containers {
        image = "${var.default_region}-docker.pkg.dev/${var.project_id}/${module.registory.repository_id}/api"
        env {
          name = "REDIHOST"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.redishost.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name = "todo_host"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.sqlhost.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "todo_user"
          value = "todo_user"
        }
        env {
          name  = "todo_pass"
          value = "todo_pass"
        }
        env {
          name  = "todo_name"
          value = "todo"
        }
        env {
          name  = "REDISPORT"
          value = module.redis.port
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "1000"
        "run.googleapis.com/cloudsql-instances"   = module.mysql.connection_name
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "all"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
      }
    }
  }

  autogenerate_revision_name = true
  depends_on = [
    null_resource.cloudbuild_api,
    google_project_iam_member.secretmanager_secretAccessor
  ]
}

# Setting Public Cloud Run API
resource "google_cloud_run_service_iam_policy" "noauth_api" {
  location    = google_cloud_run_service.api.location
  service     = google_cloud_run_service.api.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

##################
# Create frontend artifact
##################
resource "null_resource" "cloudbuild_fe" {
  provisioner "local-exec" {
    working_dir = "${path.module}/code/frontend"
    command     = "gcloud builds submit . --substitutions=_REGION=${var.default_region},_BASENAME=${var.project_name}"
  }
  depends_on = [
    module.registory,
    google_cloud_run_service.api
  ]
}

resource "google_cloud_run_service" "fe" {
  name     = "${var.project_name}-fe"
  location = var.default_region
  template {
    spec {
      containers {
        image = "${var.default_region}-docker.pkg.dev/${var.project_id}/${var.project_name}-app/fe"
        ports {
          container_port = 80
        }
      }
    }
  }
  depends_on = [null_resource.cloudbuild_fe]
}

resource "google_cloud_run_service_iam_policy" "noauth_fe" {
  location    = google_cloud_run_service.fe.location
  service     = google_cloud_run_service.fe.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
