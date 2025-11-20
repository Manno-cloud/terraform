resource "aws_autoscaling_group" "asg" {
  name                = "${var.project}-${var.env}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_grace_period = 300
  health_check_type         = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-ec2"
    propagate_at_launch = true
  }
}