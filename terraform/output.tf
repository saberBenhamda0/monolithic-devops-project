output "postgres_database_url" {
  value = module.postgreSQL.postgres_database_url
  sensitive = true
}

output "ec2_instances_ip_address" {
  value = module.ec2.ec2_address
}