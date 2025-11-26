variable "region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS region"
}

variable "rds_password" {
  description = "RDS 用の初期パスワード"
  type        = string
  sensitive   = true
}