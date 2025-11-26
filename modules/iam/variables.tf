variable "project" {
  type        = string
  description = "プロジェクト名（タグやリソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}