variable "logs-retention-in-days" {
  type = number
  default = 1
}

variable tags {
  type = map(string)
}

variable aws_region {
  type = string
}

variable env {
  type = string
}

variable ecr_repository_name {
  type = string
}

variable db_driver {
  type = string
  // mysql, mariadb, postgres ....
}

variable rds_endpoint {
  type = string
}

variable username {
  type = string
}

variable db_name {
  type = string
}

variable db_port {
  type = string
}

variable app_port {
  type = string
}

variable app_env {
  type = string
}

variable secret_manager_name {
  type = string
}