resource "random_string" "github_secret" {
  length  = 60
  special = false
}

resource "aws_codestarconnections_connection" "codestar_github" {
  name          = "code-start-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"] # upstream output (source -> build -> deploy)

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar_github.arn
        FullRepositoryId = "${var.github_username}/${var.github_repo}"
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildDocker"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"] # source_output from upstream output
      output_artifacts = ["build_output"] # build output (source -> build -> deploy)
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"] # build_output from upstream output
      version         = "1"

      configuration = {
        ApplicationName                = var.codedeploy_app_name
        DeploymentGroupName            = var.codedeploy_deployment_group_name
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yaml"
      }
    }
  }
}

#// codepipeline webhook
#resource "aws_codepipeline_webhook" "webhook" {
#  name            = "test-webhook-github-bar"
#  authentication  = "GITHUB_HMAC"
#  target_action   = "Source"
#  target_pipeline = aws_codepipeline.codepipeline.name
#
#  authentication_configuration {
#    secret_token = random_string.github_secret.result
#  }
#
#  filter {
#    json_path    = "$.ref"
#    match_equals = "refs/heads/{Branch}"
#  }
#
#  tags = merge({Name = "${var.env}-codepipeline-webhook"}, var.tags)
#}
#
#resource "github_repository_webhook" "github_repo" {
#  repository = var.github_repo
#
#  configuration {
#    url          = aws_codepipeline_webhook.webhook.url
#    content_type = "json"
#    insecure_ssl = true
#    secret       = random_string.github_secret.result
#  }
#
#  events = ["push"]
#}
