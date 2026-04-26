# Jenkins Controller - Terraform Outputs

output "jenkins_controller_instance_id" {
  description = "Instance ID of the Jenkins controller"
  value       = aws_instance.jenkins_controller.id
}

output "jenkins_controller_private_ip" {
  description = "Private IP address of the Jenkins controller"
  value       = aws_instance.jenkins_controller.private_ip
}

output "jenkins_controller_public_ip" {
  description = "Public IP address of the Jenkins controller (if enabled)"
  value       = aws_instance.jenkins_controller.public_ip
}

output "jenkins_controller_eip" {
  description = "Elastic IP of the Jenkins controller (if enabled)"
  value       = var.enable_eip ? aws_eip.jenkins_controller[0].public_ip : "Not assigned"
}

output "jenkins_controller_dns" {
  description = "Public DNS name of the Jenkins controller"
  value       = aws_instance.jenkins_controller.public_dns
}

output "jenkins_url" {
  description = "URL to access Jenkins controller"
  value       = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}

output "jenkins_security_group_id" {
  description = "Security group ID of Jenkins controller"
  value       = aws_security_group.jenkins_controller.id
}

output "jenkins_iam_role_name" {
  description = "IAM role name for Jenkins controller"
  value       = aws_iam_role.jenkins_controller.name
}

output "vpc_id" {
  description = "VPC ID where Jenkins is deployed"
  value       = data.aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID where Jenkins controller is deployed"
  value       = aws_instance.jenkins_controller.subnet_id
}

output "ssh_command" {
  description = "SSH command to connect to Jenkins controller"
  value       = "ssh -i <your-key> ec2-user@${aws_instance.jenkins_controller.public_ip}"
}

output "jenkins_controller_role_arn" {
  description = "ARN of the Jenkins controller IAM role"
  value       = aws_iam_role.jenkins_controller.arn
}
