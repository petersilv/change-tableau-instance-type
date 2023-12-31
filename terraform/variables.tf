# ----------------------------------------------------------------------------------------------------------------------
variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "state_machine_path" {
  type = string
}

variable "lambda_path" {
  type = string
}

# ----------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

locals {
  app_name = "ChangeTableauInstanceType"

  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_caller_arn  = data.aws_caller_identity.current.arn
  aws_caller_user = data.aws_caller_identity.current.user_id

  common_tags = {
    application_name = local.app_name
    owner_arn        = local.aws_caller_arn
    created_with     = "Terraform"
  }
}
