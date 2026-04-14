# Task 4: [To Be Assigned]

# Task 4: Auto Scaling Group with CloudWatch Alarms
# Variables for launch template, ASG, and CloudWatch monitoring

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
  
  validation {
    condition     = var.asg_min_size >= 1
    error_message = "Minimum size must be at least 1."
  }
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
  
  validation {
    condition     = var.asg_max_size >= var.asg_min_size
    error_message = "Maximum size must be >= minimum size."
  }
}

variable "asg_desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 1
}

variable "scale_out_adjustment" {
  description = "Number of instances to add when scaling out"
  type        = number
  default     = 1
}

variable "scale_in_adjustment" {
  description = "Number of instances to remove when scaling in"
  type        = number
  default     = -1
}

variable "scale_out_cooldown" {
  description = "Cooldown period (seconds) for scale-out policy"
  type        = number
  default     = 120
}

variable "scale_in_cooldown" {
  description = "Cooldown period (seconds) for scale-in policy"
  type        = number
  default     = 120
}

variable "cpu_scale_out_threshold" {
  description = "CPU utilization threshold to trigger scale-out (%)"
  type        = number
  default     = 60
  
  validation {
    condition     = var.cpu_scale_out_threshold > 0 && var.cpu_scale_out_threshold <= 100
    error_message = "Threshold must be between 0 and 100."
  }
}

variable "cpu_scale_in_threshold" {
  description = "CPU utilization threshold to trigger scale-in (%)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.cpu_scale_in_threshold > 0 && var.cpu_scale_in_threshold <= 100
    error_message = "Threshold must be between 0 and 100."
  }
}

variable "cloudwatch_evaluation_periods" {
  description = "Number of periods for CloudWatch alarm evaluation"
  type        = number
  default     = 2
}

variable "cloudwatch_period" {
  description = "Period (seconds) for CloudWatch metrics"
  type        = number
  default     = 60
}

variable "enable_autoscaling_notifications" {
  description = "Enable SNS notifications for scaling events"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Task        = "Task4-ASG-CloudWatch"
    CreatedBy   = "Terraform"
  }
}

# Additional variables to be defined based on task requirements
