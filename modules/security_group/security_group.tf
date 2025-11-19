###############################
# Security Group 本体
###############################
resource "aws_security_group" "security_group" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id
}