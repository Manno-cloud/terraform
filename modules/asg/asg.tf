##############################
# Auto Scalling
##############################
resource "aws_autoscaling_group" "asg" {
  name                = "${var.project}-${var.env}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

#Launch Template の指定
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  # ASG の EC2 インスタンスを ALB ターゲットグループに紐付ける
  target_group_arns = [var.target_group_arn]
  
 # ヘルスチェック設定
  health_check_grace_period = 300
  health_check_type         = "ELB"

#tagの指定
  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-ec2"
    propagate_at_launch = true
  }
}