
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
    cidr_ipv4          = "41.143.100.209/32"
    from_port          = 22
    to_port            = 22
    ip_protocol        = "tcp"
  }

  resource "aws_vpc_security_group_egress_rule" "all" {
    security_group_id = aws_security_group.vpn_sg.id
    cidr_ipv4          = "0.0.0.0/0"
    ip_protocol        = "-1"
  }