output "security_group_ids" {
  value = {
    for sg, data in aws_security_group.security_group :
    sg => data.id
  }
}
