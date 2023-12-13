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