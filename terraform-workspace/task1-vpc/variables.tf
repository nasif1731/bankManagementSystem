# Task 1: Custom VPC with Subnetting and NAT Gateway
# Variable Definitions

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "task1-vpc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1 in AZ 1"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_1_cidr, 0))
    error_message = "Public subnet 1 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2 in AZ 2"
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.public_subnet_2_cidr, 0))
    error_message = "Public subnet 2 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 in AZ 1"
  type        = string
  default     = "10.0.10.0/24"

  validation {
    condition     = can(cidrhost(var.private_subnet_1_cidr, 0))
    error_message = "Private subnet 1 CIDR must be a valid IPv4 CIDR block."
  }
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 in AZ 2"
  type        = string
  default     = "10.0.11.0/24"

  validation {
    condition     = can(cidrhost(var.private_subnet_2_cidr, 0))
    error_message = "Private subnet 2 CIDR must be a valid IPv4 CIDR block."
  }
}
