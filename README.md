# Bank Management System - Terraform Infrastructure

Comprehensive Infrastructure as Code (IaC) project using **Terraform** to deploy and manage AWS cloud resources with modular architecture and automation.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Task Breakdown](#task-breakdown)
- [Initialization and Application](#initialization-and-application)
- [AWS Resources](#aws-resources)
- [Destroy Resources](#destroy-resources)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project demonstrates enterprise-grade Infrastructure as Code practices using Terraform to provision and manage AWS resources across multiple tasks:

- **Task 1**: VPC infrastructure with public/private subnets
- **Task 2**: Network security groups with granular ingress/egress rules
- **Task 3**: EC2 compute resources with Elastic IPs
- **Task 4**: Auto Scaling Groups (ASG) with launch templates and CloudWatch monitoring
- **Task 5**: Application Load Balancer (ALB) with target group management
- **Task 6**: Modularized infrastructure with Packer custom AMI builds

Each task builds upon previous configurations, creating a layered, scalable cloud infrastructure.

---

## Prerequisites

### Required Tools

1. **Terraform** (v1.0 or later)
   ```bash
   terraform version
   ```
   Install from: https://www.terraform.io/downloads.html

2. **AWS CLI** (v2 or later)
   ```bash
   aws --version
   ```
   Install from: https://aws.amazon.com/cli/

3. **AWS Credentials Configured**
   ```bash
   aws configure
   ```
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default Region (e.g., us-east-1)

4. **Packer** (for Task 6 custom AMI)
   ```bash
   packer version
   ```
   Install from: https://www.packer.io/downloads

5. **Git** (for version control)
   ```bash
   git --version
   ```

### Account Requirements

- Active AWS account with:
  - EC2, VPC, Load Balancing, Auto Scaling permissions
  - IAM permissions to create roles and policies
  - CloudWatch monitoring access

---

## Project Structure

```
bankManagementSystem/
├── README.md                           # This file
├── README_BANKING_PROJECT_BACKUP.md    # Original project documentation
├── pom.xml                             # Maven configuration (Java application)
├── Dockerfile & docker-compose.yml     # Container deployment configs
├── terraform-workspace/                # Main Terraform workspace
│
├── task1-vpc/                          # VPC Infrastructure
│   ├── main.tf                         # VPC, subnets, IGW, NAT Gateway
│   ├── variables.tf                    # Input variables
│   ├── outputs.tf                      # Output values (VPC ID, subnet IDs, etc.)
│   ├── terraform.tfvars                # Variable values
│   └── README.md                       # Task-specific documentation
│
├── task2/                              # Network Security
│   ├── main.tf                         # Security groups with rules
│   ├── variables.tf
│   ├── outputs.tf                      # SG IDs for downstream tasks
│   ├── terraform.tfvars
│   └── README.md
│
├── task3/                              # Compute Resources
│   ├── main.tf                         # EC2 instances, Elastic IPs
│   ├── variables.tf
│   ├── outputs.tf                      # Instance IDs, public IPs
│   ├── terraform.tfvars
│   └── README.md
│
├── task4/                              # Auto Scaling & Monitoring
│   ├── main.tf                         # ASG, launch templates, CloudWatch
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
│
├── task5/                              # Load Balancing
│   ├── main.tf                         # ALB, target groups, listeners
│   ├── variables.tf
│   ├── outputs.tf                      # ALB DNS name, target group ARN
│   ├── terraform.tfvars
│   └── README.md
│
├── task6/                              # Modular Architecture with Packer
│   ├── main.tf                         # Calls VPC, security, compute modules
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── README.md
│   ├── modules/
│   │   ├── vpc/                        # VPC module
│   │   ├── security/                   # Security groups module
│   │   └── compute/                    # Compute resources module
│   └── packer/
│       └── build.pkr.hcl               # Packer template for custom AMI
│
├── terraform.tfstate                   # State file (NEVER commit this)
├── terraform.tfstate.backup            # Backup state (NEVER commit this)
│
└── .gitignore                          # Git ignore rules

```

---

## Getting Started

### 1. Clone or Navigate to Repository

```bash
cd c:\Users\nasif\Downloads\bankManagementSystem
```

### 2. Verify AWS Credentials

```bash
aws sts get-caller-identity
```

Expected output shows your AWS Account ID and ARN.

### 3. Choose a Task

Start with **Task 1** and work sequentially. Each task depends on previous infrastructure:

- **Task 1** → Foundation (VPC)
- **Task 1 + Task 2** → Networking (Security)
- **Task 1 + Task 2 + Task 3** → Compute (EC2)
- **Tasks 1-4** → Auto Scaling & Monitoring
- **Tasks 1-5** → Load Balancing
- **Tasks 1-6** → Modular Architecture with Custom AMI

---

## Initialization and Application

### Step 1: Initialize Terraform

Navigate to the task directory and initialize:

```bash
cd terraform-workspace/task1-vpc
terraform init
```

**What happens:**
- Downloads required Terraform providers (AWS)
- Creates `.terraform/` directory
- Generates `.terraform.lock.hcl` (dependency lock file)

### Step 2: Validate Configuration

```bash
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 3: Plan Deployment

Review what Terraform will create:

```bash
terraform plan
```

**Output shows:**
- Resources to be created (`+`)
- Resources to be modified (`~`)
- Resources to be destroyed (`-`)

Save plan (optional):
```bash
terraform plan -out=tfplan
```

### Step 4: Apply Configuration

Deploy resources to AWS:

```bash
terraform apply
```

**Interactive confirmation:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Type `yes` to confirm.

**Auto-approve (skip confirmation):**
```bash
terraform apply -auto-approve
```

**Expected output:**
```
Apply complete! Resources: X added, Y changed, Z destroyed.

Outputs:
vpc_id = "vpc-xxxxx..."
subnet_ids = [...]
```

### Step 5: Verify Outputs

View created resources:

```bash
terraform output
```

Or specific output:
```bash
terraform output vpc_id
```

### Applying Multiple Tasks in Sequence

To build the complete infrastructure:

```bash
# Task 1: VPC Foundation
cd terraform-workspace/task1-vpc
terraform init
terraform apply -auto-approve

# Task 2: Security Groups
cd ../task2
terraform init
terraform apply -auto-approve

# Task 3: EC2 Instances
cd ../task3
terraform init
terraform apply -auto-approve

# Continue for Task 4, 5, 6...
```

---

## AWS Resources

### Task 1-VPC: Virtual Private Cloud
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: 2 subnets across 2 availability zones (10.0.1.0/24, 10.0.2.0/24)
- **Private Subnets**: 2 subnets for backend (10.0.11.0/24, 10.0.12.0/24)
- **Internet Gateway**: Enables public subnet internet access
- **NAT Gateway**: Enables private subnet outbound internet access
- **Route Tables**: Public and private routing configurations

### Task 2: Network Security
- **Web Security Group**: Allows HTTP (80), HTTPS (443), SSH (22)
- **Database Security Group**: Allows MySQL (3306) from web tier

### Task 3: Compute Resources
- **EC2 Instance**: t2.micro in public subnet
- **Elastic IP**: Static public IP for EC2
- **Root Volume**: 20 GB gp2 storage

### Task 4: Auto Scaling & Monitoring
- **Launch Template**: Define EC2 configuration for scaling
- **Auto Scaling Group**: 2-4 instances across availability zones
- **CloudWatch Alarms**: Monitor CPU utilization
- **Scaling Policies**: Scale up/down based on demand

### Task 5: Load Balancing
- **Application Load Balancer**: Distributes traffic across instances
- **Target Group**: Registers EC2 instances as targets
- **Listener**: Forwards HTTP traffic to target group
- **Health Checks**: Monitor instance health

### Task 6: Modular Architecture + Packer
- **Modules**: Reusable VPC, Security, Compute components
- **Packer AMI**: Custom Ubuntu image with Nginx pre-installed
- **EC2 from Custom AMI**: Instance launched from Packer-built image

---

## Destroy Resources

### Destroy a Single Task

```bash
cd terraform-workspace/task1-vpc
terraform destroy
```

**Confirmation prompt:**
```
Do you want to perform these actions?
  Terraform will destroy all your managed infrastructure.
  
  Enter a value:
```

Type `yes` to confirm.

**Auto-destroy (skip confirmation):**
```bash
terraform destroy -auto-approve
```

### Destroy Multiple Tasks (Reverse Order)

**IMPORTANT**: Destroy in REVERSE order due to dependencies:

```bash
# Destroy Task 6 first
cd terraform-workspace/task6
terraform destroy -auto-approve

# Then Task 5
cd ../task5
terraform destroy -auto-approve

# Then Task 4
cd ../task4
terraform destroy -auto-approve

# And so on... (Task 3, 2, 1)
```

### Verify Destruction

Check AWS Console or use CLI:

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
aws ec2 describe-vpcs --filters "Name=cidr,Values=10.0.0.0/16"
```

---

## Troubleshooting

### Issue: "Terraform init" fails with provider error

**Solution:**
```bash
# Clear Terraform cache
rm -r .terraform/
rm .terraform.lock.hcl

# Reinitialize
terraform init
```

### Issue: "Invalid credentials" or "UnauthorizedOperation"

**Solution:**
```bash
# Verify AWS credentials
aws configure
aws sts get-caller-identity

# Check AWS region
aws configure get region
```

### Issue: "Resource already exists" during apply

**Solution:**
```bash
# Check state file
terraform state list

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Or refresh state
terraform refresh
```

### Issue: Destroy fails with "Resource in use"

**Common cause:** Dependency not resolved (e.g., ALB still attached to ASG)

**Solution:**
```bash
# View dependencies
terraform graph

# Destroy in correct order (reverse of apply)
# Task 6 → Task 5 → Task 4 → Task 3 → Task 2 → Task 1
```

### Issue: Long destroy times (15+ minutes)

**Why:** AWS ENI detachment and subnet dependency propagation delays

**Solution:**
- Monitor progress: `terraform state list`
- Don't interrupt the process
- AWS takes time to fully remove resources

### Issue: "Duplicate resource creation"

**Solution:**
1. Check if resource exists in AWS Console
2. Remove from state if orphaned:
   ```bash
   terraform state rm aws_instance.web
   ```
3. Re-apply to recreate:
   ```bash
   terraform apply -auto-approve
   ```

### Issue: Packer AMI build fails (Task 6)

**Solution:**
```bash
# Navigate to packer directory
cd task6/packer

# Validate template
packer validate build.pkr.hcl

# Build with debugging
packer build -debug build.pkr.hcl
```

---

## Common Commands Reference

| Command | Description |
|---------|-------------|
| `terraform init` | Initialize Terraform workspace |
| `terraform validate` | Validate configuration syntax |
| `terraform plan` | Preview changes (dry-run) |
| `terraform apply` | Apply configuration to AWS |
| `terraform destroy` | Remove all resources |
| `terraform output` | Display output values |
| `terraform state list` | List resources in state |
| `terraform state show <resource>` | Show resource details |
| `terraform refresh` | Sync local state with AWS |
| `terraform fmt` | Format HCL code |
| `terraform taint <resource>` | Mark for recreation |

---

## Best Practices

1. **Always run `terraform plan` before `apply`** - Review changes carefully
2. **Use `terraform.tfvars` for environment-specific values** - Keep code reusable
3. **Enable state locking** - Prevent concurrent modifications in team environments
4. **Backup state files** - State is critical; store backup safely
5. **Use version pinning** - Lock provider and module versions for consistency
6. **Implement code review** - Changes to IaC should be reviewed before merge
7. **Monitor AWS costs** - Resources have associated costs; monitor CloudWatch
8. **Document outputs** - Document what each output represents for team clarity

---

## Support & Documentation

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **Task READMEs**: See individual task `README.md` files for detailed configuration
- **Packer Docs**: https://www.packer.io/docs

---

**Last Updated**: April 14, 2026  
**Terraform Version**: 1.x  
**AWS Region**: us-east-1 (configurable via variables)

