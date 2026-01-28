data "aws_route53_zone" "primary" {
  count        = (var.acm_certificate_arn != "" && var.route_53_domain != "" && var.cdn_secret_key != "" && var.enable_cdn) ? 1 : 0
  name         = var.route_53_domain
  private_zone = false
}

resource "aws_route53_record" "cdn_alias" {
  count   = (var.acm_certificate_arn != "" && var.route_53_domain != "" && var.cdn_secret_key != "" && var.enable_cdn) ? 1 : 0
  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = var.environment != "production" ? "${var.project_name}-${var.environment}.${var.route_53_domain}" : "${var.project_name}.${var.route_53_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.api_cdn[0].domain_name
    zone_id                = aws_cloudfront_distribution.api_cdn[0].hosted_zone_id
    evaluate_target_health = false
  }
}

