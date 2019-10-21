provider "archive" {}

provider "aws" {
  version = "~> 2.0"
  region = "eu-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket=var.bucket_name
  topic {
    topic_arn     = aws_sns_topic.notification_topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic" "notification_topic" {
  name = var.notification_topic_name
  policy = data.aws_iam_policy_document.notification_topic.json
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.s3_event.arn
}

resource "aws_iam_role" "lambda" {
  assume_role_policy=data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda" {
  policy=data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn=aws_iam_policy.lambda.arn
  role=aws_iam_role.lambda.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${var.lambda_name}.py"
  output_path = "${var.lambda_name}.zip"
}

resource "aws_lambda_function" "s3_event" {
  filename="${var.lambda_name}.zip"
  function_name=var.lambda_name
  role=aws_iam_role.lambda.arn
  timeout = 10

  handler="${var.lambda_name}.handler"
  source_code_hash=filebase64sha256("${var.lambda_name}.zip")
  runtime="python3.7"
  environment {
    variables={
      REGION=data.aws_region.default.name
      SUBJECT="File created on S3"
      SENDER=var.sender
      RECIPIENT=var.recipient
    }
  }
}
resource "aws_lambda_permission" "lambda_permission" {
  action="lambda:InvokeFunction"
  function_name=aws_lambda_function.s3_event.function_name
  principal="sns.amazonaws.com"
  source_arn = aws_sns_topic.notification_topic.arn
}

resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}