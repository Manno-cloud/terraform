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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ======================
#  VPC モジュール
# ======================
#VPC
module "vpc" {
  source = "./modules/vpc"

  project = "testapp"
  env     = "dev"

  vpc_cidr = "10.0.0.0/16"

  #public_suibets(3AZ)
  public_subnets = {
    public1 = {
      cidr = "10.0.1.0/24"
      az   = "ap-northeast-1a"
    }
    public2 = {
      cidr = "10.0.2.0/24"
      az   = "ap-northeast-1c"
    }
    public3 = {
      cidr = "10.0.3.0/24"
      az   = "ap-northeast-1d"
    }
  }

  #private_suibets(3AZ)
  private_subnets = {
    private1 = {
      cidr = "10.0.10.0/24"
      az   = "ap-northeast-1a"
    }
    private2 = {
      cidr = "10.0.11.0/24"
      az   = "ap-northeast-1c"
    }
    private3 = {
      cidr = "10.0.12.0/24"
      az   = "ap-northeast-1d"
    }
  }
}

# ======================
#  Security Group モジュール
# ======================
# VPC内で必要な全ての Security Group をまとめて生成するモジュール。
module "security_group" {
  source = "./modules/security_group"

  # 作成先 VPC の ID
  vpc_id = module.vpc.vpc_id

  # モジュールに渡す Security Group 一覧
  security_groups = {

    # ALB 用 Security Group
    alb_sg = {
      name        = "alb_sg"
      description = "ALB SG"
    }

    # EC2 用 Security Group
    ec2_sg = {
      name        = "ec2_sg"
      description = "EC2 SG"
    }

    # VPC Endpoint 用 Security Group
    vpc_endpoint_sg = {
      name        = "vpc_endpoint_sg"
      description = "vpc_endpoint SG"
    }


    # RDS 用 Security Group
    rds_sg = {
      name        = "rds_sg"
      description = "RDS SG"
    }

    # ECS(Fargate) 用 Security Group
    ecs_sg = {
      name        = "ecs_sg"
      description = "ECS SG"
    }
  }
}
# ======================
#  Security Group ルール
# ======================

# ALB: HTTP (80) 外部公開
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["alb_sg"]
}


# ALB: HTTPS (443) 外部公開
resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["alb_sg"]
}

# ALB → EC2 へ 80番で通信を許可（ターゲット: EC2）
resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.security_group.security_group_ids["ec2_sg"]
  security_group_id        = module.security_group.security_group_ids["alb_sg"]
}


# EC2 → 全ての外向き通信を許可
resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["ec2_sg"]
}


# EC2 ← ALB（80番）からの通信を許可
resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.security_group.security_group_ids["ec2_sg"]
  source_security_group_id = module.security_group.security_group_ids["alb_sg"]
}


# EC2 → VPC Endpoint (443) の利用を許可
resource "aws_security_group_rule" "vpc_endpoint_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.security_group.security_group_ids["ec2_sg"]
  security_group_id        = module.security_group.security_group_ids["vpc_endpoint_sg"]
}


# VPC Endpoint → 外部向けの通信を許可
resource "aws_security_group_rule" "vpc_endpoint_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["vpc_endpoint_sg"]
}


# RDS ← EC2 から3306通信を許可
resource "aws_security_group_rule" "allow_ec2_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.security_group.security_group_ids["rds_sg"]
  source_security_group_id = module.security_group.security_group_ids["ec2_sg"]
}


# ECS ← ALB（80番）からの通信を許可（Fargateターゲット）
resource "aws_security_group_rule" "allow_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.security_group.security_group_ids["ecs_sg"]
  source_security_group_id = module.security_group.security_group_ids["alb_sg"]
}


# ECS → 全ての外向き通信
resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_ids["ecs_sg"]
}
# ======================
#  ACM モジュール
# ======================

module "acm_tokyo" {
  source = "./modules/acm"

  providers = {
    aws = aws
  }

  name            = "tokyo"
  domain_name     = "manno-cloud.com"
  route53_zone_id = module.route53.route53_zone_id
  project         = "testapp"
  env             = "dev"
}

module "acm_us" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }


  name            = "us"
  domain_name     = "cdn.manno-cloud.com"
  route53_zone_id = module.route53.route53_zone_id
  project         = "testapp"
  env             = "dev"
}

# ======================
#  S3 モジュール
# ======================

module "s3_cdn" {
  source = "./modules/s3/s3_cdn"

  project       = "testapp"
  env           = "dev"
  bucket_suffix = "cdn-images"

  cdn_distribution_arn = module.cdn.cdn_distribution_arn
}

# ======================
#  IAM モジュール
# ======================
module "iam" {
  source = "./modules/iam"

  project = "testapp"
  env     = "dev"
}


# ======================
#  ALB モジュール
# ======================
#EC2用ALB
module "alb" {
  source = "./modules/alb"

  name    = "testapp"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids

  security_group_ids = [
    module.security_group.security_group_ids["alb_sg"]
  ]

  target_port = 80
  target_type = "instance"

  certificate_arn = module.acm_tokyo.acm_certificate_arn
  enable_https    = true
}

#ECS用ALB
module "alb_ecs" {
  source = "./modules/alb"

  name    = "testapp-ecs"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids

  security_group_ids = [module.security_group.security_group_ids["alb_sg"]]

  target_port     = 80
  target_type     = "ip"
  enable_https    = true
  certificate_arn = module.acm_tokyo.acm_certificate_arn
}

# ======================
#  EC2 モジュール
# ======================

#ASGモジュール側で起動するため設定なし

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

  ami_id        = "ami-05bf4e59eee7da796"
  instance_type = "t3.micro"
  user_data     = file("${path.root}/user_data.sh")

  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  target_group_arn          = module.alb.target_group_arn
  iam_instance_profile_name = module.iam.ec2_profile_arn
}

# ======================
#  VPC endpoint
# ======================
module "vpc_endpoint" {
  source                  = "./vpc_endpoint"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  vpc_endpoint_sg_id      = module.security_group.security_group_ids["vpc_endpoint_sg"]
  project                 = "testapp"
  env                     = "dev"
}

# ======================
#  RDS モジュール
# ======================

module "rds" {
  source = "./modules/rds"

  project = "testapp"
  env     = "dev"

  subnet_ids = module.vpc.private_subnet_ids

  vpc_security_group_ids = [
    module.security_group.security_group_ids["rds_sg"]
  ]
  db_name  = "appdb"
  username = "admin"
  rds_password_parameter_name = "/testapp/dev/rds/password"
}

# ======================
#  CDN モジュール
# ======================
module "cdn" {
  source = "./modules/cdn"

  providers = {
    aws = aws
  }

  project               = "testapp"
  env                   = "dev"
  domain_name           = "cdn.manno-cloud.com"
  hosted_zone_id        = module.route53.route53_zone_id
  s3_bucket_domain_name = module.s3_cdn.bucket_domain_name
  web_acl_arn           = module.waf.waf_arn
  certificate_arn       = module.acm_us.acm_certificate_arn
}

# ======================
#  ROUTE 53 モジュール
# ======================

module "route53" {
  source = "./modules/route53"

  domain_name = "manno-cloud.com"
  project     = "testapp"
  env         = "dev"
}

# ======================
#  ROUTE 53 モジュール
# ======================

# ルートドメイン → CloudFront
resource "aws_route53_record" "root" {
  zone_id = module.route53.route53_zone_id
  name    = "manno-cloud.com"
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_domain_name
    zone_id                = module.cdn.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# CDN → CloudFront
resource "aws_route53_record" "cdn" {
  zone_id = module.route53.route53_zone_id
  name    = "cdn.manno-cloud.com"
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_domain_name
    zone_id                = module.cdn.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# ドメイン → ALB
resource "aws_route53_record" "app" {
  zone_id = module.route53.route53_zone_id
  name    = "app.manno-cloud.com"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

# ======================
#  WAF モジュール
# ======================

module "waf" {
  source = "./modules/waf"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }


  project = "testapp"
  env     = "dev"

  cloudfront_distribution_arn = module.cdn.cdn_distribution_arn
}

# ======================
#  ECR モジュール
# ======================
module "ecr" {
  source  = "./modules/ecr"

  project = "testapp"
  env     = "dev"
}

# ======================
#  ECS モジュール
# ======================
module "ecs" {
  source = "./modules/ecs"

  project = "testapp"
  env     = "dev"
  region  = var.region

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  alb_sg_id = module.security_group.security_group_ids["alb_sg"]
  ecs_sg_id = module.security_group.security_group_ids["ecs_sg"]

  target_group_arn = module.alb_ecs.target_group_arn
  listener_arn     = module.alb_ecs.https_listener_arn

  ecs_task_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  ecr_repository_url          = module.ecr.repository_url

  task_cpu    = "256"
  task_memory = "512"

  depends_on = [
  module.alb_ecs
]
}

# ======================
#  SSM モジュール
# ======================
module "ssm_parameter" {
  source = "./modules/ssm"

  project = "testapp"
  env     = "dev"

  parameter_name  = "/testapp/dev/rds/password"
  parameter_value = var.rds_password
}

############################################
# SNS（アラート通知）モジュール
############################################
module "sns" {
  source = "./modules/sns"

  project = "testapp"
  env     = "dev"
}

############################################
# 監視（CloudWatch Alarm）モジュール呼び出し
############################################
module "monitoring" {
  source = "./modules/monitoring"

  project = "testapp"
  env     = "dev"

  alb_arn_suffix    = module.alb.alb_arn_suffix
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  rds_instance_id  = module.rds.db_instance_id

  sns_topic_arn = module.sns.topic_arn
}
