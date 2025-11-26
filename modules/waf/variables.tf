variable "project" {
  type        = string
  description = "プロジェクト名（タグ・リソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "WAF を適用する CloudFront Distribution の ARN"
}