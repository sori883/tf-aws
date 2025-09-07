# AWSアカウント情報取得
data "aws_caller_identity" "current" {}
# ELBのアカウント情報取得
data "aws_elb_service_account" "current" {}

#--------------------------------------------------
# ALB Log用のS3
#--------------------------------------------------
resource "aws_s3_bucket" "s3_alb_log_public" {
  bucket = format("%s-%s-%s", var.common_name, "s3-alb-log", var.post_prefix)

  tags = {
    Name = format("%s-%s-%s", var.common_name, "s3-alb-log", var.post_prefix)
  }
}

resource "aws_s3_bucket_policy" "s3_alb_log_public_policy" {
  bucket = aws_s3_bucket.s3_alb_log_public.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.s3_alb_log_public.arn}/*"
      }
    ]
  })
}

#--------------------------------------------------
# ALB
#--------------------------------------------------
resource "aws_lb" "alb_public" {
  name               = format("%s-%s-%s", var.common_name, "alb-public", var.post_prefix)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_public_inbound]
  subnets            = [var.subenet_public_inbound_1a, var.subenet_public_inbound_1c]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.s3_alb_log_public.id
    prefix  = format("%s-%s-%s", var.common_name, "alb-public-access", var.post_prefix)
    enabled = true
  }

  connection_logs {
    bucket  = aws_s3_bucket.s3_alb_log_public.id
    prefix  = format("%s-%s-%s", var.common_name, "alb-public-connect", var.post_prefix)
    enabled = true
  }
}

#--------------------------------------------------
# target_group
#--------------------------------------------------
resource "aws_lb_target_group" "target_group_gateway" {
  name = format("%s-%s-%s", var.common_name, "target-group-gateway", var.post_prefix)
  target_type = "ip"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTP"
    port                = "traffic-port"
  }

  tags = {
    Name = format("%s-%s-%s", var.common_name, "target-group-gateway", var.post_prefix)
  }
}

#--------------------------------------------------
# listener
#--------------------------------------------------
resource "aws_lb_listener" "listener_public_https" {
  load_balancer_arn = aws_lb.alb_public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_gateway.arn
  }
}