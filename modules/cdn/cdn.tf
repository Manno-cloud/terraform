terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

############################################
# S3: 画像配信用バケット（private）
############################################

resource "aws_s3_bucket" "cdn" {
  bucket = "${var.project}-${var.env}-cdn-images"

  tags = {
    Name    = "${var.project}-${var.env}-cdn-bucket"
    Project = var.project
    Env     = var.env
  }
}

# パブリックアクセス完全ブロック
resource "aws_s3_bucket_public_access_block" "cdn" {
  bucket = aws_s3_bucket.cdn.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

############################################
# CloudFront Origin Access Identity (OAI)
# S3 に直接アクセスさせず、CloudFront 経由のみ許可
############################################

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.project}-${var.env}-cdn-oai"
}

# S3 バケットポリシー: OAI からの GetObject のみ許可
data "aws_iam_policy_document" "cdn_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cdn.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn" {
  bucket = aws_s3_bucket.cdn.id
  policy = data.aws_iam_policy_document.cdn_bucket_policy.json
}

############################################
# ACM (us-east-1) for CloudFront
############################################

resource "aws_acm_certificate" "cf" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name    = "${var.project}-${var.env}-cdn-cert"
    Project = var.project
    Env     = var.env
  }
}

# DNS 検証用レコード (Route53)
resource "aws_route53_record" "cf_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "cf" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cf.arn
  validation_record_fqdns = [for r in aws_route53_record.cf_cert_validation : r.fqdn]
}

############################################
# CloudFront Distribution
############################################

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project}-${var.env}-cdn"
  default_root_object = ""

  aliases = [var.domain_name] # cdn.manno-cloud.com

  origin {
    domain_name = aws_s3_bucket.cdn.bucket_regional_domain_name
    origin_id   = "s3-cdn-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-cdn-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

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
    acm_certificate_arn      = aws_acm_certificate_validation.cf.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name    = "${var.project}-${var.env}-cdn-distribution"
    Project = var.project
    Env     = var.env
  }

  depends_on = [aws_acm_certificate_validation.cf]
}

############################################
# Route53: cdn.manno-cloud.com → CloudFront
############################################

resource "aws_route53_record" "cdn_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

############################################
# Outputs
############################################

output "cdn_bucket_name" {
  value       = aws_s3_bucket.cdn.bucket
  description = "S3 bucket used as CloudFront origin"
}

output "cdn_domain_name" {
  value       = aws_cloudfront_distribution.cdn.domain_name
  description = "CloudFront distribution domain name"
}

output "cdn_url" {
  value       = "https://${var.domain_name}"
  description = "Custom domain URL for the CDN"
}
