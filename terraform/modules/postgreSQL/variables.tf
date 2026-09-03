variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  type        = string
}

variable "public_subnet_postgres_east_1a_id" {
    type = string
    description = "the first subnet id for postgres DB"
}

variable "public_subnet_postgres_east_1b_id" {
    type = string
    description = "the second subnet id for postgres DB"
}

variable "postgres_sg" {
  type = string
  description = "the id of the postgres security group"
}