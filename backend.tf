terraform {
  backend "s3" {
    bucket         = "testapp-tfstate-backet-fmanno"
    key            = "main/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}