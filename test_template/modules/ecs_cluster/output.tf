#--------------------------------------------------
# ECS Cluster
#--------------------------------------------------
output "ecs_cluster" {
  description = "ECS Cluster"
  value       = aws_ecs_cluster.ecs_cluster
}

#--------------------------------------------------
# ECS Cluster KMS
#--------------------------------------------------
output "kms_ecs_storage_key" {
  description = "KMS"
  value       = aws_kms_key.kms_ecs_storage_key
}
