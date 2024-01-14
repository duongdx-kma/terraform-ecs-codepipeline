provider aws {
  profile    = "duongdinhxuan_duong-admin"
  region     = var.aws_region
}

# provider for aws ACM cloudfront
provider aws {
  profile = "duongdinhxuan_duong-admin"
  region  = "us-east-1"
  alias = "us-east-1"
}
