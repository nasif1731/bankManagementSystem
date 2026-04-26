# Variables for Jenkins Controller

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "jenkins"
}

# VPC and Network Configuration
variable "vpc_cidr" {
  description = "CIDR block of the VPC (from Assignment 3 task1-vpc)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC from Assignment 3"
  type        = string
  default     = "task1-vpc"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet where Jenkins will be placed"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_name" {
  description = "Name of the Jenkins controller EC2 instance"
  type        = string
  default     = "jenkins-controller"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins controller"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "nehal-aws-key"
}

variable "enable_eip" {
  description = "Whether to assign an Elastic IP to Jenkins controller"
  type        = bool
  default     = true
}

variable "my_ip" {
  description = "Your IP address for SSH and Jenkins UI access (x.x.x.x/32 format)"
  type        = string
  default     = "0.0.0.0/32" # Change this to your actual IP
}

variable "jenkins_port" {
  description = "Port for Jenkins UI"
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "agent_security_group_id" {
  description = "Security group ID of the build agent (for internal communication)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Jenkins-CI-CD"
    Owner       = "DevOps"
    Created_By  = "Terraform"
    Assignment  = "4"
  }
}
