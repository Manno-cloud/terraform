terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
  backend "s3" {
    bucket  = "tastylog-tfstate-backet-fmanno"
    key     = "tastylog-dev.tfstate"
    region  = "ap-northeast-1"
  }
}


#Provider

provider "aws" {
  region  = "ap-northeast-1"
}

#Variables

variable "project" {
  type = string
}

variable "enviroment" {
  type = string
  default = "dev"
}

