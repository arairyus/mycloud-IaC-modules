variable "default_region" {
  type = string
  default = "asia-northeast1"
}

variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
  default = "sandbox"
}

#---------------------
# Network
#---------------------
variable "ip_cidr_range" {
  type = string
}