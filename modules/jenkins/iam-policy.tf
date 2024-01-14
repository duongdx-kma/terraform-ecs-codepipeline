# trusted policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// iam role
resource "aws_iam_role" "mapstock_batch_deploy" {
  name               = "mapstock-batch-deploy"
  description        = "mapstock-batch-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// instance profile -> will be attach to batch instance
resource "aws_iam_instance_profile" "batch_instance_profile" {
  name = "mapstock-batch-deploy"
  role = aws_iam_role.mapstock_batch_deploy.name
}

