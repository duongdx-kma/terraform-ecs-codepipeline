variable env {
  type = string
  description = "env"
}

variable vpc_id {
  type = string
  description = "vpc id"
}

variable aws_region {
  type = string
  description = "the region will launch app"
}

variable tags {
  type = map(string)
  description = "List of tags"
}

variable alb-ingress {
  type = list(object({
    from_port: number
    to_port: number
    protocol: string
    cidr_blocks: list(string)
  }))

  description = "application load balancer ingress"
}

variable batch-ingress {
  type = list(object({
    from_port: number
    to_port: number
    protocol: string
    cidr_blocks: list(string)
  }))

  description = "application load balancer ingress"
}

variable instance-ingress {
  type = list(object({
    from_port: number
    to_port: number
    protocol: string
  }))

  description = "instance private ingress"
}

variable rds-ingress {
  type = list(object({
    from_port: number
    to_port: number
    protocol: string
  }))

  description = "instance private ingress"
}

variable endpoint-ingress {
  type = list(object({
    from_port: number
    to_port: number
    protocol: string
  }))

  description = "endpoint ingress"
}