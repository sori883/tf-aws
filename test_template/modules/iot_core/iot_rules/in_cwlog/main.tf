# AWSアカウント情報取得
data "aws_caller_identity" "current" {}


locals {
  log_group_name = format("%s-%s-%s", var.common_name, "log-iot-rule-in", var.post_prefix)
}

#--------------------------------------------------
# CloudWatchロググループのKMSキー
#--------------------------------------------------
resource "aws_kms_key" "kms_log_iot_rule_in" {
  description             = format("%s-%s-%s", var.common_name, "kms-log-iot-rule-in", var.post_prefix)
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
resource "aws_cloudwatch_log_group" "log_iot_rule_in_log" {
  name              = local.log_group_name
  retention_in_days = 0
  kms_key_id = aws_kms_key.kms_log_iot_rule_in.arn

  depends_on = [ aws_kms_key.kms_log_iot_rule_in ]
}

#--------------------------------------------------
# IAMポリシー
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_iot_rule_in_log" {
  name        = format("%s-%s-%s", var.common_name, "policy-iot-in-log", var.post_prefix)
  description = "Policy to allow pushing logs to specific CloudWatch Log Group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.log_iot_rule_in_log.arn,
          "${aws_cloudwatch_log_group.log_iot_rule_in_log.arn}:*"
        ]
      }
    ]
  })
}

#--------------------------------------------------
# IAMロール
#--------------------------------------------------
resource "aws_iam_role" "iam_role_iot_rule_in_log" {
  name = format("%s-%s-%s", var.common_name, "role-iot-rule-in-log", var.post_prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#--------------------------------------------------
# IAMロールにポリシーをアタッチ
#--------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_iot_rule_in_log_poliocy" {
  role       = aws_iam_role.iam_role_iot_rule_in_log.name
  policy_arn = aws_iam_policy.iam_policy_iot_rule_in_log.arn
}


#--------------------------------------------------
# IoTルール作成(+/in)
#--------------------------------------------------
resource "aws_iot_topic_rule" "iot_rule_in_log" {
  name        = format("%s_%s_%s", var.common_name, "iot_rule_in_log", var.post_prefix)
  description = "export messages to cloudwatch log"
  enabled     = true
  sql         = "SELECT * FROM '+/in'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    batch_mode     = true
    log_group_name = aws_cloudwatch_log_group.log_iot_rule_in_log.name
    role_arn       = aws_iam_role.iam_role_iot_rule_in_log.arn
  }
}

