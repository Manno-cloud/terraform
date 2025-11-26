variable "project" {
  type        = string
  description = "プロジェクト名（タグやリソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "domain_name" {
  type        = string
  description = "CloudFront のカスタムドメイン名（例: cdn.manno-cloud.com）"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 のホストゾーン ID（例: manno-cloud.com 用）"
}

variable "web_acl_arn" {
  type        = string
  description = "CloudFront に割り当てる WAF Web ACL の ARN"
}

variable "certificate_arn" {
  type        = string
  description = "CloudFront 用 ACM 証明書（us-east-1）の ARN"
}

variable "s3_bucket_domain_name" {
  type        = string
  description = "CloudFront 用 ACM 証明書（us-east-1）の ARN"
}