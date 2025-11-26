variable "project" {
  type        = string
  description = "プロジェクト名（タグ・リソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "共通で付与するタグのマップ"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC の CIDR ブロック（例: 10.0.0.0/16）"
}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "パブリックサブネットの CIDR と AZ のマップ"
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "プライベートサブネットの CIDR と AZ のマップ"
}
