output "ssh_developer_key_id" {
  value = aws_key_pair.deployer.key_name
}