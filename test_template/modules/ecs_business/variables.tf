variable "common_name" { type = string }
variable "post_prefix" { type = string }
variable "aws_region" { type = string }
variable "vpc_cidr" { type = string }

variable "az_1a" { type = string }
variable "az_1c" { type = string }

variable "ecs_cluster_id" { type = string }
variable "ecs_business_subnet_1a_id" { type = string }
variable "ecs_business_subnet_1c_id" { type = string }
variable "ecs_business_security_group_id" { type = string }
variable "ecr_business_arn" { type = string }
variable "ecr_business_repository_url" { type = string }
variable "ecr_public_registry_id" { type = string }
variable "ecr_public_ecr_repository_prefix" { type = string }