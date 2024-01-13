variable env {
  type    = string
  default = "prod"
}

variable aws_region {
  type    = string
  default = "ap-southeast-1"
}

variable tags {
  type = map(string)
  default = {
    Terraform   = "yes"
    Environment = "prod"
    App         = "Duongdx-terraform-ecs"
  }
}

# load balancer listen port
variable lb-listen-port {
  type = number
  default = 443
}

# load balancer listen protocol
variable lb-listen-protocol {
  type = string
  default = "HTTPS"
}

# load balancer listen port
variable instance-port {
  type = number
  default = 8088
}

variable github_username {
  type = string
  default = "duongdx-kma"
  description = "github username"
}

variable github_repo {
  type = string
  default = "golang-project"
  description = "github repository name"
}

variable branch_name {
  type = string
  default = "duongdx-golang"
  description = "github branch name"
}

variable commit-id {
  default = ""
}

variable api_domain_name {
  type    = string
  default = "duongdx.com"
}

variable hosted_zone_id {
  type    = string
  default = "Z10021163CFESZLAG77PX"
}

variable username {
  default = "root"
}

variable db_name {
  default = "db_business"
}
