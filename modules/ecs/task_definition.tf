resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

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