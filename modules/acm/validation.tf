##############################
# ACM → Route53 の検証レコード作成
##############################
resource "aws_route53_record" "validation" {

  # ACM が提供する "domain_validation_options" から
  # DNS 検証に必要なレコード情報を for_each で展開する。
 provider = aws

  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options :
    dvo.domain_name => {      # キー：対象ドメイン名
      name  = dvo.resource_record_name       # Route53 に作成するレコード名
      type  = dvo.resource_record_type       # CNAME
      value = dvo.resource_record_value      # ACM が要求する値
    }
  }

  # 検証レコードを作成する Route53 ホストゾーン ID（main.tf から渡す）
  zone_id = var.route53_zone_id

  # for_each の各値を使用してレコードを作成
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

##############################
# ACM の DNS 検証を完了させるリソース
##############################
resource "aws_acm_certificate_validation" "validation" {

 provider = aws
  # 対象の ACM 証明書 ARN
  certificate_arn = aws_acm_certificate.acm.arn

  # 上で作成した Route53 レコード（validation）の FQDN を渡す
  validation_record_fqdns = [
    for r in aws_route53_record.validation : r.fqdn
  ]
}