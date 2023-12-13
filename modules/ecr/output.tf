output "ecr-output" {
  value = aws_ecr_repository.express-ecr.repository_url
}

output "ecr_name" {
  value = aws_ecr_repository.express-ecr.name
}