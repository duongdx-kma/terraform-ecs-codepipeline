resource "aws_db_subnet_group" "rds_subnet" {
  name = "rds-subnet"
  description = "RDS subnet group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "mysql_rds" {
  identifier             = "mysql-rds" # the name of RDS instance
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  multi_az               = false
  parameter_group_name   = "default.mysql5.7"
  allocated_storage      = 10
  max_allocated_storage  = 20
  db_name                = var.db_name
  username               = var.username
  password               = random_password.master_password.result
  storage_type           = "gp2"
  vpc_security_group_ids = var.rds_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
}
