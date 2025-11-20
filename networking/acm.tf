##############################
# ACM 証明書（DNS 検証）
##############################

resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.env}-acm"
  }
}
##############################
# 出力
##############################

output "acm_certificate_arn" {
  description = "ALB HTTPS Listener 用の証明書 ARN"
  value       = aws_acm_certificate.acm.arn
}
