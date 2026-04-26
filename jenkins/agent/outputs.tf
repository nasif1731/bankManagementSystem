# Jenkins Build Agent - Terraform Outputs

output "jenkins_agent_instance_id" {
  description = "Instance ID of the Jenkins build agent"
  value       = aws_instance.jenkins_agent.id
}

output "jenkins_agent_private_ip" {
  description = "Private IP address of the Jenkins build agent"
  value       = aws_instance.jenkins_agent.private_ip
}

output "jenkins_agent_dns" {
  description = "Private DNS name of the Jenkins build agent"
  value       = aws_instance.jenkins_agent.private_dns
}

output "jenkins_agent_security_group_id" {
  description = "Security group ID of Jenkins build agent"
  value       = aws_security_group.jenkins_agent.id
}

output "jenkins_agent_iam_role_name" {
  description = "IAM role name for Jenkins build agent"
  value       = aws_iam_role.jenkins_agent.name
}

output "vpc_id" {
  description = "VPC ID where Jenkins agent is deployed"
  value       = data.aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID where Jenkins agent is deployed"
  value       = aws_instance.jenkins_agent.subnet_id
}

output "jenkins_agent_work_dir" {
  description = "Jenkins agent work directory"
  value       = "/home/jenkins/agent"
}

output "jenkins_agent_label" {
  description = "Label for the Jenkins agent in Jenkins UI"
  value       = var.agent_label
}

output "ssh_command_from_controller" {
  description = "SSH command to connect to agent from Jenkins controller"
  value       = "ssh -i <jenkins-controller-key> jenkins@${aws_instance.jenkins_agent.private_ip}"
}

output "jenkins_agent_role_arn" {
  description = "ARN of the Jenkins agent IAM role"
  value       = aws_iam_role.jenkins_agent.arn
}
