##############################
# ACM 証明書（DNS 検証）
##############################

resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name       # 例: app.example.com
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.env}-acm"
  }
}

#############################################
# Route53 DNS レコード（自動検証レコード）
#############################################

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id  # Hosted Zone ID
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

##############################
# ACM 証明書の最終バリデーション
##############################

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

##############################
# 出力（ALB で使う用）
##############################

output "acm_certificate_arn" {
  description = "ALB HTTPS Listener 用の証明書 ARN"
  value       = aws_acm_certificate.cert.arn
}

output "acm_validated_certificate_arn" {
  description = "ACM バリデーション後の証明書 ARN"
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}