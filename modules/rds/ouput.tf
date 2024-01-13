output "secret_manager_name" {
  value = aws_secretsmanager_secret.rds_credentials.name
}

output "mysql-rds-address" {
  value = aws_db_instance.mysql_rds.address
}

output "mysql_engine_name" {
  value = aws_db_instance.mysql_rds.engine
}