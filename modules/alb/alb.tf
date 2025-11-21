############################################
#  Application Load Balancer (ALB)
############################################

resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnets
  security_groups    = var.security_group_ids
 
}

############################################
#  Target Group
############################################

resource "aws_lb_target_group" "target_group" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = "/"
    interval            = 30
    unhealthy_threshold = 2
    healthy_threshold   = 5
    matcher             = "200"
  }
}

############################################
#  HTTP → HTTPS Redirect Listener (port 80)
############################################

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

############################################
#  HTTPS Listener (port 443)
############################################

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
