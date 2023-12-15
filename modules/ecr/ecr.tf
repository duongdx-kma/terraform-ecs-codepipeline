resource "aws_ecr_repository" "express-ecr" {
  name         = "express-${var.env}"
  force_delete = true
}
