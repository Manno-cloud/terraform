output "cdn_bucket_name" {
  value = aws_s3_bucket.cdn.bucket
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cdn_custom_domain" {
  value = "https://${var.domain_name}"
}

output "cdn_distribution_arn" {
  value = aws_cloudfront_distribution.cdn.arn
}