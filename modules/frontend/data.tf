data "aws_iam_policy_document" "s3_policy" {
  for_each = aws_s3_bucket.frontend_bucket
  version = "2012-10-17"

  statement {
    actions   = ["s3:GetObject"]
    resources = [
      "${each.value.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this[each.key].iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [
      each.value.arn
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this[each.key].iam_arn]
    }
  }
}
