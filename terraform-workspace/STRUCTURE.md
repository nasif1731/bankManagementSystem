# Terraform Workspace Structure Reference

## Final Directory Structure

```
terraform-workspace/
│
├── README.md                          # Complete workspace documentation
├── .gitignore                         # Root-level git ignore
│
├── task1-vpc/                         # ✓ COMPLETE: VPC with Subnetting & NAT
│   ├── main.tf                        # VPC, subnets, IGW, NAT, routes
│   ├── variables.tf                   # Input variables with validation
│   ├── outputs.tf                     # Output definitions
│   ├── terraform.tfvars               # Variable values
│   ├── .gitignore                     # Task-level git ignore
│   └── README.md                      # Task 1 documentation
│
├── task2/                             # ✓ COMPLETE: Security Groups & EC2
│   ├── main.tf                        # VPC, SGs, EC2, key pair, Nginx
│   ├── variables.tf                   # Input variables with validation
│   ├── outputs.tf                     # Output definitions
│   ├── terraform.tfvars               # Variable values (REQUIRES UPDATE)
│   ├── .gitignore                     # Task-level git ignore
│   └── README.md                      # Task 2 documentation
│
├── task3/                             # ⏳ TEMPLATE: Awaiting requirements
│   ├── main.tf                        # Terraform provider setup
│   ├── variables.tf                   # Template variables
│   ├── outputs.tf                     # Empty output template
│   ├── terraform.tfvars               # Template values
│   ├── .gitignore                     # Task-level git ignore
│   └── README.md                      # Placeholder documentation
│
└── task4/                             # ⏳ TEMPLATE: Awaiting requirements
    ├── main.tf                        # Terraform provider setup
    ├── variables.tf                   # Template variables
    ├── outputs.tf                     # Empty output template
    ├── terraform.tfvars               # Template values
    ├── .gitignore                     # Task-level git ignore
    └── README.md                      # Placeholder documentation
```

## File Descriptions

### Root Level Files

| File | Purpose |
|------|---------|
| `README.md` | Main workspace documentation with all tasks overview |
| `.gitignore` | Root-level git ignore patterns |

### Task Directory Files (each task folder contains)

| File | Purpose | Required |
|------|---------|----------|
| `main.tf` | Primary Terraform configuration | ✓ Yes |
| `variables.tf` | Input variable definitions | ✓ Yes |
| `outputs.tf` | Output value definitions | ✓ Yes |
| `terraform.tfvars` | Variable values (configuration) | ✓ Yes |
| `.gitignore` | Git ignore patterns | ✓ Yes |
| `README.md` | Task-specific documentation | ✓ Yes |

---

## Task Status

### ✓ Task 1: Custom VPC with Subnetting and NAT Gateway
**Location:** `task1-vpc/`
**Status:** Complete and ready
**Key Resources:**
- VPC (10.0.0.0/16)
- 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 Private Subnets (10.0.10.0/24, 10.0.11.0/24)
- Internet Gateway
- NAT Gateway with Elastic IP
- Public and Private Route Tables

**Quick Commands:**
```bash
cd task1-vpc
terraform init && terraform plan && terraform apply
```

---

### ✓ Task 2: Security Groups and EC2 Instance Deployment
**Location:** `task2/`
**Status:** Complete, needs variable configuration
**Key Resources:**
- VPC (10.1.0.0/16)
- Web Server EC2 (t3.micro) with Nginx
- Database Server EC2 (t3.micro)
- Web Server Security Group
- Database Server Security Group
- SSH Key Pair

**Before Running:**
1. Update `terraform.tfvars`:
   - Replace `YOUR_PUBLIC_IP/32` with your actual IP
   - Replace SSH public key with your actual key

**Quick Commands:**
```bash
cd task2
# Update terraform.tfvars first!
terraform init && terraform plan && terraform apply
```

---

### ⏳ Task 3: [To Be Assigned]
**Location:** `task3/`
**Status:** Template ready, awaiting requirements
**Template Structure:** ✓ Complete

To implement:
1. Update `main.tf` with resource definitions
2. Add variables to `variables.tf`
3. Add outputs to `outputs.tf`
4. Set values in `terraform.tfvars`
5. Update `README.md` with task details

---

### ⏳ Task 4: [To Be Assigned]
**Location:** `task4/`
**Status:** Template ready, awaiting requirements
**Template Structure:** ✓ Complete

To implement:
1. Update `main.tf` with resource definitions
2. Add variables to `variables.tf`
3. Add outputs to `outputs.tf`
4. Set values in `terraform.tfvars`
5. Update `README.md` with task details

---

## Workflow Examples

### Working with a Single Task

```bash
# Navigate to task
cd terraform-workspace/task2

# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan

# Apply
terraform apply

# View outputs
terraform output

# Cleanup
terraform destroy
```

### Working with Multiple Tasks

```bash
# Deploy all tasks
for task in task1-vpc task2 task3 task4; do
  echo "Deploying $task..."
  cd "$task"
  terraform init
  terraform apply -auto-approve
  cd ..
done

# Destroy all tasks
for task in task1-vpc task2 task3 task4; do
  echo "Destroying $task..."
  cd "$task"
  terraform destroy -auto-approve
  cd ..
done
```

### View All Resource States

```bash
# List all resources across all tasks
for task in task1-vpc task2 task3 task4; do
  echo "=== $task ==="
  cd "$task"
  terraform state list
  cd ..
done
```

---

## Important Notes

### Independence
- Each task is completely independent
- Each task has its own state file
- Tasks can be deployed in any order
- Multiple tasks can run simultaneously

### Security
- `.gitignore` files prevent committing:
  - State files (*.tfstate)
  - Variable files with secrets
  - SSH keys (*.pem, *.key)
  - Credentials

### State Management
- State files are created locally after first `terraform apply`
- For team work: configure remote state (S3 backend)
- Always backup state files before major changes
- Never manually edit state files

### Cost Tracking
- Estimated costs:
  - Task 1: VPC/NAT ~ $0.045/hour
  - Task 2: 2 EC2 instances ~ $0.014/hour
- Always run `terraform destroy` to stop charges
- Monitor AWS Cost Explorer regularly

---

## Next Steps

1. **Complete Task 1 & 2 with actual AWS deployment**
2. **Receive Task 3 & 4 requirements**
3. **Implement Task 3 & 4 following the same structure**
4. **Test all tasks thoroughly**
5. **Document any custom configurations**

---

## Maintenance Checklist

- [ ] All tasks follow consistent structure
- [ ] Each task has complete README.md
- [ ] All variables properly validated
- [ ] All outputs properly defined
- [ ] .gitignore files in place
- [ ] No hardcoded values in .tf files
- [ ] All task READMEs updated in root README
- [ ] Team members have documented access patterns
- [ ] Backup strategy established for state files

---

**Created:** April 8, 2026
**Last Updated:** April 8, 2026
**Terraform Version:** >= 1.0
**AWS Provider Version:** ~> 5.0
