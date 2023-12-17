# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "${local.app_name}-Lambda"
  tags = local.common_tags

  assume_role_policy  = data.aws_iam_policy_document.lambda_assume.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.lambda.arn
  ]
}

resource "aws_iam_policy" "lambda" {
  name   = "${local.app_name}-Lambda"
  tags   = local.common_tags
  policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions   = [
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
module "lambda_function_1" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${local.app_name}-WaitForInstanceStopped"
  description   = "..."
  tags          = local.common_tags
  handler       = "wait-for-stopped.main"
  runtime       = "python3.9"
  memory_size   = 512
  timeout       = 300
  publish       = true

  create_role   = false
  lambda_role   = aws_iam_role.lambda.arn

  source_path = "./wait-for-stopped.py"

  environment_variables = {
    INSTANCE_ID = var.instance_id
    INSTANCE_TYPE = var.instance_type
  }
}
