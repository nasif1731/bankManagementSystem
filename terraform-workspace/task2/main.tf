# Task 2: Security Groups and EC2 Instance Deployment
# Fully segregated from Task 1 - creates own VPC and infrastructure
# Main Terraform Configuration

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

# Create Custom VPC for Task 2
resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "task2-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "task2-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "task2-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "task2-private-subnet"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "task2-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "task2-nat"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "task2-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "task2-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Data source: Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# ========================
# Security Groups
# ========================

# Security Group for Web Server
resource "aws_security_group" "web_sg" {
  name_prefix = "task2-web-sg-"
  description = "Security group for public-facing web server - allows HTTP, HTTPS, SSH from my IP only"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from anywhere (for testing - normally restrict to your IP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Allow HTTPS from my IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "HTTPS from my IP"
  }

  # Allow SSH from my IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH from my IP only"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "task2-web-server-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Database Server
resource "aws_security_group" "db_sg" {
  name_prefix = "task2-db-sg-"
  description = "Security group for private database server - allows MySQL only from web server SG"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL (port 3306) from web server security group only
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    description     = "MySQL from web server SG only"
  }

  # Allow SSH from web server security group (for bastion pattern)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    description     = "SSH from web server (bastion)"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "task2-db-server-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================
# SSH Key Pair
# ========================

resource "aws_key_pair" "task2" {
  key_name_prefix = "task2-ec2-key-"
  public_key      = var.ssh_public_key

  tags = {
    Name = "task2-keypair"
  }
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
# EC2 Instances
# ========================

# Web Server in Public Subnet
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.task2.key_name

  associate_public_ip_address = true

  # User data script - simplified for reliability
  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

# Create custom HTML page
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
INSTANCE_TYPE=$(ec2-metadata --instance-type | cut -d " " -f 2)
PRIVATE_IP=$(ec2-metadata --local-ipv4 | cut -d " " -f 2)

cat > /usr/share/nginx/html/index.html <<ENDHTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Task 2 - Web Server</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background: white;
      padding: 50px;
      border-radius: 15px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      max-width: 600px;
      width: 90%;
    }
    h1 { color: #333; margin-bottom: 10px; font-size: 2.5em; }
    .subtitle { color: #667eea; margin-bottom: 30px; font-size: 1.1em; }
    .info-group { background: #f8f9ff; padding: 20px; border-radius: 10px; margin-bottom: 20px; border-left: 4px solid #667eea; }
    .info-item { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #e0e0ff; }
    .info-item:last-child { border-bottom: none; }
    .label { font-weight: 600; color: #667eea; min-width: 150px; }
    .value { color: #555; font-family: 'Courier New', monospace; word-break: break-all; }
    .status { display: inline-block; background: #4caf50; color: white; padding: 8px 16px; border-radius: 20px; margin-top: 20px; font-weight: 600; }
  </style>
</head>
<body>
  <div class="container">
    <h1>✓ Web Server Running</h1>
    <p class="subtitle">Task 2: Security Groups and EC2</p>
    <div class="info-group">
      <div class="info-item">
        <span class="label">Instance ID:</span>
        <span class="value">$INSTANCE_ID</span>
      </div>
      <div class="info-item">
        <span class="label">Instance Type:</span>
        <span class="value">$INSTANCE_TYPE</span>
      </div>
      <div class="info-item">
        <span class="label">Private IP:</span>
        <span class="value">$PRIVATE_IP</span>
      </div>
      <div class="info-item">
        <span class="label">Region:</span>
        <span class="value">us-east-1</span>
      </div>
      <div class="info-item">
        <span class="label">Server:</span>
        <span class="value">Nginx</span>
      </div>
    </div>
    <span class="status">✓ Server is online and accessible</span>
  </div>
</body>
</html>
ENDHTML

systemctl restart nginx
EOF
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "task2-web-server"
  }

  depends_on = [aws_security_group.web_sg, aws_internet_gateway.main]
}

# Database Server in Private Subnet
resource "aws_instance" "db_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = aws_key_pair.task2.key_name

  associate_public_ip_address = false

  # User data script to install MySQL client
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql
              EOF
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name = "task2-db-server"
  }

  depends_on = [aws_security_group.db_sg]
}

# ========================
# Elastic IP for Web Server
# ========================

resource "aws_eip" "web_server" {
  instance = aws_instance.web_server.id
  domain   = "vpc"

  tags = {
    Name = "task2-web-server-eip"
  }

  depends_on = [aws_instance.web_server, aws_internet_gateway.main]
}
