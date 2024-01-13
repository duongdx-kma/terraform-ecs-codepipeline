resource "random_password" "master_password"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "random_string" "random_secret_key_name" {
  length = 10
  upper = false
  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.rds_credentials_key}-${random_string.random_secret_key_name.result}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
  {
    "username": "${aws_db_instance.mysql_rds.username}",
    "password": "${random_password.master_password.result}",
    "engine": "mysql",
    "host": "${aws_db_instance.mysql_rds.address}",
    "port": ${aws_db_instance.mysql_rds.port},
    "dbClusterIdentifier": "${aws_db_instance.mysql_rds.identifier}"
  }
  EOF
}