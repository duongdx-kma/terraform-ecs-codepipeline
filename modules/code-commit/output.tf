output "codecommit_repo_name" {
  value = aws_codecommit_repository.terraform-ecs.repository_name
}

output "codecommit_repo_arn" {
  value = aws_codecommit_repository.terraform-ecs.arn
}
