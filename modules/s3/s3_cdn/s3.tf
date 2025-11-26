############################################
# S3 バケット
############################################
resource "aws_s3_bucket" "bucket" {
  # バケット名：project-env-用途 のルールで統一
  bucket = "${var.project}-${var.env}-${var.bucket_suffix}"

  # 共通タグ + 呼び出し元から渡された追加タグをマージ
  tags = merge(
    {
      Name    = "${var.project}-${var.env}-${var.bucket_suffix}"
      Project = var.project
      Env     = var.env
    },
    var.tags
  )
}

############################################
# バケットの Public アクセスブロック
############################################
resource "aws_s3_bucket_public_access_block" "access_block" {
  # 対象バケット
  bucket = aws_s3_bucket.bucket.id

  # すべてのパブリック ACL をブロック
  block_public_acls = true

  # パブリックポリシーの設定をブロック
  block_public_policy = true

  # 既存のパブリック ACL も無視
  ignore_public_acls = true

  # パブリック設定されたバケットポリシー自体を拒否
  restrict_public_buckets = true
}

############################################
# CloudFront OAC 用 S3 バケットポリシー
############################################
resource "aws_s3_bucket_policy" "cdn" {
  # 対象バケット
  bucket = aws_s3_bucket.bucket.id

  # 外部テンプレート(JSON)からポリシーを生成
  policy = templatefile(
    "${path.module}/policy/s3_cdn_policy.json.tpl",
    {
      # この S3 バケットの ARN
      bucket_arn = aws_s3_bucket.bucket.arn

      # CloudFront Distribution の ARN（root module から受け取る）
      cdn_distribution_arn = var.cdn_distribution_arn
    }
  )
}