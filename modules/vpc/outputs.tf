output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = [aws_route_table.private.id]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "nat_eip" {
  value = aws_eip.nat_eip.public_ip
}