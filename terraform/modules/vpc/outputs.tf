output "private_subnets" {
  description = "all private subnets in our vpc"
  value       = { for k, v in aws_subnet.private_subnets : k => { id = v.id } }
}

output "public_subnets" {
  description = "all public subnets in our vpc"
  value       = { for k, v in aws_subnet.public_subnets : k => { id = v.id } }
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