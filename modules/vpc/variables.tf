variable env {
  type = string
  description = "env"
}

variable aws_region {
  type = string
  description = "the region will launch app"
}

variable tags {
  type = map(string)
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  # default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  # default     = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  # default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}