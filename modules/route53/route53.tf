# because already create hosted_zone: duongdx.com
data "aws_route53_zone" "selected" {
  zone_id  = var.hosted_zone_id
}

resource "aws_route53_record" "duongdx" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}
