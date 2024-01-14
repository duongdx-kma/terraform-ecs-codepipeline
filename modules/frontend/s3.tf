resource "random_string" "frontend_bucket_key" {
  length  = 10
  upper   = false
  special = false
}

# definition s3 bucket
resource "aws_s3_bucket" "frontend_bucket" {
  for_each      = var.params
  bucket        = "${each.value.bucket_name}-${random_string.frontend_bucket_key.result}"
#  force_destroy = true
}

resource "aws_s3_bucket_versioning" "frontend_bucket" {
  for_each = aws_s3_bucket.frontend_bucket
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

# s3 bucket access control list
resource "aws_s3_bucket_acl" "frontend_bucket_acl" {
  for_each   = aws_s3_bucket.frontend_bucket
  bucket     = each.value.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.frontend_bucket_acl_ownership]
}

# bucket access block
resource "aws_s3_bucket_public_access_block" "my_static_website" {
  for_each                = aws_s3_bucket.frontend_bucket
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# bucket ownership
resource "aws_s3_bucket_ownership_controls" "frontend_bucket_acl_ownership" {
  for_each = aws_s3_bucket.frontend_bucket
  bucket   = each.value.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# s3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "frontend_bucket_configure" {
  for_each = aws_s3_bucket.frontend_bucket
  bucket   = each.value.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# s3 bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = aws_s3_bucket.frontend_bucket
  bucket   = each.value.id
  policy   = data.aws_iam_policy_document.s3_policy[each.key].json
}
