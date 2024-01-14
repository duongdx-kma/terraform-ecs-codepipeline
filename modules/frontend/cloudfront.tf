locals {
  bucket_result = {
  for key, bucket in aws_s3_bucket.frontend_bucket :
  key => {
    s3_origin_id   = "${bucket.bucket}-origin"
    s3_domain_name = bucket.bucket_regional_domain_name
    domain_name    = var.params[key].domain_name
    cert_arn       = var.acm[key].arn
  }
  }
}

# cloudfront origin access identity support get s3 object privately
resource "aws_cloudfront_origin_access_identity" "this" {
  for_each = local.bucket_result
  comment  = each.value.s3_domain_name
}

resource "aws_cloudfront_distribution" "this" {
  for_each            = local.bucket_result
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "s3-cloudfront"
  default_root_object = "index.html"
  aliases             = [each.value.domain_name]
  # associate WAF ACL
  #  web_acl_id = var.cloudfront_waf_acl_arn

  origin {
    origin_id   = each.value.s3_origin_id
    domain_name = each.value.s3_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[each.key].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = each.value.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = each.value.cert_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_200"

  tags = merge({ Name = "${var.env}-cloudfront-distribution" }, var.tags)
}
