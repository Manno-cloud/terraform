############################################
# SNS（Simple Notification Service）
# アラート通知用トピック
############################################
resource "aws_sns_topic" "alert" {

  # SNS トピック名（例: tastylog-dev-alert）
  name = "${var.project}-${var.env}-alert"

  # タグ設定
  tags = {
    Name    = "${var.project}-${var.env}-alert"
    Project = var.project
    Env     = var.env

     # CI/CD デモ用のタグ（noop ではなく in-place update を発生させる）
    CICD = "true"
  }
}

