# ----------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "eventbridge" {
  name = "${local.app_name}-EventBridge"
  tags = local.common_tags

  assume_role_policy  = data.aws_iam_policy_document.eventbridge_assume.json
  managed_policy_arns = [aws_iam_policy.eventbridge.arn]
}

resource "aws_iam_policy" "eventbridge" {
  name   = "${local.app_name}-EventBridge"
  tags   = local.common_tags
  policy = data.aws_iam_policy_document.eventbridge.json
}

data "aws_iam_policy_document" "eventbridge_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    actions   = ["states:StartExecution"]
    resources = ["*"]
  }
}

# ----------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "state_machine" {
  name        = "${local.app_name}-RunStateMachine"
  description = "EventBridge rule to run the state machine at 7pm on Sunday, December 15th"
  schedule_expression = "cron(0 19 17 12 ? *)"
}

resource "aws_cloudwatch_event_target" "state_machine" {
  target_id = "${local.app_name}-RunStateMachine"
  rule      = aws_cloudwatch_event_rule.state_machine.name
  role_arn  = aws_iam_role.eventbridge.arn
  arn       = aws_sfn_state_machine.state_machine.arn
}

