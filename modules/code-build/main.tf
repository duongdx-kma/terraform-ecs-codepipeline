resource "aws_codebuild_project" "terraform_ecs_codebuild" {
  name           = "terraform-ecs-codebuild"
  description    = "this is code build"
  build_timeout  = 5
  queued_timeout = 5

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  #  vpc_config {
  #    security_group_ids = []
  #    subnets            = []
  #    vpc_id             = ""
  #  }
  # build with local caching
#  cache {
#    type  = "LOCAL"
#    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
#  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.terraform_codebuild_logs.name
      status     = "ENABLED"
    }
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = merge({Name = "${var.env}-codebuild"}, var.tags)
}

# cloudwatch group for CodeBuild
resource "aws_cloudwatch_log_group" "terraform_codebuild_logs" {
  name              = "/codebuild/terraform-build-project"
  retention_in_days = var.logs-retention-in-days
  tags              = merge({Name = "${var.env}_terraform_codebuild_logs"}, var.tags)
}