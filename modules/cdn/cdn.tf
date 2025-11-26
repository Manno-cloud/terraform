############################################
# CloudFront Origin Access Control (OAC)
############################################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-${var.env}-cdn-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

############################################
# CloudFront Distribution（CDN 本体）
############################################
resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.env}-cdn"

  aliases = [var.domain_name]

  default_root_object = "index.html"
  web_acl_id          = var.web_acl_arn

  ############################################
  # オリジン（S3 は “外から渡す”）
  ############################################
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "s3-cdn-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-cdn-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "${var.project}-${var.env}-cdn-distribution"
    Project = var.project
    Env     = var.env
  }
}