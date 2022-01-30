#~~~~~~~~~~~~~~~~~~~~
# Route 53 DNS records
#~~~~~~~~~~~~~~~~~~~~
resource "aws_route53_zone" "private" {
  count = var.create && var.create_website ? 1 : 0
  name  = "internal.${var.hosted_zone_name}"

  vpc {
    vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  }
}

resource "aws_route53_record" "lb_alias" {
  count   = var.create && var.create_website ? 1 : 0
  zone_id = aws_route53_zone.private.0.zone_id
  name    = "${var.stack}-${var.stage}.internal.${var.hosted_zone_name}"
  type    = "A"

  alias {
    name                   = aws_lb.website.0.dns_name
    zone_id                = aws_lb.website.0.zone_id
    evaluate_target_health = false
  }
}
