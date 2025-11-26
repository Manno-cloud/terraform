############################################
# ECS Service（Fargate）
############################################
resource "aws_ecs_service" "app" {

  # サービス名（例: testapp-dev-service）
  name = "${var.project}-${var.env}-service"

  # 所属する ECS クラスター
  cluster = aws_ecs_cluster.this.arn

  # 実行するタスク定義（app タスク）
  task_definition = aws_ecs_task_definition.app.arn

  # 起動させるタスク数（Fargate インスタンス数）
  desired_count = 2


 
  # Fargate 起動設定
  launch_type = "FARGATE"



  # ネットワーク設定（awsvpc モード）
  network_configuration {
    subnets         = var.private_subnet_ids  # Private Subnet で実行
    security_groups = [var.ecs_sg_id]         # ECS 専用 SG
    assign_public_ip = false                  # Public IP は付与しない（NAT経由）
  }


  # ALB 連携
  load_balancer {
    target_group_arn = var.target_group_arn  # ALB の Target Group
    container_name   = "app"                 # タスク定義内のコンテナ名
    container_port   = 80                    # コンテナ側のポート
  }



  # デプロイ設定（ローリングデプロイ）
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200



  # desired_count を自動更新しない
  lifecycle {
    ignore_changes = [desired_count]
  }

depends_on = [
  aws_ecs_task_definition.app
]

}
