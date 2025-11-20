resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-${var.env}-db-subnet-group"
  }
}

resource "aws_db_instance" "dbinstance" {
  identifier             = "${var.project}-${var.env}-rds"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = var.storage_gb
  max_allocated_storage  = var.storage_gb  # 自動拡張 OFF
  storage_type           = "gp3"

  db_name                = var.db_name
  username               = var.username
  password               = var.password

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 0  # バックアップなし（テスト用）
  deletion_protection      = false
  skip_final_snapshot      = true

  tags = {
    Name = "${var.project}-${var.env}-rds"
  }
}