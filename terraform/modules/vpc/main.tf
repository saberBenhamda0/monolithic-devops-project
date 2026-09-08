resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main infra vpc (k8 + jenkins + vpn)"
  }
}

resource "aws_internet_gateway" "gt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "vpc_internet_gateway"
  }
}

# creating public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

# creating private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.zone
  tags = {
    Name = each.key
  }
}

# public routing table with association to subnets
resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    gateway_id = aws_internet_gateway.gt.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_routing_table_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_routing_table.id
}

# eip for NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT gateway — placed in one specific public subnet
resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_k8_a"].id
  tags = {
    Name = "nat_gateway"
  }
}

# private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng.id
  }
  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_routing_table_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}