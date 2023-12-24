output "alb-sg-id" {
  value = aws_security_group.alb-sg.id
}

output "instance-sg-id" {
  value = aws_security_group.instance-sg.id
}

output "rds-sg-id" {
  value = aws_security_group.rds-sg.id
}

output "endpoint-sg-id" {
  value = aws_security_group.endpoint-sg.id
}