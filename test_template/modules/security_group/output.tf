#--------------------------------------------------
# Public Inbound Security Group
#--------------------------------------------------
output "sg_public_inbound_id" {
 description = "Public Inbound Security Group ID"
 value       = aws_security_group.sg_public_inbound.id
}

#--------------------------------------------------
# Private Gateway Security Group
#--------------------------------------------------
output "sg_private_gateway_id" {
 description = "Private Gateway Security Group ID"
 value       = aws_security_group.sg_private_gateway.id
}

#--------------------------------------------------
# Private Business Security Group
#--------------------------------------------------
output "sg_private_business_id" {
 description = "Private Business Security Group ID"
 value       = aws_security_group.sg_private_business.id
}

#--------------------------------------------------
# Private RDS Security Group
#--------------------------------------------------
output "sg_private_rds_id" {
 description = "Private RDS Security Group ID"
 value       = aws_security_group.sg_private_rds.id
}

#--------------------------------------------------
# Private VPC Endpoint Security Group
#--------------------------------------------------
output "sg_private_vpce_id" {
 description = "Private VPC Endpoint Security Group ID"
 value       = aws_security_group.sg_private_vpce.id
}