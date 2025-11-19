output "alb_dns" {
  value = module.alb.alb_dns_name
}

output "ec2_private_ip" {
  value = module.ec2.private_ip
}