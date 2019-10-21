data "aws_caller_identity" "default" {}

data "aws_region" "default" {
  name = "eu-west-1"
}

data "aws_iam_policy_document" "notification_topic" {
  policy_id = var.lambda_name

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:sns:*:*:${var.notification_topic_name}",
    ]
    condition {
      test="ArnLike"
      values=["arn:aws:s3:::${var.bucket_name}"]
      variable="aws:SourceArn"
    }

    sid = "EventPublish"
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  policy_id = "lambda_assume_role"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers=["lambda.amazonaws.com"]
      type="Service"
    }
    effect = "Allow"
    sid = "LambdaAssumeRole"
  }
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  policy_id = "lambda_exec_policy"
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    effect = "Allow"
    resources = [aws_ses_email_identity.sender.arn]
//    resources = ["arn:aws:ses:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:identity/${var.sender_email}"]
    sid = "SES"
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroup",
      "logs:GetLogEvents",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"]
    sid = "CloudWatch"
  }
}