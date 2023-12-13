resource "aws_codecommit_repository" "terraform-ecs" {
  repository_name = "terraform-ecs-codepipeline"
  description     = "This is the Terraform ECS code pipeline"
}
