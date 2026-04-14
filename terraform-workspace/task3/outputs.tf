# Task 3: S3 Bucket, Versioning, Encryption, IAM Role, and State Management
# Output values for S3, DynamoDB, and IAM resources

output "s3_bucket" {
  description = "S3 bucket details for Terraform state"
  value = {
    id     = aws_s3_bucket.terraform_state.id
    arn    = aws_s3_bucket.terraform_state.arn
    region = var.aws_region
  }
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_versioning_status" {
  description = "Versioning status of S3 bucket"
  value       = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status
}

output "s3_encryption_algorithm" {
  description = "Server-side encryption algorithm"
  value       = "AES256"
}

output "s3_public_access_block" {
  description = "Public access block configuration"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.terraform_state.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.terraform_state.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets
  }
}

output "dynamodb_table" {
  description = "DynamoDB table details for state locking"
  value = {
    name = aws_dynamodb_table.terraform_locks.name
    arn  = aws_dynamodb_table.terraform_locks.arn
  }
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "iam_role" {
  description = "IAM role for EC2 S3 access"
  value = {
    name = aws_iam_role.ec2_s3_access.name
    arn  = aws_iam_role.ec2_s3_access.arn
  }
}

output "iam_instance_profile" {
  description = "IAM instance profile for EC2"
  value       = aws_iam_instance_profile.ec2_s3_access.name
}

output "backend_config" {
  description = "Backend configuration for other Terraform projects"
  value       = <<-EOT
    Use the following backend configuration in your terraform backend:
    
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
      }
    }
  EOT
}

output "log_bucket_id" {
  description = "S3 bucket ID for access logs"
  value       = aws_s3_bucket.log_bucket.id
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
