terraform {
  required_version = ">= 1.5.0"
#test
#test33
#test33
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
  }
}

resource "aws_security_group_rule" "alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"

  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["alb_sg"]
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"

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

# ======================
#  EC2 モジュール
# ======================
module "ec2" {
  source = "./modules/ec2"

  project = "testapp"
  env     = "dev"
  name    = "testapp-web"

  ami_id = "ami-0e68e34976bb4db93"

  # VPC モジュールの private_subnets の出力名に注意！
  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_ids = [
    module.security_group.security_group_ids["ec2_sg"]
  ]

  instance_type = "t3.micro"
  user_data     = ""
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

  instance_ids = [module.ec2.instance_id]
  target_port  = 80
}
