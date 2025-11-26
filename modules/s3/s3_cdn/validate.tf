variable "project" {
  type        = string
  description = "プロジェクト名"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod）"
}

variable "bucket_suffix" {
  type        = string
  description = "バケット名の接尾辞（例: cdn-images）"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "追加で付与するタグ"
}

variable "bucket_policy_json" {
  type        = string
  default     = null
  description = "S3 バケットに適用する任意のバケットポリシー(JSON)"
}

variable "policy_file" {
  type        = string
  description = "S3 バケットポリシー（JSON）のパス"
  default     = null
}

variable "cdn_distribution_arn" {
  type = string
}