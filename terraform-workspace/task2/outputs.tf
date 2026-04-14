# Task 2: Security Groups and EC2 Instance Deployment
# Output Definitions

output "vpc_id" {
  description = "ID of Task 2 VPC"
  value       = aws_vpc.main.id
}

output "web_server_instance_id" {
  description = "Instance ID of the web server"
  value       = aws_instance.web_server.id
}

output "web_server_private_ip" {
  description = "Private IP address of the web server"
  value       = aws_instance.web_server.private_ip
}

output "web_server_public_ip" {
  description = "Public IP address (Elastic IP) of the web server"
  value       = aws_eip.web_server.public_ip
}

output "web_server_nginx_url" {
  description = "URL to access the Nginx welcome page"
  value       = "http://${aws_eip.web_server.public_ip}"
}

output "db_server_instance_id" {
  description = "Instance ID of the database server"
  value       = aws_instance.db_server.id
}

output "db_server_private_ip" {
  description = "Private IP address of the database server (use from web server)"
  value       = aws_instance.db_server.private_ip
}

output "web_security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_sg.id
}

output "web_security_group_name" {
  description = "Name of the web server security group"
  value       = aws_security_group.web_sg.name
}

output "db_security_group_id" {
  description = "ID of the database server security group"
  value       = aws_security_group.db_sg.id
}

output "db_security_group_name" {
  description = "Name of the database server security group"
  value       = aws_security_group.db_sg.name
}

output "ssh_key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.task2.key_name
}

output "ssh_into_web_server" {
  description = "SSH command to connect to web server"
  value       = "ssh -i path/to/private/key ec2-user@${aws_eip.web_server.public_ip}"
}

output "ssh_from_web_to_db" {
  description = "SSH command from web server to database server (run this from web server SSH session)"
  value       = "ssh -i path/to/private/key ec2-user@${aws_instance.db_server.private_ip}"
}

output "public_subnet_id" {
  description = "ID of public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of private subnet"
  value       = aws_subnet.private.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of NAT Gateway (for private instance outbound traffic)"
  value       = aws_eip.nat.public_ip
}

output "summary" {
  description = "Summary of all created resources"
  value = {
    vpc = {
      id   = aws_vpc.main.id
      cidr = "10.1.0.0/16"
    }
    web_server = {
      instance_id = aws_instance.web_server.id
      instance_type = var.instance_type
      private_ip  = aws_instance.web_server.private_ip
      public_ip   = aws_eip.web_server.public_ip
      url         = "http://${aws_eip.web_server.public_ip}"
    }
    db_server = {
      instance_id = aws_instance.db_server.id
      instance_type = var.instance_type
      private_ip  = aws_instance.db_server.private_ip
      accessible_from = "web-server-sg only"
    }
    security_groups = {
      web_sg_id = aws_security_group.web_sg.id
      web_sg_name = aws_security_group.web_sg.name
      db_sg_id  = aws_security_group.db_sg.id
      db_sg_name = aws_security_group.db_sg.name
    }
    ssh_key = aws_key_pair.task2.key_name
  }
}
