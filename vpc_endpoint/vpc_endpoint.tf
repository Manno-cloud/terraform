

#-----------------------------------------------------------
# Interface Endpoints
#-----------------------------------------------------------
locals {
  interface_endpoints = [
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "monitoring",
    "events",
    "ecr.api",
    "ecr.dkr",
    "sts"
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoints)

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.vpc_endpoint_sg_id]

  private_dns_enabled = true

  tags = {
    Name = "${var.project}-${var.env}-${each.value}-endpoint"
  }
}

#-----------------------------------------------------------
# Gateway Endpoints
#-----------------------------------------------------------
locals {
  gateway_endpoints = [
    "s3",
    "dynamodb"
  ]
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(local.gateway_endpoints)

  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.${each.value}"

  route_table_ids = var.private_route_table_ids

  tags = {
    Name = "${var.project}-${var.env}-${each.value}-gateway-endpoint"
  }
}
