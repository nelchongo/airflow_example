# Data Sources
data "aws_route53_zone" "zone" {
  zone_id = "Z04211931VZIR5O4OUFHD"
}

locals {
  dns_name = "${local.app_name}.${data.aws_route53_zone.zone.name}"
}

resource "aws_route53_record" "dns" {
  zone_id = "Z04211931VZIR5O4OUFHD"
  name    = local.dns_name
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = false
  }
}