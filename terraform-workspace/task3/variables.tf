# Task 3: S3 Bucket, Versioning, Encryption, IAM Role, and State Management
# Variables for S3 bucket, DynamoDB, and IAM configuration

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_suffix" {
  description = "Suffix for S3 bucket name (use your roll number or unique identifier)"
  type        = string
  default     = "task3-bucket-nasif"
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.bucket_name_suffix))
    error_message = "Bucket suffix must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption (AES-256)"
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block all public access to S3 bucket"
  type        = bool
  default     = true
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-state-lock"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Task        = "Task3-S3-StateManagement"
    CreatedBy   = "Terraform"
  }
}
