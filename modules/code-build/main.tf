resource "random_string" "jwt_key" {
  length  = 20
  upper = false
  special = false
}

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

    # variable for task building
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

    # variable for task running
    environment_variable {
      name  = "DB_DRIVER"
      value = var.db_driver
    }

    # RDS endpoint
    environment_variable {
      name  = "DB_HOST"
      value = var.rds_endpoint
    }

    # RDS user
    environment_variable {
      name  = "DB_USER"
      value = var.username
    }

    # default null. password will get from Secret Manager
    environment_variable {
      name  = "DB_PASSWORD"
      value = ""
    }

    # RDS database name
    environment_variable {
      name  = "DB_DATABASE"
      value = var.db_name
    }

    # RDS port
    environment_variable {
      name  = "DB_PORT"
      value = var.db_port
    }

    # client origin for CORS
    environment_variable {
      name  = "CLIENT_ORIGIN"
      value = "*"
    }

    # jwt key
    environment_variable {
      name  = "JWT_SECRET"
      value = random_string.jwt_key.result
    }

    # application expose port
    environment_variable {
      name  = "APP_PORT"
      value = var.app_port
    }

    # application environment
    environment_variable {
      name  = "APP_ENV"
      value = var.app_env
    }

    # aws region
    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    #secret manager name
    environment_variable {
      name  = "SECRET_MANAGER_KEY"
      value = var.secret_manager_name
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