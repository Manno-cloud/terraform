output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}


output "cloudfront_zone_id" {
  value = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "cdn_custom_domain" {
  value = "https://${var.domain_name}"
}

output "cdn_distribution_arn" {
  value = aws_cloudfront_distribution.cdn.arn
}