resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${var.project}-${var.env}-vpc"
  }, var.tags)
}

##############################
# Public Subnets
##############################
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.project}-${var.env}-public-${each.key}"
  }, var.tags)
}

##############################
# Private Subnets
##############################
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge({
    Name = "${var.project}-${var.env}-private-${each.key}"
  }, var.tags)
}

##############################
# Internet Gateway
##############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.project}-${var.env}-igw"
  }, var.tags)
}

##############################
# Public Route Table
##############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge({
    Name = "${var.project}-${var.env}-public-rt"
  }, var.tags)
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

########################################
# NAT Gateway
########################################
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge({
    Name = "${var.project}-${var.env}-nat-eip"
  }, var.tags)
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public["public1"].id

  tags = merge({
    Name = "${var.project}-${var.env}-nat"
  }, var.tags)

  depends_on = [aws_internet_gateway.igw]
}

########################################
# Private Route Table (NAT 経由)
########################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge({
    Name = "${var.project}-${var.env}-private-rt"
  }, var.tags)
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
