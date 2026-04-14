# Task 4: Auto Scaling Group with CloudWatch Alarms
# Fully independent - creates VPC, subnets, security group, key pair, and ASG with monitoring

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
# VPC and Networking
# ========================

resource "aws_vpc" "task4" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "task4-vpc" })
}

# Internet Gateway
resource "aws_internet_gateway" "task4" {
  vpc_id = aws_vpc.task4.id
  tags   = merge(var.tags, { Name = "task4-igw" })
}

# Public Subnet AZ-1
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.task4.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "task4-public-az1" })
}

# Public Subnet AZ-2
resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.task4.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "task4-public-az2" })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.task4.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.task4.id
  }

  tags = merge(var.tags, { Name = "task4-public-rt" })
}

# Route Table Associations
resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# Data source for AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# ========================
# Security Groups
# ========================

resource "aws_security_group" "web" {
  name_prefix = "task4-web-sg-"
  description = "Security group for Task 4 web servers"
  vpc_id      = aws_vpc.task4.id

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  # Allow SSH from anywhere (for testing)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, { Name = "task4-web-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

# ========================
# SSH Key Pair
# ========================

# Generate SSH key pair
resource "tls_private_key" "task4" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "task4" {
  key_name_prefix = "task4-key-"
  public_key      = tls_private_key.task4.public_key_openssh

  tags = merge(var.tags, { Name = "task4-keypair" })
}

# Save private key locally (for reference)
resource "local_file" "private_key" {
  content         = tls_private_key.task4.private_key_pem
  filename        = "${path.module}/task4-private-key.pem"
  file_permission = "0600"
}

# ========================
# AMI Data Source
# ========================

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================
# Launch Template
# ========================

resource "aws_launch_template" "web" {
  name_prefix   = "task4-launch-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  key_name               = aws_key_pair.task4.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  # Enhanced monitoring
  monitoring {
    enabled = true
  }

  # User data script - install Nginx web server and stress-ng for testing
  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

# Update system
yum update -y

# Install and start Nginx web server
amazon-linux-extras install -y nginx1
systemctl start nginx
systemctl enable nginx

# Install stress-ng tool for CPU load generation
amazon-linux-extras install -y stress-ng
yum install -y stress-ng

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
echo "nginx installed: $(nginx -v 2>&1)" >> /var/log/user-data.log
echo "stress-ng installed: $(stress-ng --version 2>&1 | head -1)" >> /var/log/user-data.log
EOF
  )

  # Root block device
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "task4-asg-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "task4-asg-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================
# Auto Scaling Group
# ========================

resource "aws_autoscaling_group" "web" {
  name_prefix           = "task4-asg-"
  vpc_zone_identifier   = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_capacity
  health_check_type     = "EC2"
  health_check_grace_period = 300
  default_cooldown      = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Propagate name tag to instances
  tag {
    key                 = "Name"
    value               = "task4-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.tags["Environment"]
    propagate_at_launch = true
  }

  tag {
    key                 = "Task"
    value               = var.tags["Task"]
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================
# Scaling Policies
# ========================

# Scale-out policy (add 1 instance when CPU >= 60%)
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "task4-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_out_adjustment
  cooldown               = var.scale_out_cooldown
}

# Scale-in policy (remove 1 instance when CPU <= 20%)
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "task4-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_in_adjustment
  cooldown               = var.scale_in_cooldown
}

# ========================
# CloudWatch Alarms
# ========================

# Alarm for scale-out (high CPU: >= 60%)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "task4-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_scale_out_threshold
  alarm_description   = "Alarm when average CPU utilization >= ${var.cpu_scale_out_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = var.tags
}

# Alarm for scale-in (low CPU: <= 20%)
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "task4-cpu-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_period
  statistic           = "Average"
  threshold           = var.cpu_scale_in_threshold
  alarm_description   = "Alarm when average CPU utilization <= ${var.cpu_scale_in_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  tags = var.tags
}
