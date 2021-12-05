resource "aws_iam_user_policy" "pp_publisher" {
  name = "packet-pigeon-publisher"
  user = aws_iam_user.pp_publisher.name
  # Terraform "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.pp_publisher_state_bucket.arn
        ]
      },
    ]
  })
}

resource "aws_iam_user" "pp_publisher" {
  name = "packet-pigeon-publisher"
  path = "/packet-pigeon/"
}

resource "aws_iam_access_key" "pp_publisher_key" {
  user = aws_iam_user.pp_publisher.name
}

resource "aws_s3_bucket" "pp_publisher_state_bucket" {
  bucket = "packet-pigeon-publisher-terraform-state"
  acl    = "private"

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  # Prevents Terraform from destroying or replacing this object - a great safety mechanism
  lifecycle {
    prevent_destroy = true
  }
  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }
  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "pp_publisher_state_bucket_access" {
  bucket = aws_s3_bucket.pp_publisher_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
