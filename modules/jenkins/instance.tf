# import list hosted zone already exist
data "aws_route53_zone" "selected" {
  zone_id = var.hosted_zone_id
}

# create cloudfront A record
resource "aws_route53_record" "s3_cloudfront_a_record" {
  zone_id = data.aws_route53_zone.selected.id
  name    = var.batch_domain_name
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2_instance.public_ip]
}


resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.path_to_public_key)
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.batch_instance_ami
  instance_type          = var.batch_instance_type
  key_name               = aws_key_pair.mykey.key_name
  subnet_id              = var.batch_subnet_id
  vpc_security_group_ids = var.batch_sg_ids
  iam_instance_profile   = aws_iam_instance_profile.batch_instance_profile.name
  user_data              = base64encode(file(var.use_data_file))

  tags = merge({ Name = "${var.env}-batch-instance" }, var.tags)

  #  lifecycle {
  #    prevent_destroy = true
  #  }
}

output "batch_instance_private_ip" {
  value = aws_instance.ec2_instance.private_ip
}

output "batch_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}