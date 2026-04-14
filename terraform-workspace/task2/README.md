# Task 2: Security Groups and EC2 Instance Deployment

Complete, fully segregated Task 2 setup with its own VPC and infrastructure.

## Quick Start

### Prerequisites

1. **Get your public IP:**
```bash
curl ifconfig.me
```
Note: You'll need to append `/32` to it (e.g., `203.0.113.42/32`)

2. **Generate or get your SSH public key:**
```bash
# If you don't have keys yet
ssh-keygen -t rsa -b 4096 -f ~/task2-key
cat ~/task2-key.pub
```

### Setup Steps

**Step 1: Update terraform.tfvars**

Edit `terraform.tfvars` and replace:
- `YOUR_PUBLIC_IP_HERE/32` → your actual public IP with /32
- `ssh-rsa AAAA...` → your full SSH public key from `cat ~/.ssh/id_rsa.pub`

Example:
```hcl
my_ip = "203.0.113.42/32"
instance_type = "t3.micro"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."
```

**Step 2: Navigate to task2 directory**

```bash
cd c:\Users\nasif\Downloads\bankManagementSystem\terraform-workspace\task2
```

**Step 3: Initialize Terraform**

```bash
terraform init
```

**Step 4: Validate configuration**

```bash
terraform fmt
terraform validate
```

**Step 5: Plan deployment**

```bash
terraform plan
```

Take a screenshot of this output.

**Step 6: Apply configuration**

```bash
terraform apply
```

Confirm with `yes`. Take a screenshot showing all outputs.

---

## Testing Steps

### Step 7: Wait for instances to initialize

Wait 1-2 minutes for instances to be fully ready.

### Step 8: Access Nginx web page

Open in browser or use curl:
```bash
curl http://YOUR_PUBLIC_IP
# or
open http://YOUR_PUBLIC_IP
```

Take a screenshot showing the Nginx page with instance ID.

### Step 9: SSH into Web Server

```bash
# Find your private key path (e.g., ~/task2-key or ~/.ssh/id_rsa)
ssh -i path/to/private/key ec2-user@YOUR_PUBLIC_IP
```

Take a screenshot of the SSH session.

### Step 10: From web server, SSH to private database server (Bastion pattern)

Once logged into web server, SSH to the database server:

```bash
# From the web server SSH session
ssh -i path/to/private/key ec2-user@PRIVATE_IP_OF_DB_SERVER
```

The private IP is shown in terraform outputs. Take a screenshot showing successful connection.

### Step 11: Verify direct access to private DB fails

On your local machine, try to SSH to the private instance directly:

```bash
# This should fail with timeout
ssh -i path/to/private/key ec2-user@PRIVATE_IP_OF_DB_SERVER
```

Take a screenshot showing the timeout/connection refused error.

### Step 12: Test validation - Try invalid instance_type

Edit `terraform.tfvars` and change:
```hcl
instance_type = "t3.large"  # Invalid - should be t3.micro, t3.small, or t3.medium
```

Then run:
```bash
terraform plan
```

Take a screenshot showing the validation error message.

### Step 13: Fix and re-apply

Change `instance_type` back to `t3.micro`:
```hcl
instance_type = "t3.micro"
```

---

## Verification in AWS Console

Take screenshots of the following:

1. **VPC Dashboard:**
   - New "task2-vpc" with CIDR 10.1.0.0/16
   - Verify Internet Gateway attached

2. **Subnets:**
   - Public subnet: 10.1.1.0/24
   - Private subnet: 10.1.10.0/24

3. **EC2 Instances:**
   - Both instances running (web-server and db-server)
   - Verify instance types and security groups

4. **Security Groups:**
   - **Web Server SG:**
     - Inbound: HTTP (80, my IP only), HTTPS (443, my IP only), SSH (22, my IP only)
     - Outbound: All traffic
   - **DB Server SG:**
     - Inbound: MySQL (3306, from web-server-sg only), SSH (22, from web-server-sg only)
     - Outbound: All traffic

5. **Network Interfaces/Route Tables:**
   - Public route table routes 0.0.0.0/0 to Internet Gateway
   - Private route table routes 0.0.0.0/0 to NAT Gateway

---

## Cleanup - Destroy Resources

When finished, destroy all resources:

```bash
terraform destroy
```

Confirm with `yes`. Take a screenshot showing completion.

Verify in AWS Console that all resources are deleted.

---

## Important Commands

```bash
terraform init          # Initialize
terraform fmt           # Format code
terraform validate      # Check syntax
terraform plan          # Show plan
terraform apply         # Create resources
terraform output        # Show outputs
terraform state list    # List all resources
terraform state show <resource>  # Show specific resource
terraform destroy       # Delete everything
```

---

## Files in this directory

- **main.tf** - Complete VPC, security groups, and EC2 configuration
- **variables.tf** - All input variables with validation
- **terraform.tfvars** - Variable values (update before running)
- **outputs.tf** - All outputs for resource IDs
- **.gitignore** - Ignores sensitive files

---

## What Gets Created

- 1 VPC (10.1.0.0/16)
- 1 Public Subnet (10.1.1.0/24)
- 1 Private Subnet (10.1.10.0/24)
- 1 Internet Gateway
- 1 NAT Gateway with Elastic IP
- 2 Route Tables (public and private)
- 2 Security Groups (web and db)
- 2 EC2 instances (t3.micro)
- 1 SSH Key Pair
- 1 Elastic IP for web server

Total estimated cost: ~$0.15/hour (micro instances + NAT)

---

## Deliverables Checklist

- [ ] terraform plan screenshot
- [ ] terraform apply output screenshot
- [ ] Nginx page screenshot (showing instance ID)
- [ ] AWS Console - Both EC2 instances running
- [ ] AWS Console - Web Security Group rules
- [ ] AWS Console - DB Security Group rules
- [ ] Terminal - SSH into web server
- [ ] Terminal - SSH from web to private DB (bastion)
- [ ] Terminal - Failed direct SSH to private DB
- [ ] terraform plan error with invalid instance_type
- [ ] terraform destroy completion screenshot
