resource "aws_s3_bucket" "fronts-bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_tag_name
    Environment = var.bucket_tag_environment
  }
}

resource "aws_s3_bucket_public_access_block" "example-fronts-bucket" {
  bucket = aws_s3_bucket.fronts-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "fornt_policy_bucket" {
  bucket = aws_s3_bucket.fronts-bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Sid = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.example-fronts-bucket]
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.fronts-bucket.id

  index_document {
    suffix = "index.html"
  }
}
