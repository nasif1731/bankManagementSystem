# Task 1: Custom VPC with Subnetting and NAT Gateway

## Overview
This task creates a complete VPC infrastructure with public and private subnets across multiple availability zones, along with Internet Gateway and NAT Gateway for routing.

## Quick Start

### 1. Navigate to task1-vpc directory
```bash
cd task1-vpc
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Validate and format
```bash
terraform fmt
terraform validate
```

### 4. Plan deployment
```bash
terraform plan
```

### 5. Apply configuration
```bash
terraform apply
```

### 6. View state
```bash
terraform state list
```

### 7. Cleanup
```bash
terraform destroy
```

## Resources Created

- **VPC:** 10.0.0.0/16 with DNS support enabled
- **Public Subnets:** 
  - 10.0.1.0/24 (AZ-a)
  - 10.0.2.0/24 (AZ-b)
- **Private Subnets:**
  - 10.0.10.0/24 (AZ-a)
  - 10.0.11.0/24 (AZ-b)
- **Internet Gateway:** Attached to VPC
- **NAT Gateway:** In public subnet with Elastic IP
- **Route Tables:** Public (→ IGW) and Private (→ NAT)

## Files
- `main.tf` - VPC, subnets, gateways, routes
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `terraform.tfvars` - Variable values
- `.gitignore` - Git ignore patterns

## Notes
- DNS support and DNS hostnames enabled on VPC
- NAT Gateway depends on Internet Gateway (explicit dependency)
- All traffic from public subnets routes through IGW
- All traffic from private subnets routes through NAT Gateway
- Cost: NAT Gateway ~$0.045/hour + data transfer charges
