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

variable codedeploy_app_name {
  type = string
}

variable codedeploy_deployment_group_name {
  type = string
}

variable codebuild_project_name {
  type = string
}

variable codebuild_project_arn {
  type = string
}

variable codecommit_repo_name {
  type = string
}

variable codecommit_repo_arn {
  type = string
}

variable branch_name {
  type = string
}

variable application_name {
  type = string
}