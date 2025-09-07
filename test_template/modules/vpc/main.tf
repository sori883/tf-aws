#--------------------------------------------------
# VPC構築
#--------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = format("%s-%s-%s", var.common_name, "vpc", var.post_prefix)
  }
}

#--------------------------------------------------
# VPC Flow Log用のS3
#--------------------------------------------------
resource "aws_s3_bucket" "s3_vpc_flowlog" {
  bucket = format("%s-%s-%s", var.common_name, "s3-vpc-flowlog", var.post_prefix)

  tags = {
    Name = format("%s-%s-%s", var.common_name, "s3-vpc-flowlog", var.post_prefix)
  }
}

#--------------------------------------------------
# VPC Flow Log
#--------------------------------------------------
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_s3_bucket.s3_vpc_flowlog.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id

  depends_on = [
    aws_vpc.vpc,
    aws_s3_bucket.s3_vpc_flowlog
  ]
}

#--------------------------------------------------
# Internet Gateway
#--------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "igw", var.post_prefix)
  }
}

#--------------------------------------------------
# Virtual Private Gateway
#--------------------------------------------------
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = format("%s-%s-%s", var.common_name, "vgw", var.post_prefix)
  }
}

