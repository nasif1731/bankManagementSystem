# Task 3: S3 Bucket, Versioning, Encryption, IAM Role, and State Management
# Variable values

aws_region = "us-east-1"

# S3 bucket suffix - use your roll number or unique identifier
# This will be combined with AWS account ID to create a unique bucket name
bucket_name_suffix = "task3-bucket-nasif"

# Enable versioning on the S3 bucket
enable_versioning = true

# Enable server-side encryption for the bucket
enable_encryption = true

# Block all public access to the bucket
block_public_access = true

# DynamoDB table for state locking
dynamodb_table_name = "terraform-state-lock"

# Tags for all resources
tags = {
  Environment = "development"
  Task        = "Task3-S3-StateManagement"
  CreatedBy   = "Terraform"
}
