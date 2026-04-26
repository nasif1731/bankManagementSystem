# Jenkins Controller - Main Terraform Configuration

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
# Data Sources
# ========================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get all availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Fetch the VPC created in Assignment 3 (task1-vpc)
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch the first public subnet from the VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["task1-vpc-public-subnet-1"]
  }
}

# Get latest Amazon Linux 2 AMI
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
# IAM Role for Jenkins EC2
# ========================

# Assume role policy document
data "aws_iam_policy_document" "jenkins_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create IAM role for EC2
resource "aws_iam_role" "jenkins_controller" {
  name               = "jenkins-controller-role"
  assume_role_policy = data.aws_iam_policy_document.jenkins_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "jenkins-controller-role"
    }
  )
}

# Attach policies to allow Terraform, Docker, ECR, and other AWS services
resource "aws_iam_role_policy_attachment" "jenkins_ec2_full_access" {
  role       = aws_iam_role.jenkins_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create instance profile
resource "aws_iam_instance_profile" "jenkins_controller" {
  name = "jenkins-controller-profile"
  role = aws_iam_role.jenkins_controller.name
}

# ========================
# Security Groups
# ========================

# Security group for Jenkins Controller
resource "aws_security_group" "jenkins_controller" {
  name        = "jenkins-controller-sg"
  description = "Security group for Jenkins controller"
  vpc_id      = data.aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "jenkins-controller-sg"
    }
  )
}

# Ingress: SSH from user IP only
resource "aws_security_group_rule" "jenkins_ssh" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.jenkins_controller.id
  description       = "SSH access from user IP"
}

# Ingress: Jenkins UI from user IP only
resource "aws_security_group_rule" "jenkins_ui" {
  type              = "ingress"
  from_port         = var.jenkins_port
  to_port           = var.jenkins_port
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.jenkins_controller.id
  description       = "Jenkins UI access from user IP"
}

# Ingress: Jenkins agent communication from VPC
resource "aws_security_group_rule" "jenkins_agent_communication" {
  type              = "ingress"
  from_port         = 50000
  to_port           = 50000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.jenkins_controller.id
  description       = "Jenkins agent communication"
}

# Egress: Allow all outbound traffic
resource "aws_security_group_rule" "jenkins_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_controller.id
  description       = "Allow all outbound traffic"
}

# ========================
# EC2 Instance - Jenkins Controller
# ========================

resource "aws_instance" "jenkins_controller" {
  # Use the first public subnet
  subnet_id              = data.aws_subnets.public.ids[0]
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_controller.name
  vpc_security_group_ids = [aws_security_group.jenkins_controller.id]

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(
      var.tags,
      {
        Name = "${var.instance_name}-volume"
      }
    )
  }

  # User data script
  user_data = base64encode(file("${path.module}/../scripts/jenkins-controller-init-v2.sh"))

  # Enable detailed monitoring
  monitoring = true

  # Public IP assignment
  associate_public_ip_address = true

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  depends_on = [
    aws_security_group.jenkins_controller,
    aws_iam_instance_profile.jenkins_controller
  ]
}

# ========================
# Elastic IP (Optional)
# ========================

resource "aws_eip" "jenkins_controller" {
  count    = var.enable_eip ? 1 : 0
  instance = aws_instance.jenkins_controller.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.instance_name}-eip"
    }
  )

  depends_on = [aws_instance.jenkins_controller]
}

# ========================
# CloudWatch Log Group (Optional)
# ========================

resource "aws_cloudwatch_log_group" "jenkins_logs" {
  name              = "/aws/ec2/jenkins-controller"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "jenkins-controller-logs"
    }
  )
}
