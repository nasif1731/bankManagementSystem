# Jenkins Controller - Terraform Variables Values

aws_region = "us-east-1"

environment = "jenkins"

vpc_name = "task1-vpc"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidr = "10.0.1.0/24"

instance_name = "jenkins-controller"

instance_type = "t3.micro"

root_volume_size = 50

enable_eip = true

key_name = "nehal"

# IMPORTANT: Change this to your actual IP address in CIDR notation (x.x.x.x/32)
# This is REQUIRED for security - only your IP can access Jenkins
my_ip = "154.192.134.97/32"

jenkins_port = 8080

ssh_port = 22

tags = {
  Project     = "Jenkins-CI-CD"
  Owner       = "DevOps"
  Created_By  = "Terraform"
  Assignment  = "4"
  Environment = "jenkins"
}
