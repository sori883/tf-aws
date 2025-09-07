# AWSアカウント情報取得
data "aws_caller_identity" "current" {}

locals {
  deploy_tag = "latest"
  log_group_name = format("%s-%s-%s", var.common_name, "log-ecs-business", var.post_prefix)
  container_name_business = format("%s-%s-%s", var.common_name, "container-business", var.post_prefix)
  container_name_business_log = format("%s-%s-%s", var.common_name, "container-firelens-business", var.post_prefix)
}

#--------------------------------------------------
# CloudWatchロググループのKMSキー
#--------------------------------------------------
resource "aws_kms_key" "kms_log_ecs_business" {
  description             = format("%s-%s-%s", var.common_name, "kms-log-ecs-business", var.post_prefix)
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
    Name = format("%s-%s-%s", var.common_name, "kms-log-ecs-business", var.post_prefix)
  }
}

#--------------------------------------------------
# CloudWatchロググループ
#--------------------------------------------------
resource "aws_cloudwatch_log_group" "log_ecs_business" {
  name              = local.log_group_name
  retention_in_days = 0
  kms_key_id = aws_kms_key.kms_log_ecs_business.arn

  depends_on = [ aws_kms_key.kms_log_ecs_business ]
}

#--------------------------------------------------
# IAMロール
#--------------------------------------------------
resource "aws_iam_role" "iam_role_ecs_business_execution" {
  name = format("%s-%s-%s", var.common_name, "role-ecs-business", var.post_prefix)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#--------------------------------------------------
# IAMポリシー（ログ）
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_ecs_business_log_execution" {
  name        = format("%s-%s-%s", var.common_name, "policy-ecs-business", var.post_prefix)
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
          aws_cloudwatch_log_group.log_ecs_business.arn,
          "${aws_cloudwatch_log_group.log_ecs_business.arn}:*"
        ]
      }
    ]
  })
}

#--------------------------------------------------
# IAMポリシー（Public）
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_ecs_business_pull_through_cache_execution" {
  name = format("%s-%s-%s", var.common_name, "policy-ecs-business-public", var.post_prefix)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.ecr_public_ecr_repository_prefix}/*"
      }
    ]
  })
}

#--------------------------------------------------
# IAMポリシー（ECR）
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_ecs_business_ecr_execution" {
  name = format("%s-%s-%s", var.common_name, "policy-ecs-ecr-business", var.post_prefix)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [var.ecr_business_arn]
      }
    ]
  })
}

#--------------------------------------------------
# IAMロールにポリシーをアタッチ
#--------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_ecs_business_policy_log_execution" {
  role       = aws_iam_role.iam_role_ecs_business_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_business_log_execution.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_business_policy_public_execution" {
  role       = aws_iam_role.iam_role_ecs_business_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_business_pull_through_cache_execution.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_business_ecr_execution" {
  role       = aws_iam_role.iam_role_ecs_business_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_business_ecr_execution.arn
}


#--------------------------------------------------
# business ECR
#--------------------------------------------------
resource "aws_ecs_task_definition" "business" {
  family                   = format("%s-%s-%s", var.common_name, "task-business", var.post_prefix)
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "2048"
  memory                  = "4096"
  execution_role_arn      = aws_iam_role.iam_role_ecs_business_execution.arn
  task_role_arn           = aws_iam_role.iam_role_ecs_business_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name_business
      image     = "${var.ecr_business_repository_url}:${local.deploy_tag}"
      cpu       = 1536
      memory    = 3072
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          "Name"   = "cloudwatch"
          "region" = var.aws_region
          "log_group_name" = local.log_group_name
          "log_stream_prefix" = "business"
        }
      }
      dependsOn = [
        {
          containerName = local.container_name_business_log
          condition     = "START"
        }
      ]
    },
    {
      name      = local.container_name_business_log
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_public_ecr_repository_prefix}/aws-observability/aws-for-fluent-bit:stable"
      cpu       = 512
      memory    = 1024
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          "enable-ecs-log-metadata" = "true"
        }
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = local.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "firelens-business"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "business" {
  name            = format("%s-%s-%s", var.common_name, "service-business", var.post_prefix)
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.business.arn
  desired_count   = 2
  availability_zone_rebalancing = "ENABLED"
  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      var.ecs_business_subnet_1a_id,
      var.ecs_business_subnet_1c_id
    ]
    security_groups = [ var.ecs_business_security_group_id ]
    assign_public_ip = false
  }
}

