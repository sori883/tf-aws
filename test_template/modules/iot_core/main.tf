# AWSアカウント情報取得
data "aws_caller_identity" "current" {}

locals {
  iot_rule_topic_cwlog = "+/in"
  iot_rule_topic_lambda = "+/in"
}

#--------------------------------------------------
# モジュール呼び出し：IoTルール作成(+/in_cwlog)
#--------------------------------------------------
module "iot_rule_in_cwlog" {
  source = "./iot_rules/in_cwlog"

  common_name = var.common_name
  post_prefix = var.post_prefix
  aws_region  = var.aws_region
  iot_rule_topic_cwlog = local.iot_rule_topic_cwlog
}

#--------------------------------------------------
# モジュール呼び出し：IoTルール作成(+/in_lambda_sqs)
#--------------------------------------------------
module "iot_rule_in_lambda" {
  source = "./iot_rules/in_lambda_sqs"

  common_name = var.common_name
  post_prefix = var.post_prefix
  aws_region  = var.aws_region
  iot_rule_topic_lambda = local.iot_rule_topic_lambda
}

#--------------------------------------------------
# IoT証明書
#--------------------------------------------------
resource "aws_iot_certificate" "iot_certificate" {
  active = true
}

#--------------------------------------------------
# IoTモノ
#--------------------------------------------------
resource "aws_iot_thing" "iot_thing" {
  name = format("%s-%s-%s", var.common_name, "iot-thing", var.post_prefix)
}

#--------------------------------------------------
# IoTポリシー
#--------------------------------------------------
resource "aws_iot_policy" "iot_policy" {
  name = format("%s-%s-%s", var.common_name, "iot-policy", var.post_prefix)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 特定のクライアントの接続を許可
        Effect   = "Allow"
        Action   = ["iot:Connect"]
        Resource = ["arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.iot_thing.name}"]
      },
      {
        # 特定のトピックへの発行と受信を許可
        Effect   = "Allow"
        Action   = ["iot:Publish", "iot:Receive"]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${local.iot_rule_topic_cwlog}",
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/${local.iot_rule_topic_lambda}"
        ],
      },
      {
        # 特定のトピックフィルターへのサブスクリプションを許可
        Effect   = "Allow"
        Action   = ["iot:Subscribe"]
        Resource = [
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/${local.iot_rule_topic_cwlog}",
          "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/${local.iot_rule_topic_lambda}"
        ]
      }
    ]
  })
}

#--------------------------------------------------
# IoT証明書とIoTポリシーのアタッチ
#--------------------------------------------------
resource "aws_iot_policy_attachment" "iot_attach_policy_to_certificate" {
  policy = aws_iot_policy.iot_policy.name
  target = aws_iot_certificate.iot_certificate.arn
}

#--------------------------------------------------
# IoT証明書をIoTモノにアタッチ
#--------------------------------------------------
resource "aws_iot_thing_principal_attachment" "attach_cert_to_thing" {
  principal = aws_iot_certificate.iot_certificate.arn
  thing     = aws_iot_thing.iot_thing.name
}

#--------------------------------------------------
# 証明書情報を保存するSecrets Manager作成
#--------------------------------------------------
resource "aws_secretsmanager_secret" "secret_iot_certificate" {
  name = format("%s-%s-%s", var.common_name, "secret-iot-certificate", var.post_prefix)
  force_overwrite_replica_secret = true
  recovery_window_in_days = 0
}

#--------------------------------------------------
# 証明書情報をSecrets Managerに保存
#--------------------------------------------------
resource "aws_secretsmanager_secret_version" "secret_iot_certificate_version" {
  secret_id = aws_secretsmanager_secret.secret_iot_certificate.id
  secret_string = jsonencode({
    certificate_pem = aws_iot_certificate.iot_certificate.certificate_pem
    private_key     = aws_iot_certificate.iot_certificate.private_key
  })
}
