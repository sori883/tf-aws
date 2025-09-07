# S3 PrefixLiast取得
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

#--------------------------------------------------
# Public Inbound Security Group
#--------------------------------------------------
resource "aws_security_group" "sg_public_inbound" {
  name        = format("%s-%s-%s", var.common_name, "sg-public-inbound", var.post_prefix)
  description = "Public Subnet Inboud Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "sg-public-inbound", var.post_prefix)
  }
}

#--------------------------------------------------
# Public Inbound Ingress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "egress_rules_public_tls" {
  security_group_id = aws_security_group.sg_public_inbound.id

  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#--------------------------------------------------
# Public Inbound Egress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "egress_rules_public_http" {
  security_group_id = aws_security_group.sg_public_inbound.id

  referenced_security_group_id = aws_security_group.sg_private_gateway.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

#--------------------------------------------------
# Gateway Security Group
#--------------------------------------------------
resource "aws_security_group" "sg_private_gateway" {
  name        = format("%s-%s-%s", var.common_name, "sg-private-gateway", var.post_prefix)
  description = "Private Gateway Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "sg-private-gateway", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Gateway Ingress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_gateway_http" {
  security_group_id = aws_security_group.sg_private_gateway.id

  referenced_security_group_id = aws_security_group.sg_public_inbound.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#--------------------------------------------------
# Private Gateway Egress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "egress_rules_gateway_rds" {
  security_group_id = aws_security_group.sg_private_gateway.id

  referenced_security_group_id = aws_security_group.sg_private_rds.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_gateway_s3" {
  security_group_id = aws_security_group.sg_private_gateway.id

  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_gateway_vpce" {
  security_group_id = aws_security_group.sg_private_gateway.id

  referenced_security_group_id = aws_security_group.sg_private_vpce.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

#--------------------------------------------------
# Business Security Group
#--------------------------------------------------
resource "aws_security_group" "sg_private_business" {
  name        = format("%s-%s-%s", var.common_name, "sg-private-business", var.post_prefix)
  description = "Private Business Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "sg-private-business", var.post_prefix)
  }
}

#--------------------------------------------------
# Private Business Egress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "egress_rules_business_rds" {
  security_group_id = aws_security_group.sg_private_business.id

  referenced_security_group_id = aws_security_group.sg_private_rds.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_business_s3" {
  security_group_id = aws_security_group.sg_private_business.id

  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_business_vpce" {
  security_group_id = aws_security_group.sg_private_business.id

  referenced_security_group_id = aws_security_group.sg_private_vpce.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_rules_business_onpremises" {
  security_group_id = aws_security_group.sg_private_business.id

  prefix_list_id    = var.prefixlist_onmremises_id
  ip_protocol       = "-1"
}


#--------------------------------------------------
# Private RDS Security Group
#--------------------------------------------------
resource "aws_security_group" "sg_private_rds" {
  name        = format("%s-%s-%s", var.common_name, "sg-private-rds", var.post_prefix)
  description = "Private RDS Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "sg-private-rds", var.post_prefix)
  }
}

#--------------------------------------------------
# Private RDS Igress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_rds_gateway" {
  security_group_id = aws_security_group.sg_private_rds.id

  referenced_security_group_id = aws_security_group.sg_private_gateway.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules_rds_business" {
  security_group_id = aws_security_group.sg_private_rds.id

  referenced_security_group_id = aws_security_group.sg_private_business.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

#--------------------------------------------------
# Private VPC Endpoint Security Group
#--------------------------------------------------
resource "aws_security_group" "sg_private_vpce" {
  name        = format("%s-%s-%s", var.common_name, "sg-private-vpce", var.post_prefix)
  description = "Private VPC Endpoint Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name = format("%s-%s-%s", var.common_name, "sg-private-vpce", var.post_prefix)
  }
}

#--------------------------------------------------
# Private VPC Endpoint Ingress Rules
#--------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "ingress_rules_vpce_gateway" {
  security_group_id = aws_security_group.sg_private_vpce.id

  referenced_security_group_id = aws_security_group.sg_private_gateway.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules_vpce_business" {
  security_group_id = aws_security_group.sg_private_vpce.id

  referenced_security_group_id = aws_security_group.sg_private_business.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
