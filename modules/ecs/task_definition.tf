############################################
# ECS Task Definition（Fargate 用タスク定義）
############################################
resource "aws_ecs_task_definition" "app" {

  # タスク名（family）
  family = "${var.project}-${var.env}-task"

  # Fargate を使用するための設定
  requires_compatibilities = ["FARGATE"]

  # ネットワークモード（Fargate は awsvpc 固定）
  network_mode = "awsvpc"

  # タスク全体の CPU / メモリ
  cpu    = var.task_cpu      # 例: 256
  memory = var.task_memory   # 例: 512

  # ECS Execution Role（ECR Pull / CloudWatch Logs など）
  execution_role_arn = var.ecs_task_execution_role_arn

  # アプリケーションコンテナ用 IAM Role（S3 / SSM / DynamoDB など必要に応じて付与）
  task_role_arn = var.ecs_task_role_arn



  # コンテナ定義（JSON 形式で記述）
  container_definitions = jsonencode([
    {
      # コンテナ名
      name = "app"

      # 使用するイメージ（ECR 最新タグ）
      image = "${var.ecr_repository_url}:latest"

      # このコンテナがタスクの主要コンテナかどうか
      essential = true

      # ALB / TargetGroup と連携するためのポート設定
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      # CloudWatch Logs 設定
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          # ログを送信するリージョン
          awslogs-region = var.region

          # CloudWatch Log Group の名前（別リソースで作成済み）
          awslogs-group = aws_cloudwatch_log_group.ecs.name

          # ストリームのプレフィックス（ecs/app など）
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
