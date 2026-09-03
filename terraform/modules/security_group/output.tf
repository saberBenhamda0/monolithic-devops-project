output "security_group_id" {
    value = aws_security_group.vpn_sg.id
}

output "postrgesql_security_group_id" {
    value = aws_security_group.postgres_sg.id
}

output "jenkins_security_group_id" {
  value = aws_security_group.jenkins_sg.id
}