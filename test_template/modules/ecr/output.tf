#--------------------------------------------------
# ECR Gateway
#--------------------------------------------------
output "ecr_gateway" {
  description = "ECR Gateway"
  value       = aws_ecr_repository.ecr_gateway
}

#--------------------------------------------------
# ECR Business
#--------------------------------------------------
output "ecr_business" {
  description = "ECS Cluster"
  value       = aws_ecr_repository.ecr_business
}

#--------------------------------------------------
# ECR Public
#--------------------------------------------------
output "ecr_public" {
  description = "ECR Public  Preix"
  value       = aws_ecr_pull_through_cache_rule.ecr_pull_cache_public
}