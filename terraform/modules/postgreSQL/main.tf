# The RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier              = "my-postgres-db"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  vpc_security_group_ids  = [var.postgres_sg]
  publicly_accessible     = false
  skip_final_snapshot     = true # set false for production
  backup_retention_period = 7
  multi_az                = false # set true for production HA

  tags = {
    Name = "postgres-db-${var.db_name}"
  }
}



# RDS requires a subnet group spanning at least 2 AZs
resource "aws_db_subnet_group" "postgres" {
  name       = "postgres-subnet-group"
  subnet_ids = [var.public_subnet_postgres_east_1a_id, var.public_subnet_postgres_east_1b_id]

  tags = {
    Name = "postgres-subnet-group"
  }
}


# Security group allowing inbound Postgres traffic
# resource "aws_security_group" "postgres_sg" {
#   name        = "postgres-sg"
#   description = "Allow PostgreSQL inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]  # restrict to your VPC/app CIDR, not 0.0.0.0/0
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }