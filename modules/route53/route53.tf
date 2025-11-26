##############################################
# Route53 Hosted Zone（公開ホストゾーン）
##############################################
resource "aws_route53_zone" "host_zone" {
  name = var.domain_name

  tags = {
    Name    = "${var.project}-${var.env}-zone"
    Project = var.project
    Env     = var.env
  }
}