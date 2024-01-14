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
  default = "api.duongdx.com"
}

variable hosted_zone_id {
  type    = string
  default = "Z10021163CFESZLAG77PX"
}

variable frontend_domain_name {
  type    = string
  default = "duongdx.com"
}

variable frontend_hosted_zone_id {
  type    = string
  default = "Z10021163CFESZLAG77PX"
}

variable frontend_bucket_name {
  type    = string
  default = "duongdx-frontend"
}

variable path_to_public_key {
  type = string
  default = "mykey.pub"
}

variable batch_instance_ami {
  type = string
  default = "ami-0fa377108253bf620"
}

variable batch_instance_type {
  type = string
  default = "t2.small"
}

variable instance_user_name {
  type        = string
  default     = "ubuntu"
  description = "consider with Bastion instance AMI"
}

variable username {
  default = "root"
}

variable db_name {
  default = "db_business"
}
