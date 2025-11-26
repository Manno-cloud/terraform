##############################
# ACM 証明書の作成
##############################

resource "aws_acm_certificate" "acm" {

  # 取得する証明書のドメイン名
  domain_name = var.domain_name

  # DNS 検証を使用して証明書を発行
  validation_method = "DNS"

  # タグ設定
  tags = {
    Name    = "${var.project}-${var.env}-acm-${var.name}"  # 証明書名
    Project = var.project  # プロジェクト識別タグ
    Env     = var.env      # 環境識別タグ（dev / stg / prod）
  }
}