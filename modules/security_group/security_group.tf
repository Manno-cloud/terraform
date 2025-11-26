###############################
# Security Group 本体の作成
###############################
resource "aws_security_group" "security_group" {

  # 複数の Security Group を一括生成するために for_each を使用
  for_each = var.security_groups


  # Security Group 名
  # → map の keyをそのまま名前に使用する
  name = each.key

  # 説明文
  description = each.value.description

  # 作成する VPC の ID
  vpc_id = var.vpc_id
}