
variable "project" {
  description = "プロジェクト名（例: testapp）"
  type        = string
}

variable "env" {
  description = "環境名（dev / stg / prod など）"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "private_route_table_ids" {}
variable "vpc_endpoint_sg_id" {}