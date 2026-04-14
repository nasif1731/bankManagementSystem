terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ========================
# VPC Module
# ========================

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  environment           = var.environment
  
  tags = merge(var.tags, {
    Module = "VPC"
  })
}

# ========================
# Security Module
# ========================

module "security" {
  source = "./modules/security"

  vpc_id                = module.vpc.vpc_id
  environment           = var.environment
  allow_ssh_from_cidr   = var.allow_ssh_from_cidr
  
  tags = merge(var.tags, {
    Module = "Security"
  })

  depends_on = [module.vpc]
}

# ========================
# Compute Module (Instance in Public Subnet)
# ========================

module "compute" {
  source = "./modules/compute"

  # Use the custom Packer AMI if available, otherwise fall back to Ubuntu 22.04
  ami_id              = var.custom_ami_id != "" ? var.custom_ami_id : data.aws_ami.ubuntu.id
  instance_type       = var.instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security.web_sg_id]
  key_name            = var.key_name
  environment         = var.environment
  instance_name       = var.instance_name
  
  # Optional user data
  user_data           = var.user_data
  
  tags = merge(var.tags, {
    Module = "Compute"
  })

  depends_on = [module.security]
}

# ========================
# Data Sources
# ========================

# Get Ubuntu 22.04 LTS AMI (fallback if custom AMI not provided)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
