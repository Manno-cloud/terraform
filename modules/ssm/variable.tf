
variable "project" {
  description = "プロジェクト名（例: testapp）"
  type        = string
}

variable "env" {
  description = "環境名（例: dev, stg, prod）"
  type        = string
}


variable "parameter_name" {
  description = "SSM パラメータ名（フルパス推奨））"
  type        = string
}

variable "parameter_value" {
  description = "SSM SecureString に保存する値（機密情報）"
  type        = string
  sensitive   = true
}