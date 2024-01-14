data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "batch_s3" {
  role = aws_iam_role.mapstock_batch_deploy.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}