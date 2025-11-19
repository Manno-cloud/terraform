###############################
# Security Group 本体
###############################
resource "aws_security_group" "security_group" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id
}

###############################
# Ingress Rules
###############################
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for sg_name, sg in var.security_groups :
    sg_name => {
      sg_name = sg_name
      rules   = sg.ingress.rules
    }
  }

  type              = "ingress"
  security_group_id = aws_security_group.security_group[each.value.sg_name].id
  from_port         = each.value.rules[0].from_port
  to_port           = each.value.rules[0].to_port
  protocol          = each.value.rules[0].protocol

  cidr_blocks = (
    contains(keys(each.value.rules[0]), "cidr_blocks")
    ? each.value.rules[0].cidr_blocks
    : null
  )

  source_security_group_id = (
    contains(keys(each.value.rules[0]), "source_sg")
    ? each.value.rules[0].source_sg
    : null
  )
}

###############################
# Egress Rules
###############################
resource "aws_security_group_rule" "egress" {
  for_each = {
    for sg_name, sg in var.security_groups :
    sg_name => {
      sg_name = sg_name
      rules   = sg.egress.rules
    }
  }

  type              = "egress"
  security_group_id = aws_security_group.security_group[each.value.sg_name].id
  from_port         = each.value.rules[0].from_port
  to_port           = each.value.rules[0].to_port
  protocol          = each.value.rules[0].protocol

  cidr_blocks = (
    contains(keys(each.value.rules[0]), "cidr_blocks")
    ? each.value.rules[0].cidr_blocks
    : null
  )

  source_security_group_id = (
    contains(keys(each.value.rules[0]), "source_sg")
    ? each.value.rules[0].source_sg
    : null
  )
}

