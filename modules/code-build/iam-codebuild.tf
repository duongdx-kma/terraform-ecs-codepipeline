# define codebuild iam role
resource "aws_iam_role" "codebuild_role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

# policy and attachment
resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.iam_codepipeline_policy.json
}
