variable "common_name" { type = string }
variable "post_prefix" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }

variable "subenet_public_inbound_1a" { type = string }
variable "subenet_public_inbound_1c" { type = string }
variable "security_group_public_inbound" { type = string }
variable "acm_arn" { type = string }