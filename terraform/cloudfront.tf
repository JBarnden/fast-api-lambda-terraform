data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "api_cdn" {
  count = (var.enable_cdn) ? 1 : 0

  enabled = true
  # Only include the environment in the domain name if environment != "production"
  aliases = var.environment != "production" ? ["${var.project_name}-${var.environment}.${var.route_53_domain}"] : ["${var.project_name}.${var.route_53_domain}"]
  comment = "CDN for ${var.project_name}-${var.environment}"

  origin {
    # Extract the domain from the function URL (remove https:// and trailing /)
    domain_name = split("/", replace(aws_lambda_function_url.api.function_url, "https://", ""))[0]
    origin_id   = "LambdaOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # SECURITY: Add a header to verify requests are from the CDN in FastAPI.
    # FastAPI can return a 403 if the header is not present or incorrect
    custom_header {
      name  = "X-CDN-Secret-Key"
      value = var.cdn_secret_key
    }
  }

  default_cache_behavior {
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "LambdaOrigin"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Certificate will need to be in us-east-1 for CloudFront
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
