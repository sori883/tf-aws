# AWSアカウント情報取得
data "aws_caller_identity" "current" {}

locals {
  ecs_cluster_name = format("%s-%s-%s", var.common_name, "ecs-cluster", var.post_prefix)
}

#--------------------------------------------------
# ECSクラスターの一時ストレージに設定するKMSキー
#--------------------------------------------------
resource "aws_kms_key" "kms_ecs_storage_key" {
  description             = format("%s-%s-%s", var.common_name, "kms-ecs-cluster-storage-key", var.post_prefix)
  deletion_window_in_days = 7

  policy = jsonencode({
    Id = "ECSClusterFargatePolicy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          "AWS" : "*"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow generate data key access for Fargate tasks."
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKeyWithoutPlaintext"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [
              data.aws_caller_identity.current.account_id
            ]
            "kms:EncryptionContext:aws:ecs:clusterName" = [
              local.ecs_cluster_name
            ]
          }
        }
        Resource = "*"
      },
      {
        Sid    = "Allow grant creation permission for Fargate tasks."
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
        Action = [
          "kms:CreateGrant"
        ]
        Condition = {
          StringEquals = {
            "kms:EncryptionContext:aws:ecs:clusterAccount" = [
              data.aws_caller_identity.current.account_id
            ]
            "kms:EncryptionContext:aws:ecs:clusterName" = [
              local.ecs_cluster_name
            ]
          }
          "ForAllValues:StringEquals" = {
            "kms:GrantOperations" = [
              "Decrypt"
            ]
          }
        }
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })

  tags = {
    Name = format("%s-%s-%s", var.common_name, "kms-ecs-cluster-storage-key", var.post_prefix)
  }
}

#--------------------------------------------------
# ECS構築
#--------------------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = format("%s-%s-%s", var.common_name, "ecs-cluster", var.post_prefix)
  
  configuration {
    managed_storage_configuration {
      fargate_ephemeral_storage_kms_key_id = aws_kms_key.kms_ecs_storage_key.id
    }
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  depends_on = [ aws_kms_key.kms_ecs_storage_key ]
}