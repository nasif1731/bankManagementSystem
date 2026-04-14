output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_eip.main.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.main.private_ip
}

output "availability_zone" {
  description = "Availability Zone where instance is launched"
  value       = aws_instance.main.availability_zone
}

output "security_groups" {
  description = "Security groups attached to the instance"
  value       = aws_instance.main.vpc_security_group_ids
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.main.public_ip
}

output "elastic_ip_id" {
  description = "Elastic IP ID"
  value       = aws_eip.main.id
}
