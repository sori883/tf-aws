# AWSアカウント情報取得
data "aws_caller_identity" "current" {}

# lambdaのソースコード取得
data "archive_file" "lambda_iot_rule_in" {
  type           = "zip"
  source_file    = "${path.module}/lambda/lambda_function.py"
  output_path    = "${path.module}/lambda/lambda_function.zip"
}

locals {
  lambda_name = format("%s-%s-%s", var.common_name, "lambda-iot-in", var.post_prefix)
  log_group_name = format("%s-%s-%s", var.common_name, "log-iot-rule-in-lambda", var.post_prefix)
  sqs_names = [
    format("%s-%s-%s", var.common_name, "sqs-one", var.post_prefix),
    format("%s-%s-%s", var.common_name, "sqs-two", var.post_prefix)
  ]
}

#--------------------------------------------------
# SQS
#--------------------------------------------------
resource "aws_sqs_queue" "sqs_iot_rule_in" {
  for_each = toset(local.sqs_names)
  name = each.value
  sqs_managed_sse_enabled = true
}

#--------------------------------------------------
# CloudWatchロググループのKMSキー
#--------------------------------------------------
resource "aws_kms_key" "kms_log_iot_rule_in" {
  description             = format("%s-%s-%s", var.common_name, "kms-log-iot-rule-in-lambda", var.post_prefix)
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs Service"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group_name}"
          }
        }
      }
    ]
  })

  tags = {
    Name = format("%s-%s-%s", var.common_name, "kms-log-iot-rule-in", var.post_prefix)
  }
}

#--------------------------------------------------
# CloudWatchロググループ
#--------------------------------------------------
resource "aws_cloudwatch_log_group" "log_iot_rule_in_lambda" {
  name              = local.log_group_name
  retention_in_days = 0
  kms_key_id = aws_kms_key.kms_log_iot_rule_in.arn

  depends_on = [ aws_kms_key.kms_log_iot_rule_in ]
}

#--------------------------------------------------
# LambdaのIAMロール作成
#--------------------------------------------------
resource "aws_iam_role" "iam_role_iot_rule_in_lambda" {
  name = format("%s-%s-%s", var.common_name, "role-lambda-iot-in", var.post_prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = format("%s-%s-%s", var.common_name, "lambda-iot-in-role", var.post_prefix)
  }
}

#--------------------------------------------------
# LambdaのIAMロールのCWログポリシー
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_iot_rule_in_lambda_log" {
  name = format("%s-%s-%s", var.common_name, "policy-lambda-iot-in-log", var.post_prefix)
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_group.log_iot_rule_in_lambda.arn,
          "${aws_cloudwatch_log_group.log_iot_rule_in_lambda.arn}:*"
        ]
      }
    ]
  })
}

# ポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "attach_lambda_log_policy" {
  role       = aws_iam_role.iam_role_iot_rule_in_lambda.name
  policy_arn = aws_iam_policy.iam_policy_iot_rule_in_lambda_log.arn
}

#--------------------------------------------------
# LambdaのIAMロールのSQSポリシー
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_iot_rule_in_lambda_sqs" {
  name = format("%s-%s-%s", var.common_name, "policy-lambda-iot-in-sqs", var.post_prefix)
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = [
          for sqs in aws_sqs_queue.sqs_iot_rule_in : sqs.arn
        ]
      }
    ]
  })
}

# ポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "attach_lambda_sqs_policy" {
  role       = aws_iam_role.iam_role_iot_rule_in_lambda.name
  policy_arn = aws_iam_policy.iam_policy_iot_rule_in_lambda_sqs.arn
}

#--------------------------------------------------
# Lambda作成
#--------------------------------------------------
resource "aws_lambda_function" "lambda_iot_rule_in" {
  function_name    = local.lambda_name
  filename         = data.archive_file.lambda_iot_rule_in.output_path
  source_code_hash = data.archive_file.lambda_iot_rule_in.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.iam_role_iot_rule_in_lambda.arn
  handler          = "lambda_function.handler"
  logging_config {
    log_group  = aws_cloudwatch_log_group.log_iot_rule_in_lambda.name
    log_format = "JSON"
  }
}

#--------------------------------------------------
# IoTルール作成(+/in)
#--------------------------------------------------
resource "aws_iot_topic_rule" "iot_rule_in_lambda" {
  name        = format("%s_%s_%s", var.common_name, "iot_rule_in_lambda", var.post_prefix)
  description = "export messages to lambda"
  enabled     = true
  sql         = "SELECT * FROM '${var.iot_rule_topic_lambda}'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.lambda_iot_rule_in.arn
  }
}

#--------------------------------------------------
# Lambdaの権限
#--------------------------------------------------
resource "aws_lambda_permission" "iot_rule_in_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_iot_rule_in.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.iot_rule_in_lambda.arn
}