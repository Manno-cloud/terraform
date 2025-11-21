resource "aws_ecr_repository" "app" {
  name = "${var.project}-${var.env}-app"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project}-${var.env}-ecr"
    Project = var.project
    Env     = var.env
  }
}