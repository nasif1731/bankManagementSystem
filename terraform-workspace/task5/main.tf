# Task 5: Elastic Load Balancer with Health Checks
# Creates ALB, target groups, listeners, and attaches to Task 4 ASG

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
# Data Sources (Reference Task 4 Resources)
# ========================

# Get Task 4 VPC
data "aws_vpc" "task4" {
  cidr_block = "10.2.0.0/16"
}

# Get Task 4 public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.task4.id]
  }

  filter {
    name   = "cidr-block"
    values = ["10.2.1.0/24", "10.2.2.0/24"]
  }
}

# Get Task 4 ASG by finding ASGs in the Task 4 VPC
data "aws_autoscaling_groups" "task4" {
  filter {
    name   = "tag:Task"
    values = ["Task4-ASG-CloudWatch"]
  }
}

# Get Task 4 EC2 security group
data "aws_security_groups" "task4_web" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.task4.id]
  }

  filter {
    name   = "group-name"
    values = ["task4-web-sg-*"]
  }
}

# ========================
# Security Groups
# ========================

# ALB Security Group - Allow HTTP from internet
resource "aws_security_group" "alb" {
  name_prefix = "task5-alb-sg-"
  description = "Security group for ALB - allows HTTP from internet"
  vpc_id      = data.aws_vpc.task4.id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "task5-alb-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Update Task 4 EC2 Security Group - restrict HTTP to ALB only
resource "aws_security_group_rule" "task4_http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = data.aws_security_groups.task4_web.ids[0]
  description              = "HTTP from ALB only"
}

# ========================
# Application Load Balancer
# ========================

resource "aws_lb" "main" {
  name_prefix        = "task5-"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids

  enable_deletion_protection = var.alb_enable_deletion_protection
  enable_http2               = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name = "task5-alb"
    }
  )
}

# ========================
# Target Group
# ========================

resource "aws_lb_target_group" "main" {
  name_prefix = "task5-"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = data.aws_vpc.task4.id

  deregistration_delay = 30
  slow_start           = 0

  # Health Check Configuration
  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    port                = "traffic-port"
    protocol            = var.target_group_protocol
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = false
    cookie_duration = 86400
  }

  tags = merge(
    var.tags,
    {
      Name = "task5-target-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ========================
# ALB Listener
# ========================

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [aws_lb_target_group.main]
}

# ========================
# ASG Attachment to Target Group
# ========================

resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = data.aws_autoscaling_groups.task4.names[0]
  lb_target_group_arn    = aws_lb_target_group.main.arn
}

# ========================
# Update ASG Desired Capacity
# ========================

resource "null_resource" "scale_asg" {
  triggers = {
    asg_name = data.aws_autoscaling_groups.task4.names[0]
    desired  = var.asg_desired_capacity
  }

  provisioner "local-exec" {
    command = "aws autoscaling set-desired-capacity --auto-scaling-group-name ${data.aws_autoscaling_groups.task4.names[0]} --desired-capacity ${var.asg_desired_capacity} --region ${var.aws_region}"
  }

  depends_on = [aws_autoscaling_attachment.main]
}
