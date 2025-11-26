output "alb_arn" {
  value = aws_lb.alb.arn
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "alb_arn_suffix" {
  value       = aws_lb.alb.arn_suffix
}

output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
}