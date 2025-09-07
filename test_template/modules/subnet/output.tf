#--------------------------------------------------
# Public Subnet 1a Inbound
#--------------------------------------------------
output "sb_public_1a_inbound_id" {
  description = "ID of the public subnet 1a inbound"
  value       = aws_subnet.sb_public_1a_inbound.id
}

#--------------------------------------------------
# Public Subnet 1c Inbound
#--------------------------------------------------
output "sb_public_1c_inbound_id" {
  description = "ID of the public subnet 1c inbound"
  value       = aws_subnet.sb_public_1c_inbound.id
}

#--------------------------------------------------
# Private Subnet 1a Gateway
#--------------------------------------------------
output "sb_private_1a_gateway_id" {
  description = "ID of the private subnet 1a gateway"
  value       = aws_subnet.sb_private_1a_gateway.id
}

#--------------------------------------------------
# Private Subnet 1c Gateway
#--------------------------------------------------
output "sb_private_1c_gateway_id" {
  description = "ID of the private subnet 1c gateway"
  value       = aws_subnet.sb_private_1c_gateway.id
}

#--------------------------------------------------
# Private Subnet 1a Business
#--------------------------------------------------
output "sb_private_1a_business_id" {
  description = "ID of the private subnet 1a business"
  value       = aws_subnet.sb_private_1a_business.id
}

#--------------------------------------------------
# Private Subnet 1c Business
#--------------------------------------------------
output "sb_private_1c_business_id" {
  description = "ID of the private subnet 1c business"
  value       = aws_subnet.sb_private_1c_business.id
}

#--------------------------------------------------
# Private Subnet 1a VPC Endpoint
#--------------------------------------------------
output "sb_private_1a_vpce_id" {
  description = "ID of the private subnet 1a VPC endpoint"
  value       = aws_subnet.sb_private_1a_vpce.id
}

#--------------------------------------------------
# Private Subnet 1c VPC Endpoint
#--------------------------------------------------
output "sb_private_1c_vpce_id" {
  description = "ID of the private subnet 1c VPC endpoint"
  value       = aws_subnet.sb_private_1c_vpce.id
}

#--------------------------------------------------
# Public Inbound Route Table
#--------------------------------------------------
output "rtb_public_inbound_id" {
  description = "ID of the public inbound route table"
  value       = aws_route_table.rtb_public_inbound.id
}

#--------------------------------------------------
# Private Gateway Route Table
#--------------------------------------------------
output "rtb_private_gateway_id" {
  description = "ID of the private gateway route table"
  value       = aws_route_table.rtb_private_gateway.id
}

#--------------------------------------------------
# Private Business Route Table
#--------------------------------------------------
output "rtb_private_business_id" {
  description = "ID of the private business route table"
  value       = aws_route_table.rtb_private_business.id
}

#--------------------------------------------------
# Private RDS Route Table
#--------------------------------------------------
output "rtb_private_rds_id" {
  description = "ID of the private RDS route table"
  value       = aws_route_table.rtb_private_rds.id
}

#--------------------------------------------------
# Private VPC Endpoint Route Table
#--------------------------------------------------
output "rtb_private_vpce_id" {
  description = "ID of the private VPC endpoint route table"
  value       = aws_route_table.rtb_private_vpce.id
}