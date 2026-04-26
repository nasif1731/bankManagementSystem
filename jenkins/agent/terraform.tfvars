# Jenkins Build Agent - Terraform Variables Values

aws_region = "us-east-1"

environment = "jenkins"

vpc_name = "task1-vpc"

vpc_cidr = "10.0.0.0/16"

private_subnet_cidr = "10.0.3.0/24"

instance_name = "jenkins-build-agent"

instance_type = "t3.micro"

root_volume_size = 50

agent_label = "linux-agent"

# Ensure this matches the Jenkins controller's private IP
jenkins_controller_private_ip = "10.0.3.67"

ssh_port = 22

tags = {
  Project     = "Jenkins-CI-CD"
  Owner       = "DevOps"
  Created_By  = "Terraform"
  Assignment  = "4"
  Environment = "jenkins"
}
