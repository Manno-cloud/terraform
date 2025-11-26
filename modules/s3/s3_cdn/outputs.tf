output "bucket_name" {
  description = "生成された S3 バケット名"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  description = "S3 バケットの ARN"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "S3 バケットのリージョナルドメイン名"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "bucket_policy_id" {
  value = aws_s3_bucket_policy.cdn.id
  description = "作成された S3 バケットポリシーの ID"
}