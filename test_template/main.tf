#--------------------------------------------------
# VPCモジュール
#--------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  common_name = var.common_name
  post_prefix = var.post_prefix
  vpc_cidr    = var.vpc_cidr
  az_1a       = var.az_1a
  az_1c       = var.az_1c
}

#--------------------------------------------------
# Subnetモジュール
#--------------------------------------------------
module "subnet" {
  source = "./modules/subnet"

  common_name         = var.common_name
  post_prefix         = var.post_prefix
  vpc_cidr            = var.vpc_cidr
  az_1a               = var.az_1a
  az_1c               = var.az_1c
  
  vpc_id              = module.vpc.vpc.id
  internet_gateway_id = module.vpc.igw.id
  vgw_id              = module.vpc.vgw.id
}

#--------------------------------------------------
# PrefixListモジュール
#--------------------------------------------------
module "prefix_list" {
  source = "./modules/prefix_list"

  common_name         = var.common_name
  post_prefix         = var.post_prefix
}


#--------------------------------------------------
# Security Groupモジュール
#--------------------------------------------------
module "security_group" {
  source = "./modules/security_group"

  common_name              = var.common_name
  post_prefix              = var.post_prefix
  aws_region               = var.aws_region 
  vpc_cidr                 = var.vpc_cidr
  
  vpc_id                   = module.vpc.vpc.id
  prefixlist_onmremises_id = module.prefix_list.prefixlist_onpremises.id
}

#--------------------------------------------------
# VPC Endpointモジュール
#--------------------------------------------------
module "vpc_endpoint" {
  source = "./modules/vpc_endpoint"

  common_name              = var.common_name
  post_prefix              = var.post_prefix
  aws_region               = var.aws_region 
  vpc_cidr                 = var.vpc_cidr
  
  vpc_id                   = module.vpc.vpc.id
  sb_private_1a_vpce_id    = module.subnet.sb_private_1a_vpce_id
  sb_private_1c_vpce_id    = module.subnet.sb_private_1c_vpce_id
  rtb_private_gateway_id   = module.subnet.rtb_private_gateway_id
  rtb_private_business_id  = module.subnet.rtb_private_business_id
  sg_private_vpce_id       = module.security_group.sg_private_vpce_id
}


#--------------------------------------------------
# ECS Clusterモジュール
#--------------------------------------------------
module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  common_name = var.common_name
  post_prefix = var.post_prefix
  vpc_cidr    = var.vpc_cidr
}

#--------------------------------------------------
# IoT Coreモジュール
#--------------------------------------------------
module "iot_core" {
  source = "./modules/iot_core"

  common_name = var.common_name
  post_prefix = var.post_prefix
  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr
}

#--------------------------------------------------
# ECRモジュール
#--------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  common_name = var.common_name
  post_prefix = var.post_prefix
  vpc_cidr    = var.vpc_cidr
}

#--------------------------------------------------
# ALBモジュール
#--------------------------------------------------
module "alb" {
  source = "./modules/alb"

  common_name = var.common_name
  post_prefix = var.post_prefix
  vpc_cidr    = var.vpc_cidr

  vpc_id                        = module.vpc.vpc.id
  subenet_public_inbound_1a     = module.subnet.sb_public_1a_inbound_id
  subenet_public_inbound_1c     = module.subnet.sb_public_1c_inbound_id
  security_group_public_inbound = module.security_group.sg_public_inbound_id
  acm_arn                       = var.acm_arn
}

#--------------------------------------------------
# タスク定義Gatewayモジュール
#--------------------------------------------------
module "tas_gateway" {
  source = "./modules/ecs_gateway"

  common_name = var.common_name
  post_prefix = var.post_prefix
  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr

  az_1a                            = var.az_1a
  az_1c                            = var.az_1c
  ecs_cluster_id                   = module.ecs_cluster.ecs_cluster.id
  ecs_gateway_subnet_1a_id         = module.subnet.sb_private_1a_gateway_id
  ecs_gateway_subnet_1c_id         = module.subnet.sb_private_1c_gateway_id
  ecs_gateway_security_group_id    = module.security_group.sg_private_gateway_id
  ecr_gateway_arn                  = module.ecr.ecr_gateway.arn
  ecr_gateway_repository_url       = module.ecr.ecr_gateway.repository_url
  ecr_public_registry_id           = module.ecr.ecr_public.registry_id
  ecr_public_ecr_repository_prefix = module.ecr.ecr_public.ecr_repository_prefix
  target_group_public_arn          = module.alb.target_group_public.arn
}

#--------------------------------------------------
# タスク定義Businessモジュール
#--------------------------------------------------
module "tas_business" {
  source = "./modules/ecs_business"

  common_name = var.common_name
  post_prefix = var.post_prefix
  aws_region  = var.aws_region
  vpc_cidr    = var.vpc_cidr

  az_1a                            = var.az_1a
  az_1c                            = var.az_1c
  ecs_cluster_id                   = module.ecs_cluster.ecs_cluster.id
  ecs_business_subnet_1a_id        = module.subnet.sb_private_1a_business_id
  ecs_business_subnet_1c_id        = module.subnet.sb_private_1c_business_id
  ecs_business_security_group_id   = module.security_group.sg_private_business_id
  ecr_business_arn                 = module.ecr.ecr_business.arn
  ecr_business_repository_url      = module.ecr.ecr_business.repository_url
  ecr_public_registry_id           = module.ecr.ecr_public.registry_id
  ecr_public_ecr_repository_prefix = module.ecr.ecr_public.ecr_repository_prefix
}
