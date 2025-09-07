#--------------------------------------------------
# VPC
#--------------------------------------------------
output "vpc" {
  description = "VPC"
  value       = aws_vpc.vpc
}

#--------------------------------------------------
# IGW
#--------------------------------------------------
output "igw" {
  description = "IGW"
  value       = aws_internet_gateway.igw
}

#--------------------------------------------------
# VGW
#--------------------------------------------------
output "vgw" {
  description = "VGW"
  value       = aws_vpn_gateway.vgw
}

#--------------------------------------------------
# S3
#--------------------------------------------------
output "s3_vpc_flow_log" {
  description = "S3 for VPC Flow Log"
  value       = aws_s3_bucket.s3_vpc_flowlog
}

