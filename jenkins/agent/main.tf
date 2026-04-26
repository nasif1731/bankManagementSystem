# Jenkins Build Agent - Main Terraform Configuration

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

# Fetch the VPC created in Assignment 3
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch a private subnet from the VPC
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["task1-vpc-private-subnet-1"]
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
# IAM Role for Build Agent EC2
# ========================

data "aws_iam_policy_document" "agent_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins_agent" {
  name               = "jenkins-build-agent-role"
  assume_role_policy = data.aws_iam_policy_document.agent_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "jenkins-build-agent-role"
    }
  )
}

# Attach policies for build agent
resource "aws_iam_role_policy_attachment" "agent_ec2_access" {
  role       = aws_iam_role.jenkins_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create instance profile
resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "jenkins-build-agent-profile"
  role = aws_iam_role.jenkins_agent.name
}

# ========================
# Security Groups
# ========================

# Security group for Jenkins Build Agent
resource "aws_security_group" "jenkins_agent" {
  name        = "jenkins-build-agent-sg"
  description = "Security group for Jenkins build agent"
  vpc_id      = data.aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "jenkins-build-agent-sg"
    }
  )
}

# Ingress: SSH from VPC (for Jenkins controller to connect)
resource "aws_security_group_rule" "agent_ssh_from_vpc" {
  type              = "ingress"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.jenkins_agent.id
  description       = "SSH access from VPC"
}

# Ingress: Jenkins JNLP agent protocol
resource "aws_security_group_rule" "agent_jnlp" {
  type              = "ingress"
  from_port         = 50000
  to_port           = 50000
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.jenkins_agent.id
  description       = "Jenkins JNLP agent communication"
}

# Egress: Allow all outbound traffic
resource "aws_security_group_rule" "agent_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_agent.id
  description       = "Allow all outbound traffic"
}

# ========================
# EC2 Instance - Jenkins Build Agent
# ========================

resource "aws_instance" "jenkins_agent" {
  # Use the first private subnet
  subnet_id              = data.aws_subnets.private.ids[0]
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.jenkins_agent.name
  vpc_security_group_ids = [aws_security_group.jenkins_agent.id]

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
  user_data = base64encode(file("${path.module}/../scripts/jenkins-agent-init.sh"))

  # Enable detailed monitoring
  monitoring = true

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )

  depends_on = [
    aws_security_group.jenkins_agent,
    aws_iam_instance_profile.jenkins_agent
  ]
}

# ========================
# CloudWatch Log Group
# ========================

resource "aws_cloudwatch_log_group" "agent_logs" {
  name              = "/aws/ec2/jenkins-build-agent"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "jenkins-build-agent-logs"
    }
  )
}
