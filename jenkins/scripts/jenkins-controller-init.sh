#!/bin/bash
# Jenkins Controller Initialization Script
# This script installs Jenkins, Java 17, Git, Docker, AWS CLI, and Terraform
# It runs as root via EC2 user_data

set -e

echo "=== Starting Jenkins Controller Setup ==="

# Update system packages
echo "Step 1: Updating system packages..."
yum update -y

 # Install Java 17 (required for Jenkins LTS compatible with this AMI)
echo "Step 2: Installing Java 17..."
yum install -y java-17-amazon-corretto-devel
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
echo "JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java.sh

# Install Git
echo "Step 3: Installing Git..."
yum install -y git

# Install Docker and Docker Daemon
echo "Step 4: Installing Docker..."
amazon-linux-extras install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install AWS CLI v2
echo "Step 5: Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install Terraform
echo "Step 6: Installing Terraform..."
TERRAFORM_VERSION="1.6.4"
wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
mv terraform /usr/local/bin/
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
terraform version

# Add Jenkins repository and install Jenkins LTS
echo "Step 7: Installing Jenkins LTS..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins (pinned to a Java 17-compatible LTS release)
yum install -y jenkins-2.541.3-1.noarch

# Start Jenkins service
echo "Step 8: Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start (it takes a moment to initialize)
echo "Step 9: Waiting for Jenkins to be ready..."
sleep 30

# Get initial admin password (printed to logs for debugging)
echo "=== Jenkins Initial Admin Password ==="
cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""

echo "=== Jenkins Controller Setup Complete ==="
echo "Jenkins is running on http://0.0.0.0:8080"
echo "Please complete the setup wizard through the Jenkins UI"
