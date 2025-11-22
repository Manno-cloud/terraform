resource "aws_ecs_service" "app" {
  name            = "${var.project}-${var.env}-service"
  cluster         = aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_ecs_task_definition.app,
    aws_lb_listener.http
  ]
}