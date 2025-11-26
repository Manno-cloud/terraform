variable "name" {
  description = "ALB の名前に付けるプレフィックス"
  type        = string
}

variable "vpc_id" {
  description = "ALB を作成する VPC の ID"
  type        = string
}

variable "subnets" {
  description = "ALB を配置するパブリックサブネットの一覧"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ALB に割り当てるセキュリティグループの一覧"
  type        = list(string)
}

variable "target_type" {
  type        = string
  description = "ターゲットグループの種類（instance または ip）"
}

variable "target_port" {
  description = "ターゲットグループが受け付けるポート番号"
  type        = number
  default     = 80
}

variable "certificate_arn" {
  type        = string
  description = "HTTPS リスナーで使用する ACM 証明書の ARN（任意）"
  default     = null
}

variable "enable_https" {
  type        = bool
  description = "HTTPS リスナーを有効にするかどうか"
  default     = false
}