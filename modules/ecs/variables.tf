variable "project" {
  type        = string
  description = "プロジェクト名（タグやリソース名に使用）"
}

variable "env" {
  type        = string
  description = "環境名（dev / stg / prod など）"
}

variable "region" {
  type        = string
  description = "AWS リージョン（例: ap-northeast-1）"
}

variable "vpc_id" {
  type        = string
  description = "VPC の ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "ECS タスクを配置するプライベートサブネットの ID 一覧"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "ALB を配置するパブリックサブネットの ID 一覧"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB に付与するセキュリティグループ ID"
}

variable "ecs_sg_id" {
  type        = string
  description = "ECS タスクに付与するセキュリティグループ ID"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ECS Task Execution Role の ARN（ECR Pull や CloudWatch Logs 用）"
}

variable "ecs_task_role_arn" {
  type        = string
  description = "アプリケーション用 ECS Task Role の ARN"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR リポジトリ URL（例: xxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/app）"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "コンテナがリッスンするポート番号"
}

variable "task_cpu" {
  type        = string
  default     = "256"
  description = "ECS タスクの CPU 量（例: 256）"
}

variable "task_memory" {
  type        = string
  default     = "512"
  description = "ECS タスクのメモリ量（例: 512）"
}

variable "target_group_arn" {
  type        = string
  description = "ALB のターゲットグループ ARN"
}

variable "listener_arn" {
  type        = string
  description = "ALB のリスナー ARN（ECS サービス用）"
}