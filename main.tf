# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
}

provider "aws" {
  profile = "til_coreteam"
  region  = "eu-west-2"
}

data "aws_caller_identity" "current" {}
