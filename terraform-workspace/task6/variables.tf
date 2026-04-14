# Root variables for Task 6

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# ========================
# VPC Variables
# ========================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ========================
# Environment & Network Variables
# ========================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "allow_ssh_from_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

# ========================
# Compute Variables
# ========================

variable "custom_ami_id" {
  description = "Custom AMI ID built with Packer (leave empty to use Ubuntu 22.04)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name for EC2 instance"
  type        = string
  default     = "app-server"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script for EC2 instance"
  type        = string
  default     = ""
}

# ========================
# Tags
# ========================

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Task6-ModulesAndPacker"
    CreatedBy   = "Terraform"
    ManagedBy   = "Terraform"
  }
}
