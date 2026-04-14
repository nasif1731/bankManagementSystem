# Task 3: S3 Bucket, Versioning, Encryption, IAM Role, and State Management
# Creates S3 bucket for Terraform state, DynamoDB for locking, and IAM role for EC2

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ========================
# Data Sources
# ========================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# ========================
# S3 Bucket for Terraform State
# ========================

# Create unique S3 bucket with timestamp
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name_suffix}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "terraform-state-bucket"
    }
  )
}

# Enable versioning on the bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Enable bucket access logging
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "state-logs/"
}

# ========================
# S3 Bucket for Logging
# ========================

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name_suffix}-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "terraform-state-logs"
    }
  )
}

# Block public access for log bucket
resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on log bucket
resource "aws_s3_bucket_versioning" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ========================
# DynamoDB Table for State Locking
# ========================

resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name = "terraform-state-lock"
    }
  )
}

# ========================
# IAM Role for EC2 to Access S3
# ========================

# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_s3_access" {
  name_prefix = "ec2-s3-access-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Create IAM policy for S3 bucket access (read and write only to this bucket)
resource "aws_iam_role_policy" "s3_bucket_access" {
  name_prefix = "s3-bucket-access-"
  role        = aws_iam_role.ec2_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:ListBucketVersions"
        ]
        Resource = [
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Sid    = "S3BucketListAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn
        ]
      },
      {
        Sid    = "DynamoDBLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.terraform_locks.arn
        ]
      }
    ]
  })
}

# Create instance profile for EC2
resource "aws_iam_instance_profile" "ec2_s3_access" {
  name_prefix = "ec2-s3-access-"
  role        = aws_iam_role.ec2_s3_access.name
}
