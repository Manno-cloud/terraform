variable "project" {
  type        = string
  description = "プロジェクト名（タグ・リソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "db_name" {
  type        = string
  default     = "testdb"
  description = "作成するデータベース名"
}

variable "username" {
  type        = string
  default     = "admin"
  description = "RDS のマスターユーザー名"
}
variable "subnet_ids" {
  type        = list(string)
  description = "RDS を配置するプライベートサブネットの ID 一覧"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "RDS に付与するセキュリティグループ ID の一覧"
}

variable "storage_gb" {
  type        = number
  default     = 20
  description = "RDS のストレージ容量（GB）"
}

variable "rds_password_parameter_name" {
  description = "RDS のパスワードが保存されている SSM Parameter Store の名前"
  type        = string
}