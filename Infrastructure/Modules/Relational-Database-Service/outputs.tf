output "rds_address" {
  value = aws_db_instance.Postgres_db.address
}

output "endpoint" {
  value = aws_db_instance.Postgres_db.endpoint
}

output "cluster_id" {
  value = aws_db_instance.Postgres_db.id
}

output "rds_username" {
  value = aws_db_instance.Postgres_db.username
}

output "rds_password" {
  value = aws_db_instance.Postgres_db.password
}

output "rds_database" {
  value = aws_db_instance.Postgres_db.db_name
}

output "rds_port" {
  value = aws_db_instance.Postgres_db.port
}
