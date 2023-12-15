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
    "./state_machine_definition.json",
    {
      INSTANCE_ID = var.instance_id
      INSTANCE_TYPE = var.instance_type
    }
  )
}
