resource "random_password" "master_password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = var.rds_credentials_key
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
  {
    "username": "${aws_db_instance.mysql_rds.username}",
    "password": "${random_password.master_password.result}",
    "engine": "mysql",
    "host": "${aws_db_instance.mysql_rds.endpoint}",
    "port": ${aws_db_instance.mysql_rds.port},
    "dbClusterIdentifier": "${aws_db_instance.mysql_rds.identifier}"
  }
  EOF
}