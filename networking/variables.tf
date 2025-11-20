#################################################
# Networking Module Variables
#################################################

# 例：app.example.com
variable "domain_name" {
  description = "ACM に使用するドメイン名（例: app.example.com）"
  type        = string
}

# Route53 の Hosted Zone ID
variable "route53_zone_id" {
  description = "ACM DNS 検証に使用する Route53 Hosted Zone ID"
  type        = string
}

variable "project" {
  description = "プロジェクト名（例: testapp）"
  type        = string
}

variable "env" {
  description = "環境名（dev / stg / prod など）"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}
