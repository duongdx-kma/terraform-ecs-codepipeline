# code deploy policy document
data "aws_iam_policy_document" "iam_codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      values   = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }

  # policy for codestart
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.codestar_github.arn]
  }

#  statement {
#    sid = "codecommitaccess"
#    actions = [
#      "codecommit:GetBranch",
#      "codecommit:GetCommit",
#      "codecommit:UploadArchive",
#      "codecommit:GetUploadArchiveStatus",
#      "codecommit:CancelUploadArchive"
#    ]
#
#    resources = [var.codecommit_repo_arn]
#  }

  statement {
    sid = "codedeployaccess"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]

    resources = ["*"]
  }

  statement {
    sid = "codestaraccess"
    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]

    resources = ["*"]
  }
}

# trusted policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
