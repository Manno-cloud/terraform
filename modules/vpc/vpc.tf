##############################################
# VPC 本体
##############################################
resource "aws_vpc" "vpc" {

  # VPC の CIDR（例: 10.0.0.0/16）
  cidr_block = var.vpc_cidr

  # DNS 解決を有効化（VPC 内で名前解決が可能に）
  enable_dns_support = true

  # EC2 に自動でホスト名を割り当てる
  enable_dns_hostnames = true

  # タグ設定
  tags = merge({
    Name = "${var.project}-${var.env}-vpc"
  }, var.tags)
}

##############################################
# Public Subnets（インターネット経由でアクセス可能）
##############################################
resource "aws_subnet" "public" {
  for_each = var.public_subnets
  # var.public_subnets の構造例：
  # {
  #   public1 = { cidr = "10.0.1.0/24", az = "ap-northeast-1a" }
  #   public2 = { cidr = "10.0.2.0/24", az = "ap-northeast-1c" }
  # }

  # 所属する VPC
  vpc_id = aws_vpc.vpc.id

  # サブネットの CIDR
  cidr_block = each.value.cidr

  # 配置する Availability Zone
  availability_zone = each.value.az

  # 起動した EC2 に自動的に Public IP を付与
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.project}-${var.env}-public-${each.key}"
  }, var.tags)
}

##############################################
# Private Subnets
##############################################
resource "aws_subnet" "private" {
  for_each = var.private_subnets
  # var.private_subnets の構造例：
  # {
  #   private1 = { cidr = "10.0.10.0/24", az = "ap-northeast-1a" }
  #   private2 = { cidr = "10.0.11.0/24", az = "ap-northeast-1c" }
  # }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge({
    Name = "${var.project}-${var.env}-private-${each.key}"
  }, var.tags)
}

##############################################
# Internet Gateway
##############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${var.project}-${var.env}-igw"
  }, var.tags)
}

##############################################
# Public Route Table
##############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                # すべての外部通信
    gateway_id = aws_internet_gateway.igw.id  # IGW 経由で出る
  }

  tags = merge({
    Name = "${var.project}-${var.env}-public-rt"
  }, var.tags)
}

# Public サブネットを Public Route Table に関連付け
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

##############################################
# NAT Gateway
##############################################
resource "aws_eip" "nat_eip" {

  # EIP を VPC 用に作成
  domain = "vpc"

  tags = merge({
    Name = "${var.project}-${var.env}-nat-eip"
  }, var.tags)
}

resource "aws_nat_gateway" "nat" {

  # NAT 用の EIP をアタッチ
  allocation_id = aws_eip.nat_eip.id

  # Public Subnet に NAT を配置
  subnet_id = aws_subnet.public["public1"].id
  # ※ public1 をデフォルトにしている

  tags = merge({
    Name = "${var.project}-${var.env}-nat"
  }, var.tags)

  #依存関係 (NAT は IGW より後に作成する必要がある)
  depends_on = [aws_internet_gateway.igw]
}

##############################################
# Private Route Table（NAT 経由で外へ出る）
##############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"              # インターネット全体
    nat_gateway_id = aws_nat_gateway.nat.id   # NAT 経由で外へ出る
  }

  tags = merge({
    Name = "${var.project}-${var.env}-private-rt"
  }, var.tags)
}

# Private サブネットを Private Route Table に紐付け
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
