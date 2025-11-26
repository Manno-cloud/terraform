############################################
# RDS Subnet Group（RDS を配置するサブネットのグループ）
############################################
resource "aws_db_subnet_group" "db_subnet_group" {
  # サブネットグループ名
  name       = "${var.project}-${var.env}-db-subnet-group"

  # RDS を配置するサブネット（通常は private サブネット）
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-${var.env}-db-subnet-group"
  }
}

############################################
# RDS Instance（MySQL 8.0）
############################################
resource "aws_db_instance" "dbinstance" {

  # RDS インスタンスの識別子
  identifier = "${var.project}-${var.env}-rds"

  # DB エンジン
  engine         = "mysql"
  engine_version = "8.0"

  # インスタンスタイプ（最小構成）
  instance_class = "db.t3.micro"

  # ストレージ設定
  allocated_storage     = var.storage_gb        # 初期ストレージ
  max_allocated_storage = var.storage_gb        # 自動拡張を無効化（課題中はコスト削減）
  storage_type          = "gp3"

  # DB 作成時の初期設定
  db_name  = var.db_name
  username = var.username
  password = data.aws_ssm_parameter.rds_password.value

  # セキュリティまわり
  vpc_security_group_ids = var.vpc_security_group_ids   # DB 用 SG
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  publicly_accessible = false  # 公開しない（セキュリティ上必須）
  multi_az            = false  # 今回はテスト用なのでシングルAZ

  # 運用設定（学習・検証向けの最小構成）
  backup_retention_period = 0   # 自動バックアップ無効
  deletion_protection     = false
  skip_final_snapshot     = true  # 削除時スナップショット不要

  tags = {
    Name = "${var.project}-${var.env}-rds"
  }
}

############################################
# SSM Parameter Store から RDS パスワードを取得
############################################
data "aws_ssm_parameter" "rds_password" {
  # root module から渡される SSM パラメータ名
  name = var.rds_password_parameter_name
}