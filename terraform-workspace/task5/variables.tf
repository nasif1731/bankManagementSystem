# Task 5: Elastic Load Balancer with Health Checks
# Variables for ALB, target groups, and ASG attachment

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "alb_enable_logging" {
  description = "Enable ALB access logging"
  type        = bool
  default     = false
}

variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
  
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TLS"], var.target_group_protocol)
    error_message = "Protocol must be HTTP, HTTPS, TCP, or TLS."
  }
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
  
  validation {
    condition     = var.target_group_port >= 1 && var.target_group_port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before target is healthy"
  type        = number
  default     = 2
  
  validation {
    condition     = var.health_check_healthy_threshold >= 2 && var.health_check_healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health checks before target is unhealthy"
  type        = number
  default     = 3
  
  validation {
    condition     = var.health_check_unhealthy_threshold >= 2 && var.health_check_unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP codes to consider healthy"
  type        = string
  default     = "200"
}

variable "asg_desired_capacity" {
  description = "Desired ASG capacity (for load balancing testing)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.asg_desired_capacity >= 1 && var.asg_desired_capacity <= 3
    error_message = "Desired capacity must be between 1 and 3."
  }
}

variable "listener_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "ALB listener protocol"
  type        = string
  default     = "HTTP"
  
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "Listener protocol must be HTTP or HTTPS."
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Task        = "Task5-LoadBalancer"
    CreatedBy   = "Terraform"
  }
}
