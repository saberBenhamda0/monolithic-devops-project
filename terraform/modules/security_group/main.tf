
  resource "aws_security_group" "vpn_sg" {
    name        = "vpn-sg"
    description = "Managed by Terraform"
    vpc_id      = var.vpc_id
  }

  resource "aws_vpc_security_group_ingress_rule" "openvpn" {
    security_group_id = aws_security_group.vpn_sg.id
    cidr_ipv4          = "0.0.0.0/0"
    from_port          = 1194
    to_port            = 1194
    ip_protocol        = "udp"
  }

  resource "aws_vpc_security_group_ingress_rule" "ssh" {
    security_group_id = aws_security_group.vpn_sg.id
    cidr_ipv4          = "196.65.249.191/32"
    from_port          = 22
    to_port            = 22
    ip_protocol        = "tcp"
  }

  resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.vpn_sg.id
    cidr_ipv4          = "0.0.0.0/0"
    ip_protocol        = "-1"
  }

  # Security group allowing inbound Postgres traffic
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.k8_public_subnets_cidr_blocks  # restrict to your VPC/app CIDR, not 0.0.0.0/0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


  # Security group allowing inbound Postgres traffic
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow jenkins inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = var.vpn_cicd  # restrict to your VPC/app CIDR, not 0.0.0.0/0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}