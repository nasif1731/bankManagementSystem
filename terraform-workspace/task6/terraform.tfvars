# Task 6: Terraform Modules and Packer - Configuration Variables

aws_region = "us-east-1"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24"
]

# Environment
environment = "dev"

# Security
allow_ssh_from_cidr = "0.0.0.0/0"  # Can be restricted to specific IP

# Compute
instance_type = "t3.micro"
instance_name = "task6-web-server"

# Custom AMI - Leave empty to use default Ubuntu 22.04
# Set this to your Packer-built AMI ID after running: packer build packer/build.pkr.hcl
custom_ami_id = "ami-09e33b589d91ea2b8"

# Optional: EC2 Key pair for SSH access
# Set this to an existing key pair name if you want SSH access
# key_name = "your-key-pair-name"
key_name = null

# Optional user data
user_data = ""

# Common tags
tags = {
  Project     = "Task6-ModulesAndPacker"
  Task        = "Task6"
  Environment = "development"
  CreatedBy   = "Terraform"
  ManagedBy   = "Terraform"
}
