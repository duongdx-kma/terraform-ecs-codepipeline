variable params {
  type = map(object({
    bucket_name    = string
    domain_name    = string
    hosted_zone_id = string
  }))
  description = "List of S3 bucket name"
}

variable route53_cert_dns {}
