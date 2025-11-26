############################################
# ECR Repository（コンテナイメージ保存場所）
############################################
resource "aws_ecr_repository" "app" {

  name = "${var.project}-${var.env}-nginx"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Project = var.project
    Env     = var.env
  }
}

############################################
# CloudWatch Logs（ECS コンテナログ用）
############################################
resource "aws_cloudwatch_log_group" "ecs" {

  # 出力されるロググループ名
  name = "/ecs/${var.project}-${var.env}-nginx"

  # ログ保持期間（日数）
  retention_in_days = 7
}

############################################
# ECS Cluster（Fargate 用クラスタ）
############################################
resource "aws_ecs_cluster" "this" {

  # クラスタ名（例: testapp-dev-cluster）
  name = "${var.project}-${var.env}-cluster"
}

############################################
# Task Definition（タスク定義）
############################################
resource "aws_ecs_task_definition" "nginx" {

  # タスク名（family）
  family = "${var.project}-${var.env}-nginx"

  # Fargate モード
  requires_compatibilities = ["FARGATE"]

  # awsvpc モード（ENI を作成して通信）
  network_mode = "awsvpc"

  # タスク全体のリソース量
  cpu    = 256   # 0.25 vCPU
  memory = 512   # 0.5 GB RAM

  # タスク実行ロール（ECR Pull / Logs）
  execution_role_arn = var.ecs_task_execution_role_arn

  # アプリコンテナ用ロール（S3 / SSM など必要なら付与）
  task_role_arn = var.ecs_task_role_arn

  # コンテナ定義（JSON 形式で渡す）
  container_definitions = jsonencode([
    {
      # コンテナ名
      name      = "nginx"

      # ECR の最新イメージを使用
      image     = "${aws_ecr_repository.app.repository_url}:latest"

      essential = true

      # コンテナ → ALB のポート設定
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]

      # CloudWatch Logs 設定
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

############################################
# ECS Service（Fargate でアプリを起動）
############################################
resource "aws_ecs_service" "nginx" {

  # サービス名（例: testapp-dev-svc）
  name = "${var.project}-${var.env}-svc"

  # 所属クラスタ
  cluster = aws_ecs_cluster.this.id

  # 使用するタスク定義
  task_definition = aws_ecs_task_definition.nginx.arn

  # 起動させるタスク数（Fargate インスタンス数）
  desired_count = 1

  # Fargate 起動
  launch_type = "FARGATE"

  # ネットワーク設定（awsvpc 専用）
  network_configuration {
    subnets         = var.private_subnet_ids  # Private Subnets で稼働
    security_groups = [var.ecs_sg_id]         # ECS の専用セキュリティグループ
  }

  # ALB と紐付ける
  load_balancer {
    target_group_arn = var.target_group_arn  # ALB の TargetGroup
    container_name   = "nginx"               # タスクのコンテナ名
    container_port   = 80                    # マッピング先のポート
  }
  # 新しいタスク定義を push しても自動更新しない
  # → 手動で "force new deployment" を行うための設定
  lifecycle {
    ignore_changes = [task_definition]
  }
}
