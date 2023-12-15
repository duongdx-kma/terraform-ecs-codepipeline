variable "logs-retention-in-days" {
  type = number
  default = 1
}

variable tags {
  type = map(string)
}

variable env {
  type = string
}

variable "ecs_service_name" {
  type = string
}
variable "ecs_cluster_name" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "blue_target_group_name" {
  type = string
}

variable "green_target_group_name" {
  type = string
}