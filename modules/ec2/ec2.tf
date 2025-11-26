resource "aws_instance" "ec2" {

  # 使用する AMI（Amazon Linux / Ubuntu など）
  ami = var.ami_id

  # EC2 のインスタンスタイプ（例: t3.micro）
  instance_type = var.instance_type


  ############################################
  # ネットワーク設定
  ############################################

  # 配置するサブネット（通常は private subnet）
  subnet_id = var.subnet_id

  # EC2 に付与するセキュリティグループ一覧
  vpc_security_group_ids = var.security_group_ids


  ############################################
  # IAM 設定
  ############################################

  # EC2 に関連付ける IAM インスタンスプロファイル
  # （AWS CLI / SSM / CloudWatch Logs 書き込み権限など）
  iam_instance_profile = var.iam_instance_profile


  ############################################
  # User Data（起動時のセットアップスクリプト）
  ############################################
  user_data = var.user_data


  ############################################
  # ルートボリューム設定
  ############################################

  root_block_device {
    volume_size = var.volume_size  # ルートディスクの容量（GB）
    volume_type = "gp3"            # 推奨の高速 EBS gp3
  }


  ############################################
  # タグ設定
  ############################################

  tags = merge({
    # EC2 の Name タグ（project-env-ec2-name）
    Name = "${var.project}-${var.env}-ec2-${var.name}"
  }, var.tags)  # var.tags は追加タグをまとめて渡す
}
