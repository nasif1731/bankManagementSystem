# Task 4: Auto Scaling Group with CloudWatch Alarms
# Variable values

aws_region = "us-east-1"

# EC2 Configuration
instance_type = "t3.micro"

# Auto Scaling Group Configuration
asg_min_size           = 1
asg_max_size           = 5
asg_desired_capacity   = 2

# Scaling Policies
scale_out_adjustment  = 1
scale_in_adjustment   = -1
scale_out_cooldown    = 120
scale_in_cooldown     = 120

# CloudWatch Alarms Configuration
cpu_scale_out_threshold       = 60  # Scale out when CPU >= 60%
cpu_scale_in_threshold        = 20  # Scale in when CPU <= 20%
cloudwatch_evaluation_periods = 2   # Must breach for 2 consecutive periods
cloudwatch_period             = 60  # Each period is 60 seconds

# Notifications
enable_autoscaling_notifications = false

# Tags
tags = {
  Environment = "development"
  Task        = "Task4-ASG-CloudWatch"
  CreatedBy   = "Terraform"
}
