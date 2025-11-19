output "security_group_ids" {
  description = "name => sg-id のマッピング"
  value = {
    for k, sg in aws_security_group.security_group :
    k => sg.id
  }
}