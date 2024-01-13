resource "aws_ecr_repository" "backend-ecr" {
  name         = "backend-${var.env}"
  force_delete = true
}
