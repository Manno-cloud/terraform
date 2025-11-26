variable "project" {
  type        = string
  description = "プロジェクト名（リソース名の接頭辞に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "subnet_ids" {
  type        = list(string)
  description = "EC2/ASG をデプロイするサブネット ID の一覧（通常はプライベートサブネット）"
}

variable "security_group_ids" {
  type        = list(string)
  description = "EC2 インスタンスに付与するセキュリティグループ ID の一覧"
}

variable "ami_id" {
  type        = string
  description = "EC2 で使用する AMI の ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 インスタンスのタイプ（例: t3.micro）"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "EC2 起動時に実行するユーザーデータスクリプト"
}

variable "desired_capacity" {
  type        = number
  default     = 2
  description = "ASG が起動するデフォルトのインスタンス数"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "ASG の最小インスタンス数"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "ASG の最大インスタンス数"
}

variable "target_group_arn" {
  type        = string
  description = "EC2 を登録するターゲットグループ（ALB）の ARN"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "EC2 インスタンスに割り当てる IAM インスタンスプロファイル名"
}