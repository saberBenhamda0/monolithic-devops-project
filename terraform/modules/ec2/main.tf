resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.aws_internet_gateway_id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.instances
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.public_rt.id
}

# each created in the apply
resource "aws_network_interface" "ec2_interface" {
  for_each         = var.instances
  subnet_id        = each.value.subnet_id
  private_ips      = [each.value.private_ip]
  security_groups  = each.value.security_group_keys
  tags = merge(
    { Name = "${each.key}-network-interface" },
    each.value.tags
  )
}

resource "aws_eip" "vpn_eip" {
  domain            = "vpc"
  network_interface = aws_network_interface.ec2_interface["vpn"].id
  depends_on        = [aws_instance.instances]
}

resource "aws_instance" "instances" {
  for_each      = var.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.ssh_key_name

  network_interface {
    network_interface_id = aws_network_interface.ec2_interface[each.key].id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  user_data = each.value.user_data_script
}