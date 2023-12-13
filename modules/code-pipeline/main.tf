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
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"] # upstream output (source -> build -> deploy)

      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName     = var.branch_name
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

