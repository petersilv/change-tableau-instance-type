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

# ----------------------------------------------------------------------------------------------------------------------
variable "instance_id" {
  type = string
}

variable "instance_type" {
  type = string
}

data "aws_caller_identity" "current" {}

locals {
  app_name = "tableau-instance-type"
  local_state_machine_definition_filepath = "./state_machine_definition.json"

  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_caller_arn  = data.aws_caller_identity.current.arn
  aws_caller_user = data.aws_caller_identity.current.user_id

  common_tags = {
    application_name = local.app_name
    owner_arn        = local.aws_caller_arn
    created_with     = "Terraform"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "stepfunctions" {
  name = "${local.app_name}-StepFunctions"
  tags = local.common_tags

  assume_role_policy  = data.aws_iam_policy_document.stepfunctions_assume.json
  managed_policy_arns = [aws_iam_policy.stepfunctions.arn]
}

resource "aws_iam_policy" "stepfunctions" {
  name   = "${local.app_name}-StepFunctions"
  tags   = local.common_tags
  policy = data.aws_iam_policy_document.stepfunctions.json
}

data "aws_iam_policy_document" "stepfunctions_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "stepfunctions" {
  statement {
    actions   = [
      "ssm:SendCommand",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:ModifyInstanceAttribute"
    ]
    resources = ["*"]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_sfn_state_machine" "state_machine" {
  name     = "${local.app_name}"
  tags     = local.common_tags
  role_arn = aws_iam_role.stepfunctions.arn

  definition = templatefile(
    "${local.local_state_machine_definition_filepath}",
    {
      INSTANCE_ID = var.instance_id
      INSTANCE_TYPE = var.instance_type
    }
  )
}
