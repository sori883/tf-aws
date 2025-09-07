#--------------------------------------------------
# S3 Gateway Endpoint
#--------------------------------------------------
output "vpce_s3gw_id" {
  description = "ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3gw.id
}

#--------------------------------------------------
# SSM Interface Endpoint
#--------------------------------------------------
output "vpce_ssm_id" {
  description = "ID of the SSM Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

#--------------------------------------------------
# SSM Messages Interface Endpoint
#--------------------------------------------------
output "vpce_ssmmessage_id" {
  description = "ID of the SSM Messages Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ssmmessage.id
}

#--------------------------------------------------
# EC2 Messages Interface Endpoint
#--------------------------------------------------
output "vpce_ec2messages_id" {
  description = "ID of the EC2 Messages Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ec2messages.id
}

#--------------------------------------------------
# CloudWatch Logs Interface Endpoint
#--------------------------------------------------
output "vpce_logs_id" {
  description = "ID of the CloudWatch Logs Interface VPC Endpoint"
  value       = aws_vpc_endpoint.logs.id
}

#--------------------------------------------------
# Secrets Manager Interface Endpoint
#--------------------------------------------------
output "vpce_secretsmanager_id" {
  description = "ID of the Secrets Manager Interface VPC Endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

#--------------------------------------------------
# API Gateway Interface Endpoint
#--------------------------------------------------
output "vpce_execute_api_id" {
  description = "ID of the API Gateway Interface VPC Endpoint"
  value       = aws_vpc_endpoint.execute_api.id
}

#--------------------------------------------------
# KMS Interface Endpoint
#--------------------------------------------------
output "vpce_kms_id" {
  description = "ID of the KMS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.kms.id
}

#--------------------------------------------------
# ECR API Interface Endpoint
#--------------------------------------------------
output "vpce_ecr_api_id" {
  description = "ID of the ECR API Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

#--------------------------------------------------
# ECR DKR Interface Endpoint
#--------------------------------------------------
output "vpce_ecr_dkr_id" {
  description = "ID of the ECR DKR Interface VPC Endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

#--------------------------------------------------
# SQS Interface Endpoint
#--------------------------------------------------
output "vpce_sqs_id" {
  description = "ID of the SQS Interface VPC Endpoint"
  value       = aws_vpc_endpoint.sqs.id
}