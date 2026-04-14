# Terraform Workspace - Multi-Task AWS Infrastructure

Complete Terraform workspace containing 4 independent tasks for AWS infrastructure management.

## Workspace Structure

```
terraform-workspace/
├── README.md                          # This file
├── .gitignore                         # Root .gitignore
│
├── task1-vpc/                         # Task 1: VPC with Subnetting and NAT
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── .gitignore
│   └── README.md
│
├── task2/                             # Task 2: Security Groups and EC2
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── .gitignore
│   └── README.md
│
├── task3/                             # Task 3: [To Be Assigned]
│   └── README.md
│
└── task4/                             # Task 4: [To Be Assigned]
    └── README.md
```

## Tasks Overview

### Task 1: Custom VPC with Subnetting and NAT Gateway
**Location:** `task1-vpc/`

Creates a complete VPC infrastructure:
- Custom VPC (10.0.0.0/16)
- 2 Public subnets in different AZs
- 2 Private subnets in different AZs
- Internet Gateway
- NAT Gateway with Elastic IP
- Public and private route tables

**Quick Start:**
```bash
cd task1-vpc
terraform init
terraform plan
terraform apply
terraform destroy
```

### Task 2: Security Groups and EC2 Instance Deployment
**Location:** `task2/`

Fully segregated task with:
- Own VPC (10.1.0.0/16)
- Web server security group (HTTP, HTTPS, SSH from my IP)
- Database server security group (MySQL from web SG only)
- EC2 instance in public subnet with Nginx
- EC2 instance in private subnet
- SSH key pair
- Bastion host pattern for private access

**Quick Start:**
```bash
cd task2
# Update terraform.tfvars with your IP and SSH key
terraform init
terraform plan
terraform apply
# Test SSH and bastion access
terraform destroy
```

### Task 3: [Awaiting Assignment]
**Location:** `task3/`

To be implemented when requirements are provided.

### Task 4: [Awaiting Assignment]
**Location:** `task4/`

To be implemented when requirements are provided.

---

## Directory Structure Conventions

Each task directory follows this standard structure:

```
task-directory/
├── main.tf              # Primary Terraform configuration
│                        # - Provider configuration
│                        # - Resource definitions
│                        # - Data sources
│
├── variables.tf         # Variable definitions
│                        # - All input variables
│                        # - Validation rules
│                        # - Variable descriptions
│
├── outputs.tf           # Output definitions
│                        # - All output values
│                        # - Resource IDs and details
│                        # - Summary outputs
│
├── terraform.tfvars     # Variable values
│                        # - Actual values for variables
│                        # - Environment-specific config
│                        # - DO NOT commit sensitive data
│
├── .gitignore           # Git ignore patterns
│                        # - Ignores state files
│                        # - Ignores sensitive files
│                        # - Ignores IDE files
│
├── README.md            # Task documentation
│                        # - Task overview
│                        # - Quick start steps
│                        # - Resource details
│                        # - Important notes
│
└── (optional)           # Other files as needed
    ├── locals.tf        # Local values
    ├── data.tf          # Data sources
    ├── terraform.tfvars.example  # Example variables
    └── ...
```

---

## Key Files Explanation

### main.tf
Contains the primary Terraform configuration:
- Provider configuration
- All resource definitions
- Data sources for lookups
- Dependencies management
- Comments explaining resources

### variables.tf
Defines all input variables:
- Variable descriptions
- Types and defaults
- Validation rules
- Sensitive variable marking

### outputs.tf
Defines all outputs:
- Resource IDs
- Important attributes
- Connection information
- Computed values

### terraform.tfvars
Contains actual values:
- Environment-specific values
- User-provided settings
- Configuration overrides
- Should be in .gitignore for sensitive data

### .gitignore
Standard patterns:
- `*.tfstate` - Terraform state files (sensitive)
- `.terraform/` - Downloaded modules
- `*.tfvars` - Variable files with secrets
- `.terraform.lock.hcl` - Lock file (can be committed)
- IDE and OS files

### README.md
Task-specific documentation:
- Overview of what gets created
- Quick start commands
- Resource details
- Important notes and costs

---

## Workflow for Each Task

### 1. Setup
```bash
cd task-directory
terraform init
```

### 2. Validate
```bash
terraform fmt
terraform validate
```

### 3. Plan
```bash
terraform plan
# Review the plan
terraform plan -out=tfplan  # Save plan (optional)
```

### 4. Apply
```bash
terraform apply
# or
terraform apply tfplan
```

### 5. Verify
```bash
terraform output              # Show all outputs
terraform state list          # List all resources
terraform state show <resource>  # Show resource details
```

### 6. Update (if needed)
Make changes to .tf files or terraform.tfvars, then:
```bash
terraform plan
terraform apply
```

### 7. Cleanup
```bash
terraform destroy
```

---

## Important Notes

### Independence
- Each task is completely independent
- Can be deployed in any order
- Each has its own state file
- Can run multiple simultaneously

### State Management
- State files are created locally (terraform.tfstate)
- Do NOT commit state files to git
- For team work: use remote state (S3 backend)
- Backup state files before major changes

### Security
- NEVER commit terraform.tfvars with sensitive data
- NEVER commit SSH keys to git
- Use .gitignore to protect:
  - `*.tfvars` files
  - `*.pem` key files
  - State files
- Use environment variables for sensitive data
- Use AWS IAM roles when possible

### Cost Management
- Set up AWS Cost Alerts
- Review monthly usage
- Clean up resources with `terraform destroy`
- NAT Gateway costs: ~$0.045/hour
- Remember cleanup = `terraform destroy`

### Validation Commands
```bash
# Validate all tasks
for dir in task*/; do
  echo "Validating $dir..."
  cd "$dir"
  terraform validate
  cd ..
done

# Plan all tasks
for dir in task*/; do
  echo "Planning $dir..."
  cd "$dir"
  terraform plan
  cd ..
done
```

---

## Troubleshooting

### Terraform Init Fails
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### State File Issues
```bash
# Refresh state from AWS
terraform refresh

# Check state consistency
terraform validate

# See current state
terraform state list
terraform state show aws_instance.web_server
```

### AWS Credentials Error
```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

### Resource Already Exists
```bash
# Check state vs AWS
terraform refresh

# Import existing resource
terraform import aws_instance.web_server i-1234567890abcdef0

# Or remove from state and re-create
terraform state rm aws_instance.web_server
terraform apply
```

---

## Best Practices

1. **Always validate before applying:**
   ```bash
   terraform validate
   terraform plan
   ```

2. **Use consistent naming:** Follow task naming conventions

3. **Add descriptive tags:** Help identify resources in AWS Console

4. **Document assumptions:** Add comments for non-obvious configs

5. **Test in dev first:** Test changes in development before prod

6. **Backup state regularly:** Use version control for .tf files

7. **Use workspaces for environments:**
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   terraform workspace select dev
   ```

8. **Review outputs carefully:** Verify outputs before using in other systems

---

## Useful Commands Reference

```bash
# Initialization & Validation
terraform init                    # Initialize working directory
terraform validate                # Check syntax
terraform fmt                     # Format code

# Planning & Applying
terraform plan                    # Show execution plan
terraform plan -out=tfplan        # Save plan to file
terraform apply tfplan            # Apply saved plan
terraform apply -auto-approve     # Auto approve
terraform apply -destroy          # Destroy with apply

# State Management
terraform refresh                 # Update state from AWS
terraform state list              # List all resources
terraform state show <resource>   # Show resource details
terraform state rm <resource>     # Remove from state
terraform state mv <old> <new>    # Rename resource

# Outputs & Info
terraform output                  # Show all outputs
terraform output <name>           # Show specific output
terraform output -json            # Output as JSON
terraform graph                   # Show resource graph

# Cleanup
terraform destroy                 # Remove all resources
terraform destroy -auto-approve   # Auto approve destroy
terraform destroy -target=<resource>  # Destroy specific resource
```

---

## AWS Console Verification

After `terraform apply`, verify in AWS Console:

1. **EC2 Dashboard**
   - Check instances are running
   - Verify security groups
   - Check key pairs

2. **VPC Dashboard**
   - Verify VPCs, subnets, route tables
   - Check Internet Gateway attachment
   - Verify NAT Gateway

3. **Security Groups**
   - Review inbound/outbound rules
   - Verify CIDR blocks and ports

4. **Elastic IPs**
   - Verify NAT Gateway and EC2 EIPs
   - Check allocation status

---

## Contributing / Adding New Tasks

When adding a new task (Task 3, 4, etc.):

1. Create new directory: `taskN/`
2. Copy structure from existing task
3. Update main.tf with task-specific resources
4. Update variables.tf with required variables
5. Update outputs.tf with important values
6. Create terraform.tfvars with template values
7. Write comprehensive README.md
8. Add to this main README

---

## Questions or Issues?

Refer to:
- Task-specific README.md files
- Terraform Official Docs: https://www.terraform.io/docs
- AWS Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- AWS CLI Docs: https://docs.aws.amazon.com/cli/

---

**Last Updated:** April 8, 2026
**Terraform Version:** >= 1.0
**AWS Provider Version:** ~> 5.0
