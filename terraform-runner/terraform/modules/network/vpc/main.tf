#==========================================================================#
# VPC                                                                      #
#==========================================================================#
resource "aws_vpc" "main" {
  cidr_block                       = var.cidr_block
  enable_dns_support               = var.enable_dns_support
  enable_dns_hostnames             = var.enable_dns_hostnames
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = {
    Name : "${var.service_prefix}-vpc"
  }
}

#==========================================================================#
# Remove the default security group rules                                  #
#==========================================================================#
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_prefix}-vpc-default-sg"
  }
}

#==========================================================================#
# Internet Gateway                                                         #
#==========================================================================#
resource "aws_internet_gateway" "main" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_prefix}-internet-gateway"
  }
}

#==========================================================================#
# Egress Only Internet Gateway (IPv6)                                     #
#==========================================================================#
resource "aws_egress_only_internet_gateway" "main" {
  count = var.enable_ipv6 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_prefix}-egress-only-igw"
  }
}
