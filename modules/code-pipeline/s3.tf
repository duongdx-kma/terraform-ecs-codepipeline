resource "random_string" "random" {
  length = 16
  upper = false
  special = false
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.application_name}-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.s3.json
}

################################################################################
# S3 Policies
################################################################################

data "aws_iam_policy_document" "s3" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
      values   = [aws_codepipeline.codepipeline.arn, var.codebuild_project_arn]
    }
  }
}