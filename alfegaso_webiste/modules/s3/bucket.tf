resource "aws_s3_bucket" "this" {
  bucket = "alfegaso-website-${var.environment}"
  tags = {
    Name        = "Alfegaso Website Bucket"
    Environment = var.environment
  }
}
