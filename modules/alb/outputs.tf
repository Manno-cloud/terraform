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