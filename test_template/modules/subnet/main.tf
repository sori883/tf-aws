#--------------------------------------------------
# Public Subnet 1a Inbound
#--------------------------------------------------
resource "aws_subnet" "sb_public_1a_inbound" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = var.az_1a

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-public-inboud-1a", var.post_prefix)
  }
}

#--------------------------------------------------
# Public Subnet 1c Inbound
#--------------------------------------------------
resource "aws_subnet" "sb_public_1c_inbound" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = var.az_1c

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-public-inboud-1c", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1a Gateway
#--------------------------------------------------
resource "aws_subnet" "sb_private_1a_gateway" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone = var.az_1a

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-gateway-1a", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1c Gateway
#--------------------------------------------------
resource "aws_subnet" "sb_private_1c_gateway" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone = var.az_1c

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-gateway-1c", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1a Business
#--------------------------------------------------
resource "aws_subnet" "sb_private_1a_business" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 5)
  availability_zone = var.az_1a

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-business-1a", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1c Business
#--------------------------------------------------
resource "aws_subnet" "sb_private_1c_business" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 6)
  availability_zone = var.az_1c

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-business-1c", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1a VPC RDS
#--------------------------------------------------
resource "aws_subnet" "sb_private_1a_rds" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 7)
  availability_zone = var.az_1a

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-rds-1a", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1c VPC RDS
#--------------------------------------------------
resource "aws_subnet" "sb_private_1c_rds" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 8)
  availability_zone = var.az_1c

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-rds-1c", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1a VPC Endpoint
#--------------------------------------------------
resource "aws_subnet" "sb_private_1a_vpce" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 9)
  availability_zone = var.az_1a

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-vpce-1a", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Subnet 1c VPC Endpoint
#--------------------------------------------------
resource "aws_subnet" "sb_private_1c_vpce" {
  vpc_id     = var.vpc_id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = var.az_1c

  tags = {
    Name = format("%s-%s-%s", var.common_name, "subnet-private-vpce-1c", var.post_prefix)
  }
}

#--------------------------------------------------
# Public Inbound Route Table
#--------------------------------------------------
resource "aws_route_table" "rtb_public_inbound" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = {
    Name = format("%s-%s-%s", var.common_name, "rtb-public-inbound", var.post_prefix)
  }
}

#--------------------------------------------------
# Association Public Inbound Route Table
#--------------------------------------------------
resource "aws_route_table_association" "association_rtb_public_to_public_1a_inbound" {
  subnet_id      = aws_subnet.sb_public_1a_inbound.id
  route_table_id = aws_route_table.rtb_public_inbound.id
}

resource "aws_route_table_association" "association_rtb_public_to_public_1c_inbound" {
  subnet_id      = aws_subnet.sb_public_1c_inbound.id
  route_table_id = aws_route_table.rtb_public_inbound.id
}

#--------------------------------------------------
# Private Gateway Route Table
#--------------------------------------------------
resource "aws_route_table" "rtb_private_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "rtb-private-gateway", var.post_prefix)
  }
}

#--------------------------------------------------
# Association Private Gateway Route Table
#--------------------------------------------------
resource "aws_route_table_association" "association_rtb_private_to_private_1a_gateway" {
  subnet_id      = aws_subnet.sb_private_1a_gateway.id
  route_table_id = aws_route_table.rtb_private_gateway.id
}

resource "aws_route_table_association" "association_rtb_private_to_private_1c_gateway" {
  subnet_id      = aws_subnet.sb_private_1c_gateway.id
  route_table_id = aws_route_table.rtb_private_gateway.id
}

#--------------------------------------------------
# Private Business Route Table
#--------------------------------------------------
resource "aws_route_table" "rtb_private_business" {
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "rtb-private-business", var.post_prefix)
  }
}

#--------------------------------------------------
# BusinessサブネットにVGWのルート伝播有効化
#--------------------------------------------------
resource "aws_vpn_gateway_route_propagation" "route_propagation_to_rtb_dx" {
  vpn_gateway_id = var.vgw_id
  route_table_id = aws_route_table.rtb_private_business.id
}

#--------------------------------------------------
# Association Private Business Route Table
#--------------------------------------------------
resource "aws_route_table_association" "association_rtb_private_to_private_1a_business" {
  subnet_id      = aws_subnet.sb_private_1a_business.id
  route_table_id = aws_route_table.rtb_private_business.id
}

resource "aws_route_table_association" "association_rtb_private_to_private_1c_business" {
  subnet_id      = aws_subnet.sb_private_1c_business.id
  route_table_id = aws_route_table.rtb_private_business.id
}

#--------------------------------------------------
# Private RDS Route Table
#--------------------------------------------------
resource "aws_route_table" "rtb_private_rds" {
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "rtb-private-rds", var.post_prefix)
  }
}

#--------------------------------------------------
# Association Private RDS Route Table
#--------------------------------------------------
resource "aws_route_table_association" "association_rtb_private_to_private_1a_rds" {
  subnet_id      = aws_subnet.sb_private_1a_rds.id
  route_table_id = aws_route_table.rtb_private_rds.id
}

resource "aws_route_table_association" "association_rtb_private_to_private_1c_rds" {
  subnet_id      = aws_subnet.sb_private_1c_rds.id
  route_table_id = aws_route_table.rtb_private_rds.id
}


#--------------------------------------------------
# Private VPC Endpoint Route Table
#--------------------------------------------------
resource "aws_route_table" "rtb_private_vpce" {
  vpc_id = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "rtb-private-vpce", var.post_prefix)
  }
}

#--------------------------------------------------
# Association Private VPC Endpoint Route Table
#--------------------------------------------------
resource "aws_route_table_association" "association_rtb_private_to_private_1a_vpce" {
  subnet_id      = aws_subnet.sb_private_1a_vpce.id
  route_table_id = aws_route_table.rtb_private_vpce.id
}

resource "aws_route_table_association" "association_rtb_private_to_private_1c_vpce" {
  subnet_id      = aws_subnet.sb_private_1c_vpce.id
  route_table_id = aws_route_table.rtb_private_vpce.id
}

