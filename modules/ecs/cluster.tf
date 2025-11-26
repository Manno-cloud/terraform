############################################
# ECS クラスター
############################################
resource "aws_ecs_cluster" "cluster" {

  # ECS クラスター名（例: testapp-dev-cluster）
  name = "${var.project}-${var.env}-cluster"
}