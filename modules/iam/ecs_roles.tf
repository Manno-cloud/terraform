###############################
# ECS Task Execution Role
###############################
resource "aws_iam_role" "ecs_execution_role" {

  # ロール名（例: testapp-dev-ecs-execution-role）
  name = "${var.project}-${var.env}-ecs-execution-role"

  # ECS タスク（Fargate 含む）が AssumeRole できるようにするポリシー
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# ECS タスク用 AssumeRole ポリシー
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]  # ECS タスクサービス
    }
  }
}

# Execution Role に AWS 管理ポリシーを付与
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


###############################
# ECS Task Role（アプリケーション用ロール）
###############################
resource "aws_iam_role" "ecs_task_role" {

  # アプリケーションタスク用の IAM ロール
  # アプリが AWS API（S3, DynamoDB, Secrets Manager など）を使う場合に必要
  name = "${var.project}-${var.env}-ecs-task-role"

  # AssumeRole 設定は execution_role と同じ
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}
