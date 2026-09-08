  resource "aws_ebs_volume" "vault_data" {
    availability_zone = "us-east-1a"   # must match your EC2 instance's AZ
    size              = 10              # GiB
    type              = "gp3" #General purpose SSD
    encrypted         = true

    tags = {
      Name = "vault-data"
    }
  }

  resource "aws_volume_attachment" "vault_data_attach" {
    device_name = "/dev/xvdf"
    volume_id   = aws_ebs_volume.vault_data.id
    instance_id = var.ec2_vault_id   # reference to your existing EC2 instance resource
  }