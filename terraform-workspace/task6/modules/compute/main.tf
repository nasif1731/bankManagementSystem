# Compute Module - main.tf
# EC2 Instance resource

resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data != "" ? base64encode(var.user_data) : null

  # Enhanced monitoring
  monitoring = true

  # Root block device
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  # Metadata options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.instance_name}"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for the instance
resource "aws_eip" "main" {
  instance = aws_instance.main.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.instance_name}-eip"
    Environment = var.environment
  })

  depends_on = [aws_instance.main]
}
