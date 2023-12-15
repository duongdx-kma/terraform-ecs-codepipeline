# define codebuild iam role
resource "aws_iam_role" "codedeploy_role" {
  name               = "codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

# policy and attachment
resource "aws_iam_role_policy" "codedeploy_policy" {
  name   = "codedeploy_policy"
  role   = aws_iam_role.codedeploy_role.id
  policy = data.aws_iam_policy_document.codedeploy_policy_docs.json
}
