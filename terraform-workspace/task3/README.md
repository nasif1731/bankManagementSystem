# Task 3: S3 Bucket, Versioning, Encryption, IAM Role, and State Management

This Terraform configuration sets up AWS S3 bucket infrastructure for centralized state management with security, versioning, encryption, state locking, and IAM access controls.

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│        AWS Account (${var.aws_region})       │
├─────────────────────────────────────────────┤
│                                              │
│  S3 Bucket: terraform-state                  │
│  ├─ Versioning: Enabled                      │
│  ├─ Encryption: AES-256                      │
│  └─ Public Access: Blocked                   │
│                                              │
│  S3 Bucket: terraform-state-logs             │
│  └─ Access Logs from State Bucket            │
│                                              │
│  DynamoDB: terraform-state-lock              │
│  └─ State Locking (Prevents Concurrent Mods) │
│                                              │
│  IAM Role: ec2-s3-access                     │
│  ├─ S3 Read/Write to state bucket only       │
│  ├─ DynamoDB Lock Access                     │
│  └─ Instance Profile for EC2                 │
│                                              │
└─────────────────────────────────────────────┘
```

## Requirements

1. **S3 Bucket**
   - Unique name using account ID as suffix
   - Versioning enabled for state recovery
   - Server-side encryption with AES-256
   - All public access blocked
   - Access logging enabled

2. **DynamoDB Table**
   - Used for state file locking
   - Prevents concurrent Terraform runs
   - Point-in-time recovery enabled
   - Server-side encryption enabled

3. **IAM Role**
   - EC2 instances can assume this role
   - Read/write access to state bucket only
   - DynamoDB lock table access
   - No permissions beyond S3 and DynamoDB

4. **Logging Bucket**
   - Separate bucket for access logs
   - Versioning enabled
   - Public access blocked

## Resources Created

| Resource | Type | Purpose |
|----------|------|---------|
| `aws_s3_bucket.terraform_state` | S3 Bucket | Main state storage |
| `aws_s3_bucket_versioning.terraform_state` | S3 Versioning | Version history of state |
| `aws_s3_bucket_server_side_encryption_configuration.terraform_state` | S3 Encryption | AES-256 encryption |
| `aws_s3_bucket_public_access_block.terraform_state` | S3 PAB | Block public access |
| `aws_s3_bucket_logging.terraform_state` | S3 Logging | Access logs to log bucket |
| `aws_s3_bucket.log_bucket` | S3 Bucket | Logging destination |
| `aws_dynamodb_table.terraform_locks` | DynamoDB | State locking |
| `aws_iam_role.ec2_s3_access` | IAM Role | EC2 assume role |
| `aws_iam_role_policy.s3_bucket_access` | IAM Policy | S3 & DynamoDB permissions |
| `aws_iam_instance_profile.ec2_s3_access` | Instance Profile | EC2 role binding |

## Variables

- `aws_region` - AWS region (default: us-east-1)
- `bucket_name_suffix` - Suffix for bucket names (default: task3-bucket-nasif)
- `enable_versioning` - Enable S3 versioning (default: true)
- `enable_encryption` - Enable AES-256 encryption (default: true)
- `block_public_access` - Block public access (default: true)
- `dynamodb_table_name` - DynamoDB table name (default: terraform-state-lock)

## Outputs

- `s3_bucket_id` - S3 bucket identifier
- `s3_bucket_arn` - S3 bucket ARN
- `s3_versioning_status` - Versioning status
- `s3_encryption_algorithm` - Encryption algorithm (AES256)
- `s3_public_access_block` - Public access block settings
- `dynamodb_table_name` - DynamoDB table name
- `iam_role` - IAM role details
- `backend_config` - Backend configuration for other projects
- `account_id` - AWS Account ID

## How to Run

### 1. Initialize Terraform
```bash
cd task3
terraform init
```

### 2. Validate Configuration
```bash
terraform validate
```

### 3. Plan Deployment
```bash
terraform plan -out=task3.tfplan
```

### 4. Apply Configuration
```bash
terraform apply task3.tfplan
# or for auto-approval (use with caution)
terraform apply -auto-approve
```

### 5. View Outputs
```bash
terraform output
```

### 6. Get Backend Configuration
```bash
terraform output backend_config
```

## Using the Backend for Other Tasks

Once deployed, configure other Terraform projects to use this S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "task3-bucket-nasif-123456789012"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## Security Features

✓ **Encryption**: AES-256 server-side encryption on all data  
✓ **Public Access**: All public access blocked via bucket policies  
✓ **Versioning**: Version history enabled for state recovery  
✓ **State Locking**: DynamoDB prevents concurrent modifications  
✓ **IAM**: Fine-grained access control via EC2 role  
✓ **Logging**: Access logs tracked in separate bucket  
✓ **Recovery**: Point-in-time recovery enabled on DynamoDB  

## Cleanup

To destroy all resources:
```bash
terraform destroy -auto-approve
```

⚠️ **WARNING**: This will delete the S3 bucket and DynamoDB table. Ensure no Terraform state is being stored here before destroying.

## Deliverables

1. S3 Bucket Settings (AWS Console):
   - Bucket name and region
   - Versioning status
   - Encryption settings
   - Public access block configuration
   - Access logs configuration

2. Terraform State File:
   - View .tfstate file in S3 bucket
   - Verify encryption and versioning

3. DynamoDB Table:
   - View state lock table
   - Verify encryption and PITR settings

4. IAM Role:
   - View role policy
   - Verify S3 and DynamoDB permissions
- `.gitignore` - Git ignore patterns

## Status
⏳ Awaiting task requirements

Once the task is assigned, files will be created following the same pattern as Task 1 and Task 2.
