############################################
# ECR（Elastic Container Registry）リポジトリ
############################################
resource "aws_ecr_repository" "app" {

  # ECR リポジトリ名（例: testapp-dev-app）
  name = "${var.project}-${var.env}-app"

  # イメージタグの変更可否
  # IMMUTABLE → 既存タグの上書きを禁止
  image_tag_mutability = "IMMUTABLE"

  # プッシュ時にマルウェアスキャンを自動実行
  image_scanning_configuration {
    scan_on_push = true
  }

force_delete = true
  # タグ設定
  tags = {
    Name    = "${var.project}-${var.env}-ecr"
    Project = var.project
    Env     = var.env
  }
}