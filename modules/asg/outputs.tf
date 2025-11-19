output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "lt_id" {
  value = aws_launch_template.lt.id
}