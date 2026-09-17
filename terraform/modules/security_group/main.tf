# 1. Fetch your machine's public IP address
data "http" "my_public_ip" {
  url = "https://icanhazip.com"
}

# 2. Clean up any trailing newlines using chomp()
locals {
  admin_public_ip_address = chomp(data.http.my_public_ip.response_body)
}

resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "openvpn" {
  security_group_id = aws_security_group.vpn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1194
  to_port           = 1194
  ip_protocol       = "udp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.vpn_sg.id
  cidr_ipv4         = local.admin_public_ip_address
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.vpn_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security group allowing inbound Postgres traffic
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = var.vpc_id

  # allowed ingress from the worker nodes in the eks cluster so our BE can access it
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.k8_public_subnets_cidr_blocks # restrict to your VPC/app CIDR, not 0.0.0.0/0
  }


    # allowed ingress from the vault cidr so vault can fetch and create dynamic creds.
    ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.vault_cidr
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


  # allow ingress from self hosted vpn we have.
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = var.vpn_cicd
  }

  # tmp allow for dev of the infra
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.admin_public_ip_address]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group allowing inbound Vault traffic
resource "aws_security_group" "vault_sg" {
  name        = "vault-sg"
  description = "Allow Vault inbound traffic"
  vpc_id      = var.vpc_id


  # allow access from self hosted vpn
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = var.vpn_cicd
  }

  # tmp to allow access for dev  
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.admin_public_ip_address]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}