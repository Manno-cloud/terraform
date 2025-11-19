###############################
# Security Group 本体
###############################
variable "vpc_id" {
  type = string
}

variable "security_groups" {
  description = "複数の SG（本体のみ）を作る"
  type = map(object({
    description = string
    # ルールはモジュール外で作るので不要
  }))
}

resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id
}