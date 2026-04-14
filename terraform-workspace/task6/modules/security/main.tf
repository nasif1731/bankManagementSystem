# Security Module - main.tf
# Web and Database security groups

# Web Security Group
resource "aws_security_group" "web" {
  name_prefix = "${var.environment}-web-sg-"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Web SG - Allow HTTP from anywhere
resource "aws_security_group_rule" "web_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  description       = "HTTP from anywhere"
}

# Web SG - Allow HTTPS from anywhere
resource "aws_security_group_rule" "web_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  description       = "HTTPS from anywhere"
}

# Web SG - Allow SSH
resource "aws_security_group_rule" "web_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allow_ssh_from_cidr]
  security_group_id = aws_security_group.web.id
  description       = "SSH access"
}

# Web SG - Allow all outbound
resource "aws_security_group_rule" "web_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${var.environment}-db-sg-"
  description = "Security group for databases"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database SG - Allow connection from web servers (MySQL/Aurora)
resource "aws_security_group_rule" "db_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.database.id
  description              = "MySQL from web servers"
}

# Database SG - Allow PostgreSQL from web servers
resource "aws_security_group_rule" "db_postgres_from_web" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.database.id
  description              = "PostgreSQL from web servers"
}

# Database SG - Allow all outbound
resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database.id
  description       = "All outbound traffic"
}
