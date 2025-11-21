############################################
# ECR Repository
############################################
resource "aws_ecr_repository" "app" {
  name = "${var.project}-${var.env}-nginx"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

############################################
# CloudWatch Logs
############################################
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project}-${var.env}"
  retention_in_days = 7
}

############################################
# ECS Cluster
############################################
resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.env}-cluster"
}

############################################
# Task Definition
############################################
resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.project}-${var.env}-nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
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
# ECS Service
############################################
resource "aws_ecs_service" "nginx" {
  name            = "${var.project}-${var.env}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name    = "nginx"
    container_port    = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
