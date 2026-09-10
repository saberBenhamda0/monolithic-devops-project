
resource "vault_mount" "database" {
  path = "database"
  type = "database"
}

# etablish the connection with the BE in vault
resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.database.path
  name          = "my-postgres"
  allowed_roles = ["readonly"]

  postgresql {
    connection_url = var.postgresql_database_url
    username        = var.postgresql_database_username
    password        = var.postgresql_database_password
  }
}

# etablish the dynamic secret feature in hashicorp vault
resource "vault_database_secret_backend_role" "readonly" {
  backend             = "database"
  name                = "readonly"
  db_name             = vault_database_secret_backend_connection.postgres.name
  creation_statements = ["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"]
  default_ttl         = 3600
  max_ttl             = 86400
}