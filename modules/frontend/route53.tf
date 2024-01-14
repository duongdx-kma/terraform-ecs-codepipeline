# import list hosted zone already exist
data "aws_route53_zone" "selected" {
  for_each = var.params
  zone_id  = each.value.hosted_zone_id
}

# create cloudfront A record
resource "aws_route53_record" "s3_cloudfront_a_record" {
  for_each = data.aws_route53_zone.selected
  zone_id  = each.value.zone_id
  name     = each.value.name
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.this[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.this[each.key].hosted_zone_id
    evaluate_target_health = true
  }
}

# create cloudfront AAAA record
resource "aws_route53_record" "s3_cloudfront_aaaa_record" {
  for_each = data.aws_route53_zone.selected
  zone_id  = each.value.zone_id
  name     = each.value.name
  type     = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.this[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.this[each.key].hosted_zone_id
    evaluate_target_health = true
  }
}

# certificate dns
resource "aws_route53_record" "cert_dns" {
  for_each        = data.aws_route53_zone.selected
  name            = tolist(var.acm[each.key].domain_validation_options)[0].resource_record_name
  records         = [tolist(var.acm[each.key].domain_validation_options)[0].resource_record_value]
  type            = tolist(var.acm[each.key].domain_validation_options)[0].resource_record_type
  zone_id         = each.value.zone_id
  ttl             = 300
  #  allow_overwrite = true
}

output "route53_cert_dns" {
  value = aws_route53_record.cert_dns
}
