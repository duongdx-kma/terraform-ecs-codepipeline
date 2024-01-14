# Create an ACM Certificate for
resource "aws_acm_certificate" "certificate" {
  for_each          = var.params
  domain_name       = each.value.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# certificate dns validation
resource "aws_acm_certificate_validation" "cert_validate" {
  for_each                = aws_acm_certificate.certificate
  certificate_arn         = each.value.arn
  validation_record_fqdns = [var.route53_cert_dns[each.key].fqdn]
}
