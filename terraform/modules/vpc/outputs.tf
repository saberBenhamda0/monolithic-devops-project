output "private_subnets" {
  description = "all private subnets in our vpc"
  value = aws_subnet.private_subnets[*].id
}

output "public_subnets" {
  description = "all public subnets in our vpc"
  value = aws_subnet.public_subnets[*].id
}

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "aws_internet_gateway_id" {
  value = aws_internet_gateway.gt.id
}

output "aws_internet_gateway_arn" {
  value = aws_internet_gateway.gt.arn
}