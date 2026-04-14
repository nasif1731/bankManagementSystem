# Task 2: Security Groups and EC2 Instance Deployment
# Variable Definitions

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "Your public IP address with /32 CIDR notation (e.g., 203.0.113.42/32)"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/32$", var.my_ip))
    error_message = "my_ip must be in CIDR notation with /32 suffix (e.g., 203.0.113.42/32). Get your IP from: curl ifconfig.me"
  }
}

variable "instance_type" {
  description = "EC2 instance type for web and database servers"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "instance_type must be one of: t3.micro, t3.small, or t3.medium."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 key pair (from ~/.ssh/id_rsa.pub)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa AAAA|^ssh-ed25519 AAAA", var.ssh_public_key))
    error_message = "ssh_public_key must be a valid SSH public key (starting with 'ssh-rsa AAAA' or 'ssh-ed25519 AAAA')."
  }
}
