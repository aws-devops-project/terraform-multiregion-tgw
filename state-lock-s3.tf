provider "aws" {
  region = "eu-west-2"
}
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for encrypting Terraform state in S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "terraform-statelock-backend-bucket"
  force_destroy = true
  # ifecycle.prevent_destroy is set to true to prevent accidental deletion of the S3 bucket, which could lead to loss of Terraform state data. This is a safety measure to ensure that the critical infrastructure state information is not lost due to human error or unintended actions.
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.terraform_state]

}
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
  }
}

#Create DynamoDB Lock Table
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
data "aws_caller_identity" "current" {}


resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
