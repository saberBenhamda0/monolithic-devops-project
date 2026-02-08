resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "eks_vpc"
    }
}

resource "aws_internet_gateway" "gt" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "vpc_internet_gateway"
    }
}


# creating 2 public subnets 

resource "aws_subnet" "public_subnets" {

    count = length(var.public_subnets)

    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnets[count.index]
    availability_zone = var.zones[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_${count.index}"
    }
}

# creating 2 private subnets 
resource "aws_subnet" "private_subnets" {

    count = length(var.private_subnets)

    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnets[count.index]
    availability_zone = var.zones[count.index]
    
    tags = {
        Name = "private_subnet_${count.index}"
    }
}


# public routing tables with there association with subnets
resource "aws_route_table" "public_routing_table" {
    vpc_id = aws_vpc.vpc.id

    route { 
        gateway_id = aws_internet_gateway.gt.id
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_route_table_association" "public_routing_table_association" {

    count = length(var.public_subnets)

    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_routing_table.id
}


# eip for NAT gateway 
resource "aws_eip" "nat_eip" {
}

# NAT gateway 
resource "aws_nat_gateway" "ng" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnets[0].id
}

# private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ng.id
    }
}

resource "aws_route_table_association" "private_routing_table_association" {

    count = length(var.private_subnets)

    subnet_id = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private_route_table.id
}