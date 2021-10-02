resource "aws_s3_bucket" "blog" {
  bucket = "blog.${var.domain_name}"
  acl    = "private"
}

resource "aws_s3_bucket" "logs" {
  bucket = "logs.${var.domain_name}"
  acl    = "private"
}
