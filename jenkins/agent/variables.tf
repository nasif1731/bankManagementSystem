# Variables for Jenkins Build Agent

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
  default     = "banking-vpc"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet where the agent will be placed"
  type        = string
  default     = "10.0.3.0/24"
}

variable "instance_name" {
  description = "Name of the Jenkins build agent EC2 instance"
  type        = string
  default     = "jenkins-build-agent"
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins build agent"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 50
}

variable "jenkins_controller_security_group_id" {
  description = "Security group ID of the Jenkins controller (for communication)"
  type        = string
  default     = ""
}

variable "jenkins_controller_private_ip" {
  description = "Private IP of the Jenkins controller"
  type        = string
  default     = "10.0.1.10"
}

variable "agent_label" {
  description = "Label for the Jenkins agent"
  type        = string
  default     = "linux-agent"
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
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
