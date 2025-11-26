variable "project" {
  type        = string
  description = "プロジェクト名（タグ・リソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}
