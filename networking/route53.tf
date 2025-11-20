##############################################
# Route53 Hosted Zone
##############################################

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name    = "${var.project}-${var.env}-zone"
    Project = var.project
    Env     = var.env
  }
}

##############################################
# Hosted Zone ID
##############################################

output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}