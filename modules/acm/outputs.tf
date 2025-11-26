output "acm_certificate_arn" {
  description = "証明書のARN"
  value       = aws_acm_certificate.acm.arn
}

output "validation_records" {
  value = {
    for dvo in aws_acm_certificate.acm.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  description = "DNS validation records for ACM"
}