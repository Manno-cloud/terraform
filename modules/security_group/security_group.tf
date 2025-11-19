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
    for rule in sg.ingress.rules :
    "${sg_name}-${rule.from_port}-${rule.to_port}-${rule.protocol}" => {
      sg_name = sg_name
      rule    = rule
    }
  }

  type              = "ingress"
  security_group_id = aws_security_group.security_group[each.value.sg_name].id

  from_port = each.value.rule.from_port
  to_port   = each.value.rule.to_port
  protocol  = each.value.rule.protocol

  # --- CIDR がある場合 ---
  cidr_blocks = try(each.value.rule.cidr_blocks, null)

  # --- SG名 → SG ID に変換する処理（重要）---
  source_security_group_id = (
    try(each.value.rule.source_sg, null) != null
    ? aws_security_group.security_group[each.value.rule.source_sg].id
    : null
  )
}


###############################
# Egress Rules
###############################
resource "aws_security_group_rule" "egress" {
  for_each = {
    for sg_name, sg in var.security_groups :
    for rule in sg.egress.rules :
    "${sg_name}-${rule.from_port}-${rule.to_port}-${rule.protocol}" => {
      sg_name = sg_name
      rule    = rule
    }
  }

  type              = "egress"
  security_group_id = aws_security_group.security_group[each.value.sg_name].id

  from_port = each.value.rule.from_port
  to_port   = each.value.rule.to_port
  protocol  = each.value.rule.protocol

  cidr_blocks = try(each.value.rule.cidr_blocks, null)
}

