#--------------------------------------------------
# S3 Gateway Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "s3gw" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [
    var.rtb_private_gateway_id,
    var.rtb_private_business_id,
  ]
  vpc_endpoint_type = "Gateway"

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Action    = "*"
        Effect    = "Allow"
        Resource  = "*"
        Principal = "*"
      }
    ]
  })

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-s3gw", var.post_prefix)
  }
}

#--------------------------------------------------
# ssm Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-ssm", var.post_prefix)
  }
}

#--------------------------------------------------
# ssmmessages Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "ssmmessage" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]
  
  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-ssmmessages", var.post_prefix)
  }
}

#--------------------------------------------------
# ec2messages Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-ec2messages", var.post_prefix)
  }
}

#--------------------------------------------------
# logs Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "logs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-logs", var.post_prefix)
  }
}

#--------------------------------------------------
# secretsmanager Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-secretmanager", var.post_prefix)
  }
}

#--------------------------------------------------
# execute-api Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "execute_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-execute-api", var.post_prefix)
  }
}

#--------------------------------------------------
# kms Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "kms" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-kms", var.post_prefix)
  }
}

#--------------------------------------------------
# ecr.api Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-ecr-api", var.post_prefix)
  }
}

#--------------------------------------------------
# ecr.dkr Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-ecr-dkr", var.post_prefix)
  }
}

#--------------------------------------------------
# sqs Interface Endpoin
#--------------------------------------------------
resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    var.sb_private_1a_vpce_id,
    var.sb_private_1c_vpce_id
  ]
  security_group_ids = [ var.sg_private_vpce_id ]
  
  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpce-sqs", var.post_prefix)
  }
}

