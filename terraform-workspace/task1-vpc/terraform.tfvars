# Task 1: Custom VPC with Subnetting and NAT Gateway
# Variable Values

aws_region  = "us-east-1"
vpc_name    = "task1-vpc"
environment = "development"

# VPC CIDR
vpc_cidr = "10.0.0.0/16"

# Public Subnets (in different AZs)
public_subnet_1_cidr = "10.0.1.0/24"   # AZ 1
public_subnet_2_cidr = "10.0.2.0/24"   # AZ 2
public_subnet_3_cidr=  "10.0.3.0/24"

# Private Subnets (in different AZs)
private_subnet_1_cidr = "10.0.10.0/24"  # AZ 1
private_subnet_2_cidr = "10.0.11.0/24"  # AZ 2

