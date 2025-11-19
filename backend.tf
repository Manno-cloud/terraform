terraform {
  backend "s3" {
    bucket         = "tastylog-tfstate-backet-fmanno"
    key            = "main/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}