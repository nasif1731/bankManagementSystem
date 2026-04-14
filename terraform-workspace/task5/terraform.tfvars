# Task 5: Elastic Load Balancer with Health Checks
# Variable values

aws_region = "us-east-1"

# ALB Configuration
alb_enable_deletion_protection = false
alb_enable_logging             = false

# Target Group Configuration
target_group_protocol = "HTTP"
target_group_port     = 80

# Health Check Configuration
health_check_enabled            = true
health_check_healthy_threshold  = 2
health_check_unhealthy_threshold = 3
health_check_interval           = 30
health_check_timeout            = 5
health_check_path               = "/"
health_check_matcher            = "200"

# ASG Configuration
asg_desired_capacity = 2

# Listener Configuration
listener_port     = 80
listener_protocol = "HTTP"

# Tags
tags = {
  Environment = "development"
  Task        = "Task5-LoadBalancer"
  CreatedBy   = "Terraform"
}
