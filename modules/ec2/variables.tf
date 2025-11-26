variable "project" {
  type        = string
  description = "プロジェクト名（タグ・リソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "name" {
  type        = string
  description = "EC2 の役割名（例: app, bastion など）"
}

variable "ami_id" {
  type        = string
  description = "起動する EC2 インスタンスの AMI ID"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 のインスタンスタイプ"
}

variable "subnet_id" {
  type        = string
  description = "EC2 を配置するサブネット ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "EC2 に付与するセキュリティグループ ID の一覧"
}

variable "iam_instance_profile" {
  type        = string
  default     = null
  description = "EC2 に割り当てる IAM インスタンスプロファイル名"
}

variable "volume_size" {
  type        = number
  default     = 8
  description = "EC2 の root ボリュームサイズ (GB)"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "EC2 起動時に実行する user-data スクリプト"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "追加で付与するタグのマップ"
}