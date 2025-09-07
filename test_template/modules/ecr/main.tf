locals {
  public_repository_prefix = "ecr-public"
}

#--------------------------------------------------
# Gateway ECR
#--------------------------------------------------
resource "aws_ecr_repository" "ecr_gateway" {
  name                 = format("%s-%s-%s", var.common_name, "ecr-gateway", var.post_prefix)
  # タグ変更不可にする
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  # latestタグは例外的に変更を許可する
  # （バージョンタグだけ不変とする）
  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  } 
}

#--------------------------------------------------
# Business ECR
#--------------------------------------------------
resource "aws_ecr_repository" "ecr_business" {
  name                 = format("%s-%s-%s", var.common_name, "ecr-business", var.post_prefix)
  # タグ変更不可にする
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  # latestタグは例外的に変更を許可する
  # （バージョンタグだけ不変とする）
  image_tag_mutability_exclusion_filter {
    filter      = "latest*"
    filter_type = "WILDCARD"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  } 
}


#--------------------------------------------------
# Pull Cache ECR
#--------------------------------------------------
resource "aws_ecr_pull_through_cache_rule" "ecr_pull_cache_public" {
  ecr_repository_prefix = local.public_repository_prefix
  upstream_registry_url = "public.ecr.aws"
}

#--------------------------------------------------
# IAMロール（Pull Cache ECR）
#--------------------------------------------------
resource "aws_iam_role" "iam_role_pull_cache_template" {
  name = format("%s-%s-%s", var.common_name, "role-pull-cache-ecr", var.post_prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#--------------------------------------------------
# IAMポリシー（Pull Cache ECR）
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_pull_cache_templaten" {
  name        = format("%s-%s-%s", var.common_name, "policy-pull-cache-ecr", var.post_prefix)
  description = "Policy to allow pushing logs to specific CloudWatch Log Group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository",
          "ecr:ReplicateImage",
          "ecr:TagResource"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:RetireGrant",
          "kms:DescribeKey"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

#--------------------------------------------------
# IAMロールにポリシーをアタッチ
#--------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_pull_cache_template_policy" {
  role       = aws_iam_role.iam_role_pull_cache_template.name
  policy_arn = aws_iam_policy.iam_policy_pull_cache_templaten.arn
}


#--------------------------------------------------
# Pull Cache Template
#--------------------------------------------------
resource "aws_ecr_repository_creation_template" "ecr_repository_creation_template_public" {
  prefix               = "${local.public_repository_prefix}/"
  description          = "Public Image template"
  image_tag_mutability = "IMMUTABLE"
  custom_role_arn      = aws_iam_role.iam_role_pull_cache_template.arn

  applied_for = [
    "PULL_THROUGH_CACHE",
  ]
  

  encryption_configuration {
    encryption_type = "KMS"
  }
}