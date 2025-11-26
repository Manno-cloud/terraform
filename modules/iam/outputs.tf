output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}


output "ec2_profile_arn" {
  value = aws_iam_instance_profile.ec2_profile.name
}
