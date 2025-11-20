terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ======================
#  VPC モジュール
# ======================
module "vpc" {
  source = "./modules/vpc"

  project = "testapp"
  env     = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    public1 = {
      cidr = "10.0.1.0/24"
      az   = "ap-northeast-1a"
    }
    public2 = {
      cidr = "10.0.2.0/24"
      az   = "ap-northeast-1c"
    }
  }

  private_subnets = {
    private1 = {
      cidr = "10.0.10.0/24"
      az   = "ap-northeast-1a"
    }
    private2 = {
      cidr = "10.0.11.0/24"
      az   = "ap-northeast-1c"
    }
  }
}

# ======================
#  Security Group モジュール
# ======================
module "security_group" {
  source = "./modules/security_group"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    alb_sg = {
      description = "ALB SG"
    }
    ec2_sg = {
      description = "EC2 SG"
    }

    vpc_endpoint_sg = {
      description = "vpc_endpoint SG"
    }
  }
}

# ======================
#  Security Group ルール
# ======================
resource "aws_security_group_rule" "alb_ingress_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["alb_sg"]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["alb_sg"]
}

resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"

  source_security_group_id = module.security_group.security_group_ids["ec2_sg"]
  security_group_id        = module.security_group.security_group_ids["alb_sg"]
}

resource "aws_security_group_rule" "ec2_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["ec2_sg"]
}

resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = module.security_group.security_group_ids["ec2_sg"]
  source_security_group_id = module.security_group.security_group_ids["alb_sg"]
}

resource "aws_security_group_rule" "vpc_endpoint_ingress" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  source_security_group_id = module.security_group.security_group_ids["ec2_sg"]
  security_group_id = module.security_group.security_group_ids["vpc_endpoint_sg"]

}

resource "aws_security_group_rule" "vpc_endpoint_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["vpc_endpoint_sg"]
}

# ======================
#  EC2 モジュール
# ======================

# ===========================
# ASG モジュール
# ===========================
module "asg" {
  source = "./modules/asg"

  project = "testapp"
  env     = "dev"

  subnet_ids = module.vpc.private_subnet_ids

  security_group_ids = [
    module.security_group.security_group_ids["ec2_sg"]
  ]

  ami_id        = "ami-0e68e34976bb4db93"
  instance_type = "t3.micro"
  user_data = file("${path.root}/user_data.sh")

  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  target_group_arn = module.alb.target_group_arn
  iam_instance_profile_name = "tastylog-dev-app-instance-profile"
}

# ======================
#  ALB モジュール
# ======================
module "alb" {
  source = "./modules/alb"

  name    = "testapp"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids

  security_group_ids = [
    module.security_group.security_group_ids["alb_sg"]
  ]

  target_port = 80

  certificate_arn = module.networking.acm_certificate_arn
  enable_https    = true
}

module "networking" {
  source = "./networking"

  domain_name     = "manno-cloud.com"
  route53_zone_id = module.networking.route53_zone_id
  project         = "testapp"
  env             = "dev"
}

module "vpc_endpoint" {
  source                  = "./vpc_endpoint"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  vpc_endpoint_sg_id      = module.security_group.security_group_ids["vpc_endpoint_sg"]
  project                 = "testapp"
  env                     = "dev"
}