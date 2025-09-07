# AWSアカウント情報取得
data "aws_caller_identity" "current" {}

locals {
  deploy_tag = "latest"
  log_group_name = format("%s-%s-%s", var.common_name, "log-ecs-gateway", var.post_prefix)
  container_name_gateway = format("%s-%s-%s", var.common_name, "container-gateway", var.post_prefix)
  container_name_gateway_log = format("%s-%s-%s", var.common_name, "container-firelens-gateway", var.post_prefix)
}

#--------------------------------------------------
# CloudWatchロググループのKMSキー
#--------------------------------------------------
resource "aws_kms_key" "kms_log_ecs_gateway" {
  description             = format("%s-%s-%s", var.common_name, "kms-log-ecs-gateway", var.post_prefix)
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
    Name = format("%s-%s-%s", var.common_name, "kms-log-ecs-gateway", var.post_prefix)
  }
}

#--------------------------------------------------
# CloudWatchロググループ
#--------------------------------------------------
resource "aws_cloudwatch_log_group" "log_ecs_gateway" {
  name              = local.log_group_name
  retention_in_days = 0
  kms_key_id = aws_kms_key.kms_log_ecs_gateway.arn

  depends_on = [ aws_kms_key.kms_log_ecs_gateway ]
}

#--------------------------------------------------
# IAMロール
#--------------------------------------------------
resource "aws_iam_role" "iam_role_ecs_gateway_execution" {
  name = format("%s-%s-%s", var.common_name, "role-ecs-gateway", var.post_prefix)

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
resource "aws_iam_policy" "iam_policy_ecs_gateway_log_execution" {
  name        = format("%s-%s-%s", var.common_name, "policy-ecs-gateway", var.post_prefix)
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
          aws_cloudwatch_log_group.log_ecs_gateway.arn,
          "${aws_cloudwatch_log_group.log_ecs_gateway.arn}:*"
        ]
      }
    ]
  })
}

#--------------------------------------------------
# IAMポリシー（Public）
#--------------------------------------------------
resource "aws_iam_policy" "iam_policy_ecs_gateway_pull_through_cache_execution" {
  name = format("%s-%s-%s", var.common_name, "policy-ecs-gateway-public", var.post_prefix)
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
resource "aws_iam_policy" "iam_policy_ecs_gateway_ecr_execution" {
  name = format("%s-%s-%s", var.common_name, "policy-ecs-ecr-gateway", var.post_prefix)
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
        Resource = [var.ecr_gateway_arn]
      }
    ]
  })
}

#--------------------------------------------------
# IAMロールにポリシーをアタッチ
#--------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_ecs_gateway_policy_log_execution" {
  role       = aws_iam_role.iam_role_ecs_gateway_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_gateway_log_execution.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_gateway_policy_public_execution" {
  role       = aws_iam_role.iam_role_ecs_gateway_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_gateway_pull_through_cache_execution.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_gateway_ecr_execution" {
  role       = aws_iam_role.iam_role_ecs_gateway_execution.name
  policy_arn = aws_iam_policy.iam_policy_ecs_gateway_ecr_execution.arn
}


#--------------------------------------------------
# Gateway ECR
#--------------------------------------------------
resource "aws_ecs_task_definition" "gateway" {
  family                   = format("%s-%s-%s", var.common_name, "task-gateway", var.post_prefix)
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "2048"
  memory                  = "4096"
  execution_role_arn      = aws_iam_role.iam_role_ecs_gateway_execution.arn
  task_role_arn           = aws_iam_role.iam_role_ecs_gateway_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name_gateway
      image     = "${var.ecr_gateway_repository_url}:${local.deploy_tag}"
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
          "log_stream_prefix" = "gateway"
        }
      }
      dependsOn = [
        {
          containerName = local.container_name_gateway_log
          condition     = "START"
        }
      ]
    },
    {
      name      = local.container_name_gateway_log
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
          "awslogs-stream-prefix" = "firelens-gateway"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "gateway" {
  name            = format("%s-%s-%s", var.common_name, "service-gateway", var.post_prefix)
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.gateway.arn
  desired_count   = 2
  availability_zone_rebalancing = "ENABLED"
  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      var.ecs_gateway_subnet_1a_id,
      var.ecs_gateway_subnet_1c_id
    ]
    security_groups = [ var.ecs_gateway_security_group_id ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_public_arn
    container_name   = local.container_name_gateway
    container_port   = 80
  }
}

