variable profile { type = string }
variable "common_name" { type = string }
variable "post_prefix" { type = string }

# resources parameter
variable "aws_region" { type = string }
variable "vpc_cidr" { type = string }
variable "az_1a" { type = string }
variable "az_1c" { type = string }
variable "acm_arn" { type = string }