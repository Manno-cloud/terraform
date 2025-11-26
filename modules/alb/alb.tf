############################################
# Application Load Balancer (ALB)
############################################
resource "aws_lb" "alb" {

  # ALB 名（var.name に -alb を付与）
  name = "${var.name}-alb"

  # ALB の種類を application に設定
  load_balancer_type = "application"

  # 公開設定
  internal = false

  # ALB を配置するサブネット
  subnets = var.subnets

  # ALB に付けるセキュリティグループ
  security_groups = var.security_group_ids
}

############################################
# Target Group（EC2 / ECS / IP ターゲット）
############################################
resource "aws_lb_target_group" "target_group" {

  # TG 名
  name = "${var.name}-tg"

  # ターゲットが受け取るポート
  port = var.target_port

  # プロトコル（ALB → ターゲット）
  protocol = "HTTP"

  # 設置する VPC ID
  vpc_id = var.vpc_id

  # instance / ip を選択（ECS なら ip）
  target_type = var.target_type

  # ヘルスチェック設定
  health_check {
    path                = "/"    # ヘルスチェックパス
    interval            = 30     # チェック間隔（秒）
    unhealthy_threshold = 2      # NG 判定までの回数
    healthy_threshold   = 5      # OK 判定までの回数
    matcher             = "200"  # 正常レスポンスコード
  }
}

############################################
# HTTP → HTTPS リダイレクト (port 80)
############################################
resource "aws_lb_listener" "http_redirect" {

  # ALB を指定
  load_balancer_arn = aws_lb.alb.arn

  # HTTP(80) を受けて、HTTPS へリダイレクトする設定
  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"       # 443 に転送
      protocol    = "HTTPS"     # HTTPS に強制
      status_code = "HTTP_301"  # 恒久的リダイレクト
    }
  }
}

############################################
# HTTPS Listener (port 443)
############################################
resource "aws_lb_listener" "https" {

  # この ALB に HTTPS リスナーを追加
  load_balancer_arn = aws_lb.alb.arn

  port     = 443
  protocol = "HTTPS"

  # ALB 用のセキュリティポリシー
  ssl_policy = "ELBSecurityPolicy-2016-08"

  # main.tf から渡される ACM 証明書 ARN（必須）
  certificate_arn = var.certificate_arn

  # デフォルトアクション（Target Group へフォワード）
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}