variable env {
  type        = string
  description = "The environment name"
}

#variable cloudfront_waf_acl_arn {
#  type        = string
#  description = "the name of cloudfront waf"
#}

variable params {
  type = map(object({
    bucket_name    = string
    domain_name    = string
    hosted_zone_id = string
  }))
  description = "List of S3 bucket name"
}

variable tags {
  type        = map(string)
  description = "The tags list"
}

variable acm {}
