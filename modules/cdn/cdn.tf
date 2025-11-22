terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

############################################
# S3: private bucket for CDN
############################################

resource "aws_s3_bucket" "cdn" {
  bucket = "${var.project}-${var.env}-cdn-images"

  lifecycle {
  prevent_destroy = true
}
  tags = {
    Name    = "${var.project}-${var.env}-cdn-bucket"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "cdn" {
  bucket = aws_s3_bucket.cdn.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  lifecycle {
  prevent_destroy = true
}

}

############################################
# Origin Access Control (OAC)
############################################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-${var.env}-cdn-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  lifecycle {
  prevent_destroy = true
}

}

############################################
# ACM Certificate (us-east-1)
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

  lifecycle {
  prevent_destroy = true
}

}

resource "aws_route53_record" "cf_validation" {
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

  lifecycle {
  prevent_destroy = true
}

}

resource "aws_acm_certificate_validation" "cf" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cf.arn
  validation_record_fqdns = [for r in aws_route53_record.cf_validation : r.fqdn]

  lifecycle {
  prevent_destroy = true
}

}

############################################
# CloudFront Distribution
############################################

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.env}-cdn"

  aliases = [var.domain_name]
  default_root_object = "index.html"
  web_acl_id = var.web_acl_arn

   lifecycle {
  prevent_destroy = true
}

  origin {
    domain_name = aws_s3_bucket.cdn.bucket_regional_domain_name
    origin_id   = "s3-cdn-origin"

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
# Route53 A Alias → CloudFront
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

  lifecycle {
  prevent_destroy = true
}

}
