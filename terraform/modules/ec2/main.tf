  resource "aws_route_table" "public_rt" {
    vpc_id = var.vpc_id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.aws_internet_gateway_id
    }
  }

  resource "aws_route_table_association" "public" {
    subnet_id      = var.subnet_id
    route_table_id = aws_route_table.public_rt.id
  }


  resource "aws_network_interface" "example" {
    subnet_id       = var.subnet_id
    private_ips     = [var.instances["vpn"].private_ip]
    security_groups = [var.instances["vpn"].security_group_keys[0]]
    tags = { Name = "primary_network_interface" }
  }

  resource "aws_eip" "vpn_eip" {
    domain            = "vpc"
    network_interface = aws_network_interface.example.id
    depends_on        = [var.aws_internet_gateway_id, aws_instance.vpn_instance]
  }

  resource "aws_instance" "vpn_instance" {
    ami           = var.instances["vpn"].ami
    instance_type = "t2.micro"
    key_name = var.instances["vpn"].ssh_key_name
    
    network_interface {
      network_interface_id = aws_network_interface.example.id
      device_index = 0
    }
    credit_specification {
      cpu_credits = "unlimited"
    }
  }