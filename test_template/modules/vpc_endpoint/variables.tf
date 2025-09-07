variable "common_name" { type = string }
variable "post_prefix" { type = string }
variable "aws_region" { type = string }
variable "vpc_cidr" { type = string }

variable "vpc_id" { type = string }
variable "sb_private_1a_vpce_id" { type = string }
variable "sb_private_1c_vpce_id" { type = string }
variable "rtb_private_gateway_id" { type = string }
variable "rtb_private_business_id" { type = string }
variable "sg_private_vpce_id" { type = string}
