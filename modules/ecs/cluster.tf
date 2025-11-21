resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-${var.env}-cluster"
}