output "postgres_database_url" {
  value = "postgresql://${urlencode(aws_db_instance.postgres.username)}:${urlencode(var.db_password)}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
  sensitive = true
}